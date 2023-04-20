window.onload = function() 
{
    var canvasDocument = document.getElementById("boardCanvas");
    var ctx = canvasDocument.getContext("2d");
    canvasDocument.addEventListener('click', function() 
    {
        ctx.clearRect(0, 0, canvasDocument.width, canvasDocument.height);
    }, false);
}