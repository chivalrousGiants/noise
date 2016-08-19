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
const dh = require('./dhKeyExchange.js');
// HTTP
app.get('/', (req, res) => {
  res.send('Hello world');
});

http.listen(HTTP_PORT, () => {
  console.log(`Listening on port ${HTTP_PORT}`)
});

// Socket.io
io.on('connection', (clientSocket) => {
  console.log('A user connected');

  clientSocket.on('disconnect', () => {
    console.log('A user disconnected');
  });

  /////////////////////////////////////////////////////////
  // Auth socket routes
  clientSocket.on('signIn', (user) => {
    userController.signIn(user, clientSocket);
  });

  clientSocket.on('signUp', (user) => {
    userController.signUp(user, clientSocket);
  });

  /////////////////////////////////////////////////////////
  // User socket routes
  clientSocket.on('find new friend', (username) => {
    userController.checkUser(username, clientSocket);
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

  /////////////////////////////////////////////////////////
  // Diffie Hellman Key Exchange-related socket routes
  clientSocket.on('initial key query', (dhxObject) => {
    dh.undertakeKeyExchange(dhxObject, clientSocket);
  });

  clientSocket.on('check for pending key exchange', (dhxObject) => {
    dh.commenceKeyExchange(dhxObject, clientSocket);
  });

});

