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
      console.log('signUp userId is', userId);

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
  console.log(dhxObject);
  //client.hmset(`user:${userId}`, ['firstname', 'Hannah', 'lastname', 'Brannan', 'username', 'hannah', 'password', 'hannah'], function(err, res) {});
  redis.client.hmset(`dh${dhxObject.lesserUserID}:${dhxObject.greaterUserId}`, ['pAlice', dhxObject.p, 'gAlice', dhxObject.g, 'eAlice', dhxObject.E], function(err, res){});
  //create pending set: client1 
  //create pending set: client2
};

//EITHER initiates keyExchange or informs client no need.
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
      console.log('final then clause', dhxObject)
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




/*
function undertakeKeyExchange (dhxObject, clientSocket){
  //setUp
  let needToInitKeyExchange = false;
  let userId1 = redis.client.hgetAsync('users', `${dhxObject.username}`)
  let userId2 = redis.client.hgetAsync('users', `${dhxObject.friendname}`)
  // getUserId(dhxObject.username, function(v) { userId1 = v;});
  // getUserId(dhxObject.friendname, function(v) {userId2 = v;});
  //  console.log('yoooserid acch', userId2);
  const greaterUserId = userId1 >= userId2 ? userId1 : userId2;
  const lesserUserID = userId1 < userId2 ? userId1 : userId2;
  dhxObject.greaterUserId = greaterUserId;
  dhxObject.lesserUserId = lesserUserID

  if (determineChatExistence(lesserUserID, greaterUserId)) {
     needToInitKeyExchange = true;
     initKeyExchange(dhxObject, clientSocket);
      clientSocket.emit("redis response undertake KeyExchange", needToInitKeyExchange);
  } else {
      clientSocket.emit("redis response no need to undertake KeyExchange", needToInitKeyExchange);
  }
};
*/