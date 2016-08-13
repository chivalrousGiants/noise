var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

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

  clientSocket.on('userSignedUp', function() {
  console.log('user signed up')
  });

  clientSocket.on('userLoggedIn', function() {
  console.log('user logged in')
  });

  clientSocket.on('chatSent', function(chatMessage) {
  	console.log('STRETCH: pass chatMessage: encrypted to redis DB')
  	//insert into redis
  });

  clientSocket.on('noisifiedChatSent', function(chatMessage) {
	console.log('TODO: pass nosified chatMessage to redis DB')
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
