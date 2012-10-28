express = require('express')
app     = express()
Client  = require('./client.js')
Player  = Client.Player
path    = require('path')

class World
    constructor: (@w = 3000, @h = 2000) ->

        return

app.get('/', (req, res) ->
    res.sendfile path.resolve(__dirname + '/../public/index.html')
    )

app.configure ->
    app.use express.static path.resolve(__dirname + '/../public')
    app.use express.static __dirname + '/'

    app.use express.errorHandler({dumpExceptions: true, showStack: true})

server = require('http').createServer(app)
io     = require('socket.io').listen(server)

players = new Object


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

    socket.on 'move', (data) ->
        deltaX = deltaY = 0
        switch data.direction
            when 'left'
                players[data.id].x -= 5
                deltaX = -5
            when 'up'
                players[data.id].y -= 5
                deltaY = -5
            when 'down'
                players[data.id].y += 5
                deltaY = 5
            when 'right'
                players[data.id].x += 5
                deltaX = 5
        io.sockets.emit 'update', {id:data.id, deltaY:deltaY, deltaX:deltaX}
        
