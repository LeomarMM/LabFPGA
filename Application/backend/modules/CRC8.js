module.exports = class CRC8
{
    constructor(polynomial)
    {
        this.poly = polynomial
    }
    calculateCRC(bytearray)
    {
        var crc = 0;
        bytearray.forEach((_byte) => 
        {
            for (var bit = 7; bit >= 0; bit--)
            {
                var crc_7 = (crc >> 7) & 1;
                var newCRC = crc_7 ^ ((_byte >> bit) & 1);
                for (var i = 1; i <= 7; i++)
                {
                    var poly_i = (this.poly >> i) & 1;
                    var crc_i = (crc >> (i-1)) & 1;
                    if(poly_i)
                    {
                        newCRC |= (crc_7 ^ crc_i) << i;
                    }
                    else
                    {
                        newCRC |= (crc_i) << i;
                    }
                }
                crc = newCRC;
            }
        });
        return crc;
    }
}