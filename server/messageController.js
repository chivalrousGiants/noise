const redis = require('./redis.js');

////////////////////////////////////
//////// REDIS MESSAGE FUNCTIONS
////////////////////////////////////

function loadNewMessages(friends, clientSocket) {
  
}


function addTimeStamp (message) {
	var score = new Date();
	message.score = score;
	return message;
}

function addNewMessageToSet (message){
	let scoredMessage = addTimeStamp(message);
	//redis.client.zadd()
}

function addNewMessageHash (timestampedMessage){
	//redis.client.
}

function retrieveNewMessages (latestTimeStamp){

}

function deleteMessage (messageID){

}

//STRETCH:
  // retrieve all messages
  // delete all messages (associated with userX)
  // 

module.exports = {
  addTimeStamp,
  addNewMessageToSet,
  addNewMessageHash,
  retrieveNewMessages,
  deleteMessage
};