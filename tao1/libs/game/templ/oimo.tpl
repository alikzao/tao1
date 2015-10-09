<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>three.js - pointerlock controls</title>
		<style>
			html, body { width: 100%; height: 100%; }
            body { background-color: #ffffff; margin: 0; overflow: hidden; font-family: arial; }
            #blocker { position: absolute; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
            #instructions { width: 100%; height: 100%; display: -webkit-box; display: -moz-box; display: box; -webkit-box-orient: horizontal; -moz-box-orient: horizontal; box-orient: horizontal; -webkit-box-pack: center; -moz-box-pack: center; box-pack: center; -webkit-box-align: center; -moz-box-align: center; box-align: center; color: #ffffff; text-align: center; cursor: pointer; }
        </style>
    </head>
	<body>
	<script src="/static/game/three.min.js"></script>
		<div id="blocker">
			<div id="instructions">
				<span style="font-size:40px">Click to play</span>
				<br />
				(W, A, S, D = Move, SPACE = Jump, MOUSE = Look around)
			</div>
		</div>
<script>


THREE.PointerLockControls = function ( camera ) {
	var scope = this;
{#	camera.rotation.set( 0, 0, 0 );#}
    mesh = new THREE.Mesh(new THREE.CubeGeometry( 50, 50, 50 ), new THREE.MeshLambertMaterial( { color:'red'} ) );
	var pitchObject = new THREE.Object3D();
	pitchObject.add( camera );
	var yawObject = new THREE.Object3D();
	pitchObject.add( mesh );
	yawObject.add( mesh );
	yawObject.position.y = 10;
	yawObject.add( pitchObject );
	var moveForward = false;
	var moveBackward = false;
	var moveLeft = false;
	var moveRight = false;
	var isOnObject = false;
	var canJump = false;
	var prevTime = performance.now();
	var velocity = new THREE.Vector3();

	var onMouseMove = function ( event ) {
		if ( scope.enabled === false ) return;
		var movementX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
		var movementY = event.movementY || event.mozMovementY || event.webkitMovementY || 0;
		yawObject.rotation.y -= movementX * 0.002;
		pitchObject.rotation.x -= movementY * 0.002;
		pitchObject.rotation.x = Math.max( -  Math.PI/2, Math.min(  Math.PI/2, pitchObject.rotation.x ) );
	};
	var onKeyDown = function ( event ) {
		switch ( event.keyCode ) {
			case 38: /*up*/ case 87: /*w*/    moveForward = true;  break;
			case 37: /*left*/ case 65: /*a*/  moveLeft = true;     break;
			case 40: /*down*/ case 83: /*s*/  moveBackward = true; break;
			case 39: /*right*/ case 68: /*d*/ moveRight = true;    break;
			case 32: /*space*/
				if ( canJump === true ) velocity.y += 500;
				canJump = false;
				break;
		}
	};
	var onKeyUp = function ( event ) {
		switch( event.keyCode ) {
			case 38: /*up*/ case 87: /*w*/    moveForward = false;  break;
			case 37: /*left*/ case 65: /*a*/  moveLeft = false;     break;
			case 40: /*down*/ case 83: /*s*/  moveBackward = false; break;
			case 39: /*right*/ case 68: /*d*/ moveRight = false;    break;
		}
	};
	document.addEventListener( 'mousemove', onMouseMove, false );
	document.addEventListener( 'keydown',   onKeyDown,   false );
	document.addEventListener( 'keyup',     onKeyUp,     false );
	this.enabled = false;
	this.getObject = function () { return yawObject; };
	this.isOnObject = function ( boolean ) {
		isOnObject = boolean;
		canJump = boolean;
	};
	this.getDirection = function() {
		// assumes the camera itself is not rotated
		var direction = new THREE.Vector3( 0, 0, -1 );
		var rotation = new THREE.Euler( 0, 0, 0, "YXZ" );
		return function( v ) {
			rotation.set( pitchObject.rotation.x, yawObject.rotation.y, 0 );
			v.copy( direction ).applyEuler( rotation );
			return v;
		}
	}();
	this.update = function () {
		if ( scope.enabled === false ) return;
		var time = performance.now();
		var delta = ( time - prevTime ) / 1000;
		velocity.x -= velocity.x * 10.0 * delta;
		velocity.z -= velocity.z * 10.0 * delta;
		velocity.y -= 9.8 * 100.0 * delta; // 100.0 = mass
		if ( moveForward )          velocity.z -= 400.0 * delta;
		if ( moveBackward )         velocity.z += 400.0 * delta;
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
		prevTime = time;
	};
};



var camera, scene, renderer, geometry, material, mesh, controls, raycaster, objects = [];
var blocker = document.getElementById( 'blocker' );
var instructions = document.getElementById( 'instructions' );
// http://www.html5rocks.com/en/tutorials/pointerlock/intro/
var havePointerLock = 'pointerLockElement' in document || 'mozPointerLockElement' in document || 'webkitPointerLockElement' in document;
if ( havePointerLock ) {
    var element = document.body;
    var pointerlockchange = function ( event ) {
        if ( document.pointerLockElement === element || document.mozPointerLockElement === element || document.webkitPointerLockElement === element ) {
            controls.enabled = true;
            blocker.style.display = 'none';
        } else {
            controls.enabled = false;
            blocker.style.display = '-webkit-box';
            blocker.style.display = '-moz-box';
            blocker.style.display = 'box';
            instructions.style.display = '';
        }
    };
    var pointerlockerror = function ( event ) { instructions.style.display = ''; };
    // Hook pointer lock state change events
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
} else instructions.innerHTML = 'Your browser doesn\'t seem to support Pointer Lock API';

init();
animate();
function init() {
    camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 1000 );
    scene = new THREE.Scene();
    scene.fog = new THREE.Fog( 0xffffff, 0, 750 );
    var light = new THREE.HemisphereLight( 0xeeeeff, 0x777788, 0.75 );
    light.position.set( 0.5, 1, 0.75 );
    scene.add( light );
    controls = new THREE.PointerLockControls( camera );
    scene.add( controls.getObject() );
    raycaster = new THREE.Raycaster( new THREE.Vector3(), new THREE.Vector3( 0, - 1, 0 ), 0, 10 );
    // floor
    geometry = new THREE.PlaneGeometry( 2000, 2000, 100, 100 );
    geometry.applyMatrix( new THREE.Matrix4().makeRotationX( - Math.PI / 2 ) );
    for ( var i = 0, l = geometry.vertices.length; i < l; i ++ ) {
        var vertex = geometry.vertices[ i ];
        vertex.x += Math.random() * 20 - 10;
        vertex.y += Math.random() * 2;
        vertex.z += Math.random() * 20 - 10;
    }
    for ( var i = 0, l = geometry.faces.length; i < l; i ++ ) {
        var face = geometry.faces[ i ];
        face.vertexColors[ 0 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 1 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 2 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
    }
    material = new THREE.MeshBasicMaterial( { vertexColors: THREE.VertexColors } );
    mesh = new THREE.Mesh( geometry, material );
    scene.add( mesh );
    // objects
    geometry = new THREE.BoxGeometry( 20, 20, 20 );
    for ( var i = 0, l = geometry.faces.length; i < l; i ++ ) {
        var face = geometry.faces[ i ];
        face.vertexColors[ 0 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 1 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        face.vertexColors[ 2 ] = new THREE.Color().setHSL( Math.random() * 0.3 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
    }
    for ( var i = 0; i < 500; i ++ ) {
        material = new THREE.MeshPhongMaterial( { specular: 0xffffff, shading: THREE.FlatShading, vertexColors: THREE.VertexColors } );
        var mesh = new THREE.Mesh( geometry, material );
        mesh.position.x = Math.floor( Math.random() * 20 - 10 ) * 20;
        mesh.position.y = Math.floor( Math.random() * 20 ) * 20 + 10;
        mesh.position.z = Math.floor( Math.random() * 20 - 10 ) * 20;
        scene.add( mesh );
        material.color.setHSL( Math.random() * 0.2 + 0.5, 0.75, Math.random() * 0.25 + 0.75 );
        objects.push( mesh );
    }
    renderer = new THREE.WebGLRenderer();
    renderer.setClearColor( 0xffffff );
    renderer.setSize( window.innerWidth, window.innerHeight );
    document.body.appendChild( renderer.domElement );
    window.addEventListener( 'resize', onWindowResize, false );
}
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize( window.innerWidth, window.innerHeight );
}
function animate() {
    requestAnimationFrame( animate );
    controls.isOnObject( false );
    raycaster.ray.origin.copy( controls.getObject().position );
{#    raycaster.ray.origin.y -= 10;#}
    var intersections = raycaster.intersectObjects( objects );
    if ( intersections.length > 0 )  controls.isOnObject( true );
    controls.update();
    renderer.render( scene, camera );
}



		</script>
	</body>
</html>