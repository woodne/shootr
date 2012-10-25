// Generated by CoffeeScript 1.3.3
(function() {
  var app, express, io, server;

  express = require('express');

  app = express();

  app.get('/', function(req, res) {
    return res.sendfile(__dirname + '/public/index.html');
  });

  app.configure(function() {
    app.use('public/js', express["static"](__dirname + 'public/js'));
    app.use('public/css', express["static"](__dirname + 'public/css'));
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });

  server = require('http').createServer(app);

  io = require('socket.io').listen(server);

  server.listen(6543);

  io.sockets.on('connection', function(socket) {
    return console.log('connection');
  });

}).call(this);