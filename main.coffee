express = require('express')
app     = express()
Client  = require('./public/js/client.js')
Player  = Client.Player

app.get('/', (req, res) ->
    res.sendfile __dirname + '/public/index.html'
    )

app.configure ->
    app.use express.static __dirname + '/public'
    # app.use 'public/css', express.static __dirname + '/public/css'
    app.use express.errorHandler({dumpExceptions: true, showStack: true})

server = require('http').createServer(app)
io     = require('socket.io').listen(server)

players = []

server.listen 6543
io.sockets.on 'connection', (socket) ->
    socket.emit 'init', {players:players}
    newPlayer = new Player (Math.random() * 500)+1, (Math.random() * 500)+1, 1, 'woodne'
    io.sockets.emit 'add', {player: newPlayer}
    players.push newPlayer


