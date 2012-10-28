Direction = 
    HORIZONTAL: 0
    VERTICAL:   1

Padding = 
    TOP:  20
    LEFT: 20

class Player
    constructor: (@x, @y, @id, @username, @rotation = 0, @velocity = {x:0, y:0}) ->
        @maxVelocity = 10
        @color = '#'+Math.floor(Math.random()*16777215).toString(16)
        return

class World
    constructor: (@x1 = 0, @x2 = 3000, @y1 = 0, @y2 = 2000) ->
        return

    height: ->
        return @y2 - @y1

    width: ->
        return @x2 - @x1

class Camera
    constructor: (@world) ->
        @left = 20
        @top  = 20
        @updateViewBounds()
        return

    transform: (x,y) ->
        xV = (@right - @left)/(@world.x2 - @world.x1) * (x - @world.x1) + @left
        yV = (@top - @bottom)/(@world.y1 - @world.y2) * (y - @world.y1) + @top

        return [xV, yV]
    updateViewBounds: ->
        @right = @left + window.innerWidth
        @bottom = @top + window.innerHeight
        console.log [@left, @right, @top, @bottom]

    getViewBounds: ->
        return [@left, @right, @top, @bottom]

    adjustViewBounds: (direction, delta) ->
        switch direction
            when Direction.VERTICAL
                @top += delta
                @bottom += delta
            when Direction.HORIZONTAL
                @left += delta
                @right += delta

class Arena
    constructor: (element, w, h) ->
        @_init(element)

    _init: (element) ->
        if not io?
            console.log '@socket.io not initialized!'
        if not element?
            throw "Failed to initialize arena"

        @players = new Object
        @frame = 0
        @socket = io.connect 'http://localhost:6543'

        @world = new World
        @camera = new Camera(@world)

        # player will be sent as JSON {x:,y:,id:,username:}
        @socket.on 'add', (data) =>
            player = data.player
            @players[data.id] = new Player(player.x, player.y, player.id, player.username)

        @socket.on 'remove', (data) =>
            delete @players[data.id]

        @socket.on 'init', (data) =>
            @id = data.id
            players = JSON.parse(data.players)
            for id, p of players
                @players[id] = new Player p.x, p.y, p.id, p.username

        @socket.on 'update', (data) =>
            @players[data.id].x += data.deltaX
            @players[data.id].y += data.deltaY

        @socket.on 'pong', (data) =>
            @curPing = (new Date).getTime() - data.time

        @canvasSelector = $('<canvas/>')
            .attr('width', window.innerWidth)
            .attr('height', window.innerHeight)
            .css('background-color','black  ')

        @canvas = @canvasSelector[0]

        $(window).resize( =>
            @canvas.width = window.innerWidth
            @canvas.height = window.innerHeight
            @camera.updateViewBounds()
        )

        element.append(@canvas)

        # ping
        window.setInterval ( =>
            @socket.emit 'ping', {time: (new Date).getTime()}), 3000

        $(document).bind 'keydown', (event) =>
            switch event.which
                when 37
                    event.preventDefault()
                    @socket.emit 'move', {direction:"left", id:@id}
                when 38
                    event.preventDefault()
                    @socket.emit 'move', {direction:"up", id:@id}
                when 39
                    event.preventDefault()
                    @socket.emit 'move', {direction:"right", id:@id}
                when 40
                    event.preventDefault()
                    @socket.emit 'move', {direction:"down", id:@id}
                when 65 #a
                    @camera.adjustViewBounds(Direction.HORIZONTAL, -5)
                when 87 #w
                    @camera.adjustViewBounds(Direction.VERTICAL, -5)
                when 68 #d
                    @camera.adjustViewBounds(Direction.HORIZONTAL, 5)
                when 83 #s
                    @camera.adjustViewBounds(Direction.VERTICAL, 5)


            

    getCtx: ->
        return @canvas.getContext('2d')

    addPlayer: (player) ->
        @players.append player

    updateWorld: ->
        return 

    renderWorld: (ctx) ->
        ctx.clearRect 0, 0, @canvas.width, @canvas.height
        [x,y] = @camera.transform(0,0)
        ctx.strokeStyle = "white"
        ctx.strokeRect x, y, @world.width(), @world.height()

        for id, player of @players
            [x, y] = @camera.transform player.x, player.y

            if @id is id
                ctx.fillStyle = 'white'
                ctx.fillText "You : #{if @curPing? then @curPing else '-1'}ms", x, y + 20
            ctx.fillStyle = player.color
            ctx.fillRect(x, y, 10, 10)

if window?
    window.loadArena = (element) ->
        return new Arena(element)

module?.exports = 
    Arena:  Arena
    Player: Player