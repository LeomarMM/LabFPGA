/*
 * state 0: Not started
 * state 1: Transmitting and awaiting ACK/NAK
 * state 2: Receiving data, CRC check and response
 */
const { Buffer } = require('node:buffer');
const CRC8 = require('./CRC8.js');
const events = require('events');
module.exports = class Monitor {
    #crc;
    #size;
    #toFPGA;
    #fromFPGA;
    #fromFPGAOld;
    #eventEmitter;
    #transmission;
    #timeout;
    constructor(serialPortObject, sizeInBytes, crcPolynomial) {
        this.#crc = new CRC8(crcPolynomial);
        this.#size = sizeInBytes;
        this.#eventEmitter = new events.EventEmitter();
        this.#transmission = 
        {
            buffer: new Array(),
            serial: serialPortObject,
            state: 0
        };
        this.#transmission.serial.on('readable', () => {
            var data = this.#transmission.serial.read();
            switch(this.#transmission.state) {
            default:
                this.#eventEmitter.emit('invalid_state', this.#transmission.state);
                break;
            case 1:
                this.#resetWatchdog();
                if(data[0] === 6) {
                    this.#transmission.state = 2;
                    data = data.subarray(1);
                } else {
                    this.#eventEmitter.emit('fpga_nak');
                    this.#sendData();
                    break;
                }
            /* falls through */
            case 2:
                this.#resetWatchdog();
                for (const word of data) {
                    this.#transmission.buffer.push(word);
                    if(this.#transmission.buffer.length == this.#size + 1) {
                        this.#resetWatchdog();
                        this.#respondFPGA();
                        break;
                    }
                }
                break;
            }
        });
    }

    on(event, handler) {
        this.#eventEmitter.on(event, handler);
    }

    start() {
        if(this.#transmission.state != 0) return;
        this.#toFPGA = new Array(this.#size).fill(0);
        this.#fromFPGA = new Array(this.#size).fill(0);
        this.#fromFPGAOld = undefined;     
        this.#transmission.state = 1;
        this.#transmission.buffer.length = 0;
        this.#sendData();
    }

    stop() {
        this.#transmission.state = 0;
        clearTimeout(this.#timeout);
        this.#eventEmitter.emit('stop');
    }

    isStopped() {
        return this.#transmission.state == 0;
    }
    
    setData(dataToFPGA) {
        this.#toFPGA = [...dataToFPGA];
        for(var i = this.#toFPGA.length; i < this.#size; i++)
            this.#toFPGA[i] = 0;
    }

    getData() {
        return this.#fromFPGA;
    }

    #crcCheck(dataToCheck) {
        var check = [...dataToCheck, 0];
        return this.#crc.calculateCRC(check);
    }

    #sendData() {
        var crcResult = this.#crcCheck(this.#toFPGA);
        this.#transmission.serial.write(Buffer.from([...this.#toFPGA, crcResult]), () => {
            this.#resetWatchdog();
        });
    }

    #respondFPGA() {
        var slicedBuffer = this.#transmission.buffer.slice(0, this.#size);
        var fpgaCRC = this.#transmission.buffer[this.#size];
        var serverCRC = this.#crcCheck(slicedBuffer);
        this.#transmission.buffer.length = 0;
        if(fpgaCRC == serverCRC) {
            this.#fromFPGA = slicedBuffer;
            this.#transmission.state = 1;
            this.#transmission.serial.write(Buffer.from([0x06]));
            if(this.#fromFPGAOld == undefined || !this.#fromFPGA.every((val, index) => val === this.#fromFPGAOld[index])) this.#eventEmitter.emit('data');
            this.#sendData();
            this.#fromFPGAOld = this.#fromFPGA;
        } else {
            this.#eventEmitter.emit('server_nak');
            this.#transmission.serial.write(Buffer.from([0x15]));
        }
    }
    #resetWatchdog() {
        clearTimeout(this.#timeout);
        this.#timeout = setTimeout(() => {
            var log = {
                state: this.#transmission.state,
                buffer: this.#transmission.buffer
            };
            this.#eventEmitter.emit('timeout', log);
            this.clear();
            this.#timeout = setTimeout(()=> {
                this.#transmission.state = 1;
                this.#sendData();
            }, 1000);
        }, 1000);
    }
    clear() {
        this.#transmission.buffer.length = 0;
        this.#transmission.state = 0;
    }
};