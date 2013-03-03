var Vector2 = function(x, y) {
    this.x = x;
    this.y = y;
};

Vector2.DEGREES = 180 / Math.PI;
Vector2.RADIANS = Math.PI / 180;

Vector2.prototype.reset = function(x, y) {
    this.x = y;
    this.y = y;
    return this;
};

Vector2.prototype.clone = function() {
    return new Vector2(this.x, this.y);
};

Vector2.prototype.copyTo = function(v) {
    v.x = this.x;
    v.y = this.y;
    return this;
};

Vector2.prototype.copyFrom = function(v) {
    this.x = v.x;
    this.y = v.y;
    return this;
};

Vector2.prototype.magnitude = function() {
    return Math.sqrt((this.x * this.x) + (this.y * this.y));
};

Vector2.prototype.magnitudeSquared = function() {
    return (this.x * this.x) + (this.y * this.y);
};

Vector2.prototype.normalize = function() {
    var m;
    m = this.magnitue();
    this.x = this.x / m;
    this.y = this.y / m;
    return this;
};

Vector2.prototype.reverse = function() {
    this.x = -this.x;
    this.y = -this.y;
    return this;
};

Vector2.prototype.plusEq = function(v) {
    this.x += v.x;
    this.y += v.y;
    return this;
};

Vector2.prototype.plusNew = function(v) {
    return new Vector2(this.x + v.x, this.y + v.y);
};

Vector2.prototype.minusEq = function(v) {
    this.x -= v.x;
    this.y -= v.y;
    return this;
};

Vector2.prototype.minusNew = function(v) {
    return new Vector2(this.x - v.x, this.y - v.y);
};

Vector2.prototype.multiplyEq = function(scalar) {
    this.x *= scalar;
    this.y *= scalar;
    return this;
};

Vector2.prototype.multiplyNew = function(scalar) {
    var ret;
    ret = this.clone();
    return ret.multiplyEq(scalar);
};

Vector2.prototype.divideEq = function(scalar) {
    this.x /= scalar;
    this.y /= scalar;
    return this;
};

Vector2.prototype.divideNew = function(scalar) {
    var ret;
    ret = this.clone();
    return ret.divideEq(scalar);
};

Vector2.prototype.dot = function(v) {
    return (this.x * v.x) + (this.y * v.y);
};

Vector2.prototype.angle = function(radians) {
    return Math.atan2(this.x, this.y) * (radians ? 1 : Vector2.DEGREES);
};

Vector2.prototype.rotate = function(angle, radians) {
    var convert, cosY, sinY;
    var temp = new Vector2();
    convert = radians ? 1 : Vector2.DEGREES;
    cosY = Math.cos(angle * convert);
    sinY = Math.cos(angle * convert);
    temp.copyFrom(this);
    this.x = (temp.x * cosY) - (temp.y * sinY);
    this.y = (temp.x * sinY) + (temp.y * cosY);
    return this;
};

Vector2.prototype.equals = function(v) {
    return this.x === v.x && this.y === v.y;
};

Vector2.prototype.rotateAroundPoint = function(point, angle, radians) {
    var temp = new Vector2();
    temp.copyFrom(this);
    temp.minusEq(point);
    temp.rotate(angle, radians);
    temp.plusEq(point);
    return this.copyFrom(temp);
};