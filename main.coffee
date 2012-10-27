express = require('express')
app     = express()
Client  = require('./public/js/client.js')
Player  = Client.Player

class World
    constructor: ->
        return

app.get('/', (req, res) ->
    res.sendfile __dirname + '/public/index.html'
    )

app.configure ->
    app.use express.static __dirname + '/public'
    # app.use 'public/css', express.static __dirname + '/public/css'
    app.use express.errorHandler({dumpExceptions: true, showStack: true})

server = require('http').createServer(app)
io     = require('socket.io').listen(server)

players = new Object


server.listen 6543
io.sockets.on 'connection', (socket) -> 
    console.log JSON.stringify(players)
    socket.emit 'init', {players:JSON.stringify(players), id:socket.id}
    newPlayer = new Player (Math.random() * 500)+1 | 0, (Math.random() * 500)+1 | 0, socket.id, 'woodne', socket.id
    io.sockets.emit 'add', {player: newPlayer, id:socket.id}
    players[socket.id] = newPlayer

    socket.on 'disconnect', (socket) ->
        console.log socket.id

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
        console.log players[data.id]
        
