/* Modules */
const {SerialPort} = require('serialport');
const Monitor = require('./modules/Monitor.js');
const config = require('./config.json');
const {toDictionary} = require('./modules/DE1SoC_Interface.js');
const WebSocket = require('ws');
const express = require('express');

/* Object initialization */
var sockets = [];
const serialPortObject = new SerialPort({path: config.port, baudRate: config.baudRate});
const monitor = new Monitor(serialPortObject, 11, config.crcPolynomial);
const wsServer = new WebSocket.Server({noServer: true});
const expressApp = express();
const expressServer = expressApp.listen(config.expressPort, () => 
{
    console.log(`Express started on port ${config.expressPort}.`)
})

/* Events */
monitor.on('data', () =>
{
    const message = JSON.stringify(toDictionary(monitor.getData()));
    sockets.forEach(s => s.send(message));
});

wsServer.on('connection', (socket) =>
{
    socket.on('message', (msg) =>
    {
        sockets.forEach(s => s.send(msg));
    });

    socket.on('close', () =>
    {
        sockets = sockets.filter(s => s !== socket);
    });
    sockets.push(socket);
});

expressServer.on('upgrade', (request, socket, head) =>
{
    console.log("[I] Incoming Websockets Upgrade Request.");
    wsServer.handleUpgrade(request, socket, head, socket => 
    {
        wsServer.emit('connection', socket, request);
    });
});

/* Module setup */

expressApp.use(express.static('public'));
monitor.start();