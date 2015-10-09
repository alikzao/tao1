<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
</head>
<body>

<!-- форма для отправки сообщений -->
<form name="publish">
  <input type="text" name="message"/>
  <input type="submit" value="Отправить"/>
</form>
<!-- здесь будут появляться входящие сообщения -->
<div id="subscribe"></div>
{#<script src="/static/game/node/requestAnimationFrame.js"></script>#}


<canvas id="gameCanvas"></canvas>



<script>
if (!window.WebSocket) document.body.innerHTML = 'WebSocket в этом браузере не поддерживается.';

init();
animate();

{#var Keys = function(up, left, right, down) {#}
function Keys(up, left, right, down) {
    console.log('lkjdkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
	var up = up || false, left = left || false, right = right || false, down = down || false;
	var onKeyDown = function(e) {
		var that = this, c = e.keyCode;
		switch (c) {
			case 37: case 65: that.left  = true; break;
			case 38: case 87: that.up    = true; break;
			case 39: case 68: that.right = true; break;
			case 40: case 83: that.down  = true; break;
		}
	};
	var onKeyUp = function(e) {
		var that = this, c = e.keyCode;
		switch (c) {
			case 37: case 65: that.left  = false; break;
			case 38: case 87: that.up    = false; break;
			case 39: case 68: that.right = false; break;
			case 40: case 83: that.down  = false; break;
		}
	};
	return { up:up, left:left, right:right, down:down, onKeyDown: onKeyDown, onKeyUp: onKeyUp };
}

function Player(startX, startY) {
	var x = startX, y = startY, id, moveAmount = 2;
	var getX = function()     { return x; };
	var getY = function()     { return y; };
	var setX = function(newX) { x = newX; };
	var setY = function(newY) { y = newY; };
	var update = function(keys) {   // Update player position
		// Previous position
		var prevX = x, prevY = y;
		if (keys.up)         y -= moveAmount;
		else if (keys.down)  y += moveAmount;
		if (keys.left)       x -= moveAmount;
        else if (keys.right) x += moveAmount;
		return (prevX != x || prevY != y) ? true : false;
	};
	var draw = function(ctx) { ctx.fillRect(x-5, y-5, 10, 10); };
	// Define which variables and methods can be accessed
	return { getX: getX, getY: getY, setX: setX, setY: setY, update: update, draw: draw }
}

/** GAME VARIABLES */
var canvas, ctx, keys, localPlayer, remotePlayers, ws;
/** GAME INITIALISATION */
function init() {
	canvas = document.getElementById("gameCanvas");
	ctx = canvas.getContext("2d");
	// Maximise the canvas
	canvas.width = window.innerWidth;
	canvas.height = window.innerHeight;
	keys = new Keys();
	// Calculate a random start position for the local player The minus 5 (half a player size) stops the player being placed right on the egde of the screen
	var startX = Math.round(Math.random()*(canvas.width-5)),  startY = Math.round(Math.random()*(canvas.height-5));
	localPlayer = new Player(startX, startY);
{#    ws = new WebSocket('ws://78.47.225.242:8765/');#}
    ws = new WebSocket('ws://localhost:8088/');
	remotePlayers = [];
	setEventHandlers();
}

function setEventHandlers() {
	window.addEventListener("keydown", function(e){ if (localPlayer)  keys.onKeyDown(e);  }, false);
	window.addEventListener("keyup",   function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
	window.addEventListener("resize", onResize, false);

    document.forms.publish.onsubmit = function() {
        ws.send( this.message.value );
        return false;
    };
    ws.onopen = function() {
       	console.log("Connected to socket server", localPlayer.getX(), localPlayer.getY() );
    	ws.send( JSON.stringify({'e':"new", 'x':localPlayer.getX(), 'y':localPlayer.getY()}) );
    };
    ws.onmessage = function(event){
        var msg = JSON.parse(event.data);
        console.warn('event.data', msg);
        if(msg.e == 'chat') {
            console.warn('msg', msg);
            var msgElem = document.createElement('div');
            msgElem.appendChild(document.createTextNode(msg));
            document.getElementById('subscribe').appendChild(msgElem);
            return false;
        }else if(msg.e == 'new'){
            console.log("New player connected: "+msg.id+' msg.msg'+msg.msg );
            var newPlayer = new Player(msg.x, msg.y);
            newPlayer.id = msg.id;
            remotePlayers.push(newPlayer);    // Add new player to the remote players array
        }else if(msg.e == 'move' ){
           	var movePlayer = playerById(msg.id);
            console.log('remotePlayers', remotePlayers);
            if (!movePlayer) {
                console.log("Player not found: "+msg.id+' msg.msg'+msg.msg );
                return;
            }
            console.log('Update player position');
            movePlayer.setX(msg.x);
            movePlayer.setY(msg.y);
        } else if(msg.e == 'remove'){
            var removePlayer = playerById(msg.id);
            if (!removePlayer) {
                console.log("Player not found: "+msg.id+' msg.msg'+msg.msg );
                return;
            }
            remotePlayers.splice(remotePlayers.indexOf(removePlayer), 1);
        }
    };
    ws.onclose = function(event)  {
        console.log("Disconnected from socket server");
    };
    ws.onerror = function(error)  {
        console.log("Ошибка " + error.message);
    };
}
{#function onKeydown(e) { if (localPlayer) { keys.onKeyDown(e); } }#}
{#function onKeyup(e) { if (localPlayer)   { keys.onKeyUp(e);   } }#}
function onResize(e) {
	// Maximise the canvas
	canvas.width = window.innerWidth;
	canvas.height = window.innerHeight;
}
/** GAME ANIMATION LOOP */
function animate() {
	update();
	draw();
	window.requestAnimFrame(animate);
}

/** GAME UPDATE */
function update() {
	// Update local player and check for change
	if (localPlayer.update(keys)) {
		ws.send( JSON.stringify({'e':'move', 'x':localPlayer.getX(), 'y':localPlayer.getY()} ));
	}
}
/** GAME DRAW */
function draw() {
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	localPlayer.draw(ctx);
	for (var i = 0; i < remotePlayers.length; i++) {  // Draw the remote players
		remotePlayers[i].draw(ctx);
	}
}
/** GAME HELPER FUNCTIONS */
function playerById(id) {
	for (var i = 0; i < remotePlayers.length; i++) {
		if (remotePlayers[i].id == id)  return remotePlayers[i];
	}
	return false;
}




</script>
<style type="text/css">
html, body, div, span, applet, object, iframe, h1, h2, h3, h4, h5, h6, p, blockquote, pre, a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp, small, strike, strong, sub, sup, tt, var, b, u, i, center, dl, dt, dd, ol, ul, li,
fieldset, form, label, legend, table, caption, tbody, tfoot, thead, tr, th, td, article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup, menu, nav, output, ruby, section, summary,
time, mark, audio, video { margin: 0; padding: 0; border: 0; font-size: 100%; font: inherit; vertical-align: baseline; }
article, aside, details, figcaption, figure, footer, header, hgroup, menu, nav, section { display: block; }
body { line-height: 1; }
ol, ul { list-style: none; }
blockquote, q { quotes: none; }
blockquote:before, blockquote:after,
q:before, q:after { content: ''; content: none; }
table { border-collapse: collapse; border-spacing: 0; }

body { overflow: hidden; }
canvas { display: block; }
</style>

</body>
</html>



{#function onSocketConnected() {#}
{#	console.log("Connected to socket server", localPlayer.getX(), localPlayer.getY() );#}
{#	ws.send( JSON.stringify({'e':"new", 'x':localPlayer.getX(), 'y':localPlayer.getY()}) );#}
{# }#}
{#function onNewPlayer(data) {#}
{#	console.log("New player connected: "+data.id);#}
{#	var newPlayer = new Player(data.x, data.y);#}
{#	newPlayer.id = data.id;#}
{#	remotePlayers.push(newPlayer);    // Add new player to the remote players array#}
{# }#}
{#function onMovePlayer(data) {#}
{#	var movePlayer = playerById(data.id);#}
{#	if (!movePlayer) {#}
{#		console.log("Player not found: "+data.id);
{#		return;#}
{#	}#}
{#	console.log('Update player position');#}
{#	movePlayer.setX(data.x);#}
{#	movePlayer.setY(data.y);#}
{# }#}
{#function onRemovePlayer(data) {#}
{#	var removePlayer = playerById(data.id);#}
{#	if (!removePlayer) {#}
{#		console.log("Player not found: "+data.id);#}
{#		return;#}
{#	}#}
{#	remotePlayers.splice(remotePlayers.indexOf(removePlayer), 1);#}
{# }#}


{#http://parser-gis.com/#}
{#http://mail-baza.com/#}
{#http://avito-baza.com/#}
{#http://parser-ruzakaz.com/#}
{#http://parser-yandex.com/#}