const redis = require('./redis.js');

////////////////////////////////////
////////REDIS-USER FUNCTIONS
////////////////////////////////////

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

function passwordMatches () {

}

function userAlreadyExists (user){

}

module.exports = {
  signIn, 
  signUp
};