const app = require('express')();
const http = require('http').Server(app);
const io = require('socket.io')(http);

// Config
const HTTP_PORT = 4000;

// Redis Database
const redis = require('./redis.js');
const userController = require('./userController.js');

app.get('/', (req, res) => {
  res.send('Hello world');
});

http.listen(HTTP_PORT, () => {
  console.log(`Listening on port ${HTTP_PORT}`)
});

// Socket.io
io.on('connection', (clientSocket) => {
  console.log('A user connected with socket id', clientSocket.id);

  clientSocket.on('disconnect', () => {
    console.log('A user disconnected with socket id', clientSocket.id);
  });

  clientSocket.on('signIn', (user) => {
    console.log('hit signIn on server socket:', user);

    userController.signIn(user, clientSocket);
  });

  clientSocket.on('find new friend', (username) => {
    console.log('hit find-new-friend on server socket with username', username);
    
    userController.checkUser(username, clientSocket);
  });

  clientSocket.on('encryptedChatSent', function(chatMessage) {
    console.log('Received ChatMessage from client:', chatMessage)
    // Insert msg id -time stamp to ordered list
    // Insert msg hash to msgs
  });

  clientSocket.on('noisifiedChatSent', function(chatMessage) {
    console.log('TODO: pass nosified chatMessage to redis DB')
    // clientSocket.emit('c', chatMessage);
  });


  clientSocket.on('getfriends', function() {
    var dummyFriends = ["Ryan", "Jae", "Michael", "Hannah"]
    io.emit(dummyFriends);
  });
});
