const app = require('express')();
const http = require('http').Server(app);
const io = require('socket.io')(http);

// Config
const HTTP_PORT = 4000;

const DPParams = require('./differentialPrivacy/dpParams');

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
  console.log(`Listening on port ${HTTP_PORT}`);
});

// Socket.io
io.on('connection', (clientSocket) => {
  console.log('A user connected with socket id', clientSocket.id);

  clientSocket.on('disconnect', () => {
    console.log('A user disconnected with socket id', clientSocket.id);
  });

  /////////////////////////////////////////////////////////
  // Auth socket routes
  clientSocket.on('signIn', (user) => {
    console.log('hit signIn on server socket:', user);

    userController.signIn(user, clientSocket);
  });

  clientSocket.on('signUp', (user) => {
    console.log('hit signUp on server socket:', user);

    userController.signUp(user, clientSocket);
  });

  /////////////////////////////////////////////////////////
  // User socket routes
  clientSocket.on('find new friend', (username) => {
    console.log('hit find-new-friend on server socket with username', username);

    userController.checkUser(username, clientSocket);
  });

  clientSocket.on('initial loading of new messages', (friends) => {
    console.log('hit initial-loading-of-new-messages on server socket with friends', friends);

    messageController.loadNewMessages(friends, clientSocket);
  });

  /////////////////////////////////////////////////////////
  // Differential Privacy-related socket routes
  clientSocket.on('getDPParams', function() {
    console.log('getDPParams requested by user', user);

    clientSocket.emit('DPParams', DPParams);
  });

  clientSocket.on('submitIRRReports', function(IRRReports) {
    console.log('submitIRRReports data received from: ', user);

    dpDataIngestController.IngestIRRReports(IRRReports)
      .then((replies) => {
        clientSocket.emit(`${IRRReports.IRRs.length} reports successfully aggregated.`);
      })
      .catch(console.error.bind(console));
  });

});

