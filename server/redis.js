const redis = require('redis');
const bluebird = require('bluebird');
const utils = require('./utils.js');

// Promisify redis -> append 'Async' to all functions
bluebird.promisifyAll(redis.RedisClient.prototype);
bluebird.promisifyAll(redis.Multi.prototype);


/*
  Creates new Redis Client
  redis.createClient(port, host)
  by default
    port: 127.0.0.1
    host: 6379
 */

 
client = redis.createClient();

/*
  Connect to Redis Client
  Need to make sure your local Redis server is up and running
 */

////////////////////////////////////
////////DUMMY DATA :: TESTING ONLY!
////////////////////////////////////
client.on('connect', function() {
  console.log('Successfully connected to redis client!');
  //set global userID var
  client.set('global_userId', 0, redis.print)

  client.incr('global_userId', redis.print);
  var userID = client.get('global_userId')
  client.hmsetAsync(`user:${userID}`, ['firstname', 'Hannah', 'lastname', 'Brannan', 'username', 'hannah', 'password', 'hannah'], function(err, res) {});
    
  client.incr(`global_userId`, redis.print);
  userID = client.get('global_userId')
  client.hmsetAsync('user:${userID}', ['firstname', 'Michael', 'lastname', 'De La Cruz', 'username', 'mikey', 'password', 'mikey'], function(err, res) {});
    
    client.incr('global_userId', redis.print);
   userID = client.get('global_userId')
  client.hmsetAsync('user:${userID}', ['firstname', 'Ryan', 'lastname', 'Hanzawa', 'username', 'ryan', 'password', 'ryan'], function(err, res) {});
    
    client.incr('global_userId', redis.print);
   userID = client.get('global_userId')
  client.hmsetAsync('user:${userID}', ['firstname', 'Jae', 'lastname', 'Shin', 'username', 'jae', 'password', 'jae'], function(err, res) {});

  client.hsetAsync('users', ['hannah', '1']);  
  client.hsetAsync('users', ['mikey', '2']);
  client.hsetAsync('users', ['ryan', '3']);
  client.hsetAsync('users', ['jae', '4']);

  // client.hgetall('user:0001', function(err, obj) {
  //   console.log(obj);
  // });

  // client.hgetall('user:0002', function(err, obj) {
  //   console.log(obj);
  // });

  // client.hgetall('user:0003', function(err, obj) {
  //   console.log(obj);
  // });

  // client.hgetall('user:0004', function(err, obj) {
  //   console.log(obj);
  // });
});

/*
  CREATE Example
  key: 'framework'
  value: 'AngularJS'
 */
// client.setAsync('framework', 'AngularJS')
//   .then(reply => console.log(reply))
//   .catch(err => console.log(err));

/*
  READ Example
  key: 'framework'
  value: 'AngularJS'
 */
 
// client.getAsync('framework')
//   .then(key => console.log(key))
//   .catch(err => console.log(err));



/*
 ***** REDIS DATA STRUCTURE *****
 *
 * Users
 *   UserID
 *   0001      (username: hannah, pw: hannah, firstname: Hannah, lastname: Brannan) 
 *   0002      (username: mikey, pw: mikey, firstname: Michael, lastname: De La Cruz)
 *   0003      (username: ryan, pw: ryan, firstname: Ryan, lastname: Hanzawa)
 *   0004      (username: jae, pw: jae, firstname: Jae, lastname: Shin)

Users
  Query: fetch certain user fields with user_id or username

  Hash user:user_id
    (firstname, 'Jae') (lastname, 'Shin') (username, 'jaebear') (password, 'xoxo')
    (auth, authSecret)
  Hash users
    (username, user_id)

Messages
  Query: fetch chat history for each friend that is not already in localDB

  Hash msgs:msg_id
    (source_user_id, id), (target_user_id, id)
    (text_encrypted, 'hey'), (has_been_deleted, 0/1) -- 0: false, 1: true
    (time, 1453425)
  Ordered Set chat:user_id_small:user_id_big
    (time, msg_id)  

PendingKeyExchange
  (TO BE DETERMINED)
  source_user_id, target_user_id

DP noisified data, PRR, IRR

DP statistics
 */


module.exports = {
  client
};
































