/*
 * state 0: Not started
 * state 1: Transmitting and awaiting ACK/NAK
 * state 2: Receiving data, CRC check and response
 */
const CRC8 = require('./CRC8.js');
module.exports = class Monitor
{
    constructor(serialPortObject, sizeInBytes, crcPolynomial)
    {
        this.crc = new CRC8(crcPolynomial);
        this.size = sizeInBytes;
        this.toFPGA = new Array(this.size).fill(0);
        this.fromFPGA = new Array(this.size).fill(0);
        this.transmission = 
        {
            buffer: new Array(),
            serial: serialPortObject,
            state: 0
        };
        this.transmission.serial.on('data', (data) => 
        {
            switch(this.transmission.state)
            {
                case 0:
                    console.log('Incoming data on inactive port: ', data);
                    break;

                case 1:
                    if(data[0] === 6)
                    {
                        console.log("Received ACK from FPGA.");
                        this.transmission.state = 2;
                        data = data.subarray(1);
                    }
                    else
                    {
                        console.log("Did not receive ACK. Resending.")
                        this.#sendData();
                        break;
                    }

                case 2:
                    for (const word of data)
                    {
                        this.transmission.buffer.push(word);
                        if(this.transmission.buffer.length == this.size + 1)
                        {
                            this.#respondFPGA();
                            break;
                        }
                    }
                    break;
            }
        });
    }

    start()
    {
        if(this.transmission.state != 0) return;        
        this.transmission.state = 1;
        this.#sendData();
    }

    setData(dataToFPGA)
    {
        this.toFPGA = [...dataToFPGA];
        for(var i = this.toFPGA.length; i < this.size; i++)
            this.toFPGA[i] = 0;
    }

    #crcCheck(dataToCheck)
    {
        var check = [...dataToCheck, 0];
        return this.crc.calculateCRC(check);
    }

    #sendData()
    {
        var crcResult = this.#crcCheck(this.toFPGA);
        this.transmission.serial.write(Buffer.from([...this.toFPGA, crcResult]));
    }

    #respondFPGA()
    {
        var slicedBuffer = this.transmission.buffer.slice(0, this.size);
        var fpgaCRC = this.transmission.buffer[this.size];
        var serverCRC = this.#crcCheck(slicedBuffer);
        this.transmission.buffer.length = 0;
        if(fpgaCRC == serverCRC) 
        {
            console.log("Server sending ACK.");
            this.fromFPGA = slicedBuffer;
            this.transmission.state = 1;
            this.transmission.serial.write(Buffer.from([0x06]));
            this.#sendData();
        }
        else
        {
            console.log("Server sending NAK.");
            this.transmission.serial.write(Buffer.from([0x15]));
        }
    }
}