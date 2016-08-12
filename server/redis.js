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
  CREATE
  key: 'framework'
  value: 'AngularJS'
 */
client.setAsync('framework', 'AngularJS')
  .then(reply => console.log(reply))
  .catch(err => console.log(err));

/*
  READ
  key: 'framework'
  value: 'AngularJS'
 */
client.getAsync('framework')
  .then(key => console.log(key))
  .catch(err => console.log(err));


