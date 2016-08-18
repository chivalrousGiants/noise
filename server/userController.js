const redis = require('./redis.js');

////////////////////////////////////
//////// REDIS-USER FUNCTIONS
////////////////////////////////////

function signIn(user, clientSocket) {
  redis.client.hgetAsync('users', user.username)
    .then(userId => {
      console.log('signIn userId is', userId);
      // NULL is returned for non-existent key
      if (userId === null) {
        // Username does not exist
        return null;
      } else {
        return redis.client.hgetallAsync(`user:${userId}`);
      }
    })
    .then(foundUser => {
      // TODO: abstract out comparePassword in utils.js
      if (foundUser !== null && foundUser.password === user.password) {
        console.log('signin password match successful');
        // Successful login
        clientSocket.emit('redis response for signin', {
          user: foundUser,
          clientSocketId: clientSocket.id
        });
      } else {
        // Username does not exist or password is incorrect
        clientSocket.emit('redis response for signin', null);
      }
    }).catch(console.error.bind(console));
}

function signUp (user, clientSocket) {
  redis.client.hgetAsync('users', user.username)
    .then(userId => {

      if (userId === null) {
        // Username not taken, thus valid for new user
        
        // Initiate insertion of new user by incrementing global_userId key
        redis.client.incr('global_userId', redis.print);

        return redis.client.getAsync('global_userId');

      } else {
        // Username already exists
        return null;
      }
    })
    .then(globalUserId => {

      // Username already exists
      if (globalUserId === null) {

        clientSocket.emit('redis response for signup', null);

      } else {

        redis.client.hmset(`user:${globalUserId}`, ['firstname', user.firstname, 'lastname', user.lastname, 'username', user.username, 'password', user.password], function(err, res) {});
        redis.client.hset('users', [user.username, `${globalUserId}`]);
        
        clientSocket.emit('redis response for signup', user);

      }
    })
    .catch(console.error.bind(console));
}

/*
  Utilized in AddFriend Endpoint
  
  Given a username (of type String)
  return value:
    if user does not exist return null
    else return all fields of user:userId hash (username, lastname, firstname, userId)
 */
function checkUser(username, clientSocket) {
  redis.client.hgetAsync('users', username)
    .then(userId => {
      console.log('userId is:', userId);
      // NULL is returned for non-existent key
      if (userId === null) {
        // Username does not exist
        return null;
      } else {
        return redis.client.hgetallAsync(`user:${userId}`);
      }
    })
    .then(user => {
      // user will be null or an object
      console.log('user is', user);

      clientSocket.emit('redis response checkUser', user);
     
    }).catch(console.error.bind(console));
}

function getUserId(username, cb){
  redis.client.hgetAsync('users', `${username}`)
    .then(userId => {
      if (userId === null) {
        return null;
      } else {
        //clientSocket.emit("redis response undertakeKeyExchange", userId)
        console.log('userId in getUserId is ', userId);
        cb(userId);
      }
    }).catch(console.error.bind(console));
};

//query redis for existing chat between two specified users, return bool
function determineChatExistence (lesserUserID, greaterUserId){
  var startTrueForTESTonly = true;

  var chatEstablished = startTrueForTESTonly ||
      redis.client.get(`dh${lesserUserID}:${greaterUserId}`, 'chatEstablished', redis.print) ||
      redis.client.get(`chat${lesserUserID}:${greaterUserId}`, redis.print);

  return chatEstablished;
};

//initiates redis data structures for the key exchange, inserts values
function initKeyExchange (dhxObject, clientSocket){
  console.log('dhxObject izzzzz', dhxObject)
  //redis.client.hmset(`user:${globalUserId}`, ['firstname', user.firstname, 'lastname', user.lastname, 'username', user.username, 'password', user.password], function(err, res) {});
  redis.client.hmsetAsync(`dh${dhxObject.lesserUserID}:${dhxObject.greaterUserId}`, ['pAlice', dhxObject.p, 'gAlice', dhxObject.g, 'eAlice', dhxObject.E])
  //create pending set: client1
    //redis.client.
  //create pending set: client2
    //redis.client.
  .then(()=>{
    redis.client.get(`dh${dhxObject.lesserUserID}:${dhxObject.greaterUserId}`, redis.print)
    clientSocket.emit("keyExchange initiated")
  })
  .catch(console.error.bind(console));
};

//EITHER initiates keyExchange between two clients or informs Alice_client no need.
function undertakeKeyExchange (dhxObject, clientSocket){
  redis.client.hgetAsync('users', `${dhxObject.username}`)
  .then(idAlice => {
    redis.client.hgetAsync('users', `${dhxObject.friendname}`)
    .then(idBob => {
        dhxObject.greaterUserId = idAlice >= idBob ? idAlice : idBob;
        dhxObject.lesserUserId = idAlice < idBob ? idAlice : idBob;
        return dhxObject;
    })
    .then(dhxObject => {
      if (determineChatExistence(dhxObject.lesserUserID, dhxObject.greaterUserId)) {
        initKeyExchange(dhxObject, clientSocket);
        clientSocket.emit("redis response undertake KeyExchange");
      } else {
        clientSocket.emit("redis response no need to undertake KeyExchange");
      }    
    })
  })
  .catch(err => console.log('Error in undertakeKeyExchange function', err));
};


module.exports = {
  signIn, 
  signUp,
  determineChatExistence,
  undertakeKeyExchange,
  initKeyExchange
};
