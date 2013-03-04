var Keys = function() {
    this.UP = 38;
    this.LEFT = 37;
    this.RIGHT = 39;
    this.DOWN = 40;
    this.keysPressed = {};
    this.defaultKeys = [32, 37, 38, 39, 40];
    this.init();

}

Keys.prototype.isKeyDown = function(key) {
    if (typeof key === 'string') {
        key = key.charCodeAt(0);
    }
    return this.keysPressed[key];
};

Keys.prototype.init = function() {
    var _this = this;
    document.body.addEventListener('keydown', function(e) {
        if (_this.defaultKeys.indexOf(e.keyCode) > -1) {
            e.preventDefault();
        }
        _this.keysPressed[e.keyCode] = true;
    });
    document.body.addEventListener('keyup', function(e) {
        if (_this.defaultKeys.indexOf(e.keyCode) > -1) {
            e.preventDefault();
        }
        _this.keysPressed[e.keyCode] = false;
    });
}