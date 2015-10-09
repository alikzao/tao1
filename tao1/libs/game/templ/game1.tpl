<!doctype html>
<html lang="en">
<head>
	<title>Игра</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
    <style type="text/css">
{#        body { font-family: Monospace; font-weight: bold; background-color: #ccccff; margin: 0px; overflow: hidden; }#}
        body { font-family: "Courier New", courier, monospace; font-size: 18px; }
        #status { color: gray; border: 1px solid gray; text-align: center; width: 300px; margin-left: 14px; margin-bottom: 24px; background-color: #eee; }
        #input-holder { padding-left: 10px; }
        #msg { width: 300px; }
        #body { width: 350px; }
        #inbox { margin-right: 10px; opacity: 0.7; background-color: #f2f2f2; max-height: 200px; }
        .msg, input { margin: 10px; }
        .local { text-align: left; font-weight: bold; }
        .remote { text-align: right; }
    </style>
</head>
<body>

<script src="/static/game/three.min.js"></script>
<script src="/static/game/detector.js"></script>
<script src="/static/game/Stats.js"></script>
<script src="/static/game/OrbitControls.js"></script>
<script src="/static/game/THREEx.WindowResize.js"></script>
<script type="text/javascript" src="/static/core/jquery/jquery1.js"></script>


<div id="ThreeJS" style="position: absolute; left:0px; top:0px">

    <!-- Чат -->
    <div id="body">
        <div id="status"></div>
        <div id="inbox"></div>
        <div id="input"><form action="#" method="post" id="messageform"><input name="msg" id="msg" autocomplete="off"/></form></div>
    </div>
    <!-- Конец чата -->

</div>


<script>

var container, scene, camera, renderer, controls, stats;
var clock = new THREE.Clock();
// custom global variables

var MovingCube;

init();
animate();

// FUNCTIONS 		
function init() {
	scene = new THREE.Scene();
	// CAMERA
	var SCREEN_WIDTH = window.innerWidth, SCREEN_HEIGHT = window.innerHeight;
	var VIEW_ANGLE = 45, ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT, NEAR = 0.1, FAR = 20000;
	camera = new THREE.PerspectiveCamera( VIEW_ANGLE, ASPECT, NEAR, FAR);
	scene.add(camera);
	camera.position.set(0,150,400);
	camera.lookAt(scene.position);	
	// RENDERER
	renderer =  Detector.webgl ? new THREE.WebGLRenderer( {antialias:true} ) : new THREE.CanvasRenderer();
	renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
	container = document.getElementById( 'ThreeJS' );
	container.appendChild( renderer.domElement );
	// CONTROLS
	controls = new THREE.OrbitControls( camera, renderer.domElement );
	// STATS
	stats = new Stats();
	stats.domElement.style.position = 'absolute'; stats.domElement.style.bottom = '0px'; stats.domElement.style.zIndex = 100;
	container.appendChild( stats.domElement );
	// LIGHT
	var light = new THREE.PointLight(0xffffff);
	light.position.set(0,250,0);
	scene.add(light);

	// FLOOR
	var floorMaterial = new THREE.MeshBasicMaterial( {color:0x444444, side:THREE.DoubleSide} );
	var floorGeometry = new THREE.PlaneGeometry(1000, 1000, 10, 10);
	var floor = new THREE.Mesh(floorGeometry, floorMaterial);
	floor.position.y = -0.5;
	floor.rotation.x = Math.PI / 2;
	scene.add(floor);
	// FOG
	scene.fog = new THREE.FogExp2( 0x9999ff, 0.00025 );
	// create an array with six textures for a cool cube
{#    var sphereGeometry = new THREE.CubeGeometry( 50, 62, 25 );#}
{#    var sphereMaterial = new THREE.MeshBasicMaterial( { color: 255228225, wireframe: true } );#}
{#	MovingCube = new THREE.Mesh(sphereGeometry, sphereMaterial);#}
{#	MovingCube.position.set(0, 25.1, 0);#}
{#	scene.add( MovingCube );	#}
	
}


function animate() {
    requestAnimationFrame( animate );
	render();		
	update();
}

function update() {
    var delta = clock.getDelta(); // seconds.
{#	var moveDistance = 200 * delta; // 200 pixels per second#}
	var moveDistance = 5 * delta; // 200 pixels per second
	var rotateAngle = Math.PI / 2 * delta;   // pi/2 radians (90 degrees) per second
    document.addEventListener('keydown', function(e) {
    // Allow CTRL+L, CTRL+T, CTRL+W, and F5 for sanity
        if (!e.ctrlKey || !(e.keyCode == 76 || e.keyCode == 84 || e.keyCode == 87)) {
            if (e.keyCode != 116) e.preventDefault();
        }
        switch (e.keyCode) {
            case 38:/*up*/     case 87: /*w*/  MovingCube.position.z -= moveDistance; break;
            case 37:/*left*/   case 65:/*a*/   MovingCube.position.x -= moveDistance; break;
            case 40:/*down*/   case 83: /*s*/  MovingCube.position.z += moveDistance; break;
            case 39:/*right*/  case 68: /*d*/  MovingCube.position.x += moveDistance; break;
            case 32:/*space*/  console.log('keypress space'); break;
        }
    }, false);
    document.addEventListener('keyup', function(e) {
        switch (e.keyCode) {
            case 38:/*up*/     case 87: /*w*/ MovingCube.position.z -= moveDistance; break;
            case 37:/*left*/   case 65:/*a*/  MovingCube.position.x -= moveDistance; break;
            case 40:/*down*/   case 83: /*s*/ MovingCube.position.z += moveDistance; break;
            case 39:/*right*/  case 68: /*d*/ MovingCube.position.x += moveDistance; break;
{#            case 32:/*space*/  break;#}
{#            case 16: /*shift*/ $('#msg').focus(); break;#}
        }
    }, false);

    controls.update();
	stats.update();
}
{#var url = 'ws://localhost:8765/';#}
var url = 'ws://78.47.225.242:8765/';
var ws = new WebSocket(url);
ws.onopen = ws.onclose = ws.onerror = function() {
    var code = ws.readyState;
    var codes = { 0: "opening", 1: "open", 2: "closing", 3: "closed"};
    $('#status').html(codes[code]);
    var msg;
{#    ws.onmessage = function(event) {#}
{#        msg = JSON.parse(event.data);#}
{#        var player = Player(msg.id);#}
{#    };#}
{#    ws.send(JSON.stringify( {'t':"player", 'id':msg.id, 'c': {x:10, y:20} } ) );#}
};



document.addEventListener('click', function(e) {
        e.preventDefault();
        console.log('click shoot');
});
$('#msg').on('keyup', function(e) { e.stopPropagation(); });
$('#msg').on('keydown', function(e) { e.stopPropagation(); });
$('#msg').on('keypress', function(e) {
    if (e.keyCode == 13) {
        newMessage();
        $('#msg').blur();
        return false;
    }
    e.stopPropagation();
});

var res12сqqwwwhhh;

var ids = {};

function Player(id) {
    ids[id] = this;
    this.id = id;
    var mesh_geometry = new THREE.CubeGeometry( 50, 62, 25 );
    var mesh_material = new THREE.MeshBasicMaterial( { color: 255228225, wireframe: true } );
	this.mesh = new THREE.Mesh(mesh_geometry, mesh_material );
	this.mesh.position.set(0, 25.1, 0);
	scene.add( this.mesh );
}


{#console.warn('palyer.id', player.id);#}

ws.onmessage = function(event) {
    var msg = JSON.parse(event.data);
    console.warn(['onmessage', msg]);
    if (msg.t == 'chat') {
        console.warn(['msg', msg]);
        showMessage(msg.m, true);
        return false;
    }else if(msg.t == 'player' && msg.e == 'new_player'){
        player = new Player(msg.id);
        console.warn(['new', msg]);
    }else if(msg.t == 'player' && msg.e == 'init'){
        player = new Player(msg.id);
        console.warn(['init', msg]);
    } else if(msg.t == 'player' && msg.e == 'rotate'){  //nado peredat object
        player = ids[msg.id];

        player.mesh.rotation.set(msg.c.y, msg.c.x, msg.c.z);
    } else if(msg.t == 'player' && msg.e == 'move')  { }

    {#    setTimeout( function(){console.warn(JSON.parse(event.data))}, 1000);#}
};

console.warn('ids', ids);
document.addEventListener('mousemove', function(e) {
    var y = e.movementY, x = e.movementX;
{#    console.warn(['x-y', y, x]);#}
    ws.send( JSON.stringify( {'t':'player', 'e':'rotate', 'id':'MovingCube', c:{'y': y, 'x':x, 'z':'0'}} ) )
}, false);




function newMessage() {
    var msg = $('#msg').val();
    showMessage(msg, false);
    $('#msg').val('').select();
    setTimeout(function() {
        ws.send(JSON.stringify({'t':'chat', m: msg}));
    }, 200);
}
function showMessage(msg, isFromRemote) {
    var node = $('<p>' + msg + '&nbsp;</p>');
    node.addClass('msg');
    node.addClass(isFromRemote ? 'remote': 'local');
    node.hide();
    $('#inbox').append(node);
    node.fadeIn();
}


function render() {
	renderer.render( scene, camera );
}

</script>

</body>
</html>
