window.onload = function() 
{
    var canvasDocument = document.getElementById("boardCanvas");
    var ctx = canvasDocument.getContext("2d");
    var img = new Image;
    img.src = 'resources/DE1-SoC_Layout.png';
    img.onload = function()
    {
        ctx.drawImage(img, 0, 0);
        console.log(img);
    }
}