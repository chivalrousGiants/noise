const redis = require('./redis.js');
const activeSocketConnections = require('./activeSocketConnections.js');

////////////////////////////////////
//////// REDIS USER FUNCTIONS
////////////////////////////////////

function signIn(user, clientSocket) {
  redis.client.hgetAsync('users', user.username)
    .then(userID => {
      // console.log('signIn userID is', userID);

      // NULL is returned for non-existent key
      if (userID === null) {
        // Username does not exist
        return [null, null];
      } else {
        return Promise.all([redis.client.hgetallAsync(`user:${userID}`), userID]);
      }
    })
    .then(([foundUser, userID]) => {
      // TODO: abstract out comparePassword in utils.js
      if (foundUser !== null && foundUser.password === user.password) {
        // console.log('signin password match successful');
        
        // Successful login
        foundUser.userID = userID;

        // add socket.id to activeConnections
        activeSocketConnections[`${userID}`] = clientSocket.id;

        clientSocket.emit('redis response for signin', {
          user: foundUser,
          clientSocketID: clientSocket.id
        });
      } else {
        // Username does not exist or password is incorrect
        clientSocket.emit('redis response for signin', null);
      }
    }).catch(console.error.bind(console));
}

function signUp (user, clientSocket) {
  redis.client.hgetAsync('users', user.username)
    .then(userID => {

      if (userID === null) {
        // Username not taken, thus valid for new user
        
        // Initiate insertion of new user by incrementing global_userID key
        redis.client.incr('global_userID', redis.print);

        return redis.client.getAsync('global_userID');

      } else {
        // Username already exists
        return null;
      }
    })
    .then(globalUserID => {

      // Username already exists
      if (globalUserID === null) {

        clientSocket.emit('redis response for signup', null);

      } else {

        redis.client.hmset(`user:${globalUserID}`, 
          ['firstname', user.firstname, 'lastname', user.lastname, 'username', 
            user.username, 'password', user.password], function(err, res) {});

        redis.client.hset('users', [user.username, `${globalUserID}`]);
        
        // add socket.id to activeConnections
        activeSocketConnections[`${globalUserID}`] = clientSocket.id;

        user.userID = globalUserID;
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
    else return userObj (username, lastname, firstname, userID)
 */
function checkUser(username, clientSocket) {
  redis.client.hgetAsync('users', username)
    .then(userID => {
      //console.log('userID in checkUser is:', userID);
      // NULL is returned for non-existent key
      if (userID === null) {
        // Username does not exist
        return [null, null];
      } else {
        return Promise.all([redis.client.hgetallAsync(`user:${userID}`), userID]);
      }
    })
    .then(([user, userID]) => {
      // user will be null or an object
      //console.log('user is', user);

      if (user !== null) {
        user.userID = userID;
      }

      clientSocket.emit('redis response checkUser', user);
     
    }).catch(console.error.bind(console));
}

function getUserID(username, cb){
  redis.client.hgetAsync('users', `${username}`)
    .then(userID => {
      if (userID === null) {
        cb(null);
      } else {
        console.log('userID in getUserID is ', userID);
        cb(userID);
      }
    }).catch(console.error.bind(console));
}

module.exports = {
  signIn, 
  signUp,
  checkUser,
  getUserID
};
