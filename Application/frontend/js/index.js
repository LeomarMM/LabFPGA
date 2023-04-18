const displaySegmentImages = 
{
    a: new Image,
    b: new Image,
    c: new Image,
    d: new Image,
    e: new Image
};
const segments =
{
    0: displaySegmentImages.a,
    1: displaySegmentImages.d,
    2: displaySegmentImages.d,
    3: displaySegmentImages.b,
    4: displaySegmentImages.c,
    5: displaySegmentImages.c,
    6: displaySegmentImages.e
};

window.onload = function() 
{
    var canvasDocument = document.getElementById("boardCanvas");
    var ctx = canvasDocument.getContext("2d");
    displaySegmentImages.a.src = 'resources/a.png';
    displaySegmentImages.b.src = 'resources/b.png';
    displaySegmentImages.c.src = 'resources/c.png';
    displaySegmentImages.d.src = 'resources/d.png';
    displaySegmentImages.e.src = 'resources/e.png';
    canvasDocument.addEventListener('click', function() 
    {
        data =
        {
            0: true,
            1: true,
            2: true,
            3: false,
            4: false, 
            5: false,
            6: false
        }
        renderDisplay(ctx, data, [82, 586]);
        console.log("I am here, so you know that your click has worked! :D");
    }, false);
}

function renderDisplay(context, data, offset)
{
    const positions = 
    {
        0: {x: 3, y: 0},
        1: {x: 23, y: 3},
        2: {x: 23, y: 28},
        3: {x: 3, y: 48},
        4: {x: 0, y: 28},
        5: {x: 0, y: 3},
        6: {x: 5, y: 24}
    };
    for(id in positions)
        if(data[id]) 
            context.drawImage(segments[id], positions[id].x + offset[0], positions[id].y + offset[1]);
}