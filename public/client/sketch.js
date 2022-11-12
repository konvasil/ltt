let input,
    button,
    data,
    socket,
    ball,
    id = ' ',
    balls = [],
    angle = 0,
    circleSize = 0,
    t = 0,
    x1, y1, x2, y2, ballsDistance;

function setup() {
    background(0);
    createCanvas(displayWidth, displayHeight);
    textAlign(CENTER);
    textSize(50)

    socket = io()

    ball = new Ball(canvas.width/2, canvas.height/2, random(14, 24), random(14, 24))

    data = {
        x: ball.pos.x,
        y: ball.pos.y,
        id: ball.id,
        r: ball.r
    };

    socket.emit('start', data)

    socket.on('heartbeat', (data) => {balls = data;})

}

function windowResized() {
    resizeCanvas(windowWidth, windowHeight)
}

function draw() {
    background(0)
    stroke(255)
    noFill()
    ball.constrain()
    circleSize += 1
    if (circleSize > 100){
        circleSize = 0
    }
    for (let i =  balls.length -1; i >= 0; i--) {
        id = balls[i].id
        if (id.substring(2, id.length) !== socket.id) { //now socket.id == username coming from server, and front end.
            fill('teal')
            ellipse(balls[i].x, balls[i].y, balls[i].r/2, balls[i].r/2)
            noFill()
            textAlign(CENTER)
            textSize(11)
            strokeWeight(0.7)
            text(id, balls[i].id, balls[i].x, balls[i].y, balls[i].r)
        }
    }

    text("ID: " + socket.id, 135, 25)
    text(["X: " + ball.pos.x.toFixed(2) + "\n" + "Y: "+ ball.pos.y.toFixed(2)], 30 + 100, 50)

    if(mouseIsPressed == true) {
        ball.update()
    } else {
        ball.accelBall()
    }

    data = {
        x: ball.pos.x,
        y: ball.pos.y,
        r: ball.r
    }

    socket.emit('update', data)

    for (let i = 0; i < balls.length; i++){
        let x1 = balls[i].x
        let y1 = balls[i].y

        for (let j = 0; j < balls.length; j++){
            let x2 = balls[j].x
            let y2 = balls[j].y

            ballsDistance = dist(x1, y1, x2, y2)

            if(ballsDistance <= 120.0){
                let xnoise1 = width / 2 * noise(t + 35)
                let ynoise1 = y1 * noise(t + 75)
                let xnoise2 = width / 2 * noise(t + 35)
                let ynoise2 = y2 * noise(t + 75)
                t += 0.0005

                line(x1, y1, x2, y2)
                ellipse(balls[i].x, balls[i].y, circleSize, circleSize)
            }
        }
    }
}
