var msg;
window.onload = function() 
{
    var canvasDocument = document.getElementById("boardCanvas");
    var ctx = canvasDocument.getContext("2d");
    var socket = new WebSocket("ws://localhost:3000");
    canvasDocument.addEventListener('click', function() 
    {
        
    }, false);
    socket.onmessage = (event) => 
    {
        render(canvasDocument, ctx, JSON.parse(event.data));
    };
}
function render(canvasDocument, context, object)
{
    context.clearRect(0,0, canvasDocument.width, canvasDocument.height);
    renderDisplay(context, object.HEX5.value, displayOffset.HEX5);
    renderDisplay(context, object.HEX4.value, displayOffset.HEX4);
    renderDisplay(context, object.HEX3.value, displayOffset.HEX3);
    renderDisplay(context, object.HEX2.value, displayOffset.HEX2);
    renderDisplay(context, object.HEX1.value, displayOffset.HEX1);
    renderDisplay(context, object.HEX0.value, displayOffset.HEX0);
}