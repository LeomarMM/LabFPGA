var socket;

function startWs() {
    socket = new WebSocket('ws://'+window.location.host);
    socket.onmessage = (event) => {
        var canvasDocument = document.getElementById('board-canvas');
        const msg = JSON.parse(event.data);
        for(item in states) {
            states[item] = msg[item].value;
        }
        render(canvasDocument, canvasDocument.getContext('2d'), msg);
    };
    socket.onclose = (event) => {
        console.error('Socket connection closed. Reconnecting.');
        setTimeout(startWs, 1000);
    };
}

function getSocket() {
    return socket;
}