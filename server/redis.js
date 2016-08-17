/************************************************************
 ******************* REDIS DATA STRUCTURE *******************
 ************************************************************
 
 Users Dummy Data
 *   userId
 *   1      (username: hannah, pw: hannah, firstname: Hannah, lastname: Brannan) 
 *   2      (username: mikey, pw: mikey, firstname: Michael, lastname: De La Cruz)
 *   3      (username: ryan, pw: ryan, firstname: Ryan, lastname: Hanzawa)
 *   4      (username: jae, pw: jae, firstname: Jae, lastname: Shin)

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
 ************************************************************/


// Requires
const redis = require('redis');
const bluebird = require('bluebird');
const utils = require('./utils.js');

/*
  Promisify redis with bluebird

  : In order to use the promisified version of a redis function just append 'Async' 
  to original function name
 */
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


//////////////////////////////////////////////////////////////
//////// Initialization of Users dummy data :: TESTING ONLY!
//////////////////////////////////////////////////////////////

/*
  Connect to Redis Client
  Need to make sure your local Redis server is up and running
 */
client.on('connect', function() {
  
  console.log('Successfully connected to redis client!');

  client.getAsync('global_userId')
    .then(userId => {
      // initialize user data
      if (userId === null) {
        client.set('global_userId', 0, redis.print);
        client.incr('global_userId', redis.print);
        client.getAsync('global_userId')
          .then(userId => {
            client.hmset(`user:${userId}`, ['firstname', 'Hannah', 'lastname', 'Brannan', 'username', 'hannah', 'password', 'hannah'], function(err, res) {});
            client.hset('users', ['hannah', `${userId}`]);
            client.incr('global_userId', redis.print);
            return client.getAsync('global_userId');
          })
          .then(userId => {
            client.hmset(`user:${userId}`, ['firstname', 'Michael', 'lastname', 'De La Cruz', 'username', 'mikey', 'password', 'mikey'], function(err, res) {});
            client.hset('users', ['mikey', `${userId}`]);
            client.incr('global_userId', redis.print);
            return client.getAsync('global_userId');
          })
          .then(userId => {
            client.hmset(`user:${userId}`, ['firstname', 'Ryan', 'lastname', 'Hanzawa', 'username', 'ryan', 'password', 'ryan'], function(err, res) {});
            client.hset('users', ['ryan', `${userId}`]);
            client.incr('global_userId', redis.print);
            return client.getAsync('global_userId'); 
          })
          .then(userId => {
            client.hmset(`user:${userId}`, ['firstname', 'Jae', 'lastname', 'Shin', 'username', 'jae', 'password', 'jae'], function(err, res) {});
            client.hset('users', ['jae', `${userId}`]);
          })
          .catch(err => {
            console.log('Error in initialization of user data', err);
          });
      } else {
        // user data has been already initialized
        return null;
      }
    })
    .catch(console.error.bind(console));

});


// Exports
module.exports = {
  client
};
































