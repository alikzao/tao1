<!DOCTYPE html>
<html>
<head>
	<title>Игра</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
    <style type="text/css"> body { font-family: "Courier New", courier, monospace; font-size: 18px; } </style>
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
{#<script src="/static/game/three.min.js"></script>#}
<script src="/static/game/three.js/build/three.min.js"></script>

<script src="/static/game/detector.js"></script>
<script src="/static/game/Stats.js"></script>
<script src="/static/game/OrbitControls.js"></script>
<script src="/static/game/THREEx.WindowResize.js"></script>

<script src="/static/core/jquery/jquery1.js"></script>


<div id="ThreeJS" style="position: absolute; left:0px; top:0px"></div>
{#<canvas id="gameCanvas"></canvas>#}



<script>
if (!window.WebSocket) document.body.innerHTML = 'WebSocket в этом браузере не поддерживается.';

var keys, localPlayer, remotePlayers, ws;
var raycaster, sceneMaterial, sceneMesh, sceneGeometry, geometry, container, scene, camera, renderer, controls, stats, clock = new THREE.Clock();

init();
animate();

{#var Keys = function(up, left, right, down) {#}
function Keys(up, left, right, down) {
    console.log('lkjdkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
	var up = up || false, left = left || false, right = right || false, down = down || false;
	var onKeyDown = function(e) {
		var that = this;
		switch (e.keyCode) {
			case 37: case 65: that.left  = true; break;
			case 38: case 87: that.up    = true; break;
			case 39: case 68: that.right = true; break;
			case 40: case 83: that.down  = true; break;
		}
	};
	var onKeyUp = function(e) {
		var that = this;
		switch (e.keyCode) {
			case 37: case 65: that.left  = false; break;
			case 38: case 87: that.up    = false; break;
			case 39: case 68: that.right = false; break;
			case 40: case 83: that.down  = false; break;
		}
	};
	return { up:up, left:left, right:right, down:down, onKeyDown: onKeyDown, onKeyUp: onKeyUp };
}

function Bullet(){
    var update = function(){ };
    var draw = function(ctx){
{#        ctx.fillStyle="red";#}
{#        ctx.fillRect(x-4, y-4, 8, 8);#}
    };
}
function Player(startX, startY, is_local) {
	var x = startX, y = startY, id, moveAmount = 2, mesh, a=0, b= 0, la=0, lb= 0, z=0;
	var getX = function()     { return x; };
	var getY = function()     { return y; };
	var getZ = function()     { return z; };
	var getA = function()     { return a; };
	var getB = function()     { return b; };
	var setX = function(newX) { x = newX; };
	var setY = function(newY) { y = newY; };
	var setZ = function(newZ) { z = newZ; };
	var setA = function(newA) { a = newA; };
	var setB = function(newB) { b = newB; };
{#	var update = function(keys) {   // Update player position#}
{#		// Previous position#}
{#		var prevX = x, prevY = y;#}
{#		if (keys.up)         y -= moveAmount;#}
{#		else if (keys.down)  y += moveAmount;#}
{#		if (keys.left)       x -= moveAmount;#}
{#        else if (keys.right) x += moveAmount;#}
{#		return prevX != x || prevY != y;#}
{#	};#}
	var update = function(keys) {   // Update player position
		// Previous position
		var prevX = x, prevZ = z;
		if (keys.up)         z -= moveAmount;
		else if (keys.down)  z += moveAmount;
		if (keys.left)       x -= moveAmount;
		else if (keys.right) x += moveAmount;
		return prevX != x || prevZ != z;
	};
    var rot = function() {   // Update player position
        var rot = la != a || lb != b || 0;
        la = a; lb = b;
	 	return rot;
	};

	var init = function() {
        mesh = new THREE.Mesh(new THREE.CubeGeometry( 50, 50, 50 ), new THREE.MeshLambertMaterial( { color:0x7777ff} ) );
        mesh.position.set(x-5, y-5, 0);
        scene.add( mesh );
    };
	var draw = function() {
        mesh.position.set(x, y, z);
        mesh.rotation.set(0, 0, 0);
        mesh.rotation.x = a;
        mesh.rotation.y = b;

         if (is_local) {
             var cameraOffset = new THREE.Vector3(0, 50, 200).applyMatrix4(mesh.matrixWorld);
             camera.position.x = cameraOffset.x;
             camera.position.y = cameraOffset.y;
             camera.position.z = cameraOffset.z;
             camera.lookAt(mesh.position);
         }
            //mesh.translateZ( y);
            //mesh.translateX( x );
    };
	return { getX:getX, getY:getY, getZ:getZ, setX:setX, setY:setY, setZ:setZ, getA:getA, getB:getB, setA:setA, setB:setB, update:update, draw:draw, init:init, rot:rot }
}


function init() {
{#	canvas = document.getElementById("gameCanvas");#}
{#	ctx = canvas.getContext("2d");#}
    scene = new THREE.Scene();
    var SCREEN_WIDTH = window.innerWidth, SCREEN_HEIGHT = window.innerHeight;
	var VIEW_ANGLE = 45, ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT, NEAR = 0.1, FAR = 20000;
	camera = new THREE.PerspectiveCamera( VIEW_ANGLE, ASPECT, NEAR, FAR);
	scene.add(camera);
	camera.position.set(0,150,400);
	camera.lookAt(scene.position);
	renderer =  Detector.webgl ? new THREE.WebGLRenderer( {antialias:true} ) : new THREE.CanvasRenderer();
	renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
	container = document.getElementById( 'ThreeJS' );
	container.appendChild( renderer.domElement );

	controls = new THREE.OrbitControls( camera, renderer.domElement );

    stats = new Stats();
	stats.domElement.style.position = 'absolute'; stats.domElement.style.bottom = '0px'; stats.domElement.style.zIndex = 100;
	container.appendChild( stats.domElement );

	var light = new THREE.PointLight(0xffffff);
	light.position.set(0,250,0);
	scene.add(light);


    raycaster = new THREE.Raycaster( new THREE.Vector3(), new THREE.Vector3( 0, - 1, 0 ), 0, 10 );
    sceneGeometry = new THREE.PlaneGeometry( 2000, 2000, 100, 100 );
    sceneGeometry.applyMatrix( new THREE.Matrix4().makeRotationX( - Math.PI / 2 ) );
    for ( var i = 0, l = sceneGeometry.vertices.length; i < l; i ++ ) {
        var vertex = sceneGeometry.vertices[ i ];
        vertex.x += Math.random() * 20 - 10;
        vertex.y += Math.random() * 2;
        vertex.z += Math.random() * 20 - 10;
    }
    for ( var i = 0, l = sceneGeometry.faces.length; i < l; i ++ ) {
        var face = sceneGeometry.faces[ i ];
        face.vertexColors[ 0 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 1 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 2 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
    }
    sceneMaterial = new THREE.MeshBasicMaterial( { vertexColors: THREE.VertexColors } );
    sceneMesh = new THREE.Mesh( sceneGeometry, sceneMaterial );
    scene.add( sceneMesh );


{#	var floorMaterial = new THREE.MeshBasicMaterial( {color:0x444444, side:THREE.DoubleSide} );#}
{#	var floorGeometry = new THREE.PlaneGeometry(440, 1000, 10, 10);#}
{#	var floor = new THREE.Mesh(floorGeometry, floorMaterial);#}
{#	floor.position.y = -0.5;#}
{#	floor.rotation.x = Math.PI / 2;#}
{#	scene.add(floor);#}

	scene.fog = new THREE.FogExp2( 0x9999ff, 0.00025 );
	//canvas.width = window.innerWidth;
	//canvas.height = window.innerHeight;
	keys = new Keys();
//	var startX = Math.round(Math.random()*(canvas.width-5)),  startY = Math.round(Math.random()*(canvas.height-5));#}
	var startX = 65,  startY = 25;
	localPlayer = new Player(startX, startY, true);
    localPlayer.init();
{#    ws = new WebSocket('ws://78.47.225.242:8088/');#}
    ws = new WebSocket('ws://localhost:8088/');
	remotePlayers = [];
	setEventHandlers();
}

function setEventHandlers() {
	window.addEventListener("keydown",   function(e){ if (localPlayer)  keys.onKeyDown(e);  }, false);
	window.addEventListener("keyup",     function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
	window.addEventListener("click",     function(e){ if (localPlayer)  new Bullet(e);    }, false);
    window.addEventListener('mousemove', function(e){
	    if (localPlayer) {
		    var x = e.movementX     || e.mozMovementX      || e.webkitMovementX   || 0;
            var y = e.movementY     || e.mozMovementY      || e.webkitMovementY   || 0;
            if (y) localPlayer.setA(Math.max(Math.PI * -0.5, Math.min(Math.PI * 0.5, localPlayer.getA() - y * 0.002)));
	        if (x) localPlayer.setB(localPlayer.getB() - x * 0.002);
        }    }, false);
{#	window.addEventListener("resize", onResize, false);#}

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
            console.log("New player connected: "+msg.id+' msg.msg '+msg.msg );
            var newPlayer = new Player(msg.x, msg.y);
            newPlayer.id = msg.id;
            newPlayer.init();
            remotePlayers.push(newPlayer);    // Add new player to the remote players array
        }else if(msg.e == 'move' ){
           	var movePlayer = playerById(msg.id);
            console.log('remotePlayers', remotePlayers);
            if (!movePlayer) {    console.log("Player not found: "+msg.id+' msg.msg '+msg.msg ); return; }
            console.log('Update player position');
            movePlayer.setX(msg.x);
            movePlayer.setY(msg.y);
        }else if(msg.e == 'rotate' ){
           	var movePlayer = playerById(msg.id);
            console.log('rotatePlayers', remotePlayers);
            if (!movePlayer) {   console.log("Player not found: "+msg.id+' msg.msg '+msg.msg ); return; }
            console.log('Update player position');
            movePlayer.setA(msg.a);
            movePlayer.setB(msg.b);
        } else if(msg.e == 'remove'){
            var removePlayer = playerById(msg.id);
            if (!removePlayer) { console.log("Player not found: "+msg.id+' msg.msg '+msg.msg ); return; }
            remotePlayers.splice(remotePlayers.indexOf(removePlayer), 1);
        }
    };
    ws.onclose = function(e)  {
        console.log('close: ', e);
        if (e.wasClean) console.log('Соединение закрыто чисто');
        else console.log('Обрыв соединения');
        console.log('Код: ' + e.code + ' причина: ' + e.reason);
    };
    ws.onerror = function(error)  {
        console.log("Ошибка onerror:   "      + error);
        console.log("Ошибка error.message:  " + error.message);
    };
}

/** если произошло нажатие клавиш отправляем сокеты на сервер, рисуем локального игрока, и ели есть в наличии рисуем удаленных игроков*/
function animate() {
    requestAnimationFrame( animate );

    var u = localPlayer.update(keys), r = localPlayer.rot();
	if (u) ws.send(JSON.stringify({'e': 'move', 'x': localPlayer.getX(), 'y': localPlayer.getY(), 'z': localPlayer.getZ() } ) );
	if (r) ws.send( JSON.stringify( { 'e':'rotate', 'id':localPlayer.id, 'a': localPlayer.getA(), 'b': localPlayer.getB() } ) );
	if (u || r) localPlayer.draw();

	for (var i = 0; i < remotePlayers.length; i++) {
		remotePlayers[i].draw();
	}
	renderer.render( scene, camera );
}

function playerById(id) {
	for (var i = 0; i < remotePlayers.length; i++) {
		if (remotePlayers[i].id == id)  return remotePlayers[i];
	}
	return false;
}



</script>

</body>
</html>






{#function update() {#}
{#	// Update local player and check for change#}
{#	if (localPlayer.update(keys)) #}
{#		ws.send( JSON.stringify({'e':'move', 'x':localPlayer.getX(), 'y':localPlayer.getY()} ));#}
{# }#}
{#/** GAME DRAW */#}
{#function draw() {#}
{#//	ctx.clearRect(0, 0, canvas.width, canvas.height); // Wipe the canvas clean#}
{#	localPlayer.draw();                            // Draw the local player#}
{#	for (var i = 0; i < remotePlayers.length; i++) {    // Draw the remote players#}
{#		remotePlayers[i].draw();#}
{#	}#}
{# }#}
{#/** GAME HELPER FUNCTIONS */#}
{#function playerById(id) {#}
{#	for (var i = 0; i < remotePlayers.length; i++) {#}
{#		if (remotePlayers[i].id == id)  return remotePlayers[i];#}
{#	}#}
{#	return false;#}
{# }#}
{##}
{#function render(){   renderer.render( scene, camera );   }#}
