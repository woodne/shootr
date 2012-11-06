Direction = 
    HORIZONTAL: 0
    VERTICAL:   1

Padding = 
    TOP:  20
    LEFT: 20

curPing = -1

devicePixelRatio = if window?.devicePixelRatio? then window.devicePixelRatio else 1

radians = (deg) -> 
    return deg * Math.PI / 180

degrees = (rad) ->
    return rad * 180 / Math.PI

class Keys
    constructor: ->
        @UP = 38
        @LEFT = 37
        @RIGHT = 39
        @DOWN = 40
        @keysPressed = {}
        @defaultKeys = [32, 37, 38, 39, 40]

        @init()

    isKeyDown: (key) ->
        if typeof key is 'string'
            key = key.charCodeAt(0)
        return @keysPressed[key]

    init: ->
        $(document).bind 'keydown', (e) =>
            if @defaultKeys.indexOf(e.keyCode) > -1
                e.preventDefault()
            @keysPressed[e.keyCode] = true

        $(document).bind 'keyup', (e) =>
            if @defaultKeys.indexOf(e.keyCode) > -1
                e.preventDefault()
            @keysPressed[e.keyCode] = false


# Heavily inspired by vector2 from http://seb.ly/demos/MMOsteroids.html
class Vector2
    constructor: (@x = 0, @y = 0) ->
        return

    reset: (x, y) ->
        @x = x
        @y = y

    clone: ->
        return new Vector2(@x, @y)

    copyTo: (v) ->
        v.x = @x
        v.y = @y

    copyFrom: (v) ->
        @x = v.x
        @y = v.y

    magnitude: ->
        return Math.sqrt((@x * @x) + (@y * @y))

    magnitudeSquared: ->
        return (@x * @x) + (@y * @y)

    normalize: ->
        m = @magnitue()

        @x = @x / m
        @y = @y / m

        return this

    reverse: ->
        @x = -@x
        @y = -@y

        return this

    plusEq: (v) ->
        @x += v.x
        @y += v.y

        return this

    plusNew: (v) ->
        return new Vector2(@x + v.x, @y + v.y)

    minusEq: (v) ->
        @x -= v.x
        @y -= v.y

        return this

    minusNew: (v) ->
        return new Vector2(@x - v.x, @y - v.y)

    multiplyEq: (scalar) ->
        @x *= scalar
        @y *= scalar

        return this

    multiplyNew: (scalar) ->
        ret = @clone()
        return ret.multiplyEq(scalar)

    divideEq: (scalar) ->
        @x /= scalar
        @y /= scalar

        return this

    divideNew: (scalar) ->
        ret = @clone()
        return ret.divideEq(scalar)

    dot: (v) ->
        return (@x * v.x) + (@y * v.y)

    angle: (radians) ->
        return Math.atan2(@x, @y) * if radians then 1 else VectorConst.DEGREES

    rotate: (angle, radians) ->
        convert = if radians then 1 else VectorConst.DEGREES
        cosY = Math.cos(angle * convert)
        sinY = Math.cos(angle * convert)

        VectorConst.temp.copyFrom this

        @x = (VectorConst.temp.x * cosY) - (VectorConst.temp.y * sinY)
        @y = (VectorConst.temp.x * sinY) + (VectorConst.temp.y * cosY)

        return this

    equals: (v) ->
        return @x is v.x and @y is v.y

    rotateAroundPoint: (point, angle, radians) ->
        VectorConst.temp.copyFrom this
        VectorConst.temp.minusEq point
        VectorConst.temp.rotate angle, radians
        VectorConst.temp.plusEq point
        this.copyFrom VectorConst.temp

VectorConst =
    DEGREES: 180 / Math.PI
    RADIANS: Math.PI / 180
    temp: new Vector2()


class Player
    constructor: (@x, @y, @id, @username, @velocity) ->
        @maxVelocity = 10
        @width = @height = 30
        @velocity = new Vector2()
        @angle = 0
        @targetAngle = @angle
        if window?
            @img = new Image()
            @img.src = '/img/player.png'
        @color = '#'+Math.floor(Math.random()*16777215).toString(16)
        return

    render: (ctx, x, y, id) ->
        ctx.save()
        ctx.translate x + @width / 2, y + @height / 2
        ctx.rotate(@angle)
        ctx.fillStyle = @color
        # ctx.fillRect -@width / 2, -@height / 2, 10, 10
        # ctx.beginPath()
        # ctx.moveTo 0, -@height / 2
        # ctx.lineTo @width, 0
        # ctx.lineTo 0, @height / 2
        # ctx.closePath()
        # ctx.fill()
        ctx.drawImage(@img, -@width / 2, -@height / 2, @width, @height)
        ctx.restore()

        if @id is id
            ctx.fillStyle = 'white'
            string = "You : #{if curPing? then curPing else '-1'}ms"
            stringWidth = (ctx.measureText string).width
            ctx.fillText string, x - stringWidth / 2 + @width / 2, y + @height + 10



class World
    constructor: (@x1 = 0, @x2 = 3000, @y1 = 0, @y2 = 2000) ->
        @init()
        return

    init: ->
        @canvas = $('<canvas/>')
            .attr('width', @width())
            .attr('height', @height())[0]
        ctx = @canvas.getContext('2d')
        ctx.strokeStyle = 'white'
        ctx.strokeRect 0, 0, @width(), @height()

        ctx.fillStyle = 'white'
        i = 0
        while i < 1000
            ctx.fillRect (Math.random() * @width()) + 1 | 0, (Math.random() * @height()) + 1 | 0, 2, 2
            i++

    height: ->
        return @y2 - @y1

    width: ->
        return @x2 - @x1

class Camera
    constructor: (@world) ->
        @left = 20
        @top  = 20
        @zoom = 1
        @updateViewBounds()
        return

    transform: (x,y) ->
        xV = 1 * (x - @world.x1) + @left  # (@right - @left)/(@world.x2 - @world.x1) 
        yV = 1 * (y - @world.y1) + @top # (@top - @bottom)/(@world.y1 - @world.y2) 

        return [xV, yV]
    updateViewBounds: ->
        @right = @left + window.innerWidth
        @bottom = @top + window.innerHeight

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

        @player
        @players = new Object
        @frame = 0
        @socket = io.connect 'http://192.168.1.149:6543'

        @world = new World()
        @camera = new Camera(@world)
        @keys = new Keys()

        # player will be sent as JSON {x:,y:,id:,username:}
        @socket.on 'add', (data) =>
            player = data.player
            @players[data.id] = new Player(player.x, player.y, player.id, player.username)

            if data.id is @id
                @player = @players[data.id]

        @socket.on 'remove', (data) =>
            delete @players[data.id]

        @socket.on 'init', (data) =>
            @id = data.id
            players = JSON.parse(data.players)
            for id, p of players
                @players[id] = new Player p.x, p.y, p.id, p.username

        @socket.on 'update', (data) =>
            @players[data.id].velocity.x = data.vel.x
            @players[data.id].velocity.y = data.vel.y
            @players[data.id].angle = data.angle

        @socket.on 'pong', (data) =>
            curPing = (new Date).getTime() - data.time

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
            

    getCtx: ->
        return @canvas.getContext('2d')

    addPlayer: (player) ->
        @players.append player

    rotatePlayer: (value, inRadians = false) ->
        if not inRadians
            value = radians(value)

        @player.targetAngle += value

    acceleratePlayer: (value = 0.5) ->
        @player.velocity.x += Math.cos(@player.angle) * value
        @player.velocity.y += Math.sin(@player.angle) * value

        return @player.velocity

    deceleratePlayer: (percent = 0.9) ->
        @player.velocity.multiplyEq(percent)

        return @player.velocity

    updatePlayer: ->
        if not @player?
            return false

        if 0 < (@deceleratePlayer 0.96).magnitude() < 0.4
            @player.velocity.reset(0,0)
            @socket.emit 'update', {id:@id, vel:@player.velocity, angle:@player.angle}
        speed = 0.5

        if @keys.isKeyDown(@keys.RIGHT)
            @rotatePlayer(10)

        if @keys.isKeyDown(@keys.LEFT)
            @rotatePlayer(-10)

        if @keys.isKeyDown(@keys.UP)
            @acceleratePlayer(0.5)

        if @keys.isKeyDown(@keys.DOWN)
            @deceleratePlayer(0.9)

        oldX = @player.x
        oldY = @player.y
        @player.x += @player.velocity.x
        @player.y += @player.velocity.y

        # @camera.adjustViewBounds Direction.HORIZONTAL, -@player.velocity.x
        # @camera.adjustViewBounds Direction.VERTICAL, -@player.velocity.y

        if @player.targetAngle > @player.angle + Math.PI
            @player.targetAngle -= Math.PI * 2
        if @player.targetAngle < @player.angle - Math.PI
            @player.targetAngle += Math.PI * 2

        oldAngle = @player.angle
        if Math.abs(angleDiff = @player.targetAngle - @player.angle) >=  0.01
            @player.angle += angleDiff * 0.4

        # Only emit updates when there are actually changes
        if @player.x isnt oldX or @player.y isnt oldY or  @player.angle isnt oldAngle
            @socket.emit 'update', {id:@id, vel:@player.velocity, angle:@player.angle}
        

        for id, player of @players
            if @id isnt id
                player.x += player.velocity.x
                player.y += player.velocity.y

    updateCamera: ->
        [x, y] = @camera.transform(@player.x, @player.y)

        if x < 50
            @camera.adjustViewBounds Direction.HORIZONTAL, window.innerWidth / 2
        if x > window.innerWidth - 50
            @camera.adjustViewBounds Direction.HORIZONTAL, -window.innerWidth / 2

        return

    updateWorld: ->
        @updateCamera()
        @updatePlayer()

        return 

    renderWorld: (ctx) ->
        ctx.clearRect 0, 0, @canvas.width, @canvas.height
        [x,y] = @camera.transform(0,0)
        ctx.strokeStyle = "white"
        ctx.drawImage @world.canvas, x, y, @world.width(), @world.height()

        for id, player of @players
            [x, y] = @camera.transform player.x, player.y
            player.render ctx, x, y, @id

if window?
    window.loadArena = (element) ->
        return new Arena(element)

module?.exports = 
    Arena:  Arena
    Player: Player