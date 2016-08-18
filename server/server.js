const app = require('express')();
const http = require('http').Server(app);
const io = require('socket.io')(http);

// Config
const HTTP_PORT = 4000;

// Redis Database
const redis = require('./redis.js');

// Controllers
const userController = require('./userController.js');
const dpDataIngestController = require('./differentialPrivacy/dpDataIngestController.js');

// HTTP
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

  clientSocket.on('signUp', (user) => {
    console.log('hit signUp on server socket:', user);

    userController.signUp(user, clientSocket);
  });
  
  clientSocket.on('find new friend', (username) => {
    console.log('hit find-new-friend on server socket with username', username);
    
    userController.checkUser(username, clientSocket);
  });


  /////////////////////////////////////////////////////////
  // Differential Privacy-related socket routes
  
  clientSocket.on('submitIRRReports', function(IRRReports) {
    console.log('hit submitIRRReports on server socket:', user);
    
    dpDataIngestController.IngestIRRReports(IRRReports)
      .then((replies) => {
        clientSocket.emit(`${IRRReports.IRRs.length} reports successfully aggregated.`);
      })
      .catch(console.error.bind(console));
  });
});

  // clientSocket.on('encryptedChatSent', function(chatMessage) {
  //   console.log('Received ChatMessage from client:', chatMessage)
  //   // Insert msg id -time stamp to ordered list
  //   // Insert msg hash to msgs
  // });

  // clientSocket.on('getfriends', function() {
  //   var dummyFriends = ["Ryan", "Jae", "Michael", "Hannah"]
  //   io.emit(dummyFriends);
  // });
