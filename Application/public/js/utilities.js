const offsets =
{
    HEX5: {x: 82, y: 585},
    HEX4: {x: 122, y: 585},
    HEX3: {x: 183, y: 585},
    HEX2: {x: 223, y: 585},
    HEX1: {x: 285, y: 585},
    HEX0: {x: 325, y: 585},
    LED9: {x: 81, y: 659},
    LED8: {x: 120, y: 659},
    LED7: {x: 164, y: 659},
    LED6: {x: 206, y: 659},
    LED5: {x: 247, y: 659},
    LED4: {x: 291, y: 659},
    LED3: {x: 334, y: 659},
    LED2: {x: 376, y: 659},
    LED1: {x: 418, y: 659},
    LED0: {x: 460, y: 659}
};
const clickArea = 
{
    SW9: {xTop: 61, yTop: 700, xEnd: 94, yEnd: 769},
    SW8: {xTop: 104, yTop: 700, xEnd: 136, yEnd: 769},
    SW7: {xTop: 146, yTop: 700, xEnd: 179, yEnd: 769},
    SW6: {xTop: 189, yTop: 700, xEnd: 221, yEnd: 769},
    SW5: {xTop: 233, yTop: 700, xEnd: 265, yEnd: 769},
    SW4: {xTop: 275, yTop: 700, xEnd: 307, yEnd: 769},
    SW3: {xTop: 319, yTop: 700, xEnd: 351, yEnd: 769},
    SW2: {xTop: 361, yTop: 700, xEnd: 393, yEnd: 769},
    SW1: {xTop: 405, yTop: 700, xEnd: 437, yEnd: 769},
    SW0: {xTop: 448, yTop: 700, xEnd: 480, yEnd: 769}
}

var states = 
{
    SW9: false,
    SW8: false,
    SW7: false,
    SW6: false,
    SW5: false,
    SW4: false,
    SW3: false,
    SW2: false,
    SW1: false,
    SW0: false,
    KEY3: false,
    KEY2: false,
    KEY1: false,
    KEY0: false
};

function getXYClickPosition(canvasDocument, event)
{
    const rect = canvasDocument.getBoundingClientRect();
    const scaleX = canvasDocument.width / rect.width;
    const scaleY = canvasDocument.height / rect.height;
    const x = (event.clientX - rect.left) * scaleX;
    const y = (event.clientY - rect.top) * scaleY;
    console.log(x,y);
    return [x, y];
}

function getClickedItem(canvasDocument, event)
{
    const [x, y] = getXYClickPosition(canvasDocument, event);
    for(item in clickArea)
    {
        if(x >= clickArea[item].xTop 
            && x <= clickArea[item].xEnd 
            && y >= clickArea[item].yTop 
            && y <= clickArea[item].yEnd)
        {
            return [item, true];
        }
    }
    return [undefined, false];
}