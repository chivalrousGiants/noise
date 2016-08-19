const redis = require('./redis.js');
const activeSocketConnections = require('./activeSocketConnections');

////////////////////////////////////
//////// REDIS MESSAGE FUNCTIONS
////////////////////////////////////

/*
  Input Parameters
    friends = { 
      friend_id: largestMessageId
      friend_id: largestMessageId
      ...
    }

  Return value
    Array of objects for each friend
      {
        friendId: friend_id
        messages: Array of message objs 
          [ {targetId, sourceId, createdAt, body, msgId} ]
        largestMessageId
      }
 */
function retrieveNewMessages(userId, friends, clientSocket) {
  
  let result = [],
    smallerId,
    largerId,
    largestMessageId,
    newMessages,
    getMsgIdsPromiseArray = [],
    getMsgsPromiseArray = [];
  
  
  Object.keys(friends).forEach(friendId => {
    
    largestMessageId = friends[friendId];

    [smallerId, largerId] = userId < friendId ? [userId, friendId] : [friendId, userId];

    getMsgIdsPromiseArray.push(
      redis.client.zrangebyscoreAsync(`chat:${smallerId}:${largerId}`, (largestMessageId + 1), '+inf')
        .then(msgIds => {
          let getMsgsPromiseArray = [];
          
          msgIds.forEach(msgId => {
            getMsgsPromiseArray.push(
              redis.client.hgetallAsync(`msgs:${msgId}`)
                .then(msg => {
                  msg.msgId = msgId;
                  return msg;
                })
                .catch(console.error.bind(console))
            );
          });

          return Promise.all(getMsgsPromiseArray);
        })
        .then(arrayOfNewMessagesPerFriend => {
          return {
            friendId,
            messages: arrayOfNewMessagesPerFriend,
            latestMessageId: arrayOfNewMessagesPerFriend[arrayOfNewMessagesPerFriend.length - 1].msgId
          };
        })
        .catch(console.error.bind(console))
    );

  });

  Promise.all(getMsgIdsPromiseArray).then(returnValue => {
    
    // Testing
    // let cnt = 1;
    // returnValue.forEach(obj => {
    //   console.log(`returnValue for obj ${cnt}:`, obj);
    //   cnt++;
    // });

    clientSocket.emit('redis response for retrieveNewMessages', returnValue);

  })
  .catch(console.error.bind(console));

}

// Testing
// let friends = {
//   '1': 15, // [3, 10, 15, 22, 27, 34, 39, 46, 51, 58]
//   '2': 30, // [6, 11, 18, 23, 30, 35, 42, 47, 54, 59]
//   '3': 10
// };

// retrieveNewMessages(4, friends);

module.exports = {
  retrieveNewMessages
};