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