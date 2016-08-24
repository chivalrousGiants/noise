const redis = require('./redis.js');

//compares userIDs and appends sorted IDs onto the dhxObject --for generating consistent redis keys amongst users--
function updateInfoWithSortedIds (dhxObject, sourceUserID, pendingID){
    dhxObject.greaterUserID = sourceUserID >= pendingID ? sourceUserID : pendingID;
    dhxObject.lesserUserID = sourceUserID < pendingID ? sourceUserID : pendingID;
    dhxObject.userID = sourceUserID;
    dhxObject.friendID = pendingID;
    //console.log(dhxObject , 'FROM INSIDE THE SORT IDS FUNC')
    return dhxObject;
};

//gets IDs from usernames, then checks if dh:user1ID:user2ID already exists. Used client-side to vet keychain generation.
function quickInitCheck (dhxObject, clientSocket){
	var dhxObjectAugmented = updateInfoWithSortedIds(dhxObject, dhxObject.userID, dhxObject.friendID);
	console.log('hit quickInitCheck with ', dhxObjectAugmented)

	redis.client.hgetallAsync(`dh:${dhxObjectAugmented.lesserUserID}:${dhxObjectAugmented.greaterUserID}`)
	.then((dhDataStructure)=>{
		if (dhDataStructure) {
			console.log('resume from middle', dhDataStructure)
      // Use SISMEMBER to check pending table in addition to cE
      // if (dhDataStructure.chatEstablished === 1) {
      //   // need to check pending table
      //   performPart3KeyExchange(dhxObject, clientSocket);
      // }
			clientSocket.emit('redis response client has ongoing exchange', dhxObjectAugmented);						
		} else {
			console.log('init', dhDataStructure)
			clientSocket.emit('redis response client must init', dhxObjectAugmented);
		}
	})
	.catch(err => console.log('Error in quickInitCheck', err))
}

//initiates mutual hash with Alice_info. Informs Bob. Places Alice in Bob's pending (to trigger response/ enable lookup of mutual hash)
function initKeyExchange (dhxObject, clientSocket){
    console.log('in initKeyExchange', dhxObject);
    dhxObject = updateInfoWithSortedIds(dhxObject, dhxObject.userID, dhxObject.friendID);
    redis.client.hmset(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, ['pAlice', `${dhxObject.p}`, 'gAlice', `${dhxObject.g}`, 'eAlice', `${dhxObject.E}`, 'chatEstablished', '0'], function(err){if (err) {console.log(err)} });
    redis.client.sadd(`pending:${dhxObject.friendID}`, `${dhxObject.userID}`);
    clientSocket.emit("redis response KeyExchange initiated", dhxObject);	
};

//chatEstablished is 0. sends Alice_info from redis to Bob_client.
//client side: BOB: gen secret b, make E, compute shared-secret S, store appropriately.
function performPart2AKeyExchange(dhxObject, clientSocket){
	console.log('pt2A dhxObj', dhxObject)
	redis.client.hgetallAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`)
  	.then(dhxObjFromStage1 =>{
  		console.log('dhxObj from stage1', dhxObjFromStage1);
  		dhxObjFromStage1['userID'] = dhxObject.userID;
  		dhxObjFromStage1['friendID'] = dhxObject.friendID;
  		clientSocket.emit('redis response retreived intermediary dhxInfo', dhxObjFromStage1);
  	})
  	.catch(err => console.log('Error in dhxPt2A', err));
};

//Bob shares his E, toggles 0>1 for Alice to hit retrieval process, unsubscribes from pending, adds self to Alice's pending notificaitons
//client side: Bob initiates his chat.
function performPart2BKeyExchange(dhxObject, clientSocket){
  dhxObject = updateInfoWithSortedIds(dhxObject, dhxObject.userID, dhxObject.friendID);
  console.log('pt2B dhxObj', dhxObject);

  redis.client.hmsetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'bobE', `${dhxObject.E}`, 'chatEstablished', '1')
    .then(() => {
    	return redis.client.saddAsync(`pending:${dhxObject.friendID}`, `${dhxObject.userID}`);
    })
  	.then(() => {
    	return redis.client.sremAsync(`pending:${dhxObject.userID}`, `${dhxObject.friendID}`);
    })
  	.then(() => {
    	clientSocket.emit("redis response Bob complete, Alice still pending", dhxObject);
    	// TODO (socket emission): tell Alice to retrieve. 	    		
  	})
    .catch(err => console.log('Error in dhxPt2B', err));
};

//Inne the whiche: Alice retreives <Bob_E>, instantiates realm chat, deletes now-irrelevant DHX_redis_stores
function performPart3KeyExchange(dhxObject, clientSocket) {
	dhxObject = updateInfoWithSortedIds(dhxObject, dhxObject.userID, dhxObject.friendID);
    console.log('Pt3 dhx obj', dhxObject);

    redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'bobE')
    .then((bobE) => {
    	dhxObject["bobE"] = bobE;

    	return redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'pAlice');
    })
  	.then((pAlice) => {
    	dhxObject["pAlice"] = pAlice;
    	// clientSocket.emit("redis response bobE retreived", dhxObject);
    	//>>>>>on client, make secret & store it.
    	//>>>>>tell realm that it can instantiate chat object.
    	return redis.client.sremAsync(`pending:${dhxObject.userID}`, `${dhxObject.friendID}`);
    })
  	.then(()=>{
  		return redis.client.delAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`);
    })
  	.then(()=>{
  		clientSocket.emit("redis response KeyExchange complete", dhxObject);
  	})
    .catch(err => console.log('Error in dhxPt3', err));
};


//checks redis for pending dhXs upon each login and friendAdd. Routes thru steps accordingly || informs user 'no pending requests' 
function routeKeyExchange (dhxObject, clientSocket){
	redis.client.smembersAsync(`pending:${dhxObject.userID}`)
  	.then(anyPendingRequests => {
  		console.log('pending request(s): ', anyPendingRequests);
      anyPendingRequests.forEach((pendingID) => {
        //sort & store the IDs of each pending relationship
	      dhxObject = updateInfoWithSortedIds(dhxObject, dhxObject.userID, pendingID);
        
        //determine Key Exchange stage (nil/0/1)
        redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'chatEstablished');
          .then ((chatEstablishedVal) => {
	        	console.log('chatEstablishedVal:' + chatEstablishedVal + 'to pending id' + pendingID)
            if (chatEstablishedVal === '0') {
	            performPart2AKeyExchange(dhxObject, clientSocket);
            } else if (chatEstablishedVal === '1') {
            	performPart3KeyExchange(dhxObject, clientSocket);
            } 
	        })
          .catch(console.error.bind(console));
      }); 
  	})
    .catch(err => console.log('Error in routeKeyExchange function', err));
};


module.exports = {
	quickInitCheck,
    initKeyExchange,
    routeKeyExchange,
    performPart2BKeyExchange
};