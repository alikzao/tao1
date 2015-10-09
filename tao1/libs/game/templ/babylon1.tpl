<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Babylon</title>
    <style>
        html, body    { overflow: hidden; width: 100%; height: 100%; margin: 0; padding: 0; }
        #renderCanvas { width: 100%; height: 100%; touch-action: none; }
        #viseur       { position:absolute; top:50%; left:50%; margin-top:-37px; margin-left:-37px; }
        .stat         { background-color:#6ba5ff; opacity:0.5; border-radius:10px; padding:10px;}
        #blocker      { position: absolute; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        #instructions { width:100%; height:100%; display:-webkit-box; display:-moz-box; display:box; -webkit-box-orient:horizontal; -moz-box-orient:horizontal; box-orient:horizontal; -webkit-box-pack:center; -moz-box-pack:center; box-pack:center; -webkit-box-align:center; -moz-box-align:center; box-align:center; color:#ffffff; text-align:center; cursor:pointer; }
    </style>

    <script src="/static/game/babylon/babylon1-debug.js"></script>
{#    <script src="/static/game/babylon/babylon1.js"></script>#}
{#    <script src="/static/game/babylon/babylon2.js"></script>#}
    <script src="/static/game/babylon/hand.js"></script>
    <script src="/static/game/babylon/Oimo.js"></script>
    <script src="/static/game/babylon/waterMaterial.js"></script>

</head>

<body>

    <img id="viseur" src="/static/game/babylon/viseur.png" />
    <div id="stats" class="" style="position:absolute; left:8px; top:8px;"></div>

    <div id="blocker">
        <div id="instructions">
            <span style="font-size:40px">Click to play || Нажмите для начала Игры</span>
            <br />
            (W, A, S, D = Move || Движение, &nbsp; &nbsp; SPACE = Jump || Прыжок, &nbsp;&nbsp;MOUSE = Look around || Движение вокруг)
        </div>
    </div>

    <canvas id="renderCanvas"></canvas>

<script type="text/javascript">
if (!window.WebSocket) document.body.innerHTML = 'WebSocket в этом браузере не поддерживается.';
var blocker =       document.getElementById( 'blocker' );
var instructions =  document.getElementById( 'instructions' );
var lock = true;


function initPointerLock(scene, camera) {
    var _this = this;
    var canvas = scene.getEngine().getRenderingCanvas();
    instructions.addEventListener("click", function(evt) {
        canvas.requestPointerLock = canvas.requestPointerLock || canvas.msRequestPointerLock || canvas.mozRequestPointerLock || canvas.webkitRequestPointerLock;
        if (canvas.requestPointerLock) canvas.requestPointerLock();
    }, false);
    var pointerlockchange = function (event) {
        _this.controlEnabled = (document.mozPointerLockElement === canvas || document.webkitPointerLockElement === canvas || document.msPointerLockElement === canvas || document.pointerLockElement === canvas);
        if (!_this.controlEnabled) {
            lock = true;
            camera.detachControl(canvas);
            blocker.style.display = 'box'; blocker.style.display = '-webkit-box'; blocker.style.display = '-moz-box';
            instructions.style.display = '';
        }
        else {
            lock = false;
            camera.attachControl(canvas);
            blocker.style.display = 'none';
        }
    };
    document.addEventListener("pointerlockchange",          pointerlockchange, false);
    document.addEventListener("mspointerlockchange",        pointerlockchange, false);
    document.addEventListener("mozpointerlockchange",       pointerlockchange, false);
    document.addEventListener("webkitpointerlockchange",    pointerlockchange, false);
}




var canvas = document.getElementById("renderCanvas");
var stats =  document.getElementById('stats');
var engine = new BABYLON.Engine(canvas, true);
var camera, meshList = [], localPlayer;

var createScene = function () {
	var scene = new BABYLON.Scene(engine);
	scene.clearColor = new BABYLON.Color3(0.8, 0.8, 0.8);
    scene.gravity = new BABYLON.Vector3(0, -0.9, 0);
    scene.collisionsEnabled = true;
	camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
	camera.setTarget(BABYLON.Vector3.Zero());
{#	camera.attachControl(canvas);#}
    camera.ellipsoid = new BABYLON.Vector3(2, 2, 1);
    camera.checkCollisions = true;
    camera.applyGravity = true;
    camera.keysUp =    [38, 87];
    camera.keysDown =  [40, 83];
    camera.keysLeft =  [37, 65];
    camera.keysRight = [39, 68];
	camera.speed = 1;
    camera.inertia = 0.9;
    camera.angularInertia = 0;
    camera.angularSensibility = 1000;
    camera.layerMask = 2;
    camera.noRotationConstraint = false;


{#	var light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);#}
{#	light.intensity = .5;#}
    var spot = new BABYLON.SpotLight("spot", new BABYLON.Vector3(0, 30, 10), new BABYLON.Vector3(0, -1, 0), 17, 1, scene);
    spot.diffuse = new BABYLON.Color3(1, 1, 1);
    spot.specular = new BABYLON.Color3(0, 0, 0);
    spot.intensity = 0.3;


{#    var skybox = BABYLON.Mesh.CreateSphere("skyBox", 50, 1000, scene);#}
{#    skybox.layerMask = 2;#}

	var box1 = BABYLON.Mesh.CreateBox("box1", 2.0, scene);
    box1.position = new BABYLON.Vector3(-2, 1, 0);
    box1.material =  new BABYLON.StandardMaterial('texture1', scene);
    box1.material.diffuseColor = new BABYLON.Color3(1, 0, 0);
    box1.checkCollisions = true;
	var box2 = BABYLON.Mesh.CreateBox("box2", 2.0, scene);
	box2.position = new BABYLON.Vector3(2, 1, 0);
    box2.material =   new BABYLON.StandardMaterial('texture1', scene);
    box2.material.diffuseColor = new BABYLON.Color3(0, 1, 0);
{#    box2.material.alpha = 0.3;#}
    box2.checkCollisions = true;
    meshList.push(box1); meshList.push(box2);


    // Skybox
    var skybox = BABYLON.Mesh.CreateBox("skyBox", 1000.0, scene);
    var skyboxMaterial = new BABYLON.StandardMaterial("skyBox", scene);
    skyboxMaterial.backFaceCulling = false;
    skyboxMaterial.reflectionTexture = new BABYLON.CubeTexture("/static/game/babylon/img/skybox/skybox", scene);
    skyboxMaterial.reflectionTexture.coordinatesMode = BABYLON.Texture.SKYBOX_MODE;
    skyboxMaterial.diffuseColor = new BABYLON.Color3(0, 0, 0);
    skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
    skybox.material = skyboxMaterial;


    // Ground
    var groundMaterial = new BABYLON.StandardMaterial("ground", scene);
    groundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/babylon/img/earth.jpg", scene);
{#    var ground = BABYLON.Mesh.CreateGroundFromHeightMap("ground", "/static/game/babylon/img/worldHeightMap.jpg", 500, 500, 300, 0, 10, scene, false);#}
{#    var ground = BABYLON.Mesh.CreateGroundFromHeightMap("ground", "/static/game/babylon/img/worldHeightMap.jpg", 200, 200, 250, 0, 10, scene, false);#}
    var ground = BABYLON.Mesh.CreateGroundFromHeightMap("ground", "/static/game/babylon/img/worldHeightMap2.jpg", 100, 100, 100, 0, 10, scene, false);
{#    var ground = BABYLON.Mesh.CreateGroundFromHeightMap("ground", "/static/game/babylon/img/worldHeightMap.jpg", 70, 70, 16, 0, 10, scene, false);#}
    ground.position.y = -2.0;
    ground.material = groundMaterial;
{#    ground.checkCollisions = true;#}

{#    var collisionGround = BABYLON.Mesh.CreateGround("ground1", 1000, 1000, 1, scene);#}
{#    collisionGround.position.y = -1.0;#}
{#    collisionGround.isVisible = false;#}
{#    collisionGround.checkCollisions = true;#}


    var extraGround = BABYLON.Mesh.CreateGround("extraGround", 1000, 1000, 1, scene, false);
    var extraGroundMaterial = new BABYLON.StandardMaterial("extraGround", scene);
    extraGroundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/babylon/water/Shaders/Ground/ground.jpg", scene);
    extraGroundMaterial.diffuseTexture.uScale = 60;
    extraGroundMaterial.diffuseTexture.vScale = 60;
    extraGround.position.y = -2.05;
    extraGround.material = extraGroundMaterial;
    extraGround.checkCollisions = true;


    // Water
    BABYLON.Engine.ShadersRepository = "";
    var water = BABYLON.Mesh.CreateGround("water", 1000, 1000, 1, scene, false);
    var waterMaterial = new WaterMaterial("water", scene, spot);
    waterMaterial.refractionTexture.renderList.push(extraGround);
    waterMaterial.refractionTexture.renderList.push(ground);
    waterMaterial.reflectionTexture.renderList.push(ground);
    waterMaterial.reflectionTexture.renderList.push(skybox);
    water.material = waterMaterial;



     //Sphere to see the light's position
    var sun = BABYLON.Mesh.CreateSphere("sun", 10, 4, scene);
    sun.material = new BABYLON.StandardMaterial("sun", scene);
    sun.material.emissiveColor = new BABYLON.Color3(1, 1, 0);



{#    var keys = new Keys();#}
	localPlayer = new Player(scene, camera);
    scene.registerBeforeRender(function () {
        sun.position = spot.position;
        spot.position.x -= 0.5;
        if (spot.position.x < -90) spot.position.x = 100;

        var u = localPlayer.update(keys), r = localPlayer.rot();
        if (u) ws.send( JSON.stringify( { 'e':'move',  'x': localPlayer.getX(), 'y': localPlayer.getY(), 'z': localPlayer.getZ() } ) );
        if (u) ws.send( JSON.stringify( { 'e':'shoot', 'x': localPlayer.getX(), 'y': localPlayer.getY(), 'z': localPlayer.getZ() } ) );
        if (r) ws.send( JSON.stringify( { 'e':'rotate', 'id':localPlayer.id,    'a': localPlayer.getA(), 'b': localPlayer.getB() } ) );
        if (u || r) localPlayer.draw();

        for (var i = 0; i < remotePlayers.length; i++) {
            remotePlayers[i].draw();
        }

    });
    window.addEventListener("click", function (e) {
        if(!lock) new Bullet(scene, e, localPlayer.getState(), camera, box1);
    });
	document.addEventListener("keydown",   function(e){ if (localPlayer)  keys.onKeyDown(e);  }, false);
	document.addEventListener("keyup",     function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
    document.addEventListener('mousemove', function(e){
	    if (localPlayer) {
		    var x = e.movementX     || e.mozMovementX      || e.webkitMovementX   || 0;
            var y = e.movementY     || e.mozMovementY      || e.webkitMovementY   || 0;
            if (y) localPlayer.setA(Math.max(Math.PI * -0.5, Math.min(Math.PI * 0.5, localPlayer.getA() - y * 0.002)));
	        if (x) localPlayer.setB(localPlayer.getB() - x * 0.002);
        }    }, false);

{# http://pauluskp.com/static/game/babylon/babylon1-debug.js #}

    var wsUri = (window.location.protocol=='https:'&&'wss://'||'ws://')+window.location.host;
    ws = new WebSocket(wsUri);
    handlers();
	return scene;
};
function handlers(){

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
        } else if (msg.e == 'shoot'){
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

function Bullet(scene, e, player, camera, box1){
    var speed = 100;
    var bullet = new BABYLON.Mesh.CreateSphere('bullet', 3, 0.3, scene);

    var startPos = camera.position;
    bullet.position = new BABYLON.Vector3(startPos.x, startPos.y, startPos.z);
    bullet.material =  new BABYLON.StandardMaterial('texture1', scene);
    bullet.material.diffuseColor = new BABYLON.Color3(3, 2, 0);

    var invView = new BABYLON.Matrix();
    camera.getViewMatrix().invertToRef(invView);
    var direction = BABYLON.Vector3.TransformNormal(new BABYLON.Vector3(0, 0, 1), invView);
    direction.normalize();
    scene.registerBeforeRender(function () {
        bullet.position.addInPlace(direction);

        for (var i=0; i < meshList.length; i++ ){
            if(bullet.intersectsMesh(meshList[i], true)) {
                bullet.material.emissiveColor = new BABYLON.Color3(1, 0, 0);
                explosion(meshList[i]);
                setTimeout( function(){ bullet.dispose(); }, 900 );
                setTimeout( function(){ delete meshList[i]; }, 1000 );
                setTimeout( function(){ audio() }, 100 );
{#                setTimeout( function(){ meshList[i].dispose(); }, 2000 );#}
            } else { }
        }

    });
{#    scene.actionManager = new BABYLON.ActionManager(scene);#}
{#    scene.actionManager.registerAction(new BABYLON.SetValueAction({trigger: BABYLON.ActionManager.OnIntersectionExitTrigger, parameter: sphere }, bullet, "scaling", new BABYLON.Vector3(1, 1, 1)));#}
}
function audio(){
    var ss = '/static/game/sound/explode.ogg';
    var audio = document.createElement( 'audio' );
    var source = document.createElement( 'source' );
    source.src = ss;
    audio.appendChild( source );
    audio.play();
//    audio.volume = 0;
}
function explosion(obj){
    var particleSystem = new BABYLON.ParticleSystem("particles", 1000, scene);
{#    var particleSystem = new BABYLON.ParticleSystem("particles", 1000, scene);#}
    particleSystem.particleTexture = new BABYLON.Texture("/static/game/babylon/img/flare.png", scene);
    particleSystem.emitter = obj; // the starting object, the emitter

    // Where the particles come from
    particleSystem.minEmitBox = new BABYLON.Vector3(-0.5, 1, -0.5); // Starting all from
    particleSystem.maxEmitBox = new BABYLON.Vector3(0.5, 1, 0.5); // To...

    // Colors of all particles
    particleSystem.color1 = new BABYLON.Color4(1, 0.5, 0, 1.0);
    particleSystem.color2 = new BABYLON.Color4(1, 0.5, 0, 1.0);
    particleSystem.colorDead = new BABYLON.Color4(0, 0, 0, 0.0);

    // Size of each particle (random between...
    particleSystem.minSize = 0.3;
    particleSystem.maxSize = 1;

    // Life time of each particle (random between...
    particleSystem.minLifeTime = 0.2;
    particleSystem.maxLifeTime = 0.4;

    // Emission rate
    particleSystem.emitRate = 600;

    // Blend mode : BLENDMODE_ONEONE, or BLENDMODE_STANDARD
    particleSystem.blendMode = BABYLON.ParticleSystem.BLENDMODE_ONEONE;

    // Set the gravity of all particles
    particleSystem.gravity = new BABYLON.Vector3(0, 0, 0);

    // Direction of each particle after it has been emitted
    particleSystem.direction1 = new BABYLON.Vector3(0, 4, 0);
    particleSystem.direction2 = new BABYLON.Vector3(0, 4, 0);

    // Angular speed, in radians
    particleSystem.minAngularSpeed = 0;
    particleSystem.maxAngularSpeed = Math.PI;

    // Speed
    particleSystem.minEmitPower = 1;
    particleSystem.maxEmitPower = 3;
    particleSystem.updateSpeed = 0.007;
    // Start the particle system
    particleSystem.start();
    setTimeout( function(){ obj.dispose(); }, 900 );
    setTimeout( function(){ particleSystem.stop(); }, 900 );
{#        particleSystem.stop();#}



}


function Player(scene, camera) {
	var wp= BABYLON.Mesh.CreateBox("box2", 1.0, scene);
    wp.position = new BABYLON.Vector3( 1, -1, 5);
    wp.parent = camera;
    wp.checkCollisions = true;
    wp.material =  new BABYLON.StandardMaterial('texture1', scene);
    wp.material.diffuseColor = new BABYLON.Color3(0, 0, 1);
{#    wp.material.alpha = 0.3;#}

	var canJump = false;
	var prevTime = performance.now();
	var velocity = {x:0, y:0, z:0};
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
        if(lock) return;
		var prevX = x, prevZ = z, prevY = y;    // Previous position
		velocity.x -= velocity.x * 10.0 * delta;
		velocity.z -= velocity.z * 10.0 * delta;
		velocity.y -= 9.8 * 100.0 * delta; // 100.0 = mass
		if      (keys.up)    z -= moveAmount;
		else if (keys.down)  z += moveAmount;
		if      (keys.left)  x -= moveAmount;
		else if (keys.right) x += moveAmount;
		return prevX != x || prevZ != z;
	};
    this.rot = function() {
        if(!this.enabled ) return;
        var rot = la != a || lb != b || 0;
        la = a; lb = b;
	 	return rot;
	};

    this.getState =  function(){ return { x:wp.position.x, y:wp.position.y, z:wp.position.z, a:wp.rotation.y, b:wp.rotation.x} };
    this.getObject = function(){ return wp };
	this.setState =  function(newX, newY, newZ, newA, newB) { wp.x = newX; wp.y = newY; wp.z = newZ; wp.rotation.y = newA; wp.rotation.x = newB; };

	this.rotate = function(horiz, vert) {
{#        weapon.rotation.x = Math.max(Math.PI * -0.5, Math.min(Math.PI * 0.5, selfBox.rotation.x - vert * 0.002));#}
{#        weapon.rotation.y -= horiz * 0.002;#}
{#        camera.cameraRotation.x -= Math.max(Math.PI * -0.5, Math.min(Math.PI * 0.5, camera.cameraRotation.x - vert * 0.005));#}
{#        camera.cameraRotation.y = horiz * 0.005;#}
	};
    this.update = function(){ };
    initPointerLock(scene, camera);
}



var scene = createScene();
engine.runRenderLoop(function () {
	scene.render();
    stats.innerHTML = "<div class='stat'>Total vertices: " +    scene.getTotalVertices() + "<br>"
                    + "Active vertices: " +                     scene.getActiveVertices() + "<br>"
                    + "Active particles: " +                    scene.getActiveParticles() + "<br><br>"
                    + "FPS: <b>" +                              BABYLON.Tools.GetFps().toFixed() + "</b><BR>"
                    + "Frame duration: " +                      scene.getLastFrameDuration() + " ms<br><br>"
                    + "<i>Evaluate Active Meshes duration:</i> " + scene.getEvaluateActiveMeshesDuration() + " ms<br>"
                    + "<i>Render Targets duration:</i> " +      scene.getRenderTargetsDuration() + " ms<br>"
                    + "<i>Particles duration:</i> " +           scene.getParticlesDuration() + " ms<br>"
                    + "<i>Sprites duration:</i> " +             scene.getSpritesDuration() + " ms<br>"
                    + "<i>Render duration:</i> " +              scene.getRenderDuration() + " ms"
                    + "<BR><BR>"
                    + "Camera Position: (" + camera.position.x.toFixed(4) + ", " + camera.position.y.toFixed(4) + ", " + camera.position.z.toFixed(4) + ")<BR>"
                    + "View Range: "+ camera.maxZ +"</div>";
});

window.addEventListener("resize", function () { engine.resize(); });


</script>

</body>
</html>


{# В первой получается матрица трансформации (пустая). Во второй - они туда записывают инвертированную трансформацию камеры. В третьей, они беруг новый вектор и поворачивают его через получившуюся матрицу, в четвёртой ещё зачем-то нормализуют его (приводят к единичному вектору). Но я пока нифига не понимаю: почему нужно инвертировать матрицу камеры? что за трансформнормал - трансформация нормали, трансформация нормалью, нормальная трансформация? В конечном итоге после трансформации вектора его ещё нужно нормализовать (то есть преобразование выше - его денормализует? Очень странно, если это только поворот) - если об этом не знаешь - фиг догадаешься и фиг догадаешься решить подобным образом какую-то другую задачу.#}