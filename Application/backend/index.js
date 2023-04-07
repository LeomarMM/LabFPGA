/* Modules */
const Monitor = require('./modules/Monitor.js');
const {SerialPort} = require('serialport');
const config = require('./config.json');

/* Object initialization */
serialPortObject = new SerialPort({path: config.port, baudRate: config.baudRate});
monitor = new Monitor(serialPortObject, config.sizeInBytes, config.crcPolynomial);