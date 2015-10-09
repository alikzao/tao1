<!DOCTYPE html>
<html>
<head>
	<title>Игра</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
{#    <style type="text/css"> body { font-family: "Courier New", courier, monospace; font-size: 18px; } </style>#}
    <style>
        html, body { width: 100%; height: 100%; }
        body { background-color: #ffffff; margin: 0; overflow: hidden; font-family: arial; }
        #blocker { position: absolute; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        #instructions { width: 100%; height: 100%; display: -webkit-box; display: -moz-box; display: box; -webkit-box-orient: horizontal; -moz-box-orient: horizontal; box-orient: horizontal; -webkit-box-pack: center; -moz-box-pack: center; box-pack: center; -webkit-box-align: center; -moz-box-align: center; box-align: center; color: #ffffff; text-align: center; cursor: pointer; }
    </style>

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
<script src="/static/game/three.min.js"></script>
{#<script src="/static/game/three.js/build/three.min.js"></script>#}

<script src="/static/game/detector.js"></script>
<script src="/static/game/Stats.js"></script>
{#<script src="/static/game/OrbitControls.js"></script>#}
{#<script src="/static/game/THREEx.WindowResize.js"></script>#}

<script src="/static/core/jquery/jquery1.js"></script>


<div id="blocker">
    <div id="instructions">
        <span style="font-size:40px">Click to play || Нажмите для начала Игры</span>
        <br />
        (W, A, S, D = Move || Движение, &nbsp; &nbsp; SPACE = Jump || Прыжок, &nbsp;&nbsp;MOUSE = Look around || Движение вокруг)
    </div>
</div>
<div id="ThreeJS" style="position: absolute; left:0px; top:0px"></div>




<script>
if (!window.WebSocket) document.body.innerHTML = 'WebSocket в этом браузере не поддерживается.';

var keys, localPlayer, remotePlayers, ws, testvar;
var raycaster, sceneMaterial, sceneMesh, objects = [], sceneGeometry, geometry, container, scene, camera, renderer, controls, stats, clock = new THREE.Clock();
var blocker = document.getElementById( 'blocker' );
var instructions = document.getElementById( 'instructions' );
var havePointerLock = 'pointerLockElement' in document || 'mozPointerLockElement' in document || 'webkitPointerLockElement' in document;
if ( havePointerLock ) {
        {#        var controls = localPlayer;#}
{#    var aaa = new Player();#}
    console.warn('object localPlayer', localPlayer);
    console.warn('havePointerLock ', havePointerLock );
    var element = document.body;
    var pointerlockchange = function ( event ) {
        console.warn('======================pointerlockchange================= ', 'pointerlockchange ');
        console.warn('======================object localPlayer================', localPlayer);
        if ( document.pointerLockElement === element || document.mozPointerLockElement === element || document.webkitPointerLockElement === element ) {
            console.warn('======================object localPlayer================');
            localPlayer.enabled = true;
            blocker.style.display = 'none';
        } else {
            console.warn('--------======================object localPlayer================');
            localPlayer.enabled = false;
            blocker.style.display = '-webkit-box';
            blocker.style.display = '-moz-box';
            blocker.style.display = 'box';
            instructions.style.display = '';
        }
    };
    var pointerlockerror = function ( event ) { instructions.style.display = ''; };
    document.addEventListener( 'pointerlockchange',         pointerlockchange, false );
    document.addEventListener( 'mozpointerlockchange',      pointerlockchange, false );
    document.addEventListener( 'webkitpointerlockchange',   pointerlockchange, false );

    document.addEventListener( 'pointerlockerror',          pointerlockerror,  false );
    document.addEventListener( 'mozpointerlockerror',       pointerlockerror,  false );
    document.addEventListener( 'webkitpointerlockerror',    pointerlockerror,  false );

    instructions.addEventListener( 'click', function ( event ) {
        instructions.style.display = 'none';
        // Ask the browser to lock the pointer
        element.requestPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock;
        if ( /Firefox/i.test( navigator.userAgent ) ) {
            var fullscreenchange = function ( event ) {
                if ( document.fullscreenElement === element || document.mozFullscreenElement === element || document.mozFullScreenElement === element ) {
                    document.removeEventListener( 'fullscreenchange',    fullscreenchange );
                    document.removeEventListener( 'mozfullscreenchange', fullscreenchange );
                    element.requestPointerLock();
                }
            };
            document.addEventListener( 'fullscreenchange',    fullscreenchange, false );
            document.addEventListener( 'mozfullscreenchange', fullscreenchange, false );
            element.requestFullscreen = element.requestFullscreen || element.mozRequestFullscreen || element.mozRequestFullScreen || element.webkitRequestFullscreen;
            element.requestFullscreen();
        } else element.requestPointerLock();
    }, false );
} else instructions.innerHTML = 'Your browser doesn\'t seem to support Pointer Lock API || Ваш браузер не подерживает API блокировки указателя';



init();
animate();

{#var Keys = function(up, left, right, down) {#}
function Keys(up, left, right, down) {
    console.log('lkjdkkkkkkkkkkkkkkkkkkkkkkkkkkkkk  init keys');
	var up = up || false, left = left || false, right = right || false, down = down || false;

    var canJump = false;
    var prevTime = performance.now();
    var velocity =   new THREE.Vector3();
    var stepObject = new THREE.Object3D();
    var yawObject =  new THREE.Object3D();
	yawObject.position.y = 10;
	yawObject.add( stepObject );

	var onKeyDown = function(e) {
		var that = this;
		switch (e.keyCode) {
			case 37: case 65: that.left  = true; break;
			case 38: case 87: that.up    = true; break;
			case 39: case 68: that.right = true; break;
			case 40: case 83: that.down  = true; break;
            case 32: /*space*/
				if ( canJump === true ) velocity.y += 350;
				canJump = false;
				break;
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
    this.update = function(){ };
    this.draw = function(ctx){
{#        ctx.fillStyle="red";#}
{#        ctx.fillRect(x-4, y-4, 8, 8);#}
    };
}
function Player(startX, startY, is_local) {
	var x = startX, y = startY, id, moveAmount = 2, mesh, a=0, b= 0, la=0, lb= 0, z=0;
    var velocity = new THREE.Vector3();
    console.warn('scope.enabled', this.enabled);
	this.getX = function()     { return x; };
	this.getY = function()     { return y; };
	this.getZ = function()     { return z; };
	this.getA = function()     { return a; };
	this.getB = function()     { return b; };
	this.setX = function(newX) { x = newX; };
	this.setY = function(newY) { y = newY; };
	this.setZ = function(newZ) { z = newZ; };
	this.setA = function(newA) { a = newA; };
	this.setB = function(newB) { b = newB; };
    this.getObject = function(){return {x:x, y:y, z:z} };
	this.update = function(keys) {              // Update player position
        if(!this.enabled) return;
		var prevX = x, prevZ = z, prevY = y;    // Previous position
		if (keys.up)         z -= moveAmount;
		else if (keys.down)  z += moveAmount;
		if (keys.left)       x -= moveAmount;
		else if (keys.right) x += moveAmount;
		return prevX != x || prevZ != z;
	};
    this.rot = function() {
        if(!this.enabled ) return;
        var rot = la != a || lb != b || 0;
        la = a; lb = b;
	 	return rot;
	};
	this.init = function() {
{#        if(!this.enabled ) return;#}
        mesh = new THREE.Mesh(new THREE.CubeGeometry( 50, 50, 50 ), new THREE.MeshLambertMaterial( { color:'red'} ) );
        mesh.position.set(x-5, y-5, 0);
        scene.add( mesh );
    };
	this.draw = function() {
        if(!this.enabled ) return;

        camera.rotation.set( 0, 0, 0 );
        var stepObject = new THREE.Object3D();
        stepObject.add( camera );
        var yawObject = new THREE.Object3D();
        yawObject.position.y = 10;
        yawObject.add( pitchObject );

        if ( moveLeft )             velocity.x -= 400.0 * delta;
        if ( moveRight )            velocity.x += 400.0 * delta;
        if ( isOnObject === true )  velocity.y = Math.max( 0, velocity.y );
        yawObject.translateX( velocity.x * delta );
        yawObject.translateY( velocity.y * delta );
        yawObject.translateZ( velocity.z * delta );
        if ( yawObject.position.y < 10 ) {
            velocity.y = 0;
            yawObject.position.y = 10;
            canJump = true;
        }


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
    };
}


function init() {
    scene = new THREE.Scene();
    scene.fog = new THREE.Fog( 0xffffff, 0, 750 );
	var light = new THREE.HemisphereLight( 0xeeeeff, 0x777788, 0.75 );
	light.position.set( 0.5, 1, 0.75 );
    scene.add( light );
	camera = new THREE.PerspectiveCamera( 45, window.innerWidth/window.innerHeight, 0.1, 20000);
	scene.add(camera);
	camera.position.set(0,150,400);
	camera.lookAt(scene.position);
	renderer =  Detector.webgl ? new THREE.WebGLRenderer( {antialias:true} ) : new THREE.CanvasRenderer();
    renderer.setClearColor( 0xffffff );  // цвет окружающего пространства.
	renderer.setSize(window.innerWidth, window.innerHeight);
	document.body.appendChild( renderer.domElement );
    window.addEventListener( 'resize', onWindowResize, false );

{#	controls = new THREE.OrbitControls( camera, renderer.domElement );#}

    stats = new Stats();
	stats.domElement.style.position = 'absolute'; stats.domElement.style.bottom = '0px'; stats.domElement.style.zIndex = 100;
	document.body.appendChild( stats.domElement );


    raycaster = new THREE.Raycaster( new THREE.Vector3(), new THREE.Vector3( 0, - 1, 0 ), 0, 10 );
    //scene
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
    // endScene
    //obgects
    sceneGeometry = new THREE.BoxGeometry( 20, 20, 20 );
    for ( var i = 0, l = sceneGeometry.faces.length; i < l; i ++ ) {
        var face = sceneGeometry.faces[ i ];
        face.vertexColors[ 0 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 1 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 2 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
    }
    for ( var i = 0; i < 500; i ++ ) {
        sceneMaterial = new THREE.MeshPhongMaterial( { specular: 0xffffff, shading: THREE.FlatShading, vertexColors: THREE.VertexColors } );
        var mesh = new THREE.Mesh( sceneGeometry, sceneMaterial );
        mesh.position.x = Math.floor( Math.random() * 20 - 10 ) * 20;
        mesh.position.y = Math.floor( Math.random() * 20 ) * 20 + 10;
        mesh.position.z = Math.floor( Math.random() * 20 - 10 ) * 20;
        scene.add( mesh );
        sceneMaterial.color.setHSL( Math.random() * 0.2 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        objects.push( mesh );
    }
    //endObjects

	keys = new Keys();
//	var startX = Math.round(Math.random()*(canvas.width-5)),  startY = Math.round(Math.random()*(canvas.height-5));#}
	var startX = 65,  startY = 25;
	localPlayer = new Player(startX, startY, true);
    localPlayer.init();
    ws = new WebSocket('ws://78.47.225.242:8088/');
{#    ws = new WebSocket('ws://localhost:8088/');#}
	remotePlayers = [];
	setEventHandlers();
}
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize( window.innerWidth, window.innerHeight );
}

function setEventHandlers() {
	document.addEventListener("keydown",   function(e){ if (localPlayer)  keys.onKeyDown(e);  }, false);
	document.addEventListener("keyup",     function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
	document.addEventListener("click",     function(e){ if (localPlayer)  new Bullet(e);    }, false);
    document.addEventListener('mousemove', function(e){
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
