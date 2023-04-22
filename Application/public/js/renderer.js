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

displaySegmentImages.a.src = 'resources/a.png';
displaySegmentImages.b.src = 'resources/b.png';
displaySegmentImages.c.src = 'resources/c.png';
displaySegmentImages.d.src = 'resources/d.png';
displaySegmentImages.e.src = 'resources/e.png';

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
            context.drawImage(segments[id], positions[id].x + offset.x, positions[id].y + offset.y);
}

function render(canvasDocument, context, object)
{
    context.clearRect(0,0, canvasDocument.width, canvasDocument.height);
    for(var i = 0; i<=5; i++)
        renderDisplay(context, object["HEX"+i].value, offsets["HEX"+i]);
    for(var i = 0; i<=9; i++)
    {
        if(!object["SW"+i].value) continue;
        context.beginPath();
        context.rect(offsets["LED"+i].x, offsets["LED"+i].y, 8, 15);
        context.fillStyle = "red";
        context.fill();
    }
}