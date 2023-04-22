window.onload = function() 
{
    var canvasDocument = document.getElementById("boardCanvas");
    var ctx = canvasDocument.getContext("2d");
    var socket = new WebSocket("ws://"+window.location.host);

    canvasDocument.addEventListener('mousedown', function(event) 
    {
        const [item, isSwitch] = getClickedItem(canvasDocument, event);
        if(item == undefined) return;
        if(isSwitch)
            states[item] = !states[item];
        else
            states[item] = true;
        socket.send(JSON.stringify(states));
    }, false);

    canvasDocument.addEventListener('mouseup', function(event) 
    {
        const [item, isSwitch] = getClickedItem(canvasDocument, event);
        if(item == undefined) return;
        if(!isSwitch)
            states[item] = false;
            socket.send(JSON.stringify(states));
    }, false);

    socket.onmessage = (event) => 
    {
        render(canvasDocument, ctx, JSON.parse(event.data));
    };
}