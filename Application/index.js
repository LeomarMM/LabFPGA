/* Modules */
const {SerialPort} = require('serialport');
const Monitor = require('./modules/Monitor.js');
const config = require('./config.json');
const {toBinary, toDictionary} = require('./modules/DE1SoC_Interface.js');
const WebSocket = require('ws');
const express = require('express');
const multer  = require('multer');
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

/* Object initialization */
var sockets = [];
const serialPortObject = new SerialPort({path: config.port, baudRate: config.baudRate});
const monitor = new Monitor(serialPortObject, 11, config.crcPolynomial);
const wsServer = new WebSocket.Server({noServer: true});
const expressApp = express();
const expressServer = expressApp.listen(config.expressPort, () => 
{
    console.log(`[I] Express started on port ${config.expressPort}.`)
})

/* Events */
monitor.on('data', () =>
{
    const message = JSON.stringify(toDictionary(monitor.getData()));
    sockets.forEach(s => s.send(message));
});
monitor.on('stop', () =>
{
    console.log('[I] Stopped communication with FPGA.')
});
wsServer.on('connection', (socket) =>
{
    const message = JSON.stringify(toDictionary(monitor.getData()));
    socket.send(message);
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
monitor.start();