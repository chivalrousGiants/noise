////////////////////////////////////
////////REDIS-MESSAGE FUNCTIONS
////////////////////////////////////

function addTimeStamp (message) {

}

function addNewMessageToSet (timestampedMessage){

}

function addNewMessageHash (timestampedMessage){

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