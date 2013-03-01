express = require('express')
app     = express()
Client  = require('./client.js')
Player  = Client.Player
path    = require('path')

app.get('/', (req, res) ->
    res.sendfile path.resolve(__dirname + '/../public/index.html')
    )

app.configure ->
    app.use express.static path.resolve(__dirname + '/../public')
    app.use express.static __dirname + '/'

    app.use express.errorHandler({dumpExceptions: true, showStack: true})

server = require('http').createServer(app)
io     = require('socket.io').listen(server)

players = new Object()


server.listen 6543

io.sockets.on 'connection', (socket) -> 
    socket.emit 'init', {players:JSON.stringify(players), id:socket.id}
    newPlayer = new Player (Math.random() * 500)+1 | 0, (Math.random() * 500)+1 | 0, socket.id, 'woodne', socket.id
    io.sockets.emit 'add', {player: newPlayer, id:socket.id}
    players[socket.id] = newPlayer

    socket.on 'disconnect',  ->
        delete players[socket.id]
        io.sockets.emit 'remove', {id:socket.id}

    socket.on 'ping', (data) ->
        socket.emit 'pong', {time: data.time}

    socket.on 'update', (data) ->
        player = players[data.id]
        player.velocity = data.vel
        player.x = data.pos.x
        player.y = data.pos.y
        player.angle = data.angle

sendStateToClients = ->
    data = new Object()
    for id, p of players
        data[id] = {angle: p.angle, vel: p.velocity, pos: {x:p.x, y:p.y}}

    io.sockets.emit 'update', data

setInterval(sendStateToClients, 1000 / 30)