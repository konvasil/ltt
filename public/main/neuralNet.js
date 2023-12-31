let state = 'waiting', predictionMode = 'automatic', xoff = 0.0, speedCursor = 0.001, speedSlider, modelInfo, socket, brain, cursor = {}, button, inputs = [], oscObjMsg = {}, msg = {}, trainData = [], canvas, t = 0, noiseScale = 0.02, noiseVal = 0.0;
let angle = 0.0;
let jitter = 0.0;

let tempo = 10;

let freqs = {
    low: 80,
    lowmid: 120,
    mid: 220,
    high: 660
}

const options = {
    task: 'regression',
    debug: true
}

const trainingOptions = {
    epochs: 10,
    batchSize: 12
} 

function setup(){
    //canvas = createCanvas(windowWidth/2, windowHeight/3, WEBGL)
    canvas = createCanvas(windowWidth, windowHeight/3)
    noStroke()
    //fill(255);
    //Draw the rectangle from the center and it will also be the
    // Move the canvas so it’s inside our <div id="sketch-holder">.
    canvas.parent('sketch-holder')
    //noFill()
    t = 0
    tempo = 120

    colorMode(HSB, 255);

    let modelInfo = {
        model: '../model/model.json',
        metadata: '../model/model_meta.json',
        weights: '../model/model.weights.bin'
    }

    brain = ml5.neuralNetwork(options)
    //brain.load(modelInfo, modelLoaded)
    //Host IP address

    //socket = io()

    let OlderUsers = 0;
    socket.on('newclientconnect', (users) => {
        tempo = users.guests
        if(users.guests !== NaN){
            console.log(users.description, users.guests)
            //Tone.Transport.bpm.value = users.guests * (2 * 60)
            tempoChange(users.guests * (2*25))
        }
    })

    //receive input data from ball clients
    socket.on('heartbeat', (data) => {
        if(state == 'collecting'){
            data.forEach(items => {

                let inputs = {
                    x: items.x,
                    y: items.y
                }

                let target = {
                    freq: freqs[items.id]
                }

                brain.addData(inputs, target)

            })

            trainData.push(data)
            console.log(data)
            //collectData()
        } /*else if (state == 'waiting' || state != 'prediction') {
          // drawBezier(data)
          }*/
    })
}

/*function collectData(data) {
  for(let i = 0; i < trainData.length; i +=1){
  trainData[i].forEach(items => {
  let target = {
  freq: freqs[items.id]
  }
  brain.addData([items.x, items.y], target)
  })
  }
  }*/

/*function windowResized() {
  resizeCanvas(width, height)
  }*/

function sleep(ms){
    return new Promise(resolve => setTimeout(resolve, ms))
}

async function keyPressed(){
    if (key == 'p') {
        saveCanvas(canvas, 'VizData-lickTheToad', 'jpg');
    }

    if (key == 's') {
        brain.saveData('data')
    }
    else if (key == 'c') {

        //alert('collecting data!')
        await sleep(1000)
        state = 'collecting'
        console.log('collecting...')
        await sleep(3000) // duration of collecting data
        console.log('done collecting!')
        state = 'waiting'

    }

    if(key == 't' && state == 'waiting') {
        state = 'training'
        console.log('training started')
        brain.normalizeData()
        brain.train(trainingOptions, whileTraining, finished)
    }

    //load data from GitHub
    if(key == 'f' && state == 'waiting') {
        fetch('https://raw.githubusercontent.com/KonVas/lick-the-toad/main/public/main/data.json', {
            mode: 'no-cors',
            credentials: 'same-origin'
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error("HTTP error " + response.status);
                }
                return response.json()
            })
            .then(data => {
                console.log(data)
                //brain.loadData(data, dataLoaded)
            })
            .catch(error => console.log(error))
    }

    //load file from data folder
    if(key == 'd' && state == 'waiting') {
        brain.loadData('data.json', dataLoaded)
    }

    //save model in model folder
    if(key == 'm' && state == 'prediction') {
        brain.save('model')
    }

    if(key == 'n' && predictionMode == 'automatic') {
        predictionMode = 'manual'
        document.getElementById("predicMode-message").innerHTML = "Prediction: " + predictionMode
    } else if (predictionMode == 'manual'){
        predictionMode = 'automatic'
        document.getElementById("predicMode-message").innerHTML = "Prediction: " + predictionMode
    }
}

function dataLoaded(){
    console.log('data loaded')

    state = 'training'

    console.log('starting training')
    //console.log(trainingOptions)

    brain.normalizeData()
    brain.train(trainingOptions, whileTraining, finished)
}

function modelLoaded() {
    console.log('model loaded')
    //state = 'prediction' //comment for training the model.
}


function whileTraining(epoch, loss){
    console.log(`epoch:${epoch}, loss:${Object.entries(loss)}...🍔`)
}

function finished () {
    console.log('training finished!')
    state = 'prediction'
    inputs.push(brain.data.training);
    brain.predict([mouseX, mouseY], handleResults)
    //brain.neuralNetwork.model.layers[0].getWeights()[0].print()
}

//prediction is using a cursor moved by Perlin noise generator in automatic mode.

function drawCursor() {

    if(predictionMode == 'automatic'){
        fill(255)
        stroke(255, 18)
        xoff = xoff + speedCursor / 2
        cursor = {
            x:noise(xoff) * width,
            y:noise(xoff) * height
        }
        fill(255)
        stroke(255, 18)
        text("Freq Out: " + msg.freq.toFixed(2), cursor.x, cursor.y)
        line(cursor.x, 0, cursor.x, height)
        line(0, cursor.y, width, cursor.y)

        brain.predict(cursor, handleResults)

    } else if (predictionMode == 'manual'){
        cursor = {
            x:mouseX,
            y:mouseY
        }

        fill(255)
        stroke(255, 18)
        text("Freq Out: " + msg.freq, cursor.x, cursor.y)
        line(cursor.x, 0, cursor.x, height)
        line(0, cursor.y, width, cursor.y)
    }
}

/*function drawCords(){
  fill(255)
  stroke(255, 18)
  text("Prediction Breakpoints: " + brain.data.training.length, width / 2 - 250, height /2 - 125)
  }*/

/*function drawBezier() {
  fill(255)
  let data = brain.data.training;
  let x3 = width * noise(t + 35)
  let y3 = height * noise(t + 75)
  t += 0.005

  if(data.length > 0 || data !== 'undefined') {
  for (let i = 0; i < data.length; i += 1){
  let x1 = map(data[i].xs.x, 0, 1, 0, width/2)
  let y1 = map(data[i].xs.y, 0, 1, 0, height/2)
  let noiseVal = noise((x1 + i) * noiseScale, y1 * noiseScale)

  for (let j = 0; j < data.length; j+=1){
  let x2 = map(data[j].xs.x, 0, 1, 0, width/2)
  let y2 = map(data[j].xs.y, 0, 1, 0, height/2)
  stroke(noiseVal * 255, 18)
  bezier(x1, y1, x2, y2, x3, y3)

  }
  }

  if (frameCount % 500 == 0){
  background(255)
  }
  }
  }*/

/*function drawTrainedData() {
  brain.data.training.forEach(items => {
  let x = map(items.xs.x, 0, 1, 0, width)
  let y = map(items.xs.y, 0, 1, 0, height)
  stroke(255, 18);
  noFill();
  fill('teal');
  ellipse(x, y, 6, 6) //draw balls when training is done
  })
  }*/

function drawTrainedData () {

    let x3 = width * noise(t + 35)
    let y3 = height * noise(t + 75)
    t += 0.005
    
    fill('teal')
    stroke(255, 18)

    let data = brain.data.training;
    
    let radius = 16

    for(let i=0; i<data.length; i++){
        let x1 = map(data[i].xs.x, 0, 1, 0, width-radius)
        let y1 = map(data[i].xs.y, 0, 1, 0, height-radius)
        //translate(canvasWidth/4, canvasHeight/3)
        translate(p5.Vector.fromAngle(millis() / 2000, 80));
        //rotateZ(millis() / 2000);
        let spots = ellipse(x1-radius, y1-radius, radius);
        text(JSON.stringify(data[i].ys.freq.toFixed(2)), x1+2 + radius, y1+2 + radius) /*appears as normalized data after training (0.0 - 1.0)*/

        for(let j=0; j<data.length; j++){
            let x2 = map(data[j].xs.x, 0, 1, 0, width-radius)
            let y2 = map(data[j].xs.y, 0, 1, 0, height-radius)

            let xnoise1 = width / 2 * noise(t + 35)
            let ynoise1 = y1 * noise(t + 75)
            let xnoise2 = width / 2 * noise(t + 35)
            let ynoise2 = y2 * noise(t + 75)
            let noiseVal = noise((x1 + i) * noiseScale, y1 * noiseScale)
            stroke(noiseVal * 255, 18)
            line(x1-radius, y1-radius, x2-radius, y2-radius)
        }
    }
    if (frameCount % 500 == 0){
        background(255)
    }
}



function draw() {
    background(50)
    strokeWeight(2)
    if(state == 'collecting') {
        fill(50)
        stroke(255, 18)
        floor( text('collecting data from users'.toUpperCase(), width/2, height/2))
    }
    if (state == 'prediction'){
        rectMode(CENTER);
        background(51);
        noFill();
        // during even-numbered seconds (0, 2, 4, 6...) add jitter to
        // the rotation
        //if (second() % 2 === 0) {
        //    jitter = random(-0.1, 0.1);
        //}
        //increase the angle value using the most recent jitter value
        //angle = angle + jitter;
        //use cosine to get a smooth CW and CCW motion when not jittering
        //let c = cos(angle);
        //move the shape to the center of the canvas
        translate(width / 2, height / 2);
        //apply the final rotation
        //rotate(c);

        drawTrainedData()
        drawCursor()
    }
}

//predict manually using coordinates
function mouseDragged(){
    if(state == 'prediction' && predictionMode == 'manual'){
        brain.predict([mouseX, mouseY], handleResults)
    }
}

function handleResults(error, result) {
    if(error){
        console.log(error)
        return
    }

    msg = {
        freq: result[0].freq,
        cursor_x: cursor.x,
        cursor_y: cursor.y
    }

    //console.log(msg)

    //oscFwd(msg)

    //brain.predict([mouseX, mouseY], handleResults)
}
