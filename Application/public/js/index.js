window.onload = function() 
{
    var canvasDocument = document.getElementById("board-canvas");
    var form = document.getElementById("bts-form");
    var file = document.getElementById("bitstream-file");
    var button = document.getElementById("bitstream-button");
    var ctx = canvasDocument.getContext("2d");
    for(var i = 0; i<=9; i++) renderSwitch("SW"+i, false, ctx);
    canvasDocument.addEventListener('touchstart', (event) => {selectStart(canvasDocument, event, getSocket(), false)}, false);
    canvasDocument.addEventListener('mousedown', (event) => {selectStart(canvasDocument, event, getSocket(), true)}, false);
    canvasDocument.addEventListener('touchend', (event) => {selectEnd(canvasDocument, event, getSocket(), false)}, false);
    canvasDocument.addEventListener('mouseup', (event) => {selectEnd(canvasDocument, event, getSocket(), true)}, false);
    button.onclick = () =>
    {
        file.click();
    }
    file.onchange = () =>
    {
        form.submit();
        file.value = null;
    }
    startWs();
}