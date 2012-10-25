express= require('express')
app    = express()

app.get('/', (req, res) ->
    res.sendfile __dirname + '/public/index.html'
    )

app.configure ->
    app.use 'public/js', express.static __dirname + 'public/js'
    app.use 'public/css', express.static __dirname + 'public/css'
    app.use express.errorHandler({dumpExceptions: true, showStack: true})

server = require('http').createServer(app)
io     = require('socket.io').listen(server)


server.listen 6543
io.sockets.on 'connection', (socket) ->
    console.log 'connection'
#init()
