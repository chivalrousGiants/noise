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

////////////////////////////////////
////////REDIS-USER FUNCTIONS
////////////////////////////////////

function addUser (user) {

}

function passwordMatches () {

}

function userAlreadyExists (user){

}

////////////////////////////////////
////////REDIS-ADD FRIEND FUNCTIONS
////////////////////////////////////

function addFriend (baseUser, friend) {
	
}


module.exports = {
	addTimeStamp: addTimeStamp,
	deleteMessage: deleteMessage,
	addNewMessage: addNewMessage,
	retrieveNewMessages: retrieveNewMessages
}