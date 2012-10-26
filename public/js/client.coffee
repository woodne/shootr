socket = null

class Player
    constructor: (@x, @y, @id, @username) ->
        @color = "red" 
        return

class Arena
    constructor: (element, w, h) ->
        @_init(element)

    _init: (element) ->
        if not io?
            console.log 'Socket.io not initialized!'
        if not element?
            throw "Failed to initialize arena"

        @players = []

        socket = io.connect 'http://localhost:6543'

        # player will be sent as JSON {x:,y:,id:,username:}
        socket.on 'add', (data) =>
            @players.push new Player(data.x, data.y, data.id, data.username)

        socket.on 'init', (data) =>
            for p in data.players
                @players.push new Player p.x, p.y, p.id, p.username

        socket.on 'update', (data) =>
            return

        @canvasSelector = $('<canvas/>')
            .attr('width', window.innerWidth)
            .attr('height', window.innerHeight)
            .css('background-color','black  ')

        @canvas = @canvasSelector[0]

        $(window).resize( =>
            @canvas.width = window.innerWidth
            @canvas.height = window.innerHeight
        )

        element.append(@canvas)

        

        $(document).bind 'keydown', 'left', -> thisPlayer.x -= 1
        $(document).bind 'keydown', 'right', -> thisPlayer.x += 1

    getCtx: ->
        return @canvas.getContext('2d')

    addPlayer: (player) ->
        @players.append player

    renderWorld: (ctx) ->
        ctx.clearRect 0, 0, @canvas.width, @canvas.height
        for player in @players
            ctx.fillStyle = player.color
            ctx.fillRect(player.x, player.x, 10, 10)

if window?
    window.loadArena = (element) ->
        return new Arena(element)

module.exports = 
    Arena:  Arena
    Player: Player