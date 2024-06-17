const properties =
{
    HEX5: 
    {
        renderCoords: {x: 86, y: 23}
    },
    HEX4: 
    {
        renderCoords: {x: 126, y: 23}
    },
    HEX3: 
    {
        renderCoords: {x: 187, y: 23}
    },
    HEX2: 
    {
        renderCoords: {x: 227, y: 23}
    },
    HEX1: 
    {
        renderCoords: {x: 289, y: 23}
    },
    HEX0: 
    {
        renderCoords: {x: 329, y: 23}
    },
    LEDR9: 
    {
        renderCoords: {x: 32, y: 97}
    },
    LEDR8: 
    {
        renderCoords: {x: 71, y: 97}
    },
    LEDR7: 
    {
        renderCoords: {x: 115, y: 97}
    },
    LEDR6: 
    {
        renderCoords: {x: 157, y: 97}
    },
    LEDR5: 
    {
        renderCoords: {x: 198, y: 97}
    },
    LEDR4: 
    {
        renderCoords: {x:242, y: 97}
    },
    LEDR3: 
    {
        renderCoords: {x: 285, y: 97}
    },
    LEDR2: 
    {
        renderCoords: {x: 327, y: 97}
    },
    LEDR1: 
    {
        renderCoords: {x: 369, y: 97}
    },
    LEDR0: 
    {
        renderCoords: {x: 411, y: 97}
    },
    SW9:
    {
        clickArea: {xTop: 18, yTop: 140, xEnd: 52, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 22, yTop: 155, yMid: 172}
    },
    SW8:
    {
        clickArea: {xTop: 60, yTop: 140, xEnd: 95, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 65, yTop: 155, yMid: 172}
    },
    SW7:
    {
        clickArea: {xTop: 102, yTop: 140, xEnd: 136, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 107, yTop: 155, yMid: 172}
    },
    SW6:
    {
        clickArea: {xTop: 144, yTop: 140, xEnd: 178, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 150, yTop: 155, yMid: 172}
    },
    SW5:
    {
        clickArea: {xTop: 188, yTop: 140, xEnd: 222, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 194, yTop: 155, yMid: 172}
    },
    SW4:
    {
        clickArea: {xTop: 230, yTop: 140, xEnd: 264, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 236, yTop: 155, yMid: 172}
    },
    SW3:
    {
        clickArea: {xTop: 274, yTop: 140, xEnd: 307, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 280, yTop: 155, yMid: 172}
    },
    SW2:
    {
        clickArea: {xTop: 316, yTop: 140, xEnd: 350, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 322, yTop: 155, yMid: 172}
    },
    SW1:
    {   
        clickArea: {xTop: 360, yTop: 140, xEnd: 393, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 366, yTop: 155, yMid: 172}
    },
    SW0:
    {
        clickArea: {xTop: 402, yTop: 140, xEnd: 438, yEnd: 210},
        holdClick: false,
        renderCoords: {xTop: 409, yTop: 155, yMid: 172}
    },
    KEY3:
    {
        clickArea: {xTop: 81, yTop: 235, xEnd: 152, yEnd: 304},
        holdClick: true
    },
    KEY2: 
    {
        clickArea: {xTop: 160, yTop: 235, xEnd: 229, yEnd: 304},
        holdClick: true
    },
    KEY1: 
    {
        clickArea: {xTop: 236, yTop: 235, xEnd: 307, yEnd: 304},
        holdClick: true
    },
    KEY0:
    {
        clickArea: {xTop: 314, yTop: 235, xEnd: 383, yEnd: 304},
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

function getXYClickPosition(canvasDocument, event, isClick) {
    const rect = canvasDocument.getBoundingClientRect();
    const scaleX = canvasDocument.width / rect.width;
    const scaleY = canvasDocument.height / rect.height;
    const x = ((isClick ? event.clientX : event.touches[0].clientX) - rect.left) * scaleX;
    const y = ((isClick ? event.clientY : event.touches[0].clientY) - rect.top) * scaleY;
    return [x, y];
}

function getClickedItem(canvasDocument, event, isClick) {
    const [x, y] = getXYClickPosition(canvasDocument, event, isClick);
    for(item in properties) {
        if(properties[item].clickArea == undefined) continue;
        if(x >= properties[item].clickArea.xTop 
            && x <= properties[item].clickArea.xEnd 
            && y >= properties[item].clickArea.yTop 
            && y <= properties[item].clickArea.yEnd) {
            return [item, properties[item].holdClick];
        }
    }
    return [undefined, false];
}

function selectStart(canvasDocument, event, socket, isClick) {
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

function selectEnd(canvasDocument, event, socket, isClick) {
    event.preventDefault();
    if(!isClicking) return;
    isClicking = false;
    const [item, holdClick] = clickedItem;
    if(item == undefined) return;
    if(holdClick)
        states[item] = false;
    socket.send(JSON.stringify(states));
}