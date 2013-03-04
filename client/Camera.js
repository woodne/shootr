var Camera = function(world) {
    this.world = world;
    this.left = 20;
    this.top = 20;
    this.zoom = 1;
    this.updateViewBounds();
    return;
}

Camera.prototype.transform = function(x, y) {
    var xV, yV;
    xV = 1 * (x - this.world.x1) + this.left;
    yV = 1 * (y - this.world.y1) + this.top;
    return [xV, yV];
};

Camera.prototype.updateViewBounds = function() {
    this.right = this.left + window.innerWidth;
    this.bottom = this.top + window.innerHeight;
};

Camera.prototype.getViewBounds = function() {
    return [this.left, this.right, this.top, this.bottom];
};

Camera.prototype.adjustViewBounds = function(direction, delta) {
    switch (direction) {
        case Direction.VERTICAL:
            this.top += delta;
            this.bottom += delta;
            break;
        case Direction.HORIZONTAL:
            this.left += delta;
            this.right += delta;
            break;
    }
};