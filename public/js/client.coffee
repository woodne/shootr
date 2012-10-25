class Player
    constructor: (@x, @y) ->
        @color = "red"
        return

class Arena
    constructor: (element, w, h) ->
        @_init(element)

    _init: (element) ->
        if not element?
            throw "Failed to initialize arena"

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

        @players = [new Player(50,50)]

    getCtx: ->
        return @canvas.getContext('2d')

    addPlayer: (player) ->
        @players.append player

    renderWorld: (ctx) ->
        ctx.clearRect 0, 0, @canvas.width, @canvas.height
        @updateWorld()
        for player in @players
            ctx.fillStyle = player.color
            ctx.fillRect(player.x, player.x, 10, 10)

    updateWorld: ->
        for player in @players
            player.x += 1
            player.y += 1
            if player.x > 100
                player.x = 0
            if player.y > 100
                player.y = 0

window.loadArena = (element) ->
    return new Arena(element)