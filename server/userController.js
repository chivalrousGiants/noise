const redis = require('./redis.js');

////////////////////////////////////
////////REDIS-USER FUNCTIONS
////////////////////////////////////

// user = {username: , password: }

function signIn (user, clientSocketId) {

  redis.client.hgetAsync('users', user.username)
    .then(userId => {
      if (!userId) {
        // username does not exist
        

      }
    }).catch(err => {
      console.log('Error in utils signIn', err);
    });

  // redis.client.hget('users', user.username, function(err, userId) {
  //   if (err) {
  //     console.log('Error in utils signIn', err);
  //   } else if (!userId) {
  //     // username does not exist
  //     return false;
  //   } else {
  //     redis.client.hget(`user:${userId}`, 'password', function(err, pw) {
  //       if ()
  //     }
  //   }
  // });


}

function addUser (user) {

}

function passwordMatches () {

}

function userAlreadyExists (user){

}

module.exports = {
  signIn
};