const redis = require('./redis.js');

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
      {
        friend: friend_id
        messages: [ {msgObj - including msgId} {msgObj} ... ]
        largestMessageId
      }
   */
  

  let result = [];

  // loop through friend_id's in friends parameter
  // let newMessages = {};
  // zrange chat:user_id:user:id from (largestMessageId + 1) to -1
  // add them to newMessages.messages including the msgId subkeys
  // set newMessages.friend and newMessages.largestMessageId
  // result.push(newMessages)

  return result;
};


// function addTimeStamp (message) {
// 	var score = new Date();
// 	message.score = score;
// 	return message;
// }

// function addNewMessageToSet (message){
// 	let scoredMessage = addTimeStamp(message);
// 	//redis.client.zadd()
// }

// function addNewMessageHash (timestampedMessage){
// 	//redis.client.
// }

// function retrieveNewMessages (latestTimeStamp){

// }

// function deleteMessage (messageID){

// }

//STRETCH:
  // retrieve all messages
  // delete all messages (associated with userX)
  // 

module.exports = {
  retrieveNewMessages
};