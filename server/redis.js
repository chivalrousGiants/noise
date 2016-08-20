/************************************************************
 ******************* REDIS DATA STRUCTURE *******************
 ************************************************************
 
 Users
 *   userID
 *   1      (username: hannah, pw: hannah, firstname: Hannah, lastname: Brannan) 
 *   2      (username: mikey, pw: mikey, firstname: Michael, lastname: De La Cruz)
 *   3      (username: ryan, pw: ryan, firstname: Ryan, lastname: Hanzawa)
 *   4      (username: jae, pw: jae, firstname: Jae, lastname: Shin)

Users
  Query: fetch certain user fields with userID or username

  Hash user:userID
    (firstname, 'Jae') (lastname, 'Shin') (username, 'jaebear') (password, 'xoxo')
    (auth, authSecret)
  Hash users
    (username, userID)

Messages
  Query: fetch all new messages that is not already written in Realm

  Hash msgs:msgID
    (field, value) = (sourceID, userID), (targetID, userID) (body, 'hey') (createdAt, time_stamp)
  Ordered-Set chat:smaller_userID:larger_userID
    (score, element) = (index, msgID)

PendingKeyExchange

  Hash   DH:lesser_user_ID:greater_user_ID
    lesser_user_p: 
    lesser_user_g:
    lesser_user_E:
    greater_user_p: 
    greater_user_g:
    greater_user_E:
    chatEstablished: 0/1/2

  Set   pending:user_ID
      targetUserID1
      targetUserID2
      targetUserID3
      et al
  
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

// Generates random sentences (used for initializing message data)
const chance = new require('chance')();

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


////////////////////////////////////////////////////
//////// Initialization of Users 1, 2, 3, 4 ////////
////////////////////////////////////////////////////

/*
  Connect to Redis Client
  Need to make sure your local Redis server is up and running
 */
client.on('connect', function() {
  
  console.log('Successfully connected to redis client!');

  // Initialize User data
  client.getAsync('global_userID')
    .then(userID => {

      // Users have not been initialized
      if (userID === null) {
        client.hmset('user:1', ['firstname', 'Hannah', 'lastname', 'Brannan', 'username', 'hannah', 'password', 'hannah']);
        client.hset('users', ['hannah', 1]);

        client.hmset('user:2', ['firstname', 'Michael', 'lastname', 'De La Cruz', 'username', 'mikey', 'password', 'mikey']);
        client.hset('users', ['mikey', 2]);

        client.hmset('user:3', ['firstname', 'Ryan', 'lastname', 'Hanzawa', 'username', 'ryan', 'password', 'ryan']);
        client.hset('users', ['ryan', 3]);

        client.hmset('user:4', ['firstname', 'Jae', 'lastname', 'Shin', 'username', 'jae', 'password', 'jae']);
        client.hset('users', ['jae', 4]);

        // global_userID = # of users so far
        // global_userID increments when a new user signs up
        client.set('global_userID', 4, redis.print);
      } 

      // Initialize Message data
      return client.getAsync('global_msgID');
    })
    .then(msgID => {
      // Initialize message data for users 1, 2, 3, 4
      //    Each user sends 5 messages each to other users
      //    A pair of two users has ten messages between them
      //    Each message is prefixed by 'num1:num2:num3'
      //        num1 = messageID
      //        num2 = sourceID
      //        num3 = targetID
      if (msgID === null) {
        let newMsgID = 0;

        for (let cnt = 1; cnt <= 5; cnt++) {
          for (let sourceID = 1; sourceID <= 4; sourceID++) {
            for (let targetID = 1; targetID <= 4; targetID++) {
              if (!(sourceID === targetID)) {
                newMsgID++;
                client.hmset(`msgs:${newMsgID}`, [
                  'sourceID', `${sourceID}`,
                  'targetID', `${targetID}`,
                  'body', `${newMsgID}:${sourceID}:${targetID} ${chance.sentence()}`,
                  'createdAt', Date.now()
                ]);

                if (sourceID < targetID) {
                  client.zadd(`chat:${sourceID}:${targetID}`, `${newMsgID}`, `${newMsgID}`);
                } else {
                  client.zadd(`chat:${targetID}:${sourceID}`, `${newMsgID}`, `${newMsgID}`);
                }
              }
            }
          }
        }

        // global_msgID = # of total msgs so far
        // global_msgID is incremented before adding new message
        client.set('global_msgID', newMsgID, redis.print);

      } else {
        // message data has been already initialized
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
