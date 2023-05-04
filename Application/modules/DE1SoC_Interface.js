const extractFromBytes = (uint8array, bytes, signal, componentName, componentDescription) => 
{
    var extracted = 0;
    var dictionary = {};
    for(var i = uint8array.length-1; i >= 0; i--)
    {
        var byte = uint8array[i];
        for(var b = 0; b < 8; b++)
        {
            var logic = (byte >> b) & 1;
            dictionary[signal+extracted] = 
            {
                buttonId: signal+extracted,
                fullName: componentName+"[" + extracted + "]",
                description: componentDescription,
                value: logic
            };
            extracted++;
            if(extracted >= bytes) return dictionary;
        }
    }
    return dictionary;
};
const extractDisplayByte = (byte, digit) => 
{
    var dictionary = {};
    dictionary["HEX"+digit] = 
    {
        buttonId: "HEX"+digit,
        fullName: "Seven Segment Digit " + digit,
        description: "Seven Segment Display for DE1SoC FPGA.",
        value: 
        {
            0: !(byte & 1),
            1: !((byte >> 1) & 1),
            2: !((byte >> 2) & 1),
            3: !((byte >> 3) & 1),
            4: !((byte >> 4) & 1),
            5: !((byte >> 5) & 1),
            6: !((byte >> 6) & 1)
        }
    };
    return dictionary;
};
const extractButtonData = (uint8array, buttons) => 
{
    return extractFromBytes(uint8array, buttons, "KEY", "Push-button", "Virtual push-button for DE1SoC FPGA.");
};
const extractLEDData = (uint8array, leds) =>
{
    return extractFromBytes(uint8array, leds, "LEDR", "LED", "LED for DE1SoC FPGA.");
};
const extractSwitchData = (uint8array, switches) =>
{
    return extractFromBytes(uint8array, switches, "SW", "Slide Switch", "Slide Switch for DE1SoC FPGA.");
};
const extractDisplayData = (uint8array) =>
{
    var dictionary = {};
    for(i in uint8array)
    {
        dictionary = Object.assign(dictionary, extractDisplayByte(uint8array[i], uint8array.length-i-1));
    }
    return dictionary;
};
const toDictionary = (data) =>
{
    const switches = extractSwitchData(data.slice(0, 2), 10);
    const buttons = extractButtonData(data.slice(2, 3), 4);
    const leds = extractLEDData(data.slice(3, 5), 10);
    const displays = extractDisplayData(data.slice(5, 12));
    return Object.assign({}, switches, buttons, leds, displays);
}
const toBinary = (data) =>
{
    const binData = new Array(11).fill(0);
    var tempNum = 0;
    for(var i = 9; i >= 0; i--)
        tempNum += (data["SW"+i] << i);
    binData[0] = tempNum >> 8;
    binData[1] = tempNum & 0xFF;
    tempNum = 0;
    for(var i = 3; i >= 0; i--)
        tempNum += (data["KEY"+i] << i);
    binData[2] = tempNum;
    return binData;
}
var startupValues = JSON.stringify(toDictionary([0, 0, 0, 0x03, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]));
module.exports = {toBinary, toDictionary, startupValues};