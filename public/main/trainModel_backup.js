let state = 'waiting';
let balls = [];
let socket;
let brain;
let predictions;


function setup() {
    createCanvas(innerWidth, innerHeight);
    strokeWeight(0.1)
    background('black');

    let options = {
        inputs:['x', 'y'],
        outputs:['pitch'],
        task: 'regression',
        debug: 'true'
    }

    brain = ml5.neuralNetwork(options)

    brain.loadData('../data/ball-data-pitch.json', dataLoaded)

    socket = io.connect('http://192.168.1.24:8000/')

}

function dataLoaded() {
    console.log('data loaded')
    console.log(brain.data)
    let data = brain.data.data.raw
    state = 'training'

    console.log('normalizing data')
    brain.normalizeData();

    console.log('starting training')

    const trainingOptions = {
        epochs:20
    }

    brain.train(trainingOptions, whileTraining, finished)

    data.forEach(items => {
        let inputs = items.xs
        fill('teal')
        noStroke()
        ellipse(inputs.x, inputs.y, 24/4)
    })

}

function draw() {
    frameRate(30)
    prediction()
    stroke('black')
}

function prediction(){
    if (mouseIsPressed && state == 'prediction') {
        stroke('grey')
        line(mouseX, 0, mouseX, innerWidth)
        line(0, mouseY, innerHeight, mouseY)
        brain.predict([mouseX, mouseY], handleResults)
        socket.emit('predictions', predictions)
        console.log(predictions)
    }
}

function whileTraining(epoch, loss) {
    console.log(`epoch:${epoch}, loss:${loss}`)
}

function finished() {
    console.log('training finished!')
    state = 'prediction'
    //brain.save()
    brain.predict([Math.random(), Math.random()], handleResults)
}

function handleResults(error, results) {
    if (error) {
        console.log(error)
        return
    } else {
        console.log(`Prediction: ${results[0].label} is ${results[0].value}`)

        predictions = {
            label: results[0].label,
            value: results[0].value
        }
    }
}
