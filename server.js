const config_file = process.argv[2] ? process.argv[2] : './config.json';
const config = require(config_file);
const express = require('express')
const cors = require('cors');
const app = express();
const httpServer = require("http").createServer(app);
const Ball = require('./api/Ball.js');
let PORT = 8000;
let handshake;
let clients = {};
let balls = [];

var osc = require('osc'),
    WebSocket = require('ws');

//console.log(app.set('port', process.env.SOCKETS_PORT || 8000))

let server = httpServer.listen(PORT, () => {
    console.info(`App listening on port ${PORT}`)
})


app.use(cors());

var getIPAddresses = function () {
    var os = require("os"),
        interfaces = os.networkInterfaces(),
        ipAddresses = [];

    for (var deviceName in interfaces){
        var addresses = interfaces[deviceName];

        for (var i = 0; i < addresses.length; i++) {
            var addressInfo = addresses[i];

            if (addressInfo.family === "IPv4" && !addressInfo.internal) {
                ipAddresses.push(addressInfo.address);
            }
        }
    }

    return ipAddresses;
};

var udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    localPort: 57121,
    remoteAddress: "127.0.0.1",
    remotePort: 57120
});

udpPort.open()

udpPort.on("ready", function (oscMsg, timeTag, info) {
    var ipAddresses = getIPAddresses();
    console.log("Listening for OSC over UDP.");
    ipAddresses.forEach(function (address) {
        console.log(" Host:", address + ", Port:", udpPort.options.localPort)
    })
});

/*udpPort.on("ready", function () {
  udpPort.send({
  address: "/s_new",
  args: [
  {
  type: "s",
  value: "default"
  },
  {
  type: "i",
  value: 100
  }
  ]
  }, "127.0.0.1", 57120);
  });*/

const wss = new WebSocket.Server({
    port:8081
});

wss.on("connection", function (socket) {
    console.log("A Web Socket connection has been established!");
    var socketPort = new osc.WebSocketPort({
        socket: socket
    });
    /*relaying from socketport to udp,
      server hits back OSC from SC to browser
      [Browser(WBsocks) <--> UDP <--> SC]*/
    var relay = new osc.Relay(udpPort, socketPort, {
        raw: true
    });
});

udpPort.on("message", function (oscMessage) {
    console.log(oscMessage);
});

udpPort.on("error", function (err) {
    console.log(err);
});

/*const io = require("socket.io")(server, {
  allowRequest: (req, callback) => {
  const noOriginHeader = req.headers.origin === undefined;
  callback(null, noOriginHeader);
  }//testing CORS maybe also below is better
  })*/

const io = require("socket.io")(server, {
    allowRequest: (req, callback) => {
        const noOriginHeader = req.headers.origin === undefined;
        callback(null, noOriginHeader);
    },
    cors: {
        origin: `http://${server}:${PORT}`,
        methods: ["GET", "POST"],
        credentials: true,
        optionsSuccessStatus: 200
    }
})

app.use(express.static('public'));
app.use(express.static('main'));
app.use(express.static('client'));
app.use(express.static('images'));

app.get('/k-v.png', function(req, res) {
    res.sendFile(__dirname + '/images/k-v.png'); 
})

app.get('/socket.io.min.js', function(req, res) {
    res.sendFile(__dirname + '/node_modules/socket.io/client-dist/socket.io.min.js');
})

app.get('/osc-browser.min.js', function(req, res) {
    res.sendFile(__dirname + '/node_modules/osc/dist/osc-browser.min.js')
})

app.get('/CCapture.all.min.js', function(req, res) {
    res.sendFile(__dirname + '/node_modules/ccapture.js/build/CCapture.all.min.js');
})

udpPort.on("message", (oscMsg) => {
    console.log("An OSC message just arrived!", oscMsg.args);
})

function heartbeat() {
    io.sockets.emit('heartbeat', balls)
}

setInterval( heartbeat, 33 )

let ball;

io.sockets.on('connection', (socket) => {

    clients[socket.id] = socket;

    console.log(socket.client.conn.server.clientsCount + " users connected " + socket.id);

    socket.on('new_ball', (data) => {

        if ( balls.some(ball => ball.id === socket.id) ) {
            console.log('a user with this ID exists')
        } else {
            socket.customId = data.customId

            ball = new Ball(socket.customId, data.x, data.y, data.r*2) //socket.id: to get ID of user.
            balls.push(ball);
            socket.emit('new_ball', ball);
        }
    })

    socket.on('update', (data) => {
        let ball = {}

        for(let i=0; i < balls.length; i++) {
            if(socket.customId == balls[i].id) {
                ball = balls[i]
            }
        }

        ball.x = data.x,
        ball.y = data.y,
        ball.r = data.r
    })

    socket.on('disconnect', (cause) => {
        const index = balls.findIndex(ball => ball.id === socket.id)
        const  usersCount = socket.client.conn.server.clientsCount

        try {
            balls.splice(index, 1)
            delete clients[socket.id]
        } catch (error) {
            console.error(error)
        }

        console.info("user disconnected reason: " + cause, "-", usersCount + " remained", balls.length);
        if(usersCount == 0){
            console.log('waiting users to log in');
        }
    });

    socket.on("connect_error", (err) => {
        console.log(`connect_error due to ${err.message}`);
    });
});
