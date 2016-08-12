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
  })

  clientSocket.on('chatSent', function(chatMessage) {
  	console.log('Outside of MVP, return encrypted chatMessage from the DB')
  	clientSocket.emit('', chatMessage);
  })

  clientSocket.on('getfriends', function() {
    var dummyFriends = ["Ryan", "Jae", "Michael", "Hannah"]
    io.emit(dummyFriends);

  })

  clientSocket.on('signinOrSignup', function(username) {
    users.push(username)
    console.log(username, 'connected and userscount is', users.length, username )
  })
})
