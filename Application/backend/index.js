/* Modules */
const Monitor = require('./modules/Monitor.js');
const {SerialPort} = require('serialport');
const config = require('./config.json');
const {toDictionary} = require('./modules/DE1SoC_Interface.js');
/* Object initialization */
serialPortObject = new SerialPort({path: config.port, baudRate: config.baudRate});
monitor = new Monitor(serialPortObject, 11, config.crcPolynomial);

monitor.on('data', () =>
{
    console.log(toDictionary(monitor.getData()));
});

monitor.start();