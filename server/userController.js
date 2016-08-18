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

function getUserId(username, clientSocket){
    redis.client.hgetAsync('users', username)
    .then(userId => {
      if (userId === null) {
        return null;
      } else {
        //clientSocket.emit("redis response undertakeKeyExchange", userId)
        return userId;
      }
    }).catch(console.error.bind(console));
};

function checkForChat (userId1, userId2, clientSocket){
  //TODO
  return true;
};

function initKeyExchange (dhxObject, clientSocket){
  let needToInitKeyExchange = false;
  const userId1 = getUserId(dhxObject.username);
  const userId2 = getUserId(dhxObject.friendname);
  if (checkForChat(userId1, userId2, clientSocket)) {
    needToInitKeyExchange = true;
  }
  clientSocket.emit("redis response undertakeKeyExchange", needToInitKeyExchange);
};

module.exports = {
  signIn, 
  signUp,
  initKeyExchange
};