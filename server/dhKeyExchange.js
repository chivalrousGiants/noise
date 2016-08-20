const redis = require('./redis.js');

//initiates redis data structures & vals : mutual dh exchange hash; alicePendingList; bobPendingList
function initKeyExchange (dhxObject, clientSocket){
  console.log('in initKeyExchange', dhxObject)
  redis.client.hmset(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, ['pAlice', `${dhxObject.p}`, 'gAlice', `${dhxObject.g}`, 'eAlice', `${dhxObject.E}`, 'chatEstablished', '0'], function(err, res){console.log(err)});
  //add whichever of these places Alice userId in Bob's object && only that one
  if (dhxObject.lesserUserID === dhxObject.aliceID){
	  redis.client.sadd(`pendingChats:${dhxObject.greaterUserID}`, `${dhxObject.lesserUserID}`);
  } else {
	  redis.client.sadd(`pendingChats:${dhxObject.lesserUserID}`, `${dhxObject.greaterUserID}`);
  }
  clientSocket.emit("redis response KeyExchange initiated", dhxObject);
};

//EITHER initiates keyExchange between two clients or informs Alice_client no need.
function undertakeKeyExchange (dhxObject, clientSocket){
  redis.client.hgetAsync('users', `${dhxObject.username}`)
  .then(ID_Alice => {
    redis.client.hgetAsync('users', `${dhxObject.friendname}`)
    .then(ID_Bob => {
        dhxObject.greaterUserID = ID_Alice >= ID_Bob ? ID_Alice : ID_Bob;
        dhxObject.lesserUserID = ID_Alice < ID_Bob ? ID_Alice : ID_Bob;
        dhxObject.aliceID = ID_Alice;
        dhxObject.bobID = ID_Bob;
        return dhxObject;
    })
    .then(dhxObject => {
        //determine whether keyX has already begun &/ is complete:
        redis.client.hgetAsync(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, 'chatEstablished')
        .then ((chatEstablishedVal) => {
            if(chatEstablishedVal === 2) {
            	//can now delete now-unnecessary data structures
              clientSocket.emit("redis response KeyExchange complete", dhxObject);
            } else if (chatEstablishedVal === 1){
            	//perform pt 2 key exchange
            } else {
            	//perform pt 1 key exchange
              initKeyExchange(dhxObject, clientSocket);
                //emit 'still waiting?'
            } 
        })
    })
  })
  .catch(err => console.log('Error in undertakeKeyExchange function', err));
};

function commenceKeyExchange (dhxObject, clientSocket){
// 	console.log(' in commence key exchange function!!')
// 	redis.client.smembersAsync(`pendingChats:${dhxObject.userID}`)
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