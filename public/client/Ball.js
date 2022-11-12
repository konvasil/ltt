function Ball(x, y, r) {
    this.pos = createVector(x, y)
    this.velocity = createVector();
    this.acceleration = createVector();
    this.speed = 5;
    this.r = r

    this.vx = 0;
    this.vy = 0;
    this.ax = 0;
    this.ay = 0;

    this.update = function() {
        let mouse = createVector(mouseX, mouseY);
        this.acceleration = p5.Vector.sub(mouse, this.pos);
        //set magnitude of acceleration
        this.acceleration.setMag(0.25);
        this.velocity.add(this.acceleration);
        this.velocity.limit(this.speed);
        this.pos.add(this.velocity);
    }

    this.accelBall = function() {

        let vMultiplier = 0.007;
        let bMultiplier = 0.6;
        let vx = 0;
        let vy = 0;

        let accelSensor = createVector(accelerationX, accelerationY)

        vx = vx + accelSensor.y;
        vy = vy + accelSensor.x;

        this.pos.y = this.pos.y + vy * vMultiplier;
        this.pos.x = this.pos.x + vx * vMultiplier;

        this.acceleration = p5.Vector.sub(accelSensor, this.pos)


        // Bounce when touch the edge of the canvas
        if (this.pos.x < 0) {
            this.pos.x = 0;
            vx = -vx * bMultiplier;
        }
        if (this.pos.y < 0) {
            this.pos.y = 0;
            vy = -vy * bMultiplier;
        }
        if (this.pos.x > width - 20) {
            this.pos.x = width - 20;
            vx = -vx * bMultiplier;
        }
        if (this.pos.y > height - 20) {
            this.pos.y = height - 20;
            vy = -vy * bMultiplier;
        }
    }

    this.constrain = function() {
        this.pos.x = constrain(this.pos.x, -width, width);
        this.pos.y = constrain(this.pos.y, -height, height);
    }
}
