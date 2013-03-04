var Arena = function(element, w, h) {
    this._init(element);
};

Arena.prototype._init = function(element) {
    if (!(typeof io !== "undefined") && io !== null) {
        console.log('socket.io not initialized!');
    }
    if (element === null) {
        throw "Failed to initialize arena";
    }

    this.players = {};
    this.socket = io.connect('http://localhost:6543');
    this.world = new World();
    this.camera = new Camera(this.world);
    this.keys = new Keys();

    this.socket.on('add', this._onAdd.bind(this));
    this.socket.on('remove', this._onRemove.bind(this));
    this.socket.on('init', this._onInit.bind(this));
    this.socket.on('update', this._onUpdate.bind(this));
    this.socket.on('pong', this._onPong.bind(this));

    this.canvas = document.createElement('canvas');
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
    this.canvas.style.backgroundColor = 'black';

    window.onresize = this._onResize.bind(this);

    element.appendChild(this.canvas);
};

Arena.prototype._onResize = function() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
    this.camera.updateViewBounds();
};

Arena.prototype._onAdd = function(data) {
    var player = data.player;
    this.players[data.id] = new Player(player.x, player.y, player.id, player.username);

    this.addToScoreboard(data.id, player);
    if (data.id === this.id) {
        this.player = this.players[data.id];
    }
};

Arena.prototype._onRemove = function(data) {
    delete this.players[data.id];
};

Arena.prototype._onInit = function(data) {
    this.id = data.id;
    players = JSON.parse(data.players);
    for (id in players) {
        p = players[id]
        this.players[id] = new Player(p.x, p.y, p.id, p.username);
        this.addToScoreboard(id, p);
    }
};

Arena.prototype._onUpdate = function(data) {
    for (id in data) {
        p = data[id];
        this.players[id].x = p.pos.x;
        this.players[id].y = p.pos.y;
        this.players[id].angle = p.angle;
    }
};

Arena.prototype._onPong = function(data) {
    this.curPing = (new Date).getTime() - data.time;
};

Arena.prototype.addToScoreboard = function(id, player) {

}

Arena.prototype.getCtx = function() {
    return this.canvas.getContext('2d');
};

Arena.prototype.rotatePlayer = function(value, inRadians) {
    if (inRadians == null) {
        inRadians = false;
    }
    if (!inRadians) {
        value = radians(value);
    }
    return this.player.targetAngle += value % (2 * Math.PI);
};

Arena.prototype.acceleratePlayer = function(value) {
    if (value == null) {
        value = 0.5;
    }
    this.player.velocity.x += Math.cos(this.player.angle) * value;
    this.player.velocity.y += Math.sin(this.player.angle) * value;
    return this.player.velocity;
};

Arena.prototype.deceleratePlayer = function(percent) {
    if (percent == null) {
        percent = 0.9;
    }
    this.player.velocity.multiplyEq(percent);
    return this.player.velocity;
};

Arena.prototype.updatePlayer = function() {
    var _tmp;
    if (0 < (_tmp = this.deceleratePlayer(0.96).magnitude()) && _tmp < 0.4) {
        this.player.velocity.reset(0,0);
        this.socket.emit('update', {
            id: this.id,
            vel: this.player.velocity,
            angle: this.player.angle,
            pos: {
                x: this.player.x,
                y: this.player.y
            }
        });
    }
    var speed = 0.5;

    if (this.keys.isKeyDown(this.keys.RIGHT)) {
        this.rotatePlayer(10);
    }
    if (this.keys.isKeyDown(this.keys.LEFT)) {
        this.rotatePlayer(-10);
    }
    if (this.keys.isKeyDown(this.keys.UP)) {
        this.acceleratePlayer(0.5);
    }
    if (this.keys.isKeyDown(this.keys.DOWN)) {
        this.deceleratePlayer(0.9);
    }

    oldX = this.player.x;
    oldY = this.player.y;
    this.player.x += this.player.velocity.x;
    this.player.y += this.player.velocity.y;
    if (this.player.targetAngle > this.player.angle + Math.PI) {
        this.player.targetAngle -= Math.PI * 2;
    }
    if (this.player.targetAngle < this.player.angle - Math.PI) {
        this.player.targetAngle += Math.PI * 2;
    }
    oldAngle = this.player.angle;
    if (Math.abs(angleDiff = this.player.targetAngle - this.player.angle) >= 0.01) {
        this.player.angle += angleDiff * 0.4;
    }
    if (this.player.x !== oldX || this.player.y !== oldY || this.player.angle !== oldAngle) {
        this.socket.emit('update', {
            id: this.id,
            vel: this.player.velocity,
            angle: this.player.angle,
            pos: {
                x: this.player.x,
                y: this.player.y
            }
        });
    }

    for(id in this.players) {
        var player = this.players[id];
        if (this.id !== id) {
            player.x += player.velocity.x;
            player.y += player.velocity.y;
        }
    }
};

Arena.prototype.updateCamera = function() {
    var pt = this.camera.transform(this.player.x, this.player.y);

    if (pt.x < 50) {
        this.camera.adjustViewBounds(Direction.HORIZONTAL, window.innerWidth / 2);
    }
    if (pt.x > window.innerWidth - 50) {
        this.camera.adjustViewBounds(Direction.HORIZONTAL, -window.innerWidth / 2);
    }
    // if (pt.y < 50) {
    //     this.camera.adjustViewBounds(Direction.VERTICAL, -window.innerHeight / 2);
    // }
    // if (pt.y > window.innerHeight - 50) {
    //     this.camera.adjustViewBounds(Direction.VERTICAL, window.innerHeight / 2);
    // }
};

Arena.prototype.updateWorld = function() {
    this.updateCamera();
    this.updatePlayer();
};

Arena.prototype.renderWorld = function(ctx) {
    ctx.clearRect(0,0, this.canvas.width, this.canvas.height);
    var pt = this.camera.transform(0,0);
    var x = pt[0];
    var y = pt[1];

    ctx.strokeStyle = "white";
    ctx.drawImage(this.world.canvas, x, y, this.world.width, this.world.height);

    for (id in this.players) {
        var player = this.players[id];
        pt = this.camera.transform(player.x, player.y);
        x = pt[0];
        y = pt[1];
        player.render(ctx, x, y, this.id);
    }
};

if (typeof window !== 'undefined') {
    window.loadArena = function(element) {
        return new Arena(element);
    }
}