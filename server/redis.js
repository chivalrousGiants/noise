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
    (field, value) = (sourceId, user_id), (targetId, user_id) (body, 'hey') (createdAt, time_stamp)
  Ordered-Set chat:user_id_small:user_id_big
    (score, element) = (index, msg_id)

PendingKeyExchange
  (TO BE DETERMINED)
  source_user_id, target_user_id

DP IRR Sums
  Query: Given a cohort number, fetch an array of integers with each value
  representing the sum of the bits at each corresponding index for IRRs 
  reported by that cohort.

    BITFIELD coh:cohort_num GET u16 0*16 GET u16 1*16 GET u16 2*16 ...

  Insert: Given a cohort number and a bit place, increment the number at
  the specified bit place to the sum representing the sum of the bits at
  each corresponding index for IRRs reported by that cohort.
    
    BITFIELD coh:cohort_num OVERFLOW FAIL INCRBY u16 16*bit_place 1

  Bitfield bitCounts:cohort_num

DP Total Reports per Cohort
  Query: Given a cohort number, fetch the total number of reports submitted
  for that cohort.

  Insert: Given a cohort number, increment the total number of reports.

  Hash repTotals
    (coh:0, 3456) (coh:1, 3544) (coh:2, 3654) ...

DP statistics
 ************************************************************/


// Requires
const redis = require('redis');
const bluebird = require('bluebird');
const utils = require('./utils');

const {
  BLOOM_FILTER_SIZE,
  NUM_HASH_FUNCTIONS,
  NUM_COHORTS,
  F_PARAM,
  P_PARAM,
  Q_PARAM,
  MAX_SUM_BITS,
} = require('./differentialPrivacy/dpParams');

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

  /////////////////////////////////////////////////////////
  // DP statistics data structures - Uncomment to clear existing data and initialize new data structures

  // 1. Create bit field for each cohort
  // for (let cohortNum of Array(NUM_COHORTS).keys()) {
  //   // BLOOM_FILTER_SIZE * MAX_SUM_BITS - 1 is the index of the least significant bit of the last bit's sum.
  //   // Set this bit to zero manually to pre-allocate space for this bitfield.
  //   client.batch([
  //     ['SET', `bitCounts:${cohortNum}`, '0'],
  //     ['BITFIELD', `bitCounts:${cohortNum}`, 'SET', `u${MAX_SUM_BITS}`, 0, 0],
  //     ['BITFIELD', `bitCounts:${cohortNum}`, 'SET', `u1`, `${BLOOM_FILTER_SIZE * MAX_SUM_BITS - 1}`, 0],
  //   ]).exec((err, res) => {
  //     if (err) console.error(error);
  //   });
  // };

  // 2. Create hash table holding each cohort's total number of reports
  // [...Array(NUM_COHORTS).keys()].forEach(cohortNum => {
  //   client.hmset(`repTotals`, `coh${cohortNum}`, 0, (err, res) => {
  //     if (err) console.error(err);
  //   });
  // });

// (Closing brace for client.on('connect'))
});

// Exports
module.exports = {
  client
};
