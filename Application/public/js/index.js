window.onload = function() 
{
    var canvasDocument = document.getElementById("boardCanvas");
    var ctx = canvasDocument.getContext("2d");
    for(var i = 0; i<=9; i++) renderSwitch("SW"+i, false, ctx);
    var socket = new WebSocket("ws://"+window.location.host);
    canvasDocument.addEventListener('touchstart', (event) => {selectStart(canvasDocument, event, socket, false)}, false);
    canvasDocument.addEventListener('mousedown', (event) => {selectStart(canvasDocument, event, socket, true)}, false);
    canvasDocument.addEventListener('touchend', (event) => {selectEnd(canvasDocument, event, socket, false)}, false);
    canvasDocument.addEventListener('mouseup', (event) => {selectEnd(canvasDocument, event, socket, true)}, false);
    socket.onmessage = (event) => 
    {
        const msg = JSON.parse(event.data);
        for(item in states)
        {
            states[item] = msg[item].value;
        }
        render(canvasDocument, ctx, msg);
    };
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