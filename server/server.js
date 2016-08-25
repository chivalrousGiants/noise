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
const messageController = require('./messageController.js');
const dpDataIngestController = require('./differentialPrivacy/dpDataIngestController.js');
const dpAnalysisController = require('./differentialPrivacy/dpAnalysisController.js');
const dh = require('./dhKeyExchange.js');


// HTTP
app.get('/', (req, res) => {
  res.send('Hello world');
}); 

http.listen(HTTP_PORT, () => {
  //console.log(`Listening on port ${HTTP_PORT}`);
});

// Socket.io

// activeSocketConnections object that keep track of logged-in & active users
const activeSocketConnections = require('./activeSocketConnections');

io.on('connection', (clientSocket) => {
  console.log('A user connected with socket id', clientSocket.id);

  //this is the time when I need to check for the key exchange.

  clientSocket.on('disconnect', () => {

    // if client was a logged-in active user, delete from activeConnections array
    if (`${clientSocket.id}` in activeSocketConnections) {
      delete activeSocketConnections[`${clientSocket.id}`];
    }
    console.log('A user disconnected with socket id', clientSocket.id);
  });


  /////////////////////////////////////////////////////////
  // Auth socket routes
  clientSocket.on('signIn', (user) => {
    // console.log('hit signIn on server socket:', user);

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
  // Message socket routes
  clientSocket.on('initial retrieval of new messages', (userID, friends) => {
    // console.log('hit initial-retrieval-of-new-messages on server socket with userID', userID);
    // console.log('hit initial-retrieval-of-new-messages on server socket with friends', friends);

    messageController.retrieveNewMessages(userID, friends, clientSocket);
  });

  clientSocket.on('send new message', (message) => {
    messageController.handleNewMessage(message, clientSocket);
  });
  /////////////////////////////////////////////////////////
  // Differential Privacy-related socket routes
  clientSocket.on('getDPParams', function() {
    //console.log('getDPParams requested by user', user);

    clientSocket.emit('DPParams', DPParams);
  });


  clientSocket.on('submitIRRReports', function(IRRReports) {
    //console.log('submitIRRReports data received from: ', user);

    dpDataIngestController.IngestIRRReports(IRRReports)
      .then((replies) => {
        clientSocket.emit(`${IRRReports.IRRs.length} reports successfully aggregated.`);
      })
      .catch(console.error.bind(console));
  });

  /////////////////////////////////////////////////////////
  // Diffie Hellman Key Exchange-related socket routes

  clientSocket.on('check for pending key exchange', (dhxObject) => {
    // console.log('hit server check for pending key exchange', dhxObject)
    dh.routeKeyExchange(dhxObject, clientSocket);
  });

  clientSocket.on('commence part 2 key exchange', (dhxObject) => {
    // console.log('hit commencepart 2 key exchange with ', dhxObject);
    dh.performPart2BKeyExchange(dhxObject, clientSocket);
  });

  clientSocket.on('check need to init key exchange', (dhxObject) => {
    dh.quickInitCheck(dhxObject, clientSocket);
  });

  clientSocket.on('initiate key exchange', (dhxObject) => {
    dh.initKeyExchange(dhxObject, clientSocket);
  });

});

//TODO: export clientsocket
