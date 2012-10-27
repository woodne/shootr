socket = null

class Player
    constructor: (@x, @y, @id, @username) ->
        @color = '#'+Math.floor(Math.random()*16777215).toString(16)
        return

class Arena
    constructor: (element, w, h) ->
        @_init(element)

    _init: (element) ->
        if not io?
            console.log 'Socket.io not initialized!'
        if not element?
            throw "Failed to initialize arena"

        @players = new Object

        socket = io.connect 'http://localhost:6543'

        # player will be sent as JSON {x:,y:,id:,username:}
        socket.on 'add', (data) =>
            player = data.player
            @players[data.id] = new Player(player.x, player.y, player.id, player.username)

        socket.on 'init', (data) =>
            @id = data.id
            players = JSON.parse(data.players)
            for id, p of players
                @players[id] = new Player p.x, p.y, p.id, p.username

        socket.on 'update', (data) =>
            @players[data.id].x += data.deltaX
            @players[data.id].y += data.deltaY

        @canvasSelector = $('<canvas/>')
            .attr('width', window.innerWidth)
            .attr('height', window.innerHeight)
            .css('background-color','black  ')

        @canvas = @canvasSelector[0]

        $(window).resize( =>
            @canvas.width = window.innerWidth
            @canvas.height = window.innerHeight
        )

        $(window).unload ->
            socket.emit 'disconnect'
        element.append(@canvas)

        

        $(document).bind 'keydown', (event) =>
            switch event.which
                when 37
                    event.preventDefault()
                    socket.emit 'move', {direction:"left", id:@id}
                when 38
                    event.preventDefault()
                    socket.emit 'move', {direction:"up", id:@id}
                when 39
                    event.preventDefault()
                    socket.emit 'move', {direction:"right", id:@id}
                when 40
                    event.preventDefault()
                    socket.emit 'move', {direction:"down", id:@id}
            

            

    getCtx: ->
        return @canvas.getContext('2d')

    addPlayer: (player) ->
        @players.append player

    renderWorld: (ctx) ->
        ctx.clearRect 0, 0, @canvas.width, @canvas.height
        for id, player of @players
            if @id is id
                ctx.fillStyle = 'white'
                ctx.fillText 'You', player.x + 10, player.y + 10
            ctx.fillStyle = player.color
            ctx.fillRect(player.x, player.y, 10, 10)

if window?
    window.loadArena = (element) ->
        return new Arena(element)

module?.exports = 
    Arena:  Arena
    Player: Player