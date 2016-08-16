const redis = require('./redis.js');

////////////////////////////////////
//////// REDIS-USER FUNCTIONS
////////////////////////////////////

function signIn(user, clientSocket) {
  redis.client.hgetAsync('users', user.username)
    .then(userId => {
      // NULL is returned for non-existent key
      if (userId === null) {
        // Username does not exist
        return null;
      } else {
        return redis.client.hgetAsync(`user:${userId}`, 'password');
      }
    })
    .then((password) => {
      // TODO: abstract out comparePassword in utils.js
      if (password === user.password) {
        // Successful login
        clientSocket.emit('signIn successful', {
          user: user,
          clientSocketId: clientSocket.id
        });
      } else {
        // Username does not exist or password is incorrect
        clientSocket.emit('signIn unsuccessful', {
          user: user,
          clientSocketId: clientSocket.id
        });
      }
    }).catch(console.error.bind(console));
}

function signUp (user, clientSocket) {
  //check if user exists
  console.log('TEST signUp on redis: ', user, typeof user, user.username);
  return redis.client.hgetAsync('users', user.username)
  .then((returnedUser) =>{
    //if user doesn't exist
    //create new user
    if (!returnedUser){
        //increment global_userId stored in db
/*
  var userID = client.get('global_userId')
  client.hmsetAsync(`user:${userID}`, ['firstname', 'Hannah', 'lastname', 'Brannan', 'username', 'hannah', 'password', 'hannah'], function(err, res) {});

*/
        redis.client.incr('global_userId')

        ///TESTING >>STRING 
        let newUserId = redis.client.get('global_userId');
        // let userName = JSON.stringify(user.username);

        //add a single new username-userId pair to hash: users
        redis.client.hmsetAsync('users', 'username', `${user.username}`, 'userId', `${newUserId}`)
        .then(()=>{
          //create a unique userId hash, storing all affiliated user data here.
          redis.client.hmsetAsync(`user:${newUserId}`, [
            user.username,
            user.password
          ])
        })
        .then(() => { 
          clientSocket.emit('sign up success');
        })
        .catch(err => {
          console.log('error in inserting new user' , err)
          clientSocket.emit('signUp failure', err);
        })
    } else {
      clientSocket.emit('username taken', {user:user});
    }
  })
  .catch(err => {
    console.log('Error in retreiving user: ', err)
  });
    //YES>>>>> throw error
}

/*
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
