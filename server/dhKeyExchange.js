const redis = require('./redis.js');

//initiates redis data structures & vals : mutual dh exchange hash; alicePendingList; bobPendingList
function initKeyExchange (dhxObject, clientSocket){
  console.log('in initKeyExchange')
  redis.client.hmset(`dh:${dhxObject.lesserUserID}:${dhxObject.greaterUserID}`, ['pAlice', `${dhxObject.p}`, 'gAlice', `${dhxObject.g}`, 'eAlice', `${dhxObject.E}`, 'chatEstablished', '0'], function(err, res){console.log(err)});
  redis.client.sadd(`pendingChats:${dhxObject.lesserUserID}`, `${dhxObject.greaterUserID}`);
  redis.client.sadd(`pendingChats:${dhxObject.greaterUserID}`, `${dhxObject.lesserUserID}`);
  clientSocket.emit("redis response KeyExchange initiated", dhxObject);
};

//EITHER initiates keyExchange between two clients or informs Alice_client no need.
function undertakeKeyExchange (dhxObject, clientSocket){
	console.log('Diffie Hellman obj in undertakeKeyExchange', dhxObject)
  redis.client.hgetAsync('users', `${dhxObject.username}`)
  .then(ID_Alice => {
    redis.client.hgetAsync('users', `${dhxObject.friendname}`)
    .then(ID_Bob => {
        dhxObject.greaterUserID = ID_Alice >= ID_Bob ? ID_Alice : ID_Bob;
        dhxObject.lesserUserID = ID_Alice < ID_Bob ? ID_Alice : ID_Bob;
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
	console.log(' in commence key exchange function!!')
};

module.exports = {
  undertakeKeyExchange,
  initKeyExchange,
  commenceKeyExchange
};