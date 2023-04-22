const properties =
{
    HEX5: 
    {
        renderCoords: {x: 82, y: 585}
    },
    HEX4: 
    {
        renderCoords: {x: 122, y: 585}
    },
    HEX3: 
    {
        renderCoords: {x: 183, y: 585}
    },
    HEX2: 
    {
        renderCoords: {x: 223, y: 585}
    },
    HEX1: 
    {
        renderCoords: {x: 285, y: 585}
    },
    HEX0: 
    {
        renderCoords: {x: 325, y: 585}
    },
    LEDR9: 
    {
        renderCoords: {x: 81, y: 659}
    },
    LEDR8: 
    {
        renderCoords: {x: 120, y: 659}
    },
    LEDR7: 
    {
        renderCoords: {x: 164, y: 659}
    },
    LEDR6: 
    {
        renderCoords: {x: 206, y: 659}
    },
    LEDR5: 
    {
        renderCoords: {x: 247, y: 659}
    },
    LEDR4: 
    {
        renderCoords: {x: 291, y: 659}
    },
    LEDR3: 
    {
        renderCoords: {x: 334, y: 659}
    },
    LEDR2: 
    {
        renderCoords: {x: 376, y: 659}
    },
    LEDR1: 
    {
        renderCoords: {x: 418, y: 659}
    },
    LEDR0: 
    {
        renderCoords: {x: 460, y: 659}
    },
    SW9:
    {
        clickArea: {xTop: 61, yTop: 700, xEnd: 94, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 68, yTop: 717, yMid: 734}
    },
    SW8:
    {
        clickArea: {xTop: 104, yTop: 700, xEnd: 136, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 111, yTop: 717, yMid: 734}
    },
    SW7:
    {
        clickArea: {xTop: 146, yTop: 700, xEnd: 179, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 153, yTop: 717, yMid: 734}
    },
    SW6:
    {
        clickArea: {xTop: 189, yTop: 700, xEnd: 221, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 196, yTop: 717, yMid: 734}
    },
    SW5:
    {
        clickArea: {xTop: 233, yTop: 700, xEnd: 265, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 240, yTop: 717, yMid: 734}
    },
    SW4:
    {
        clickArea: {xTop: 275, yTop: 700, xEnd: 307, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 282, yTop: 717, yMid: 734}
    },
    SW3:
    {
        clickArea: {xTop: 319, yTop: 700, xEnd: 351, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 326, yTop: 717, yMid: 734}
    },
    SW2:
    {
        clickArea: {xTop: 361, yTop: 700, xEnd: 393, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 368, yTop: 717, yMid: 734}
    },
    SW1:
    {   
        clickArea: {xTop: 405, yTop: 700, xEnd: 437, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 412, yTop: 717, yMid: 734}
    },
    SW0:
    {
        clickArea: {xTop: 448, yTop: 700, xEnd: 480, yEnd: 769},
        holdClick: false,
        renderCoords: {xTop: 455, yTop: 717, yMid: 734}
    },
    KEY3:
    {
        clickArea: {xTop: 501, yTop: 701, xEnd: 570, yEnd: 770},
        holdClick: true
    },
    KEY2: 
    {
        clickArea: {xTop: 579, yTop: 701, xEnd: 648, yEnd: 770},
        holdClick: true
    },
    KEY1: 
    {
        clickArea: {xTop: 657, yTop: 701, xEnd: 726, yEnd: 770},
        holdClick: true
    },
    KEY0:
    {
        clickArea: {xTop: 734, yTop: 701, xEnd: 803, yEnd: 770},
        holdClick: true
    }
};
var isClicking = false;
var clickedItem;
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

function getXYClickPosition(canvasDocument, event, isClick)
{
    const rect = canvasDocument.getBoundingClientRect();
    const scaleX = canvasDocument.width / rect.width;
    const scaleY = canvasDocument.height / rect.height;
    const x = ((isClick ? event.clientX : event.touches[0].clientX) - rect.left) * scaleX;
    const y = ((isClick ? event.clientY : event.touches[0].clientY) - rect.top) * scaleY;
    return [x, y];
}

function getClickedItem(canvasDocument, event, isClick)
{
    const [x, y] = getXYClickPosition(canvasDocument, event, isClick);
    for(item in properties)
    {
        if(properties[item].clickArea == undefined) continue;
        if(x >= properties[item].clickArea.xTop 
            && x <= properties[item].clickArea.xEnd 
            && y >= properties[item].clickArea.yTop 
            && y <= properties[item].clickArea.yEnd)
        {
            return [item, properties[item].holdClick];
        }
    }
    return [undefined, false];
}

function selectStart(canvasDocument, event, socket, isClick)
{
    event.preventDefault();
    if(isClicking) return;
    isClicking = true;
    clickedItem = getClickedItem(canvasDocument, event, isClick);
    const [item, holdClick] = clickedItem;
    if(item == undefined) return;
    if(holdClick) states[item] = true;
    else states[item] = !states[item];
    socket.send(JSON.stringify(states));
}

function selectEnd(canvasDocument, event, socket, isClick)
{
    event.preventDefault();
    if(!isClicking) return;
    isClicking = false;
    const [item, holdClick] = clickedItem;
    if(item == undefined) return;
    if(holdClick)
        states[item] = false;
        socket.send(JSON.stringify(states));
}