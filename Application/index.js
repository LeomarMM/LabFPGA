/* Modules */
const {SerialPort} = require('serialport');
const Monitor = require('./modules/Monitor.js');
const config = require('./config.json');
const {toBinary, toDictionary, startupValues} = require('./modules/DE1SoC_Interface.js');
const WebSocket = require('ws');
const express = require('express');
const multer  = require('multer');
const { exec } = require("child_process");

/* Object initialization */
var sockets = [];
const serialPortObject = new SerialPort({path: config.port, baudRate: config.baudRate});
const monitor = new Monitor(serialPortObject, config.sizeInBytes, config.crcPolynomial);
const wsServer = new WebSocket.Server({noServer: true});
const expressApp = express();
const expressServer = expressApp.listen(config.expressPort, () => 
{
    console.log(`[I] Express started on port ${config.expressPort}.`)
})
const storage = multer.diskStorage(
{
    destination: function (req, file, callback) 
    {
        callback(null, 'bitstreams');
    },
    filename: function (req, file, callback) {
        callback(null, 'user_bitstream.sof');
    }
});
const upload = multer({storage: storage});
var currentData = startupValues;

/* Events and Functions */
function programFPGA(cdf)
{
    console.log(`[I] Programming FPGA with ${cdf}.`);
    exec(config.quartus_pgm + " -c "+config.quartus_pgm_port+" bitstreams/" + cdf + ".cdf", (err, stdout, stderr) => 
    {
        monitor.start();
    });
}

monitor.on('data', () =>
{
    currentData = JSON.stringify(toDictionary(monitor.getData()));
    sockets.forEach(s => s.send((monitor.isStopped() ? startupValues : currentData)));
});

monitor.on('stop', () =>
{
    sockets.forEach(s => s.send((monitor.isStopped() ? startupValues : currentData)));
    console.log('[I] Stopped communication with FPGA.');
    programFPGA("user_cdf");
});

wsServer.on('connection', (socket) =>
{
    socket.send((monitor.isStopped() ? startupValues : currentData));
    socket.on('message', (msg) =>
    {
        console.log("[I] Received new states from client.");
        const dataObject = JSON.parse(msg);
        monitor.setData(toBinary(dataObject));
    });

    socket.on('close', () =>
    {
        sockets = sockets.filter(s => s !== socket);
    });
    sockets.push(socket);
});

expressServer.on('upgrade', (request, socket, head) =>
{
    console.log("[I] Incoming Websocket Connection Request.");
    wsServer.handleUpgrade(request, socket, head, socket => 
    {
        wsServer.emit('connection', socket, request);
    });
});

expressApp.post('/upload', upload.single('bitstream'), (req, res, next) =>
{
    console.log('[I] Received a file to upload to FPGA.');
    console.log('[I] Stopping communication with FPGA.');
    monitor.stop();
    res.sendStatus(200);
});
  
/* Module setup */
expressApp.use(express.static('public'));
programFPGA('default_cdf');