var Player = function(x, y, id, username, velocity) {
    this.x = x;
    this.y = y;
    this.id = id;
    this.username = username;
    this.velocity = velocity;
    this.maxVelocity = 10;
    this.width = this.height = 30;
    this.velocity = new Vector2();
    this.angle = 0;
    this.targetAngle = this.angle;
    this.kills = 0;
    if (typeof window !== "undefined" && window !== null) {
        this.img = new Image();
        this.img.src = '/img/player.png';
    }
    this.color = '#' + Math.floor(Math.random() * 16777215).toString(16);
    return;   
}

Player.prototype.render = function(ctx, x, y, id) {
    var string, stringWidth;
    ctx.save();
    ctx.translate(x + this.width / 2, y + this.height / 2);
    ctx.rotate(this.angle);
    ctx.fillStyle = this.color;
    ctx.drawImage(this.img, -this.width / 2, -this.height / 2, this.width, this.height);
    ctx.restore();
    if (this.id === id) {
        ctx.fillStyle = 'white';
        string = "You : " + (curPing != null ? curPing : '-1') + "ms";
        stringWidth = (ctx.measureText(string)).width;
        ctx.fillText(string, x - stringWidth / 2 + this.width / 2, y + this.height + 10);
    }   
}

