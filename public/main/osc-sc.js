//https://github.com/colinbdclark/osc.js-examples/blob/master/udp-browser/web/index.html


var oscPort = new osc.WebSocketPort({
  url: "ws://192.168.1.102:8081"
});


//receiving OSC
/*oscPort.on("message", function(msg) {
  $("#message").text(msg)
  state = 'waiting'
  let trainData = [];
  trainData.push(msg.args)
  console.log(`pack receive...📦 ${msg.args}`)
  for(let i = 0; i < trainData.length; i +=1){
  brain.addData([trainData[i][0]], [trainData[i][1]])
  }
  })*/

oscPort.on("message", function(oscMsg) {
  console.log("OSC msg received: ", oscMsg)
  document.getElementById("in-osc-message").innerHTML = "Incoming OSC: " + JSON.stringify(oscMsg, undefined, 2)
})

oscPort.open()

//default msg starting values
msg = {
  freq: Math.floor(Math.random() * 220) + 120,
  cursor_x: 0.5,
  cursor_y: 0.5
}

let oscFwd = function () {
  if(msg === NaN){
    console.log("NaN values detected or empty string", msg)
  } else {

    //checks for bad values and constructs key-value pairs
    msg = Object.fromEntries(Object.entries(msg).map(([key, value]) => [key, value]))
  }

  //oscPort.on("ready", function () {
    oscPort.send({
      address: '/lick-the-toad', //OSC message path
      args: [
        {
          type: "s",
          value: JSON.stringify(socket.id)
        },
        {
          type: "s",
          value: JSON.stringify(msg).replace('{', '(').replace('}', ')').replace(/\"/g, "").replace(/\""/g, "")
        }
      ]
    })
  //})

  let text = `Data: ${JSON.stringify(msg).replace('{', '(').replace('}', ')').replace(/\"/g, "").replace(/\""/g, "")}`
  document.getElementById("osc-message").innerHTML = text //passes current OSC message to user interface/main index interface.
}

//osc tester
sendOSC = function() {oscPort.on("ready", function() {oscPort.send({address: "/hello", args: ["world"]})})}
sendOSC()
//msg = JSON.stringify(msg).replace('{', '(').replace('}', ')').replace(/\"/g, "").replace(/\""/g, "")
//oscFwd()
