const redis = require('./redis.js');

////////////////////////////////////
////////REDIS-USER FUNCTIONS
////////////////////////////////////

// user = {username: , password: }

function signIn (user, clientSocket) {

  redis.client.hgetAsync('users', user.username)
    .then(userId => {
      if (!userId) {
        // username does not exist
        clientSocket.emit('signIn unsuccessful', {
          user: user,
          clientSocketId: clientSocket.id
        });
      } else {
        redis.client.hgetAsync(`user:${userId}`, 'password')
          .then(pw => {
            // TODO: abstract out comparePassword in utils.js
            if (pw === user.password) {
              // successful login
              clientSocket.emit('signIn successful', {
                user: user,
                clientSocketId: clientSocket.id
              });
            } else {
              // password is incorrect
              clientSocket.emit('signIn unsuccessful', user);
            }
          }).catch(err => {
            console.log('Error in password compare', err);
          });
      }
    }).catch(err => {
      console.log('Error in username compare', err);
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

function signUp (user, clientSocket) {
  console.log('hit signUp on redis: ', user);
  //check if user exists
  redis.client.hgetAsync('users', user.username)
  console.log('hit signUp on redis: ', user);
  .then((user) =>{
//NO USER OF THAT NAME>>>>>> 
    if (!user){
    //parse the user obj
    //assign an incrementing userID     
    //add to db
      redis.client.hmsetAsync()
      clientSocket.emit('username available', {user: user});
    } else {
      clientSocket.emit('username taken', {user:user});
    }
  })
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