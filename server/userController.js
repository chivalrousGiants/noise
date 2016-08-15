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
  //check if user exists
  console.log('TEST signUp on redis: ', user, typeof user, user.username);
  return redis.client.hgetAsync('users', user.username)
  .then((returnedUser) =>{
    //if user doesn't exist

    if (!returnedUser){
        //parse pieces of user Obj. Increment userId, assemble to add to db
        let newUserId = redis.client.incr('global_userId', redis.print)
        redis.client.hmsetAsync(newUserId, {
          'username': user.username,
          'password': user.password
        }, redis.print)
        .then(()=>{
          redis.client.hmsetAsync(`user:${newUserId}`, [
            user.username, user.password
          ], redis.print)
        })
        .then(() => { 
          clientSocket.emit('sign up success');
        })
        .catch(err => {
          console.log('error in inserting new user' , err)
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

function passwordMatches () {

}

function userAlreadyExists (user){

}

module.exports = {
  signIn, 
  signUp
};