const redis = require('./redis.js');

//initiates redis data structures & vals : mutual dh exchange hash; alicePendingList; bobPendingList
function initKeyExchange (dhxObject, clientSocket){
  console.log('in initKeyExchange')
  redis.client.hmset(`dh:${dhxObject.lesserUserId}:${dhxObject.greaterUserId}`, ['pAlice', `${dhxObject.p}`, 'gAlice', `${dhxObject.g}`, 'eAlice', `${dhxObject.E}`, 'chatEstablished', '0'], function(err, res){console.log(err)});
  redis.client.sadd(`pendingChats:${dhxObject.lesserUserId}`, `${dhxObject.greaterUserId}`);
  redis.client.sadd(`pendingChats:${dhxObject.greaterUserId}`, `${dhxObject.lesserUserId}`);
  clientSocket.emit("redis response KeyExchange initiated", dhxObject);
};

//EITHER initiates keyExchange between two clients or informs Alice_client no need.
function undertakeKeyExchange (dhxObject, clientSocket){
	console.log('Diffie Hellman obj in undertakeKeyExchange', dhxObject)
  redis.client.hgetAsync('users', `${dhxObject.username}`)
  .then(idAlice => {
    redis.client.hgetAsync('users', `${dhxObject.friendname}`)
    .then(idBob => {
        dhxObject.greaterUserId = idAlice >= idBob ? idAlice : idBob;
        dhxObject.lesserUserId = idAlice < idBob ? idAlice : idBob;
        return dhxObject;
    })
    .then(dhxObject => {
        //determine whether keyX has already begun &/ is complete:
        redis.client.hgetAsync(`dh:${dhxObject.lesserUserId}:${dhxObject.greaterUserId}`, 'chatEstablished')
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