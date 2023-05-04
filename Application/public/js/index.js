window.onload = function() 
{
    var canvasDocument = document.getElementById("board-canvas");
    var form = document.getElementById("bts-form");
    var file = document.getElementById("bitstream-file");
    var button = document.getElementById("bitstream-button");
    var ctx = canvasDocument.getContext("2d");
    for(var i = 0; i<=9; i++) renderSwitch("SW"+i, false, ctx);
    var socket = new WebSocket("ws://"+window.location.host);
    canvasDocument.addEventListener('touchstart', (event) => {selectStart(canvasDocument, event, socket, false)}, false);
    canvasDocument.addEventListener('mousedown', (event) => {selectStart(canvasDocument, event, socket, true)}, false);
    canvasDocument.addEventListener('touchend', (event) => {selectEnd(canvasDocument, event, socket, false)}, false);
    canvasDocument.addEventListener('mouseup', (event) => {selectEnd(canvasDocument, event, socket, true)}, false);
    button.onclick = () =>
    {
        file.click();
    }
    file.onchange = () =>
    {
        form.submit();
    }
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