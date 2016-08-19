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
    Array of objs for each friend
      {
        friendId
        messages: Array of msgObjs [ {targetId, sourceId, createdAt, body, msgId} ]
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
    
    /////////// Testing
    // let cnt = 1;
    // returnValue.forEach(obj => {
    //   console.log(`returnValue for obj ${cnt}:`, obj);
    //   cnt++;
    // });

    clientSocket.emit('redis response for retrieveNewMessages', returnValue);

  })
  .catch(console.error.bind(console));

}

/*
  Input Parameters
    message = { sourceID, targetID, body, createdAt }

  Return value
    TO: clientSocket
      userArray[0] = messageID (generated when inserting new message to redis)

    TO: targetId's socket
      userArray[0] = messageID
      userArray[1] = msgObj { sourceId, targetId, body, createdAt }
 */
function handleNewMessage(message, clientSocket) {
  // write new message to db
  redis.client.incr('global_msgId', redis.print);
  redis.client.getAsync('global_msgId')
    .then(msgId => {

      redis.client.hmset(`msgs:${msgId}`, [
        'sourceId', message.sourceID,
        'targetId', message.targetID,
        'body', message.body,
        'createdAt', message.createdAt
      ]);

      redis.client.zadd(`chat:${message.sourceID}:${message.targetID}`, `${msgId}`, `${msgId}`);

      clientSocket.emit('successfully sent new message', msgId);

      // check if friend (target of msg) is online
      let friendSocketId = activeSocketConnections[`${message.targetID}`];

      if (friendSocketId) {
        clientSocket.broadcast.to(friendSocketId)
          .emit('receive new message', msgId, message);
      }
    })
    .catch(console.error.bind(console));
}



/////////// Testing
// let friends = {
//   '1': 15, // [3, 10, 15, 22, 27, 34, 39, 46, 51, 58]
//   '2': 30, // [6, 11, 18, 23, 30, 35, 42, 47, 54, 59]
//   '3': 10
// };
// retrieveNewMessages(4, friends);

module.exports = {
  retrieveNewMessages
  handleNewMessage
};