const redis = require('./redis.js');
const bluebird = require('bluebird');

////////////////////////////////////
//////// REDIS MESSAGE FUNCTIONS
////////////////////////////////////

function retrieveNewMessages(username, friends, clientSocket) {
  /*
    username = username of the logged-in user

    friends = {
      friend_id: largestMessageId
      friend_id: largestMessageId
      ...
    }

    need to return 
      Array of objects for each friend
      newMessages = {
        friendId: friend_id
        messages: [ {msgObj - including msgId} {msgObj} ... ]
        largestMessageId
      }
   */
  
  let result = [],
    smallerId,
    largerId,
    largestMessageId,
    newMessages,
    msgIdsPromiseArray = [];
  
  redis.client.hgetAsync('users', username)
    .then(userId => {

      Object.keys(friends).forEach(friendId => {
        largestMessageId = friends[friendId];

        [smallerId, largerId] = userId < friendId ? [userId, friendId] : [friendId, userId];

        msgIdsPromiseArray.push(redis.client.zrangeAsync(`chat:${smallerId}:${largerId}`, `${largestMessageId + 1}`, -1));
      });

      return bluebird.all(msgIdsPromiseArray).then(arr => {
        console.log(arr);
      });

      console.log('after bluebird.all');
      
    }).catch(console.error.bind(console));

    // .then(userId => {
    //   // loop through friend_id's in friends parameter
    //   for (let friendId in friends) {

    //     largestMessageId = friends[friendId];
        
    //     newMessages = {};
    //     newMessages.friendId = friendId;
    //     newMessages.messages = [];

    //     [smallerId, largerId] = userId < friendId ? [userId, friendId] : [friendId, userId];

    //     redis.client.zrangeAsync(`chat:${smallerId}:${largerId}`, largestMessageId + 1, -1)
    //       .then(msgIds => {

    //         // msgIds = array of msgIds
    //         msgIds.forEach(msgId => {
    //           redis.client.hgetallAsync(`msgs:${msgId}`)
    //             .then(msg => {
    //               if (msg === null) {
    //                 throw 'Msg for given msgId does not exist';
    //               }

    //               // add msgId key to msg obj
    //               msg.msgId = msgId;
    //               newMessages.messages.push(msg);

    //             }).catch(console.error.bind(console));
    //         });

    //         newMessages.largestMessageId = msgIds.pop();
    //       });

    //     result.push(newMessages);
        
    //   }

    //   console.log('result is:', result);
    //   // clientSocket.emit('redis response for retrieveNewMessages', result);

    // })
    // .catch(console.error.bind(console));

}

// Testing
let friends = {
  '1': 0, // [3, 10, 15, 22, 27, 34, 39, 46, 51, 58]
  '2': 0  // [6, 11, 18, 23, 30, 35, 42, 47, 54, 59]
};
retrieveNewMessages('jae', friends);

module.exports = {
  retrieveNewMessages
};