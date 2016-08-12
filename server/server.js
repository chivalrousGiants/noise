var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(request, response) {
  response.send('hello world');
});

http.listen(4000, function() {
  console.log('listening')
});

var allUsers = [];

io.on('connection', function(clientSocket) {
  console.log('a user connected')
  clientSocket.on('disconnect', function() {
  console.log('user disconnected')
  })
  clientSocket.on('chatSent', function(chatMessage) {

  })
  clientSocket.on('signinOrSignup', function(username) {
    console.log(username, 'connected')
  })
})
