var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var utils = require('./utils.js');

app.get('/', function(request, response) {
  response.send('hello world');
});

http.listen(4000, function() {
  console.log('listening')
});

//forDummyData
var users = [];

io.on('connection', function(clientSocket) {
  console.log('a user connected')

  clientSocket.on('disconnect', function() {
  console.log('user disconnected')
  });

  clientSocket.on('newUserAdded', function(newUser) {
  console.log('user signed up', newUser)
  });

  clientSocket.on('userSigningIn', function() {
  console.log('user logged in')
  });

  clientSocket.on('encryptedChatSent', function(chatMessage) {
  	console.log('TEST: chatMessage from client on server', chatMessage)
  	//insert msg id -time stamp to ordered list
    //insert msg hash to msgs
  });

  clientSocket.on('noisifiedChatSent', function(chatMessage) {
	console.log('TODO: pass nosified chatMessage to redis DB')
	//clientSocket.emit('c', chatMessage);
  });

  clientSocket.on('friendAdded', function(chatMessage) {
  console.log('TODO: pass friend')
  //clientSocket.emit('c', chatMessage);
  });

  clientSocket.on('getfriends', function() {
    var dummyFriends = ["Ryan", "Jae", "Michael", "Hannah"]
    io.emit(dummyFriends);

  });

  clientSocket.on('signinOrSignup', function(username) {
    users.push(username)
    console.log(username, 'connected and userscount is', users.length, username )
  });
});
