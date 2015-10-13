
if (!window.WebSocket) document.body.innerHTML = 'WebSocket in the browser is not supported.';
var blocker =       document.getElementById( 'blocker' );
var instructions =  document.getElementById( 'instructions' );
var click_here =    document.getElementById( 'click_here' );
var lock = true;
var canvas = document.getElementById("renderCanvas");
var stats =  document.getElementById('stats');
var engine = new BABYLON.Engine(canvas, true);
var camera, scene, meshList = [], localPlayer, trueDirection, mesh, lmesh, loader;

function initPointerLock(scene, camera) {
    var _this = this;
    var canvas = scene.getEngine().getRenderingCanvas(); //TODO непонятнная ошибка какаято
    click_here.addEventListener("click", function(evt) {
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
function Player(scene, camera, startX, startY, is_local ) {
    var x = startX, y = startY, a=0, b= 0, la=0, lb= 0, z=0; //mesh
//    var moveAmount = 0.6;
    var moveAmount = 0.00001;

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
	this.update = function(keys) {
		var prevX = x, prevZ = z, prevY = y;
		if      (keys.up)    z -= moveAmount;
		else if (keys.down)  z += moveAmount;
		if      (keys.left)  x -= moveAmount;
		else if (keys.right) x += moveAmount;
		return prevX != x || prevZ != z;
//		return true;
	};
    this.rot = function() {
        var rot = la != a || lb != b || 0;
        la = a; lb = b;
	 	return rot;
	};
    this.getState =  function(){ return { x:mesh.position.x, y:mesh.position.y, z:mesh.position.z, a:mesh.rotation.y, b:mesh.rotation.x}; };
    this.draw = function() {
//        loader.onFinish = function (tasks) {
            if (!is_local) {
                mesh.position = new BABYLON.Vector3(x, y, z);
                mesh.rotation.x = a;
                mesh.rotation.y = b;
            }
//        };
    };

    this.init = function(name) {
        console.log('is_local->', is_local);
        if (is_local) {
            console.log('local box ->', name);
          	lmesh = new BABYLON.Mesh.CreateBox(name, 1.0, scene);
            lmesh.position = new BABYLON.Vector3( 1, -1, 5);
            lmesh.parent = camera;
            lmesh.isVisible = false;
//            tasklmesh = loader.addMeshTask('name', "", "static/game/", "ufo3.babylon");
//            tasklmesh = loader.addMeshTask('name', "", "static/game/", "q.babylon");

            tasklmesh = loader.addMeshTask(name, "", "static/game/", "int.babylon");
            tasklmesh.onSuccess = function (task) {
                task.loadedMeshes[0].position = new BABYLON.Vector3(3, -3, 9);
                task.loadedMeshes[0].parent = camera;
            };

        }else {
            console.log('remote box ->', name);
//            var tasklmesh = loader.addMeshTask(name, "", "static/game/", "int.babylon");
//            tasklmesh.onSuccess = function (task) {
//                mesh = task.loadedMeshes[0];
//                mesh.position = new BABYLON.Vector3(1, 1, 2);
//            };
//            mesh = new BABYLON.Mesh.CreateSphere(name, 1.0, scene);

            mesh = BABYLON.Mesh.CreateSphere(name, 16, 2, scene);
            mesh.position = new BABYLON.Vector3( 50, 5, -10);
            mesh.checkCollisions = true;
            mesh.scaling.x = -3;
            mesh.scaling.z = -3;
            mesh.material = new BABYLON.StandardMaterial("texture1", scene);
            mesh.material.diffuseTexture = new BABYLON.Texture("/static/game/ufo_t.png", scene);



//            mesh = new BABYLON.Mesh.CreateBox(name, 1.0, scene);
//            mesh.position = new BABYLON.Vector3( 1, 1, 2);
//            mesh.material =  new BABYLON.StandardMaterial('texture1', scene);
//            mesh.material.diffuseColor = new BABYLON.Color3(1, 1, 0);
        }
    };
    this.getObject = function(){ return mesh };
    this.getLObject = function(){ return lmesh };
//	this.setState =  function(newX, newY, newZ, newA, newB) { wp.x = newX; wp.y = newY; wp.z = newZ; wp.rotation.y = newA; wp.rotation.x = newB; };
    initPointerLock(scene, camera);
}

scene = new BABYLON.Scene(engine);
loader =  new BABYLON.AssetsManager(scene);
var createScene = function () {

	scene.clearColor = new BABYLON.Color3(0.8, 0.8, 0.8);
    scene.gravity = new BABYLON.Vector3(0, -0.9, 0);
    scene.collisionsEnabled = true;
	camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(80, 5, -10), scene);
	camera.setTarget(BABYLON.Vector3.Zero());
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


	var light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
	light.intensity = .5;
    var spot = new BABYLON.SpotLight("spot", new BABYLON.Vector3(0, 30, 10), new BABYLON.Vector3(0, -1, 0), 17, 1, scene);
    spot.diffuse = new BABYLON.Color3(1, 1, 1);
    spot.specular = new BABYLON.Color3(0, 0, 0);
    spot.intensity = 0.3;


	var box1 = BABYLON.Mesh.CreateBox("box1", 2.0, scene);
    box1.position = new BABYLON.Vector3(60, 0, -5);
    box1.material =  new BABYLON.StandardMaterial('texture1', scene);
    box1.material.diffuseColor = new BABYLON.Color3(1, 0, 0);
    box1.checkCollisions = true;
	var box2 = BABYLON.Mesh.CreateBox("box2", 2.0, scene);
	box2.position = new BABYLON.Vector3(70, 0, -7);
    box2.material =   new BABYLON.StandardMaterial('texture1', scene);
    box2.material.diffuseColor = new BABYLON.Color3(0, 1, 0);
    box2.checkCollisions = true;
    meshList.push(box1); meshList.push(box2);


    // Skybox
    var skybox = BABYLON.Mesh.CreateBox("skyBox", 800.0, scene);
    var skyboxMaterial = new BABYLON.StandardMaterial("skyBox", scene);
    skyboxMaterial.backFaceCulling = false;
    skyboxMaterial.reflectionTexture = new BABYLON.CubeTexture("/static/game/img/skybox/skybox", scene);
    skyboxMaterial.reflectionTexture.coordinatesMode = BABYLON.Texture.SKYBOX_MODE;
    skyboxMaterial.diffuseColor = new BABYLON.Color3(0, 0, 0);
    skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
    skybox.material = skyboxMaterial;

    // Ground
    var ground = BABYLON.Mesh.CreateGroundFromHeightMap("ground", "/static/game/water/Assets/heightMap.png", 90, 90, 70, 0, 10, scene, false);
    var groundMaterial = new BABYLON.StandardMaterial("ground", scene);
    groundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/water/Shaders/Ground/ground.jpg", scene);
    groundMaterial.diffuseTexture.uScale = 6;
    groundMaterial.diffuseTexture.vScale = 6;
    groundMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
    ground.position.y = -2.0;
    ground.material = groundMaterial;


    var extraGround = BABYLON.Mesh.CreateGround("extraGround", 400, 400, 1, scene, false);
    var extraGroundMaterial = new BABYLON.StandardMaterial("extraGround", scene);
    extraGroundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/water/Shaders/Ground/ground.jpg", scene);
    extraGroundMaterial.diffuseTexture.uScale = 60;
    extraGroundMaterial.diffuseTexture.vScale = 60;
    extraGround.position.y = -2.05;
    extraGround.material = extraGroundMaterial;
    extraGround.checkCollisions = true;

    // Water
    //BABYLON.Engine.ShadersRepository = "";
    //var water = BABYLON.Mesh.CreateGround("water", 400, 400, 1, scene, false);
    //var waterMaterial = new WaterMaterial("water", scene, spot);
    //waterMaterial.refractionTexture.renderList.push(extraGround);
    //waterMaterial.reflectionTexture.renderList.push(skybox);
    //water.material = waterMaterial;

    var sun = BABYLON.Mesh.CreateSphere("sun", 10, 4, scene);
    sun.material = new BABYLON.StandardMaterial("sun", scene);
    sun.material.emissiveColor = new BABYLON.Color3(1, 1, 0);

    var keys = new Keys();
	localPlayer = new Player(scene, camera, 6, 6, true);
    localPlayer.init();
    scene.registerBeforeRender(function () {
//        localPlayer.draw(ctx);
        sun.position = spot.position;
        spot.position.x -= 0.5;
        if (spot.position.x < -90) spot.position.x = 100;
//==============================================================================
        if(localPlayer) var u = localPlayer.update(keys);
//        var u = localPlayer;
        var r = localPlayer.rot();
        if(ws.readyState == ws.OPEN) {
           ws.send( JSON.stringify( { 'e':'move',  'x': camera.position.x, 'y': camera.position.y, 'z': camera.position.z } ) );
           if (r) ws.send( JSON.stringify( { 'e':'rotate', 'id':localPlayer.id,    'a': localPlayer.getA(), 'b': localPlayer.getB(), camera:camera.position } ) );
        }
        for (var i = 0; i < remotePlayers.length; i++) {
            remotePlayers[i].draw();
        }
    });
    window.addEventListener("click", function (e) {
        if(!lock){
            var localBullet = new Bullet();
            localBullet.selfBullet();
            var player = localPlayer.getLObject();

            var width_p  = scene.getEngine().getRenderWidth();
            var height_p = scene.getEngine().getRenderHeight();
            var pickInfo = scene.pick(width_p/2, height_p/2, null, false, camera);
//            console.log('mesh', player, 'mesh.name', player.name);//, 'mesh.position', player.position);#}
//            ws.send( JSON.stringify( { 'e':'shoot', 'id':player.id, 'pos':camera.position, 'dir':camera.cameraDirection, 'pickinfo':pickInfo.pickedPoint} ) );           //ws.send( JSON.stringify( { 'e':'shoot', 'id':player.id, 'dir':camera.cameraDirection, 'pos':camera.position, 'trueDir':trueDirection } ) );#}
            ws.send( JSON.stringify( { 'e':'shoot', 'id':player.id, 'pos':player.position, 'dir':pickInfo.pickedPoint, 'd2':trueDirection} ) );           //ws.send( JSON.stringify( { 'e':'shoot', 'id':player.id, 'dir':camera.cameraDirection, 'pos':camera.position, 'trueDir':trueDirection } ) );

//            ws.send( JSON.stringify( { 'e':'shoot', 'id':player.id, 'pos':camera.position, 'dir':camera.cameraDirection } ) );           //ws.send( JSON.stringify( { 'e':'shoot', 'id':player.id, 'dir':camera.cameraDirection, 'pos':camera.position, 'trueDir':trueDirection } ) );
        }
    });
	document.addEventListener("keydown",   function(e){ if (localPlayer)  keys.onKeyDown(e);  }, false);
	document.addEventListener("keyup",     function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
    document.addEventListener('mousemove', function(e){
	    if (localPlayer) {
            localPlayer.setA( camera.cameraRotation.x );
	        localPlayer.setB( camera.cameraRotation.y );
        }
    }, false);

    var wsUri = (window.location.protocol=='https:'&&'wss://'||'ws://')+window.location.host+':6677/game_handler';
    ws = new WebSocket(wsUri);
   	remotePlayers = [];
    handlers(scene, camera);
    loader.load();
	return scene;
};

function handlers(scene, camera){
//    document.forms.publish.onsubmit = function() {
//        ws.send( this.message.value );
//        return false;
//    };
    ws.onopen = function() {
       	console.log("Connected to socket server", localPlayer.getX(), localPlayer.getY() );
    	ws.send( JSON.stringify({'e':"new", 'x':localPlayer.getX(), 'y':localPlayer.getY()}) );
    };
    ws.onmessage = function(event){
        var msg = JSON.parse(event.data);
        if(msg.e == 'new'){
            console.log("New remote player connected (msg.id): "+msg.id+' msg.msg '+msg.msg );
            var newPlayer = new Player(scene, camera, msg.x, msg.y);
            newPlayer.id = msg.id;
            newPlayer.init(msg.id);
            remotePlayers.push(newPlayer);    // Add new player to the remote players array
        }else if(msg.e == 'move' ){
           	var movePlayer = playerById(msg.id);
            if (!movePlayer) logg(msg);
            movePlayer.setX(msg.x);
            movePlayer.setY(msg.y);
            movePlayer.setZ(msg.z);
        }else if(msg.e == 'rotate' ){
           	var movePlayer = playerById(msg.id);
            if (!movePlayer) logg(msg);
            movePlayer.setA(msg.a);
            movePlayer.setB(msg.b);
        } else if(msg.e == 'remove'){
            var removePlayer = playerById(msg.id);
            if (!removePlayer) logg(msg);
            remotePlayers.splice(remotePlayers.indexOf(removePlayer), 1);
            var mes = scene.getMeshByID(msg.id);
            mes.dispose();
        } else if (msg.e == 'shoot'){
            console.log()
            var player = playerById(msg.id);
            if (!player) logg(msg);
            var meshh = scene.getMeshByID(msg.id);
            var poss = meshh.position;
            var bullet = new Bullet();
//            bullet.remoteBullet(msg.id, msg.pos, msg.dir);
            bullet.remoteBullet(msg.id, poss, msg.dir, msg.d2);
        } else if (msg.e == 'chat'){
            console.log();
            var player = playerById(msg.id);
            var player = localPlayer.getLObject();
//            if (!player) logg(msg);
            console.log('msg.id == localPlayer', msg.id, localPlayer.id, msg.id == localPlayer.id);
            showMessage(msg, true);
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

function logg(msg){
    console.log("Player not found: "+msg.id+' msg.msg '+msg.msg ); return;
}
function playerById(id) {
	for (var i = 0; i < remotePlayers.length; i++) {
		if (remotePlayers[i].id == id)  return remotePlayers[i];
	}
	return false;
}


function Bullet(){
    var speed = 100;
    var bullet = new BABYLON.Mesh.CreateSphere('bullet', 3, 0.3, scene);
    bullet.material =  new BABYLON.StandardMaterial('texture1', scene);
    bullet.material.diffuseColor = new BABYLON.Color3(3, 2, 0);
    this.selfBullet = function(){
        var startPos = camera.position;
        bullet.position = new BABYLON.Vector3(startPos.x, startPos.y, startPos.z);
        var invView = new BABYLON.Matrix();
        camera.getViewMatrix().invertToRef(invView);
        var direction = BABYLON.Vector3.TransformNormal(new BABYLON.Vector3(0, 0, 1), invView);
        direction.normalize();

        trueDirection = direction;
        scene.registerBeforeRender(function () {
            bullet.position.addInPlace(direction);
            for (var i=0; i < meshList.length; i++ ){
                if(bullet.intersectsMesh(meshList[i], true)) {
                    bullet.material.emissiveColor = new BABYLON.Color3(1, 0, 0);
                    explosion(meshList[i]);
                    setTimeout( function(){ bullet.dispose(); }, 900 );
                    setTimeout( function(){ delete meshList[i]; }, 1000 );
                    setTimeout( function(){ audio() }, 100 );
    //                setTimeout( function(){ meshList[i].dispose(); }, 2000 );
                }
            }
        });
    };
    this.remoteBullet = function(player, pos, dir, d2){
        console.log('remoteBullet player->', player, 'pickinfo->', dir);
        console.log('!!!pos->', pos);
//        var ctr = 0;
        bullet.position = new BABYLON.Vector3(pos.x, pos.y, pos.z);
//        dir.normalize();
        scene.registerBeforeRender(function () {
            bullet.position.addInPlace(d2);
//            bullet.position = new BABYLON.Vector3(parseFloat(d2.x*ctr), parseFloat(d2.y*ctr), parseFloat(d2.z*ctr));
//            bullet.position = new BABYLON.Vector3(d2.x*ctr, d2.y*ctr, d2.z*ctr);
//            bullet.position = new BABYLON.Vector3(dir.x*ctr, dir.y*ctr, dir.z*ctr);
//            ctr += 0.05;
//            ctr += 1;
        });
    };

}


function jump(){
    console.log('jump=>');
    var acceleration = new BABYLON.Vector3(0, -150, 0);
    var jumpHeight =   125;
	var thrust =       Math.sqrt( Math.abs( 2 * jumpHeight * acceleration.y )); //толчок
    camera.position.y += thrust;
}

function Keys(up, left, right, down) {
//    console.log('init keys');
	var up = up || false, left = left || false, right = right || false, down = down || false;
	var onKeyDown = function(e) {
		var that = this;
		switch (e.keyCode) {
			case 37: case 65: that.left  = true; break;
			case 38: case 87: that.up    = true; break;
			case 39: case 68: that.right = true; break;
			case 40: case 83: that.down  = true; break;
//			case 13:
//                newMessage();
//                e.stopPropagation();
//                break;
		}
	};
	var onKeyUp = function(e) {
		var that = this;
		switch (e.keyCode) {
			case 37: case 65: that.left  = false; break;
			case 38: case 87: that.up    = false; break;
			case 39: case 68: that.right = false; break;
			case 40: case 83: that.down  = false; break;
			case 13:
                newMessage();
                e.stopPropagation();
                break;
			case 32:
                jump();
                e.stopPropagation();
                break;
		}
	};
	return { up:up, left:left, right:right, down:down, onKeyDown: onKeyDown, onKeyUp: onKeyUp };
}
function newMessage(e) {
    var mess = document.getElementById('msg').value;
    console.warn('__newMessage__  mess=> ', mess);
//    var mess = document.getElementById('msg').value;
    showMessage(mess,  false);
    document.getElementById('msg').value = '';
    document.getElementById('msg').focus();
    // Delay the response, for effect.
    setTimeout(function() {
        ws.send( JSON.stringify( { 'e':'chat', 'id':localPlayer.id, 'mes':mess} ) );
    }, 200);
}
function showMessage(msg, isFromRemote) {
    console.warn('__showMessage__  isFromRemote=> ', isFromRemote);
    console.warn('__showMessage__  msg=> ', msg);
    var node_class = isFromRemote ? 'remote': 'local';
    var mess =       isFromRemote ? msg.mes : msg;
    var elem = document.createElement('p');
    elem.innerHTML = '<div class="msg '+node_class+'">' + mess + '&nbsp;</div>';
    var parent = document.getElementById('inbox');
//    document.getElementById('inbox').appendChild(elem);
    insertAfter(elem, parent);
//    document.getElementById('inbox').insertBefore(parent, messEl);  1-й что вставить, 2-й во что вставлять
    document.getElementById('inbox').style.display = "block";
}
function insertAfter(elem, refElem) {
    var parent = refElem.parentNode;
    var next = refElem.nextSibling;
    if (next) return parent.insertBefore(elem, next);
    else return parent.appendChild(elem);
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
//    var particleSystem = new BABYLON.ParticleSystem("particles", 1000, scene);
    particleSystem.particleTexture = new BABYLON.Texture("/static/game/img/flare.png", scene);
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
//        particleSystem.stop();
}


var scene = createScene();
loader.onFinish = function (tasks) {
    engine.runRenderLoop(function () {
        scene.render();
        stats.innerHTML = "<div class='stat'>Total vertices: " +    scene.getTotalVertices() + "<br>"
                        + "Active particles: " +                    scene.getActiveParticles() + "<br><br>"
                        + "FPS: <b>" +                              engine.getFps().toFixed() + "</b><BR>"
                        //+ "Frame duration: " +                      scene.getLastFrameDuration() + " ms<br><br>"
                        //+ "<i>Evaluate Active Meshes duration:</i> " + scene.getEvaluateActiveMeshesDuration() + " ms<br>"
                        //+ "<i>Render Targets duration:</i> " +      scene.getRenderTargetsDuration() + " ms<br>"
                        //+ "<i>Particles duration:</i> " +           scene.getParticlesDuration() + " ms<br>"
                        //+ "<i>Sprites duration:</i> " +             scene.getSpritesDuration() + " ms<br>"
                        + "<i>Render duration:</i> " +              scene.getRenderDuration() + " ms"
                        + "<BR><BR>"
                        + "Camera Position: (" + camera.position.x.toFixed(4) + ", " + camera.position.y.toFixed(4) + ", " + camera.position.z.toFixed(4) + ")<BR>"
                        + "View Range: "+ camera.maxZ +"</div>";
    });
};
window.addEventListener("resize", function () { engine.resize(); });



// В первой получается матрица трансформации (пустая). Во второй - они туда записывают инвертированную трансформацию камеры.
// В третьей, они беруг новый вектор и поворачивают его через получившуюся матрицу, в четвёртой ещё зачем-то нормализуют его
// (приводят к единичному вектору). Но я пока нифига не понимаю: почему нужно инвертировать матрицу камеры? что за трансформнормал -
// трансформация нормали, трансформация нормалью, нормальная трансформация? В конечном итоге после трансформации вектора его ещё нужно
// нормализовать (то есть преобразование выше - его денормализует? Очень странно,
// если это только поворот) - если об этом не знаешь - фиг догадаешься и фиг догадаешься решить подобным образом какую-то другую задачу.
















