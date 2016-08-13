const redis = require('redis');
const bluebird = require('bluebird');

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
const client = redis.createClient();

/*
  Connect to Redis Client
  Need to make sure your local Redis server is up and running
 */
client.on('connect', function() {
  console.log('Successfully connected to redis client!');
});

/*
  CREATE Example
  key: 'framework'
  value: 'AngularJS'
 */
client.setAsync('framework', 'AngularJS')
  .then(reply => console.log(reply))
  .catch(err => console.log(err));

/*
  READ Example
  key: 'framework'
  value: 'AngularJS'
 */
client.getAsync('framework')
  .then(key => console.log(key))
  .catch(err => console.log(err));



/*
 ***** REDIS DATA STRUCTURE *****

Users
  Query: fetch certain user fields with user_id or username

  Hash user:user_id
    (realname, 'Jae Shin') (username, 'jaebear') (password, 'xoxo')
  Hash users
    (username, user_id)

Messages
  Query: fetch chat history for each friend that is not already in localDB

  Hash msgs:msg_id
    (source_user_id, id), (target_user_id, id)
    (text_encrypted, 'hey'), (has_been_deleted, 0/1)
    (time, 1453425)
  Ordered Set chat:user_id_small:user_id_big
    (time, msg_id)  

PendingKeyExchange
  (TO BE DETERMINED)
  source_user_id, target_user_id

DP noisified data, PRR, IRR

DP statistics

 */
































