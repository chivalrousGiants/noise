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
      console.log('found password for user in db is', foundUser.password);
      // TODO: abstract out comparePassword in utils.js
      if (foundUser.password === user.password) {
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

        return client.getAsync('global_userId');

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

        client.hmset(`user:${globalUserId}`, ['firstname', user.firstname, 'lastname', user.lastname, 'username', user.username, 'password', user.password], function(err, res) {});
        client.hset('users', [user.username, `${globalUserId}`]);
        
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

      clientSocket.emit('reply for checkUser', user);
     
    }).catch(console.error.bind(console));
}

module.exports = {
  signIn, 
  signUp,
  checkUser
};
