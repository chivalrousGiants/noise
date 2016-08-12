const redis = require('redis');

/*
  Creates new Redis Client

  redis.createClient(port, host)

  by default
    port: 127.0.0.1
    host: 6379
 */
const client = redis.createClient();

client.on('connect', function() {
  console.log('connected');
})



