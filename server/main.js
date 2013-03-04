express = require('express');
app     = express();
Player  = require('../client/Player.js');
Vector2 = require('../client/Vector2.js');
path    = require('path');

app.get('/', function(req, res) {
    res.sendfile(path.resolve(__dirname + '/../public/index.html'));
});

app.configure(function() {
    app.use(express.static(path.resolve(__dirname + '/../public/')));
    app.use(express.static(__dirname + '/'));

    app.use(express.errorHandler({
        dumpExceptions: true,
        showStack: true
    }))
});

server = require('http').createServer(app);
io     = require('socket.io').listen(server);

players = {};

server.listen(6543);

io.sockets.on('connection', function(socket) {
    socket.emit('init', {players: JSON.stringify(players), id:socket.id});
    newPlayer = new Player((Math.random() * 500)+1 | 0, (Math.random() * 500)+1 | 0, socket.id, 'woodne', socket.id);
    io.sockets.emit('add', {player: newPlayer, id: socket.id});
    players[socket.id] = newPlayer;

    socket.on('disconnect', function() {
        delete players[socket.id];
        io.sockets.emit('remove', {id: socket.id});
    });

    socket.on('ping', function(data) {
        return socket.emit('pong', {
            time: data.time
        });
    });

    socket.on('update', function(data) {
        var player;
        player = players[data.id];
        player.velocity = data.vel;
        player.x = data.pos.x;
        player.y = data.pos.y;
        return player.angle = data.angle;
    });
});

var sendStateToClients = function() {
    data = {};
    for (id in players) {
        p = players[id];
        data[id] = {angle: p.angle, vel: p.velocity, pos: {x:p.x, y:p.y}}
    }

    io.sockets.emit('update', data);
}

setInterval(sendStateToClients, 1000 / 30);