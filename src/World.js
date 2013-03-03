var World = function(x1, y1, x2, y2) {
    this.x1 = x1 != null ? x1 : 0;
    this.x2 = x2 != null ? x2 : 3000;
    this.y1 = y1 != null ? y1 : 0;
    this.y2 = y2 != null ? y2 : 2000;
    this.width = this.x2 - this.x1;
    this.height = this.y2 - this.y1;
    this.init();
    return;
};

World.prototype.init = function() {
    this.canvas = document.createElement('canvas');
    this.canvas.width = this.width;
    this.canvas.height = this.height;

    var ctx = this.canvas.getContext('2d');
    ctx.strokeStyle = 'white';
    ctx.strokeRect(0, 0, this.width(), this.height());
    ctx.fillStyle = 'white';

    for (var i = 0; i < 1000; i++) {
        ctx.fillRect(Math.random() * this.width + 1 | 0, Math.random() * this.height + 1 | 0, 2, 2);
    }

    return;
}