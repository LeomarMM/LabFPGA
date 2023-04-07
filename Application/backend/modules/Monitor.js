const CRC8 = require('./CRC8.js');
module.exports = class Monitor
{
    constructor(serialPortObject, sizeInBytes, crcPolynomial)
    {
        this.crc = new CRC8(crcPolynomial);
        this.size = sizeInBytes;
        this.serial = serialPortObject;
    }
}