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
	console.log('hit quickInitCheck with ', dhxObject)
	redis.client.hgetAsync('users', `${dhxObject.username}`)
	.then((userID)=>{
		redis.client.hgetAsync('users', `${dhxObject.friendname}`)
		.then((friendID)=>{
			redis.client.hgetallAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`)
			.then((dhDataStructure)=>{
				if (dhDataStructure) {
					console.log('resume from middle')
					clientSocket.emit('redis response client has ongoing exchange', dhxObject);						
				} else {
					console.log('init')
					clientSocket.emit('redis response client must init', dhxObject);
				}
			})
		})
	})
	.catch(err => console.log('Error in quickInitCheck', err))
}

//initiates mutual hash with Alice_info. Informs Bob. Places Alice in Bob's pending (to trigger response/ enable lookup of mutual hash)
function initKeyExchange (dhxObject, clientSocket){
    console.log('in initKeyExchange', dhxObject);
    redis.client.hmset(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, ['pAlice', `${dhxObject.p}`, 'gAlice', `${dhxObject.g}`, 'eAlice', `${dhxObject.E}`, 'chatEstablished', '0'], function(err){if (err) {console.log(err)} });
    redis.client.sadd(`pending:${dhxObject.friendID}`, `${dhxObject.userID}`);
    clientSocket.emit("redis response KeyExchange initiated", dhxObject);	
};

//starts at stage 0. sends Alice_info to Bob_client.
        //client side: BOB: gen secret, make E, compute secret, store appropriately.
function performPart2AKeyExchange(dhxObject, clientSocket){
	console.log('pt2A dhxObj', dhxObject) //
	redis.client.hgetallAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`)
	.then(dhxObjFromStage1 =>{
		console.log(dhxObjFromStage1);
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
    .then(()=>{
    	redis.client.saddAsync(`pending:${dhxObject.friendID}`, `${dhxObject.userID}`)
    	.then(()=> {
	    	redis.client.sremAsync(`pending:${dhxObject.userID}`, `${dhxObject.friendID}`)
	    	.then(()=>{
	    		//clientSocket.emit("redis response KeyExchange complete", dhxObject);
		    	clientSocket.emit("redis response Bob complete, Alice still pending", dhxObject);
		    	//tell Alice to retrieve. 
		    	//tell Bob to instantiate his chat.	    		
	    	})
    	})
    })
    .catch(err => console.log('Error in dhxPt2B', err));
};

//Inne the whiche: Alice retreives <Bob_E>, instantiates realm chat, deletes now-irrelevant DHX_redis_stores
function performPart3KeyExchange(dhxObject, clientSocket) {
	dhxObject = updateInfoWithSortedIds(dhxObject, dhxObject.userID, dhxObject.friendID);
    console.log('Pt3 dhx obj', dhxObject);

    redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'bobE')
    .then((bobE)=>{
    	dhxObject["bobE"] = bobE;

    	redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'pAlice')
    	.then((pAlice)=>{
	    	dhxObject["pAlice"] = pAlice;
	    	clientSocket.emit("redis response bobE retreived", dhxObject);
	    	//>>>>>on client, make secret & store it.
	    	//>>>>>tell realm that it can instantiate chat object.
	    	redis.client.sremAsync(`pending:${dhxObject.userID}`, `${dhxObject.friendID}`)
	    	.then(()=>{
	    		redis.client.delAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`)
		    	.then(()=>{
		    		clientSocket.emit("redis response KeyExchange complete", dhxObject);
		    	})
	    	})
    	})
    })
    .catch(err => console.log('Error in dhxPt3', err));
};


//checks redis for pending dhXs upon each login and friendAdd. Routes thru steps accordingly || informs user 'no pending requests' 
function routeKeyExchange (dhxObject, clientSocket){

  redis.client.hgetAsync('users', `${dhxObject.username}`)
  .then(sourceUserID => {
  	  //console.log(dhxObject, sourceUserID, 'xxxxx')
    	//determine whether pending requests are waiting for the user
    	redis.client.smembersAsync(`pending:${sourceUserID}`)
    	.then(anyPendingRequests => {
    		console.log('pending request(s): ', anyPendingRequests);
    		if (anyPendingRequests.length > 0) {

		        anyPendingRequests.forEach(function(pendingID){
			        //sort & store the IDs of each pending relationship
				    dhxObject = updateInfoWithSortedIds(dhxObject, sourceUserID, pendingID);

		           //determine Key Exchange stage (nil/0/1)
			        redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'chatEstablished')
			        .then ((chatEstablishedVal) => {
			        	console.log('chatEstablishedVal:' + chatEstablishedVal + 'to pending id' + pendingID)

			        	///
			        	//Need a way to enter at this exact point
			        	///

			            if (chatEstablishedVal === '0'){
				            performPart2AKeyExchange(dhxObject, clientSocket);
			            } else if (chatEstablishedVal === '1') {
			            	performPart3KeyExchange(dhxObject, clientSocket);
			            } 
			        })	
		        });
    		} else {
    		  //EITHER:
    		  if (dhxObject.friendname){
		    	  //func triggered by 'add friend' 
    		  	redis.client.hgetAsync('users', `${dhxObject.friendname}`)
    		  	.then(friendID=>{
    		  		var dhxObjectMod = updateInfoWithSortedIds(dhxObject, sourceUserID, friendID);
	                initKeyExchange(dhxObjectMod, clientSocket);
	                clientSocket.emit("initiating keyExchange");
    		  	})
	          } else {
		          //routine query with no results 
	    		  clientSocket.emit("redis response no need to undertake KeyExchange")
	    	  }
    		}
    	})
    })
  .catch(err => console.log('Error in routeKeyExchange function', err));
};


module.exports = {
	quickInitCheck,
    initKeyExchange,
    routeKeyExchange,
    performPart2BKeyExchange
};