var app = require('express')();
var http = require('http').Server(app);

app.get('/', function(request, response) {
  response.send('hello world');
});

http.listen(4000, function() {
  console.log('listening')
})
