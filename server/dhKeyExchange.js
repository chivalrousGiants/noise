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
  console.log('in initKeyExchange', dhxObject)
  redis.client.hmset(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, ['pAlice', `${dhxObject.p}`, 'gAlice', `${dhxObject.g}`, 'eAlice', `${dhxObject.E}`, 'chatEstablished', '0'], function(err, res){if (err) {console.log(err)}});
  //add Alice userId in Bob's object
  redis.client.sadd(`pending:${dhxObject.friendID}`, `${dhxObject.userID}`);
  clientSocket.emit("redis response KeyExchange initiated", dhxObject);
};



//EITHER initiates keyExchange between sourceClient and friendClient(s) or informs Alice_client no need.
function undertakeKeyExchange (dhxObject, clientSocket){

  redis.client.hgetAsync('users', `${dhxObject.username}`)
  .then(sourceUserId => {
  	  console.log(dhxObject, sourceUserId, 'xxxxx')
    	//determine whether pending requests are waiting for the user
    	redis.client.smembersAsync(`pending:${sourceUserId}`)
    	.then(anyPendingRequests => {
    		console.log('pending requests is ', anyPendingRequests);
    		if (anyPendingRequests.length > 0) {
		        anyPendingRequests.forEach(function(pendingID){

			        //first, sort & store the IDs of each pending relationship
				    dhxObject = updateInfoWithIds(dhxObject, sourceUserId, pendingID);


		           //then determine the stage of the Diffie Hellman Key Exchange (nil/0/1/2)
			        redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'chatEstablished')
			        .then ((chatEstablishedVal) => {
			        	console.log('chatEstablishedVal is ', chatEstablishedVal);
			            if(chatEstablishedVal === 2) {
			              //action MUST be needed (only 1 person has pending status)
			              //remove self from other's pending list
			              //remove dh:lesser:greater object completely
			              //inform user so they can instantiate chat.
			              clientSocket.emit("redis response KeyExchange complete", dhxObject);
			            } else if (chatEstablishedVal === 0){
			            	//action MUST be needed (only 1 person has pending status)
			            	//perform pt 2 of key exchange:
			            	commenceKeyExchange(dhxObject, clientSocket);
			            } else if (chatEstablishedVal === 1) {
			            	console.log('1 confirmed')
			            	//action MAY be needed (I could be either user)
			            	//if I've never seen Bob'sE, I'm Alice and I need to act.
			            	//if I have Bob's E already, I'm Bob, and I can do nothing.
			            } 
			        })	
		        });

    		} else {
    		//no pending requests exist, but also no chat exists (with your requested friend).
    		//>>>> initialize the key exchange.
    		  if (dhxObject.friendname){
    		  	redis.client.hgetAsync('users', `${dhxObject.username}`)
    		  	.then(friendID=>{
    		  		var dhxObjectMod = updateInfoWithIds(dhxObject, sourceUserId, friendID);
    		  		console.log('dhxObjectMod izzzz', dhxObjectMod);
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

function commenceKeyExchange (dhxObject, clientSocket){
	console.log(' in commence key exchange function!!')


	            //get info... 
            	//    ... go down to client
            	//        gen secret, make E, compute secret, store

            	//>>> make another call to server: 
            	//put up E, toggle 0 -> 1. 
            	    //(keep self on friends' list)//


// 	redis.client.smembersAsync(`pending:${dhxObject.userID}`)
// 	.then(list => {
// 		if (list || list.length)
// 		console.log(list)
// 	    Array.prototype.forEach.call(list, function (val, key, list){
// 	    	redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'chatEstablished')
// 	    	.then(chatEstablishedVal=>{
// 	    		if (chatEstablishedVal === 0){
// 	    			//either you set it to one or the other person did **NEED TO KNOW YOUR OWN E VAL
// 	    			//check to see if YOU HAVE AN is a eAlice
// 	    			redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'eAlice')
// 	    			.then(eAliceHasVal => {
// 	    				if (eAliceHasVal) {
// 	    				  clientSocket.emit("waiting for friend response");	
// 	    				}
// 	    			}).catch(err=>'Error in undertakeKeyExchange function', err)
// 	    		} else if (chatEstablishedVal === 1) {
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
// 	    	})
// 	    });
// 	});

};

module.exports = {
  undertakeKeyExchange,
  initKeyExchange,
  commenceKeyExchange
};