<!-- app.game:cannot -->
<!DOCTYPE html>
<html>
<head><title>Game</title> <meta charset="utf-8">
    <script src="/static/game/three.min.js"></script>
    <script type="text/javascript" src="/static/game/sh/build/ShaderParticles.min.js"></script>

</head>
<body>

<script>
var keys, localPlayer, bulletCollision, sceneMaterial, sceneMesh, sceneGeometry, geometry, container, scene, camera, renderer, clock, raycaster;
var ballMeshes = [], bullets = [], meshList = [];
var shootDirection = new THREE.Vector3();
var shootVelo = 15;
var projector = new THREE.Projector();
var prevTime = performance.now();
var emitter, particleGroup, pool, pos = new THREE.Vector3();
var emitterSettings = {
    type: 'sphere',
    positionSpread: new THREE.Vector3(10, 10, 10),
    radius: 1, speed: 100, sizeStart: 30, sizeStartSpread: 30,
    sizeEnd: 0, opacityStart: 1, opacityEnd: 0,
    colorStart: new THREE.Color('red'),
    colorStartSpread: new THREE.Vector3(0, 10, 0),
    colorEnd: new THREE.Color('red'),
    particleCount: 1000, alive: 0, duration: 0.05
};

init();
initParticles();
animate();


function initParticles() {
    particleGroup = new SPE.Group({
        texture: THREE.ImageUtils.loadTexture('/static/game/sh/examples/img/smokeparticle.png'),
        maxAge: 0.5, blending: THREE.AdditiveBlending
    });
    particleGroup.addPool( 10, emitterSettings, false );
    scene.add( particleGroup.mesh );
}
function rand( size ) { return size * Math.random() - (size/2); }
function createExplosion(posit) {
    if (posit) particleGroup.triggerPoolEmitter(1, (pos.set(posit.x, posit.y, posit.z)));
    else       particleGroup.triggerPoolEmitter(1, (pos.set(rand(150), rand(150), rand(150))));

}


function Keys() {
    console.log(' init keys');
	var up = false, left = false, right = false, down = false;
	var that = this;
	this.onKeyDown = function(e) {
		switch (e.keyCode) {
			case 37: case 65: that.moveLeft		= true; break;
			case 38: case 87: that.moveForward	= true; break;
			case 39: case 68: that.moveRight	= true; break;
			case 40: case 83: that.moveBackward	= true; break;
		}
	};
	this.onKeyUp = function(e) {
		switch (e.keyCode) {
			case 37: case 65: that.moveLeft		= false; break;
			case 38: case 87: that.moveForward	= false; break;
			case 39: case 68: that.moveRight	= false; break;
			case 40: case 83: that.moveBackward	= false; break;
		}
	};
}


function Bullet(obj, direction){
    this.owner = obj;
    this.speed = 120;
    this.direction = direction;

{#    console.log('create bullet', localPlayer.getState());#}
    var pos = localPlayer.getState();
    var  x = pos.x, y = pos.y, z = pos.z;

	var ballMesh = new THREE.Mesh(new THREE.SphereGeometry(4,20,20), new THREE.MeshLambertMaterial({color:'yellow'}));
	ballMesh.position.set(x, y*0.8, z);

    scene.add(ballMesh);
    this.remove = function(bullet, i){
        scene.remove(bullet);
{#        ballMeshes.splice(i, 1);#}
    };
	this.update = function() {
        try{
            var scaledDirection = new THREE.Vector3();
            return function(delta) {
                scaledDirection.copy(this.direction).multiplyScalar(this.speed * delta);
                ballMesh.position.add(scaledDirection);
            };
        }catch(e){ console.log(e); }
	}();
    bullets.push(this);
    ballMeshes.push(ballMesh);
{#    console.log('end create bullet', this);#}
}


function Player(startX, startY, is_local) {
    var mesh = new THREE.Mesh(new THREE.CubeGeometry(1, 1, 15), new THREE.MeshLambertMaterial({ color: 'red'}));
	var pitchObject = new THREE.Object3D();
	pitchObject.add( camera );
	pitchObject.add( mesh );
	var yawObject = new THREE.Object3D();
	// yawObject.add( mesh );
	yawObject.position.y = 10;
	yawObject.add( pitchObject );
    scene.add( yawObject );
	camera.position.z = 15;
	camera.position.y = 10;
	mesh.position.x = 3;
	mesh.position.y = 5;
	mesh.position.z = 5;

	var canJump = false;
	var prevTime = performance.now();
	var velocity = {x:0, y:0, z:0};

    this.getState = function(){ return {x: yawObject.position.x, y: yawObject.position.y, z: yawObject.position.z, a: yawObject.rotation.y, b: pitchObject.rotation.x} };
    this.getObject = function(){ return yawObject };
	this.setState = function(newX, newY, newZ, newA, newB) {
		yawObject.x = newX; yawObject.y = newY; yawObject.z = newZ; yawObject.rotation.y = newA;
		pitchObject.rotation.x = newB; dirty = true;
	};
	this.rotate = function(horiz, vert) {
        pitchObject.rotation.x = Math.max(Math.PI * -0.5, Math.min(Math.PI * 0.5, pitchObject.rotation.x - vert * 0.002));
        yawObject.rotation.y -= horiz * 0.002;
	};
   	this.draw = function() {
        object1 = new THREE.Object3D();
        object2 = new THREE.Object3D();
        object1.add( object2 );
        object2.add( camera );
        object2.add( mesh );
        scene.add( object1 );
        object2.rotateX(a);
        object1.rotateY(b);
        object1.translateX( x );
        object1.translateY( y );
        object1.translateZ( z );
        if ( object1.position.y < 10 ) object1.position.y = 10;
    };

	this.update = function(delta, keys) {
		velocity.x -= velocity.x * 10.0 * delta;
		velocity.z -= velocity.z * 10.0 * delta;
		velocity.y -= 9.8 * 100.0 * delta; // 100.0 = mass
		if ( keys.moveForward )   velocity.z -= 400.0 * delta;
		if ( keys.moveBackward )  velocity.z += 400.0 * delta;
		if ( keys.moveLeft )      velocity.x -= 400.0 * delta;
    	if ( keys.moveRight )     velocity.x += 400.0 * delta;
		// if ( isOnObject === true )  velocity.y = Math.max( 0, velocity.y );
		yawObject.translateX( velocity.x * delta );
		yawObject.translateY( velocity.y * delta );
		yawObject.translateZ( velocity.z * delta );
		if ( yawObject.position.y < 10 ) {
			velocity.y = 0;
			yawObject.position.y = 10;
			canJump = true;
		}
	};
    this.getDirection = function() {
		var direction = new THREE.Vector3( 0, 0, -1 );
		var rotation = new THREE.Euler( 0, 0, 0, "YXZ" );
		return function() {
			rotation.set( pitchObject.rotation.x, yawObject.rotation.y, 0 );
			return direction.clone().applyEuler( rotation );
		}
	}();
}


function init() {
    scene = new THREE.Scene();
    scene.fog = new THREE.Fog( 0xffffff, 0, 750 );
	var light = new THREE.HemisphereLight( 0xeeeeff, 0x777788, 0.75 );
	light.position.set( 0.5, 1, 0.75 );
    scene.add( light );

	camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 20000);

    raycaster = new THREE.Raycaster( new THREE.Vector3(), new THREE.Vector3( 0, - 1, 0 ), 0, 10 );
{#    raycaster = new THREE.Raycaster( );#}

	renderer =  new THREE.WebGLRenderer( {antialias:true} ) ;
    renderer.setClearColor( '#AFEEEE' );
	renderer.setSize(window.innerWidth, window.innerHeight);
	document.body.appendChild( renderer.domElement );
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
    sceneMesh = new THREE.Mesh( sceneGeometry, new THREE.MeshBasicMaterial( { vertexColors: THREE.VertexColors } ) );
    scene.add( sceneMesh );
    // endScene

    var cube1 = new THREE.Mesh(new THREE.BoxGeometry(10,5,5), new THREE.MeshBasicMaterial({color:'blue'}));
    var cube2 = new THREE.Mesh(new THREE.BoxGeometry(20,10,10), new THREE.MeshBasicMaterial({color:'green'}));
    cube1.position.set(8, 8, 8); cube1.position.set(6, 6, 6);
	scene.add(cube1); scene.add(cube2);
    meshList.push(cube1); meshList.push(cube2);

    clock = new THREE.Clock();
	keys = new Keys();
	localPlayer = new Player(65, 25, true);
{#    bulletCollision = checkBulletCollision();#}
	document.addEventListener("keydown",   function(e){ if (localPlayer)  keys.onKeyDown(e);  }, false);
	document.addEventListener("keyup",     function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
    document.addEventListener("click",     function(e){ if (localPlayer)  new Bullet(e, localPlayer.getDirection());    }, false);
    document.addEventListener('mousemove', function(e){
	    if (localPlayer) {
		    var x = e.movementX     || e.mozMovementX      || e.webkitMovementX   || 0;
            var y = e.movementY     || e.mozMovementY      || e.webkitMovementY   || 0;
            localPlayer.rotate(x, y);
        }
    }, false);

{#    for (var i = 0; i < ballMeshes.length; i++) {#}
{#        var originPoint = i.position.clone();#}
{#        for (var vertexIndex = 0; vertexIndex < i.geometry.vertices.length; vertexIndex++) {#}
{#		    var localVertex = i.geometry.vertices[vertexIndex].clone();#}
{#		    var globalVertex = localVertex.applyMatrix4(i.matrix);#}
{#		    var directionVector = globalVertex.sub(i.position);#}
{#		    var ray = new THREE.Raycaster(originPoint, directionVector.clone().normalize());#}
{#		    var collisionResults = ray.intersectObjects(i);#}
{#		    if (collisionResults.length > 0 && collisionResults[0].distance < directionVector.length())#}
{#			    createExplosion();#}
{#	    }#}
{#    }#}

}

function checkPlayerCollision(player){ }

function animate() {
    requestAnimationFrame(animate);

    particleGroup.tick(  clock.getDelta() );

	var time = performance.now();
	var delta = ( time - prevTime ) / 1000;
{#    var delta = clock.getDelta();#}
	localPlayer.update(delta, keys);

{#    checkPlayerCollision(player);#}
	for(var i = 0; i < bullets.length; i++) {
		bullets[i].update(delta);
	}
	for(var res = 0; res < meshList.length; res++) {
        for (var i = 0; i < ballMeshes.length; i++) {
            raycaster.ray.origin.copy(ballMeshes[i].position);
{#            console.warn('meshList[res]->', JSON.stringify(meshList[res]) );#}
            var intersections = raycaster.intersectObject(meshList[res]);
{#            console.warn('intersections->', JSON.stringify(intersections) );#}
            if (intersections.length > 0) {
{#                            console.warn('intersections->', JSON.stringify(intersections) );#}
                createExplosion(ballMeshes[i].position);
                scene.remove(ballMeshes[i]);
                scene.remove(meshList[res]);
                //TODO удалить из самого масива все меши
            }
        }
    }
    prevTime = time;
	renderer.render(scene, camera);
}
{#function animate() {#}
{#    requestAnimationFrame(animate);#}
{#	renderer.render(scene, camera);#}
{# }#}
</script>
</body>
</html>








{#<!DOCTYPE html>#}
{#<html>#}
{#<head><title>Игра</title> <meta charset="utf-8"> <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0"> </head>#}
{#<body>#}
{#<script src="/static/game/three.min.js"></script>#}
{#<style>#}
{#body { font-family: Monospace; font-weight: bold; background-color: #ccccff; margin: 0px; overflow: hidden; background-color:white;#}
{#</style>#}
{#<script>#}
{#var mesh, renderer, camera, scene, localPlay, key, plane, object3D;#}
{##}
{#init();#}
{#render();#}
{##}
{##}
{#function init(){#}
{#    scene = new THREE.Scene();#}
{#    camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );#}
{##}
{#    renderer = new THREE.WebGLRenderer();#}
{#    renderer.setSize( window.innerWidth, window.innerHeight );#}
{#    document.body.appendChild( renderer.domElement );#}
{#	var light = new THREE.PointLight(0xffffff);#}
{#	light.position.set(100,250,100);#}
{#	scene.add(light);#}
{#	var plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000, 10, 10), new THREE.MeshBasicMaterial({color: 0xcccccc, side:THREE.DoubleSide}));#}
{#	plane.position.y = -0.5;#}
{#	plane.rotation.x = Math.PI / 2;#}
{#	scene.add(plane);#}
{#	var cube = new THREE.Mesh(new THREE.BoxGeometry(3,2,2), new THREE.MeshBasicMaterial({color:'blue'}));#}
{#	scene.add(cube);#}
{#    camera.lookAt(scene.position);#}
{#    localPlay = new Player();#}
{#    localPlay.init();#}
{##}
{#    key = new Keys();#}
{#    document.addEventListener('keydown', function(e){key.onKeyDown(e)}, false);#}
{#    document.addEventListener('keyup',   function(e){key.onKeyUp(e)}, false);#}
{# }#}
{##}
{#function render(){#}
{#    requestAnimationFrame( render );#}
{#    localPlay.draw();#}
{#    renderer.render( scene, camera );#}
{# }#}
{##}
{#function Player(preX, preY, preZ){#}
{#    var x=preX, y=preY, z=preZ;#}
{#    var x=0.1, y=0.1, z=0.1;#}
{#    var velocity = new THREE.Vector3();#}
{##}
{#    this.init = function(){#}
{#        mesh = new THREE.Mesh(new THREE.BoxGeometry(1,5,1), new THREE.MeshBasicMaterial({color:'red'}) );#}
{#        scene.add(mesh);#}
{#    };#}
{#    this.draw = function(){#}
{#        // засунуть в обьект кучу всего и вместе порулить этим#}
{#       	var prevTime = performance.now();#}
{#       	var velocity = new THREE.Vector3();#}
{#		var time = performance.now();#}
{#		var delta = ( time - prevTime ) / 1000;#}
{#        if (key.up)         z -= 0.2;#}
{#		else if (key.down)  z += 0.2;#}
{#		if (key.left)       x -= 0.2;#}
{#		else if (key.right) x += 0.2;#}
{##}
{#        camera.position.z = 5;#}
{#        camera.rotation.set( 0, 0, 0 );#}
{##}
{#        object3D = new THREE.Object3D();#}
{#        object3D.add( camera );#}
{#        object3D.add( mesh );#}
{#        scene.add(object3D);#}
{#        object3D.position.set(x, y, z);#}
{#        mesh.position.set(x, y, z);#}
{##}
{##}
{#        var cameraOffset = new THREE.Vector3(0, 2, 8).applyMatrix4(mesh.matrixWorld);#}
{#        camera.position.set(cameraOffset.x, cameraOffset.y, cameraOffset.z);#}
{#        camera.lookAt(mesh.position);#}
{##}
{#        camera.position.set(x, y, z);#}
{##}
{#        mesh.rotation.x += 0.1;#}
{#        mesh.rotation.y += 0.1;#}
{#    }#}
{# }#}
{##}
{#function Keys(up, left, right, down) {#}
{#    console.log(' init keys');#}
{#	var up = up || false, left = left || false, right = right || false, down = down || false;#}
{#	this.onKeyDown = function(e) {#}
{#		var that = this;#}
{#		switch (e.keyCode) {#}
{#			case 37: case 65: that.left  = true; break;#}
{#			case 38: case 87: that.up    = true; break;#}
{#			case 39: case 68: that.right = true; break;#}
{#			case 40: case 83: that.down  = true; break;#}
{#		}#}
{#	};#}
{#	this.onKeyUp = function(e) {#}
{#		var that = this;#}
{#		switch (e.keyCode) {#}
{#			case 37: case 65: that.left  = false; break;#}
{#			case 38: case 87: that.up    = false; break;#}
{#			case 39: case 68: that.right = false; break;#}
{#			case 40: case 83: that.down  = false; break;#}
{#		}#}
{#	};#}
{# }#}
{##}
{#</script>#}
{#</body></html>#}








{#        if ( keyboard.pressed("A") )#}
{#		MovingCube.rotateOnAxis( new THREE.Vector3(0,1,0), rotateAngle);#}


{#<!DOCTYPE html>#}
{#<html>#}
{#<head><title>Игра</title> <meta charset="utf-8"> <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0"> </head>#}
{#<body>#}
{#<script src="/static/game/three.min.js"></script>#}
{#<style>#}
{#body { font-family: Monospace; font-weight: bold; background-color: #ccccff; margin: 0px; overflow: hidden; background-color:white;#}
{#</style>#}
{#<script>#}
{#var mesh, renderer, camera, scene, localPlay, key, plane, object3D;#}
{##}
{#init();#}
{#render();#}
{##}
{##}
{#function init(){#}
{#    scene = new THREE.Scene();#}
{#    camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );#}
{##}
{#    camera = new THREE.PerspectiveCamera( 45, window.innerWidth/window.innerHeight, 0.1, 20000);#}
{#	scene.add(camera);#}
{#	camera.position.set(0,150,400);#}
{#	camera.lookAt(scene.position);#}
{##}
{##}
{#    scene.add(camera);#}
{#    renderer = new THREE.WebGLRenderer();#}
{#    renderer.setSize( window.innerWidth, window.innerHeight );#}
{#    document.body.appendChild( renderer.domElement );#}
{#	var light = new THREE.PointLight(0xffffff);#}
{#	light.position.set(100,250,100);#}
{#	scene.add(light);#}
{#	var plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000, 10, 10), new THREE.MeshBasicMaterial({color: 0xcccccc, side:THREE.DoubleSide}));#}
{#	plane.position.y = -0.5;#}
{#	plane.rotation.x = Math.PI / 2;#}
{#	scene.add(plane);#}
{#	var cube = new THREE.Mesh(new THREE.BoxGeometry(3,2,2), new THREE.MeshBasicMaterial({color:'blue'}));#}
{#	scene.add(cube);#}
{#    camera.lookAt(scene.position);#}
{#    mesh = new THREE.Mesh(new THREE.BoxGeometry(1,5,1), new THREE.MeshBasicMaterial({color:'red'}) );#}
{#    scene.add(mesh);#}
{#    camera.position.z = 5;#}
{##}
{#    object3D = new THREE.Object3D();#}
{#    object3D.add( camera );#}
{#    object3D.add( mesh );#}
{#    scene.add(object3D);#}
{##}
{#    object3D.position.z = 5;#}
{#    object3D.position.set(x, y, z);#}
{##}
{##}
{# }#}
{##}
{#function render(){#}
{#    requestAnimationFrame( render );#}
{#    object3D.rotation.x += 0.1;#}
{#    object3D.rotation.y += 0.1;#}
{#    mesh.rotation.x += 0.1;#}
{#    mesh.rotation.y += 0.1;#}
{#    renderer.render( scene, camera );#}
{# }#}
{##}






{#//Mesh to align#}
{#var cylinder = new THREE.Mesh(new THREE.CylinderGeometry(10, 10, 15), new THREE.MeshLambertMaterial({color: 0x0000ff}));#}
{#//vector to align to#}
{#var vector = new THREE.Vector3(5, 10, 15 );#}
{#//create a point to lookAt#}
{#var focalPoint = new THREE.Vector3(cylinder.position.x + vector.x, cylinder.position.y + vector.y, cylinder.position.z + vector.z );#}
{#//all that remains is setting the up vector (if needed) and use lookAt#}
{#cylinder.up = new THREE.Vector3(0,0,1);//Z axis up#}
{#cylinder.lookAt(focalPoint);#}


{#</script>#}
{##}
{#</body></html>#}



{#<div id="pointer-lock-demo" class="" style="width:200px; height:200px; margin: 200px; cursor:pointer;  border:1px solid red;">Щелкните для разблокировки</div>#}
{#<canvas id="gameCanvas"></canvas>#}
{#<script type="text/javascript">#}
{#    // определяем, поддерживается ли pointerLock#}
{#    var havePointerLock = 'pointerLockElement' in document || 'mozPointerLockElement' in document || 'webkitPointerLockElement' in document;#}
{#    // Элемент, для которого будем включать pointerLock#}
{#    var requestedElement = document.getElementById('pointer-lock-demo');#}
{#    // Танцы с префиксами для методов включения/выключения pointerLock#}
{#    requestedElement.requestPointerLock = requestedElement.requestPointerLock || requestedElement.mozRequestPointerLock || requestedElement.webkitRequestPointerLock;#}
{#    document.exitPointerLock =  document.exitPointerLock || document.mozExitPointerLock || document.webkitExitPointerLock;#}
{#    var isLocked = function(){ return requestedElement === document.pointerLockElement || requestedElement === document.mozPointerLockElement || requestedElement === document.webkitPointerLockElement; };#}
{#    requestedElement.addEventListener('click', function(){#}
{#        if(!isLocked()) requestedElement.requestPointerLock();#}
{#        else document.exitPointerLock();#}
{#    }, false);#}
{##}
{#    var pointerlockchange = function() {#}
{#        if(!havePointerLock){ alert('Ваш браузер не поддерживает pointer-lock'); return; }#}
{#        if (isLocked()) {#}
{#            play.enabled = true;#}
{#            requestedElement.style.display = 'none';#}
{#        } else {#}
{#            play.enabled = false;#}
{#            requestedElement.style.display = 'box';#}
{#            requestedElement.style.display = '-webkit-box';#}
{#        }#}
{#    };#}
{#    document.addEventListener('pointerlockchange', pointerlockchange, false);#}
{#    document.addEventListener('mozpointerlockchange', pointerlockchange, false);#}
{#    var play = new Player();#}
{#    document.addEventListener('mousemove', function(e){ play.draw(e) }, false);#}
{#    function Player(){#}
{#        var scope = this;#}
{#        this.draw = function(e){#}
{#            if (scope.enable === false) return;#}
{#            var x = e.movementX || e.mozMovementX || e.webkitMovementX || 0;#}
{#            var y = e.movementY || e.mozMovementY || e.webkitMovementY || 0;#}
{#            var canvas = document.getElementById("gameCanvas");#}
{#            canvas.width = window.innerWidth;#}
{#            canvas.height = window.innerHeight;#}
{#            var ctx = canvas.getContext("2d");#}
{#            ctx.fillRect(x, y, 50, 50);#}
{#        };#}
{#    }#}



{#Движение камеры со светом#}
{#camera.add( pLight );#}
{#pLight.position = new THREE.Vector3(0,0,10);#}


{#var geometry = new THREE.TetrahedronGeometry(40, 0);#}
{#geometry.applyMatrix( new THREE.Matrix4().makeRotationAxis( new THREE.Vector3( 1, 0, -1 ).normalize(), Math.atan( Math.sqrt(2)) ) );#}



{#function update(){#}
{#    //все препятствия заносятся в масив #}
{#    //а потом созлается обьект этот рейкастер   и проверяется что если в какоето из препяствий масива вьехало то все  #}
{##}
{#	var wall2 = new THREE.Mesh(wallGeometry, wallMaterial);#}
{#	wall2.position.set(-150, 50, 0);#}
{#	wall2.rotation.y = 3.14159 / 2;#}
{#	scene.add(wall2);#}
{#	collidableMeshList.push(wall2)#}
{##}
{#	for (var vertexIndex = 0; vertexIndex < MovingCube.geometry.vertices.length; vertexIndex++)#}
{#	{#}
{#		var localVertex = MovingCube.geometry.vertices[vertexIndex].clone();#}
{#		var globalVertex = localVertex.applyMatrix4( MovingCube.matrix );#}
{#		var directionVector = globalVertex.sub( MovingCube.position );#}
{##}
{#		var ray = new THREE.Raycaster( originPoint, directionVector.clone().normalize() );#}
{#		var collisionResults = ray.intersectObjects( collidableMeshList );#}
{#		if ( collisionResults.length > 0 && collisionResults[0].distance < directionVector.length() )#}
{#			appendText(" Hit ");#}
{#	}#}
{##}
{# }#}





<script>
	var renderer	= new THREE.WebGLRenderer();
	renderer.setSize( window.innerWidth, window.innerHeight );
	document.body.appendChild( renderer.domElement );
	var onRenderFcts= [];
	var scene	= new THREE.Scene();
	var camera	= new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.01, 1000);
	camera.position.z = 100;
	var world	= new OIMO.World();
	onRenderFcts.push(function(delta){ world.step() });
	var geometry	= new THREE.CubeGeometry(100,100,400);
	var material	= new THREE.MeshNormalMaterial();
	var mesh	= new THREE.Mesh( geometry, material );
	mesh.position.y	= -geometry.height/2;
	scene.add(mesh);
	var ground	= THREEx.Oimo.createBodyFromMesh(world, mesh, false);
    for(var i = 0; i < 100; i++ ){
	(function(){
		if( Math.random() < 0.5 ){
			var width	= 3 + (Math.random()-0.5)*1; var height	= 3 + (Math.random()-0.5)*1; var depth	= 3 + (Math.random()-0.5)*1;
			var geometry	= new THREE.CubeGeometry(width, height, depth)
		}else{
			var radius	= 3 + (Math.random()-0.5)*0; var geometry	= new THREE.SphereGeometry( radius );
		}
		var material	= new THREE.MeshNormalMaterial();
		var mesh	= new THREE.Mesh( geometry, material );
		scene.add( mesh );
		mesh.position.x	= (Math.random()-0.5)*20;
		mesh.position.y	= 25 + (Math.random()-0.5)*15;
		mesh.position.z	= (Math.random()-0.5)*20;
		// create IOMO.Body from mesh
		var body	= THREEx.Oimo.createBodyFromMesh(world, mesh);
        window.body	= body;
		// add an updater for them
		var updater	= new THREEx.Oimo.Body2MeshUpdater(body, mesh);
		onRenderFcts.push(function(delta){ updater.update(); });
		// if the position.y < 20, reset the position
		onRenderFcts.push(function(delta){
			if( mesh.position.y < -20 ){  mesh.position.x = (Math.random()-0.5)*20; mesh.position.y	= 25 + (Math.random()-0.5)*15; mesh.position.z = (Math.random()-0.5)*20;
				body.setPosition(mesh.position.x, mesh.position.y, mesh.position.z);
			}
		});
	})();
    }
	var iomoStats	= new THREEx.Oimo.Stats(world);
	document.body.appendChild(iomoStats.domElement);
	onRenderFcts.push(function(delta){ iomoStats.update() });
	var mouse	= {x : 0, y : 0};
	document.addEventListener('mousemove', function(event){
		mouse.x	= (event.clientX / window.innerWidth ) - 0.5
		mouse.y	= (event.clientY / window.innerHeight) - 0.5
	}, false)
	onRenderFcts.push(function(delta, now){
		camera.position.x += (mouse.x*50 - camera.position.x) * (delta*3)
		camera.position.y += (mouse.y*50 - (camera.position.y - 5)) * (delta*3)
		camera.lookAt( scene.position )
	});
	onRenderFcts.push(function(){ renderer.render( scene, camera ); });

	var lastTimeMsec= null;
	requestAnimationFrame(function animate(nowMsec){
		requestAnimationFrame( animate );
		lastTimeMsec	= lastTimeMsec || nowMsec-1000/60;
		var deltaMsec	= Math.min(200, nowMsec - lastTimeMsec);
		lastTimeMsec	= nowMsec;
		onRenderFcts.forEach(function(onRenderFct){ onRenderFct(deltaMsec/1000, nowMsec/1000) });
	});
</script>