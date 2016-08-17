const redis = require('../redis');

const {
  BLOOM_FILTER_SIZE,
  NUM_HASH_FUNCTIONS,
  NUM_COHORTS,
  F_PARAM,
  P_PARAM,
  Q_PARAM,
  MAX_SUM_BITS,
} = require('./dpParams');

// For the specified cohort, tell Redis to add each bit to its corresponding sum
function IngestIRRReports(IRRReports) {
  IRRReports.IRRs.forEach((IRR) => {
    IRR.forEach((bit, index) => {
      redis.client.batch([
        ['BITFIELD', `bitCounts:${IRRReports.cohortNum}`, 'INCRBY', `u${MAX_SUM_BITS}`, `#${index}`, bit],
      ]).exec((err, res) => {
        if (err) console.error(error);
        console.log(res);
      });
    });
  });
}

IngestIRRReports(SampleIRRReports);

// function signUp (user, clientSocket) {
//   redis.client.hgetAsync('users', user.username)
//     .then(userId => {
//       console.log('signUp userId is', userId);

//       if (userId === null) {
//         // Username not taken, thus valid for new user
        
//         // Initiate insertion of new user by incrementing global_userId key
//         redis.client.incr('global_userId', redis.print);

//         return redis.client.getAsync('global_userId');

//       } else {
//         // Username already exists
//         return null;
//       }
//     })
//     .then(globalUserId => {

//       // Username already exists
//       if (globalUserId === null) {

//         clientSocket.emit('redis response for signup', null);

//       } else {

//         redis.client.hmset(`user:${globalUserId}`, ['firstname', user.firstname, 'lastname', user.lastname, 'username', user.username, 'password', user.password], function(err, res) {});
//         redis.client.hset('users', [user.username, `${globalUserId}`]);
        
//         clientSocket.emit('redis response for signup', user);

//       }
//     })
//     .catch(console.error.bind(console));
// }

// Exports
module.exports = {
  IngestIRRReports,
};
