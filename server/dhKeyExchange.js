const redis = require('./redis.js');

//updates object passed during Diffie Hellman exchaange with descriptive IDs
function updateInfoWithIds (dhxObject, sourceUserId, pendingID){
    dhxObject.greaterUserID = sourceUserId >= pendingID ? sourceUserId : pendingID;
    dhxObject.lesserUserID = sourceUserId < pendingID ? sourceUserId : pendingID;
    dhxObject.userID = sourceUserId;
    dhxObject.friendID = pendingID;
    return dhxObject;
};

//initiates redis data structures & vals : mutual dh exchange hash; alicePendingList; bobPendingList
function initKeyExchange (dhxObject, clientSocket){
  console.log('in initKeyExchange')
  redis.client.hmset(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, ['pAlice', `${dhxObject.p}`, 'gAlice', `${dhxObject.g}`, 'eAlice', `${dhxObject.E}`, 'chatEstablished', '0'], function(err, res){if (err) {console.log(err)}});
  //add Alice userId in Bob's object
  redis.client.sadd(`pending:${dhxObject.friendID}`, `${dhxObject.userID}`);
  clientSocket.emit("redis response KeyExchange initiated", dhxObject);
};



//EITHER initiates keyExchange between sourceClient and friendClient(s) or informs Alice_client no need.
function undertakeKeyExchange (dhxObject, clientSocket){

  redis.client.hgetAsync('users', `${dhxObject.username}`)
  .then(sourceUserId => {
  	  //console.log(dhxObject, sourceUserId, 'xxxxx')
    	//determine whether pending requests are waiting for the user
    	redis.client.smembersAsync(`pending:${sourceUserId}`)
    	.then(anyPendingRequests => {
    		console.log('pending request(s): ', anyPendingRequests);
    		if (anyPendingRequests.length > 0) {
		        anyPendingRequests.forEach(function(pendingID){

			        //sort & store the IDs of each pending relationship
				    dhxObject = updateInfoWithIds(dhxObject, sourceUserId, pendingID);


		           //then determine the stage of the Diffie Hellman Key Exchange (nil/0/1/2)
			        redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'chatEstablished')
			        .then ((chatEstablishedVal) => {

			            if(chatEstablishedVal === '2') {

			              console.log('2 confirmed')
			              //action MUST be needed (only 1 person has pending status)
			              //remove self from other's pending list
			              //remove dh:lesser:greater object completely
			              //inform user so they can instantiate chat.
			              clientSocket.emit("redis response KeyExchange complete", dhxObject);

			            } else if (chatEstablishedVal === '0'){
			            	//action MUST be needed (only 1 person has pending status at this level)

			            	performPart2AKeyExchange(dhxObject, clientSocket);

			            } else if (chatEstablishedVal === '1') {

			            	console.log('1 confirmed')
			            	//action MAY be needed (I could be either user)
			            	//if I've never seen Bob'sE, I'm Alice and I need to act.
			            	//if I have Bob's E already, I'm Bob, and I can do nothing.
			            } 
			        })	
		        });

    		} else {
    		//no pending requests exist, but also no chat exists (with your requested friend)> init key exchange.
    		  if (dhxObject.friendname){
    		  	redis.client.hgetAsync('users', `${dhxObject.username}`)
    		  	.then(friendID=>{
    		  		var dhxObjectMod = updateInfoWithIds(dhxObject, sourceUserId, friendID);
	                initKeyExchange(dhxObjectMod, clientSocket);
	                clientSocket.emit("initiating keyExchange");
    		  	})
	          }
	          //this is a routine query with no results && there is no friend-in-mind
    		  clientSocket.emit("No pending KeyExchanges")
    		}
    	})
    })
  .catch(err => console.log('Error in undertakeKeyExchange function', err));
};

function performPart2AKeyExchange(dhxObject, clientSocket){
	console.log('into performPart2AKeyExchange function', dhxObject)
	//get info && send it to the client. 
	redis.client.hgetallAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`)
	.then(dhxObjFromStage1 =>{
		dhxObjFromStage1['userId'] = dhxObject.userID;
		dhxObjFromStage1['friendId'] = dhxObject.friendID;
		clientSocket.emit('Retreived dhxInfo from redis', dhxObjFromStage1);
        //client side: gen secret, make E, compute secret, store. this will prbz need 2 users to test? 
	})
	.catch(err => {if (err){console.log(err)}});

};

function performPt2BKeyExchange(){
            	//>>> upon another call to server: 
            	//put up E, toggle 0 -> 1. 
            	    //(keep self on friends' list)//
};

// 	    		  if (chatEstablishedVal === 1) {
// 	    			//either you set it or the other person did.
// 	    			redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'eBob')
// 	    				.then(eAliceHasVal => {
// 	    				if () {
// 	    					//you set it
// 	    				  clientSocket.emit("waiting for friend response");	
// 	    				} else {
// 	    					//the other person set it.
// 	    					// -retreive Alice base, E, 
// 	    					// -send it to the client side
// 	    					//     --on client side: make own secret, make own E
// 	    					//     --then, back to REDIS with Bob E
// 	    					// -delete pending statuses.
// 	    				}
// 	    			}).catch(err=>'Error in undertakeKeyExchange function', err)
// 	    		} else if (chatEstablishedVal === 2) {
// 	    			//emit socketmssg to instantiate chat
// 	    			    //what if this fails? 
// 	    			//delete friendUserID from pending
// 	    			//destory entire dh:1:2 obj
// 	    		}


module.exports = {
  undertakeKeyExchange,
  initKeyExchange,
  performPt2BKeyExchange
};