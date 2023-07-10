/* Modules */
const {SerialPort} = require('serialport');
const Monitor = require('./modules/Monitor.js');
const config = require('./config.json');
const {toBinary, toDictionary, startupValues} = require('./modules/DE1SoC_Interface.js');
const WebSocket = require('ws');
const express = require('express');
const multer  = require('multer');
const { exec } = require('child_process');

/* Object initialization */
var sockets = [];
const serialPortObject = new SerialPort({path: config.port, baudRate: config.baudRate});
const monitor = new Monitor(serialPortObject, config.sizeInBytes, config.crcPolynomial);
const wsServer = new WebSocket.Server({noServer: true});
const expressApp = express();
const expressServer = expressApp.listen(config.expressPort, () => {
    serverLog(`[I] Express started on port ${config.expressPort}.`);
});
const storage = multer.diskStorage(
    {
        destination: (_req, _file, callback) => {
            callback(null, 'bitstreams/'+config.boardName+'/');
        },
        filename: (_req, _file, callback) => {
            callback(null, 'user_bitstream.sof');
        }
    });
const upload = multer({storage: storage});
var currentData = startupValues;


/* Events and Functions */
function serverLog(message) {
    var timeZoneOffset = (new Date()).getTimezoneOffset() * 60000;
    var date = new Date((Date.now() - timeZoneOffset)).toISOString().
        replace(/T/, ' ').      // replace T with a space
        replace(/\..+/, '');     // delete the dot and everything after
    console.log(`(${date}) ${message}`);
}

function programFPGA(cdf) {
    serverLog(`[I] Programming FPGA with ${cdf}.`);
    exec(config.quartus_pgm + ' -c '+config.quartus_pgm_port+' bitstreams/'+ config.boardName+'/' + cdf + '.cdf', () => {
        monitor.start();
    });
}

monitor.on('data', () => {
    currentData = JSON.stringify(toDictionary(monitor.getData()));
    sockets.forEach(s => s.send((monitor.isStopped() ? startupValues : currentData)));
});

monitor.on('stop', () => {
    sockets.forEach(s => s.send((monitor.isStopped() ? startupValues : currentData)));
    serverLog('[I] Stopped communication with FPGA.');
    programFPGA('user_cdf');
});

monitor.on('timeout', (e) => {
    serverLog(`[!] Timeout at state ${e.state}.`);
});

monitor.on('fpga_nak', () => {
    serverLog('[!] FPGA did not return an ACK. Resending.');
});

monitor.on('server_nak', () => {
    serverLog('[!] Received data CRC mismatch. Sending NAK.');
});

wsServer.on('connection', (socket) => {
    socket.send((monitor.isStopped() ? startupValues : currentData));

    socket.on('message', (msg) => {
        serverLog('[I] Received new states from client.');
        const dataObject = JSON.parse(msg);
        monitor.setData(toBinary(dataObject));
    });

    socket.on('close', () => {
        serverLog('[I] Websockets connection closed.');
        sockets = sockets.filter(s => s !== socket);
    });

    sockets.push(socket);
});

expressServer.on('upgrade', (request, socket, head) => {
    serverLog('[I] Incoming Websocket Connection Request.');
    wsServer.handleUpgrade(request, socket, head, socket => {
        wsServer.emit('connection', socket, request);
    });
});

expressApp.use(function (req, _res, next) {
    serverLog(`[I] Received HTTP request for ${req.originalUrl}`);
    next();
});

expressApp.post('/upload', upload.single('bitstream'), (_req, res) => {
    serverLog('[I] Received a file to upload to FPGA.');
    serverLog('[I] Stopping communication with FPGA.');
    monitor.stop();
    res.status(200).end();
});
  
/* Module setup */
expressApp.use(express.static('public'));
programFPGA('default_cdf');