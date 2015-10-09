<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>Игра</title>
{#		<link rel="stylesheet" href="/static/game/game1.css" />#}
{#        <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>#}
            <script type="text/javascript" src="/static/core/jquery/jquery1.js"></script>
        <style>
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



		<div id="start">
			<div id="instructions" class="center">
{#				Нажмите чтоб начать игру#}
			</div>
		</div>
		<div id="hud" class="hidden">

            <div id="body">
                <div id="status"></div>
                <div id="inbox"></div>
                <div id="input">
                    <form action="#" method="post" id="messageform"> <table>
                        <tr> <td><input name="msg" id="msg" autocomplete="off"/></td>
{#                            <td id="input-holder"><input type="submit" value="Отправить"/> </td> #}
                        </tr>
                    </table> </form>
                </div>
            </div>

{#            <input id="vvv" type="checkbox" />#}

			<div id="crosshairs"></div>
			<div id="upper-right">
{#				Здоровье: <span id="health">100</span>#}
			</div>
			<div id="respawn" class="center hidden">
{#				В вас попали! перезайдете через <span class="countdown">3</span>&hellip;#}
			</div>
			<div id="hurt" class="hidden"></div>
		</div>

        <script src="/static/game/detector.js"></script>            <!-- проверка подержки вебгл виеокарточкой-->
{#		<script src="/static/game/bigscreen.min.js"></script>       <!-- раскрытие на весь экран и сворачивание-->#}
{#		<script src="/static/game/pointerlock.js"></script>         <!-- тоже чтото техническое-->#}
		<script src="/static/game/three.min.js"></script>           <!-- сама библиотека для отрисовки вебгл-->
		<script src="/static/game/OrbitControls.js"></script>
{#                <script type="text/javascript" src="/static/static/three/build/three.js"></script>#}
<!-- =================================  Рабочие файлы  ======================================================= -->
{#		<script src="/static/game/player.js"></script>              <!-- поведение игрока небольшой файлик-->#}
{#		<script src="/static/game/bullet.js"></script>              <!-- поведение пли тоже небольшой-->#}
{#		<script src="/static/game/game.js"></script>                <!-- сама логика игрушки-->#}
	</body>


<script type="text/javascript">

$(function() {
    var conteiner, scene, camera, renderer, controls, stats;
    var m_cube;

    var clock = new THREE.Clock();
    var delta = clock.getDelta(); // seconds.
	var moveDistance = 200 * delta;

    init();
    animate();

    var url = 'ws://localhost:8765/';
{#    var url = 'ws://78.47.225.242:8765/';#}

    console.log(['m_cube', m_cube]);
    document.addEventListener('mousemove', function(event) {
{#    if(!paused) player.rotate(event.movementY, event.movementX, 0); #}
            console.log('mousemove ');
    }, false);

    document.addEventListener('keydown', function(e) {
        // Allow CTRL+L, CTRL+T, CTRL+W, and F5 for sanity
        if (!e.ctrlKey || !(e.keyCode == 76 || e.keyCode == 84 || e.keyCode == 87)) {
            if (e.keyCode != 116) {
                e.preventDefault();
            }
        }
        switch (e.keyCode) {
            case 38: // up
            case 87: // w
                m_cube.translateZ( -moveDistance );
                break;
            case 37: // left
            case 65: // a
                m_cube.translateX( -moveDistance );
                break;
            case 40: // down
            case 83: // s
                m_cube.translateZ(  moveDistance );
                break;
            case 39: // right
            case 68: // d
                m_cube.translateX(  moveDistance );
                break;
            case 32: // space
                console.log('keypress space');
                break;
        }
    }, false);
    document.addEventListener('keyup', function(e) {
        switch (e.keyCode) {
            case 38: // up
            case 87: // w
                m_cube.translateZ( -moveDistance );
                break;
            case 37: // left
            case 65: // a
                m_cube.translateX( -moveDistance );
                break;
            case 40: // down
            case 83: // s
                m_cube.translateZ(  moveDistance );
                break;
            case 39: // right
            case 68: // d
                m_cube.translateX(  moveDistance );
                break;
            case 32: // space
                break;
            case 16: //
                $('#msg').focus();
                break;
        }
    }, false);
    document.addEventListener('click', function(e) {
            e.preventDefault();
            console.log('click shoot');
    });

    $('#msg').on('keyup', function(e) { e.stopPropagation(); });
    $('#msg').on('keydown', function(e) { e.stopPropagation(); });
    $('#msg').on('keypress', function(e) {
        if (e.keyCode == 13) {
            newMessage($(this));
            $('#msg').blur();
            return false;
        }
        e.stopPropagation();
    });

{#    $('#msg').select();#}

    var ws = new WebSocket(url);
    ws.onmessage = function(event) {
{#        if (isFromRemote && msg!=undefined && !msg['msg']) return false;#}
{#        var msg = JSON.parse(event.data).msg;#}
        var msg = JSON.parse(event.data);
        if (msg['t'] != 'chat') {return false};
        showMessage(msg.m, true);
        setTimeout( function(){console.warn(JSON.parse(event.data))}, 1000);
    };
    ws.onopen = ws.onclose = ws.onerror = function() {
        var code = ws.readyState;
        var codes = { 0: "opening", 1: "open", 2: "closing", 3: "closed"};
        $('#status').html(codes[code]);
    };

    function newMessage(form) {
        var msg = $('#msg').val();
        showMessage(msg, false);
        $('#msg').val('').select();
        // Delay the response, for effect.
        setTimeout(function() {
            ws.send(JSON.stringify({'t':'chat', m: msg}));
        }, 200);
    }

    function showMessage(msg, isFromRemote) {
{#        console.error(msg);#}
        var node = $('<p>' + msg + '&nbsp;</p>');
        node.addClass('msg');
        node.addClass(isFromRemote ? 'remote': 'local');
        node.hide();
        $('#inbox').append(node);
        node.fadeIn();
    }








function init(){
    scene = new THREE.Scene();
    var screen_width = window.innerWidth, screen_height = window.innerHeight;
    var view_angle = 45, aspect = screen_width / screen_height, near = 0.1, far = 2000;
    camera = new THREE.PerspectiveCamera(view_angle, aspect, near/*около*/, far);
    scene.add(camera);
    camera.position.set(0, 150, 400);
    camera.lookAt(scene.position);
    if(Detector.webgl) renderer = new THREE.WebGLRenderer({antialiasing:true})
    else renderer = new THREE.CanvasRenderer();

    renderer.setSize(screen_width, screen_height);
    conteiner = document.getElementById('hud');
    conteiner.appendChild(renderer.domElement);
    // EVENTS
{#	THREEx.WindowResize(renderer, camera);#}
{#	THREEx.FullScreen.bindKey({ charCode : 'm'.charCodeAt(0) });#}
    // CONTROLS
	controls = new THREE.OrbitControls( camera, renderer.domElement );
    var floorMaterial = new THREE.MeshBasicMaterial( {color:0x444444, side:THREE.DoubleSide} );
	var floorGeometry = new THREE.PlaneGeometry(1000, 1000, 10, 10);
	var floor = new THREE.Mesh(floorGeometry, floorMaterial);
	floor.position.y = -0.5;
	floor.rotation.x = Math.PI / 2;
	scene.add(floor);
	// SKYBOX/FOG
	var skyBoxGeometry = new THREE.CubeGeometry( 10000, 10000, 10000 );
	var skyBoxMaterial = new THREE.MeshBasicMaterial( { color: 0x9999ff, side: THREE.BackSide } );
	var skyBox = new THREE.Mesh( skyBoxGeometry, skyBoxMaterial );
	// scene.add(skyBox);
	scene.fog = new THREE.FogExp2( 0x9999ff, 0.00025 );
    // CUSTOM //
	////////////

    var sphereGeometry = new THREE.CubeGeometry( 50, 62, 25 );
    var sphereMaterial = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } );
{#	var sphereMaterial = new THREE.MeshLambertMaterial(  );#}
	m_cube = new THREE.Mesh(sphereGeometry, sphereMaterial);
	m_cube.position.set(120, 70, -30);
	scene.add( m_cube );
}

function animate(){
    requestAnimationFrame(animate);
    render();
    update();
}

function update(){
    controls.update();
}

    function render(){
        renderer.render( scene, camera);
    }
});
</script>




</html>


{#   1) setup ->    #}