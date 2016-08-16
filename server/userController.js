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

function signUp (user, clientSocket) {
  console.log('hit signUp on redis: ', user);
  //check if user exists
  redis.client.hgetAsync('users', user.username)
//   .then((user) =>{
// //NO USER OF THAT NAME>>>>>> 
//     if (!user){
//     //parse the user obj
//     //assign an incrementing userID     
//     //add to db
//       redis.client.hmsetAsync()
//       clientSocket.emit('username available', {user: user});
//     } else {
//       clientSocket.emit('username taken', {user:user});
//     }
//   })
  .catch(err => {
    console.log('Error in retreiving user: ', err)
  });
    //YES>>>>> throw error
}

function passwordMatches () {

}

function userAlreadyExists (user){

}

module.exports = {
  signIn, 
  signUp
};