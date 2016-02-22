
if (!window.WebSocket) document.body.innerHTML = 'WebSocket in the browser is not supported.';
var blocker =       document.getElementById( 'blocker' );
var instructions =  document.getElementById( 'instructions' );
var click_here =    document.getElementById( 'click_here' );
var lock = true;
var canvas = document.getElementById("renderCanvas");
var stats =  document.getElementById('stats');
var engine = new BABYLON.Engine(canvas, true);
var camera, camera2,  scene, meshList = [], localPlayer, trueDirection, lmesh, loader, enemy, llmesh; //mesh

function iniPointerLock(scene, camera) {
    var _this = this;
    var canvas = scene.getEngine().getRenderingCanvas();
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
    var x = startX, y = startY, a=0, b= 0, la=0, lb= 0, z=0, mesh;
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
	};
    this.rot = function() {
        var rot = la != a || lb != b || 0;
        la = a; lb = b;
	 	return rot;
	};
    this.getState =  function(){ return { x:mesh.position.x, y:mesh.position.y, z:mesh.position.z, a:mesh.rotation.y, b:mesh.rotation.x}; };
    this.draw = function() {
        if (!is_local) {
            mesh.position = new BABYLON.Vector3(x, y, z);
            mesh.rotation.x = a;
            mesh.rotation.y = b;
        }
    };

    this.init = function(name, bot) {
        console.log('is_local->', is_local);
        if (is_local) {
          	lmesh = new BABYLON.Mesh.CreateBox(name, 1.0, scene);
            lmesh.parent = camera;
            //lmesh.isVisible = false;
            llmesh.onSuccess = function (task) {
                task.loadedMeshes[0].position = new BABYLON.Vector3(28, -2, 41);
                mm = task.loadedMeshes[0].clone('new_local');
                mm.position = new BABYLON.Vector3(4, -4, 11);
                //mm.loadedMeshes[0].position = new BABYLON.Vector3(2, -3, 9);
                //mm.parent = camera;
                mm.parent = lmesh;
            };

        }else {
            var alpha, color;
            if(bot==true) {
                alpha = 0.5;
                color = new BABYLON.Color3(0.5, 0.7, 0.4);
            } else {
                alpha = 0.5;
                color = new BABYLON.Color3(0.7, 0.4, 0.5);
            }
            mesh = BABYLON.Mesh.CreateSphere(name, 16, 8, scene);
            mesh.material =  new BABYLON.StandardMaterial('texture1', scene);
            mesh.material.diffuseColor = color;
            mesh.material.alpha = alpha;
            meshList.push( mesh );
            mesh.position = new BABYLON.Vector3( 50, -3, -10);
            return mesh;
            //enemy.onSuccess = (function(mesh) {
            //    return function callback (task) {
            //         var name = ''+get_random();
            //         mesh.position = new BABYLON.Vector3( 50, -3, -10);
            //         var nm = task.loadedMeshes[0].clone(name);
            //         nm.parent = mesh;
                //}
            //})(mesh);
        }
    };
    this.getObject = function(){ return mesh };
    this.getLObject = function(){ return lmesh };
    iniPointerLock(scene, camera);
}

scene = new BABYLON.Scene(engine);
loader =  new BABYLON.AssetsManager(scene);
var createScene = function () {

	scene.clearColor = new BABYLON.Color3(0.8, 0.8, 0.8);
    scene.gravity = new BABYLON.Vector3(0, -0.9, 0);
    scene.collisionsEnabled = true;
	camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(-30, 2, 50), scene);  // place where emergence tank
	//camera.setTarget(BABYLON.Vector3(0, 0, 10));
	camera.setTarget(BABYLON.Vector3.Zero());
    camera.ellipsoid = new BABYLON.Vector3(4, 2, 4);
    camera.checkCollisions = true;
    camera.applyGravity = true;
    //camera.applyGravity = false;
    camera.keysUp =    [38, 87];
    camera.keysDown =  [40, 83];
    camera.keysLeft =  [37, 65];
    camera.keysRight = [39, 68];
	camera.speed = 5;
    camera.inertia = 0.5;
    camera.angularInertia = 0;
    camera.angularSensibility = 1000;
    camera.layerMask = 2;


    camera2 = new BABYLON.FreeCamera("minimap", new BABYLON.Vector3(0,170,0), scene);
    camera2.setTarget(new BABYLON.Vector3(0.0,0.7,0.6));
    var xstart = 0.7, ystart = 0.75;
    var width = 0.99-xstart, height = ystart;
    //camera2.viewport = new BABYLON.Viewport(xstart, ystart, width, height);
    camera2.viewport = new BABYLON.Viewport(.646, .42, .35, .56);

    //scene.activeCamera = camera;
	scene.activeCameras.push(camera);
    scene.activeCameras.push(camera2);


	var light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
    light.diffuse = new BABYLON.Color3(1, 1, 1);
    light.specular = new BABYLON.Color3(1, 1, 1);
    light.groundColor = new BABYLON.Color3(0, 0, 0);
	//light.intensity = .5;
	var box1 = BABYLON.Mesh.CreateBox("box1", 2.0, scene);
    box1.position = new BABYLON.Vector3(-73, 0, 6);
    box1.material =  new BABYLON.StandardMaterial('texture1', scene);
    box1.material.diffuseColor = new BABYLON.Color3(1, 0, 0);
    box1.checkCollisions = true;
	var box2 = BABYLON.Mesh.CreateBox("box2", 2.0, scene);
	box2.position = new BABYLON.Vector3(-60, 0, -48);
    box2.material =   new BABYLON.StandardMaterial('texture1', scene);
    box2.material.diffuseColor = new BABYLON.Color3(0, 1, 0);
    box2.checkCollisions = true;
    meshList.push(box1); meshList.push(box2);

    var box3 = BABYLON.Mesh.CreateBox("box3", 2.0, scene);
    box3.position = new BABYLON.Vector3(-32, 0, -38);
    box3.material =  new BABYLON.StandardMaterial('texture1', scene);
    box3.material.diffuseColor = new BABYLON.Color3(0, 0, 1);

    enemy = loader.addMeshTask('enemy1', "", "/static/game/t3/", "t.babylon");
    llmesh = loader.addMeshTask('a3', "", "/static/game/a3/", "untitled1.babylon");

    var palm = loader.addMeshTask('g2', "", "/static/game/g2/", "untitled.babylon");
    palm.onSuccess = function (task) {
        pp = task.loadedMeshes[0];
        pp.position = new BABYLON.Vector3(13, -2, 1.5);
        var p1 = task.loadedMeshes[0].clone('p1');
        p1.position = new BABYLON.Vector3(11, -2, 32);
    };

    var grass = loader.addMeshTask('g1', "", "/static/game/g1/", "untitled.babylon");
    grass.onSuccess = function (task) {
        task.loadedMeshes[0].position = new BABYLON.Vector3(60, -2, -15);
        var g1 = task.loadedMeshes[0].clone('g1');
        g1.position = new BABYLON.Vector3(55, -2, -15);
        var g2 = task.loadedMeshes[0].clone('g2');
        g2.position = new BABYLON.Vector3(50, -2, -10);
        var g3 = task.loadedMeshes[0].clone('g3');
        g3.position = new BABYLON.Vector3(45, -2, -25);
        var g4 = task.loadedMeshes[0].clone('g4');
        g4.position = new BABYLON.Vector3(40, -2, 15);
        var g5 = task.loadedMeshes[0].clone('g5');
        g5.position = new BABYLON.Vector3(40, -2, 25);

    };


    dom1mesh = loader.addMeshTask('dom1', "", "/static/game/dom1/", "dom2.babylon");
    dom1mesh.onSuccess = function (task) {
        task.loadedMeshes[0].position = new BABYLON.Vector3(45, 1, 20);
    };

    var dom2mesh = loader.addMeshTask('dom2', "", "/static/game/dom2/", "dom3.babylon");
    dom2mesh.onSuccess = function (task) {
        task.loadedMeshes[0].position = new BABYLON.Vector3(70, -2, 30);
    };
    var box4 = BABYLON.Mesh.CreateBox("box4", 22.0, scene);
    box4.position = new BABYLON.Vector3(71, -2, 30);
    box4.material =   new BABYLON.StandardMaterial('texture1', scene);
    box4.material.diffuseColor = new BABYLON.Color3(0, 1, 0);
    box4.material.alpha = 0.0;
    box4.checkCollisions = true;


    var plan1 = BABYLON.Mesh.CreatePlane("plane1", 220.0, scene);
    plan1.material  = new BABYLON.StandardMaterial("texture1", scene);
    plan1.material.alpha = 0;
    //plan1.wireframe = true;
    plan1.position = new BABYLON.Vector3(0, 0, 100);
    plan1.checkCollisions = true;

    var plan2 = BABYLON.Mesh.CreatePlane("plane2", 220.0, scene);
    plan2.material =  new BABYLON.StandardMaterial('texture1', scene);
    plan2.material.alpha = 0;
    plan2.position = new BABYLON.Vector3(0, 0, -100);
    plan2.rotation.x = -179.03; // вперед-назад
    //plan2.rotation.z = 0;
    plan2.rotation.z = 300.1;   //
    //plan2.rotation.y = -100;
    plan2.checkCollisions = true;

    var plan3 = BABYLON.Mesh.CreatePlane("plane3", 220.0, scene);
    plan3.material =  new BABYLON.StandardMaterial('texture1', scene);
    //plan3.material.diffuseColor = new BABYLON.Color3(0, 1, 0);   //зелёный
    plan3.material.alpha = 0;
    plan3.position = new BABYLON.Vector3(100, 0, 0);
    plan3.rotation.x = -169.65;
    plan3.rotation.z = 0;
    plan3.rotation.y = -4.72;
    plan3.checkCollisions = true;

    var plan4 = BABYLON.Mesh.CreatePlane("plane4", 320.0, scene);
    plan4.material =  new BABYLON.StandardMaterial('texture1', scene);
    //plan4.material.diffuseColor = new BABYLON.Color3(1, 0, 0); //красн
    plan4.material.alpha = 0;
    plan4.position = new BABYLON.Vector3(-100, 0, 0);
    plan4.rotation.x = 169.63;
    plan4.rotation.z = 0;
    //plan4.rotation.y = 79.8;
    plan4.rotation.y = 80.11;
    plan4.checkCollisions = true;


    // Skybox
    var skybox = BABYLON.Mesh.CreateBox("skyBox", 500.0, scene);
    var skyboxMaterial = new BABYLON.StandardMaterial("skyBox", scene);
    skyboxMaterial.backFaceCulling = false;
    skyboxMaterial.reflectionTexture = new BABYLON.CubeTexture("/static/game/img/skybox/skybox", scene);
    skyboxMaterial.reflectionTexture.coordinatesMode = BABYLON.Texture.SKYBOX_MODE;
    skyboxMaterial.diffuseColor = new BABYLON.Color3(0, 0, 0);
    skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
    skybox.material = skyboxMaterial;

    // Ground
    var ground = BABYLON.Mesh.CreateGroundFromHeightMap("ground", "/static/game/water/Assets/heightMap.png", 200, 200, 70, 0, 10, scene, false);
    var groundMaterial = new BABYLON.StandardMaterial("ground", scene);
    groundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/water/Shaders/Ground/ground.jpg", scene);
    groundMaterial.diffuseTexture.uScale = 6;
    groundMaterial.diffuseTexture.vScale = 6;
    groundMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
    ground.position.y = -2.0;
    ground.material = groundMaterial;


    var extraGround = BABYLON.Mesh.CreateGround("extraGround", 200, 200, 1, scene, false);
    var extraGroundMaterial = new BABYLON.StandardMaterial("extraGround", scene);
    extraGroundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/water/Shaders/Ground/ground.jpg", scene);
    // // //extraGroundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/p.jpg", scene);
    extraGroundMaterial.diffuseTexture.uScale = 60;
    extraGroundMaterial.diffuseTexture.vScale = 60;
    extraGround.position.y = -2.05;
    extraGround.material = extraGroundMaterial;
    extraGround.checkCollisions = true;

    var keys = new Keys();
	localPlayer = new Player(scene, camera, 6, 6, true);
    localPlayer.init();
    scene.registerBeforeRender(function () {
//==============================================================================
        var dirx = camera.rotation.x;
        if(dirx > 0.1)
            camera.rotation.x = 0.1;
        if(dirx < -0.15)
            camera.rotation.x = -0.15;
//==============================================================================
        if(localPlayer) var u = localPlayer.update(keys);
        var r = localPlayer.rot();
        if(ws.readyState == ws.OPEN && !lock) {

            ws.send( JSON.stringify( { 'e':'move', 'id':localPlayer.id, 'x': camera.position.x, 'y': -2, /*camera.position.y,*/
                'z': camera.position.z } ) );

            if (r) ws.send( JSON.stringify( { 'e':'rotate', 'id':localPlayer.id,    'a': localPlayer.getA(),
                'b': localPlayer.getB(), camera:camera.position } ) );
        }
        for (var i = 0; i < remotePlayers.length; i++) {
            remotePlayers[i].draw();
        }
    });

    var gunS = new BABYLON.Sound("gunshot", "static/game/gun.wav", scene);
    window.addEventListener("mousedown", function (e) { if (!lock && e.button === 0) gunS.play(); });

    var ms = new BABYLON.Sound("mss", "static/game/007.mp3", scene, null, {/*volume:0.05,*/ loop: true, autoplay: false });
    //var ms = new BABYLON.Sound("Violons", "sounds/violons11.wav", scene, null, { loop: true, autoplay: false });
    //ms.attachToMesh(llmesh);
	document.addEventListener("keydown",  function(e){
        switch (e.keyCode) {
            /*case 39: case 37: case 65: case 68:*/
           case 38: case 40: case 83: case 87:
				if (!ms.isPlaying) ms.play();
				break;
        }
    });
	document.addEventListener("keyup",   function(e){
        switch (e.keyCode) {
            case 38:  case 40: case 83: case 87:
				if (ms.isPlaying) ms.pause();
				break;
        }
    });

    camera.keysUp =    [38, 87];
    camera.keysDown =  [40, 83];
    camera.keysLeft =  [37, 65];
    camera.keysRight = [39, 68];
    window.addEventListener("click", function (e) {
        if(!lock){
            var localBullet = new Bullet();
            localBullet.selfBullet();
            var player = localPlayer.getLObject();
            console.log('%c play shoot @@@ ', 'background: green; color: blue;', 'pos->', camera.position, 'dir->', trueDirection);
            ws.send( JSON.stringify( { 'e':'shoot', 'id':player.id, 'pos':player.position, 'dir': trueDirection} ) );
        }
    });


	document.addEventListener("keydown",   function(e){
        if (localPlayer)  keys.onKeyDown(e);
    }, false);
	document.addEventListener("keyup",     function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
    document.addEventListener('mousemove', function(e){
	    if (localPlayer) {
            localPlayer.setA( camera.cameraRotation.x );
	        localPlayer.setB( camera.cameraRotation.y );
        }
    }, false);

   	remotePlayers = [];
    enemy.onSuccess = function (task) {
        var wsUri = (window.location.protocol=='https:'&&'wss://'||'ws://')+window.location.hostname+':80/game_handler';
        ws = new WebSocket(wsUri);
        ws.onopen = function () {
            var room = window.location.hash;
            room = room.replace("#", "");
            localPlayer.room = room;
            //console.log("Connected to socket server", 'localPlayer.id:', localPlayer.id, 'X:', localPlayer.getX(), 'Y:', localPlayer.getY(), 'room:', localPlayer.room  );
            ws.send(JSON.stringify({'e': "new", 'x': localPlayer.getX(), 'y': localPlayer.getY(), 'room': room}));
        };
        ws.onmessage = function (event) {
            var msg = JSON.parse(event.data);
    //        console.warn('msg', msg);
            if (msg.e == 'new') {
                //console.log("New remote player connected (msg.id): "+msg.id+' msg.msg '+msg.msg );
                var newPlayer = new Player(scene, camera, msg.x, msg.y);
                newPlayer.id = msg.id;

                var mesh = newPlayer.init(msg.id, msg.bot);
                var name = ''+get_random();
                mesh.position = new BABYLON.Vector3( 50, -3, -10);
                var nm = task.loadedMeshes[0].clone(name);
                nm.parent = mesh;

                remotePlayers.push(newPlayer);    // Add new player to the remote players array
            } else if (msg.e == 'move') {
                var movePlayer = playerById(msg.id);
                if (!movePlayer) {
                    logg(msg);
                    return;
                }
                movePlayer.setX(msg.x);
                movePlayer.setY(msg.y);
                movePlayer.setZ(msg.z);
            } else if (msg.e == 'rotate') {
                var rotPlayer = playerById(msg.id);
                if (!rotPlayer) {
                    logg(msg);
                    return;
                }
                rotPlayer.setA(msg.a);
                rotPlayer.setB(msg.b);
            } else if (msg.e == 'remove') {
                var removePlayer = playerById(msg.id);
                if (!removePlayer) {
                    logg(msg);
                    return;
                }
                remotePlayers.splice(remotePlayers.indexOf(removePlayer), 1);
                var mes = scene.getMeshByID(msg.id);
                mes.dispose();
            } else if (msg.e == 'shoot') {
                var player = playerById(msg.id);
                if (!player) {
                    logg(msg);
                    return;
                }
                var meshh = scene.getMeshByID(msg.id);
                var poss = meshh.position;
                var bullet = new Bullet();
                bullet.remoteBullet(msg.pos, msg.dir);
                //bullet.remoteBullet(poss, msg.dir, msg.bot);
            } else if (msg.e == 'chat') {
                player = localPlayer.getLObject();
                showMessage(msg, true);
            }
        };
        ws.onclose = function (e) {
            console.log('close: ', e);
            if (e.wasClean) console.log('Connection was closed cleanly');
                else console.log('Disconnect the connection');
            console.log('Code: ' + e.code + '  reason: ' + e.reason);
        };
        ws.onerror = function (error) {
            console.log("Error: error " + error);
        };
    };
    loader.load();
	return scene;
};


function playerById(id) {
	for (var i = 0; i < remotePlayers.length; i++) {
		if (remotePlayers[i].id == id)  return remotePlayers[i];
	}
	return false;
}


function Bullet(){
    var speed = 100;
    var bullet = new BABYLON.Mesh.CreateSphere('bullet', 3, 0.7, scene);
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
                    //setTimeout( function(){ delete meshList[i]; }, 1000 );
                    setTimeout( function(){ audio() }, 100 );
    //                setTimeout( function(){ meshList[i].dispose(); }, 2000 );
                }
            }
        });
    };
    this.remoteBullet = function( pos, dir ){
        bullet.position = new BABYLON.Vector3(pos.x, pos.y, pos.z);
        //console.log('%c shot bot @@@ ', 'background: yellow; color: blue;', pos, dir, bullet.position );
        scene.registerBeforeRender(function () {
            bullet.position.addInPlace(dir);
        });
    };

}

function get_random(){
    return parseInt( Math.random() * (999 - 100) + 100);
}

function logg(msg){
    console.log("Player not found: "+msg.id+' msg.msg '+msg.msg );
}

function lo(msg){
    console.log('%c success FPS @@@ 222! ', 'background: #222; color: red', msg);
}


function jump(){
    console.log('jump=>');
    var acceleration = new BABYLON.Vector3(0, -150, 0);
    var jumpHeight =   125;
	var thrust =       Math.sqrt( Math.abs( 2 * jumpHeight * acceleration.y )); //толчок
    camera.position.y += thrust;
}

function Keys(up, left, right, down) {
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
    var node_class = isFromRemote ? 'remote': 'local';
    var mess =       isFromRemote ? msg.mes : msg;
    var elem = document.createElement('p');
    elem.innerHTML = '<div class="msg '+node_class+'">' + mess + '&nbsp;</div>';
    var parent = document.getElementById('inbox');
    insertAfter(elem, parent);
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
}

function explosion(obj){
    var particleSystem = new BABYLON.ParticleSystem("particles", 1000, scene);
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
    //setTimeout( function(){ obj.dispose(); }, 900 );
    setTimeout( function(){
        particleSystem.stop();
    }, 900 );
    setTimeout( function(){
        particleSystem.dispose();
    }, 1200 );
    //particleSystem.dispose();
}


var scene = createScene();
loader.onFinish = function (tasks) {
    engine.runRenderLoop(function () {
        scene.render();
        stats.innerHTML = "<div class='stat'>"
                        + "FPS: <b>" +                              engine.getFps().toFixed() + "</b><br>"
                        + "Room number: <b style='color:red;'>" +   localPlayer.room + "</b><br><br>"

                        + "Total vertices: " +    scene.getTotalVertices() + "<br>"
                        + "View Range: "+ camera.maxZ +"<br>"
                        + "<i>Render duration:</i> " +scene.getRenderDuration() + " ms <br>"
                        + "Camera Position: ( x:" + camera.position.x.toFixed(4) + ", y:" + camera.position.y.toFixed(4) + ", z:" + camera.position.z.toFixed(4) + ")" +
            "</div>";
    });
};
window.addEventListener("resize", function () { engine.resize(); });






