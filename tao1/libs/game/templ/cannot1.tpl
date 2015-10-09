<!DOCTYPE html>
<html>
<head><title>Игра</title> <meta charset="utf-8"> <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0"> </head>
<body>
<script src="/static/game/three.min.js"></script>
<style>
body { font-family: Monospace; font-weight: bold; background-color: #ccccff; margin: 0px; overflow: hidden; background-color:white;
</style>
<script>
var mesh, renderer, camera, scene, localPlay, key, plane, object3D;

init();
render();


function init(){
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );

{#    camera = new THREE.PerspectiveCamera( 45, window.innerWidth/window.innerHeight, 0.1, 20000);#}
{#	scene.add(camera);#}
{#	camera.position.set(0,150,400);#}
{#	camera.lookAt(scene.position);#}


{#    scene.add(camera);#}
    renderer = new THREE.WebGLRenderer();
    renderer.setSize( window.innerWidth, window.innerHeight );
    document.body.appendChild( renderer.domElement );
	var light = new THREE.PointLight(0xffffff);
	light.position.set(100,250,100);
	scene.add(light);
	var plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000, 10, 10), new THREE.MeshBasicMaterial({color: 0xcccccc, side:THREE.DoubleSide}));
	plane.position.y = -0.5;
	plane.rotation.x = Math.PI / 2;
	scene.add(plane);
	var cube = new THREE.Mesh(new THREE.BoxGeometry(3,2,2), new THREE.MeshBasicMaterial({color:'blue'}));
	scene.add(cube);
{#    camera.lookAt(scene.position);#}
    localPlay = new Player();
    localPlay.init();

    key = new Keys();
    document.addEventListener('keydown', function(e){key.onKeyDown(e)}, false);
    document.addEventListener('keyup',   function(e){key.onKeyUp(e)}, false);
}

function render(){
    requestAnimationFrame( render );
    localPlay.draw();
    renderer.render( scene, camera );
}

function Player(preX, preY, preZ){
{#    var x=preX, y=preY, z=preZ;#}
    var x=0.1, y=0.1, z=0.1;
    var velocity = new THREE.Vector3();

    this.init = function(){
        mesh = new THREE.Mesh(new THREE.BoxGeometry(1,5,1), new THREE.MeshBasicMaterial({color:'red'}) );
        scene.add(mesh);
    };
    this.draw = function(){
        // засунуть в обьект кучу всего и вместе порулить этим
       	var prevTime = performance.now();
       	var velocity = new THREE.Vector3();
		var time = performance.now();
		var delta = ( time - prevTime ) / 1000;
        if (key.up)         z -= 0.2;
		else if (key.down)  z += 0.2;
		if (key.left)       x -= 0.2;
		else if (key.right) x += 0.2;

        camera.position.z = 5;
{#        camera.rotation.set( 0, 0, 0 );#}

        object3D = new THREE.Object3D();
        object3D = new THREE.Object3D();
        object3D.add( camera );
        object3D.add( mesh );
        scene.add(object3D);

{#        object3D.add( camera );#}
{#        object3D.add( mesh );#}
{#        object3D.position.z = 5;#}
        object3D.position.set(x, y, z);
        mesh.position.set(x, y, z);


{#        var cameraOffset = new THREE.Vector3(0, 2, 8).applyMatrix4(mesh.matrixWorld);#}
{#        camera.position.set(cameraOffset.x, cameraOffset.y, cameraOffset.z);#}
{#        camera.lookAt(mesh.position);#}


{#        if ( keyboard.pressed("A") )#}
{#		MovingCube.rotateOnAxis( new THREE.Vector3(0,1,0), rotateAngle);#}

{#        camera.position.set(x, y, z);#}

{#        mesh.rotation.x += 0.1;#}
{#        mesh.rotation.y += 0.1;#}
    }
}

function Keys(up, left, right, down) {
    console.log(' init keys');
	var up = up || false, left = left || false, right = right || false, down = down || false;
	this.onKeyDown = function(e) {
		var that = this;
		switch (e.keyCode) {
			case 37: case 65: that.left  = true; break;
			case 38: case 87: that.up    = true; break;
			case 39: case 68: that.right = true; break;
			case 40: case 83: that.down  = true; break;
		}
	};
	this.onKeyUp = function(e) {
		var that = this;
		switch (e.keyCode) {
			case 37: case 65: that.left  = false; break;
			case 38: case 87: that.up    = false; break;
			case 39: case 68: that.right = false; break;
			case 40: case 83: that.down  = false; break;
		}
	};
}




{#//Mesh to align#}
{#var cylinder = new THREE.Mesh(new THREE.CylinderGeometry(10, 10, 15), new THREE.MeshLambertMaterial({color: 0x0000ff}));#}
{#//vector to align to#}
{#var vector = new THREE.Vector3(5, 10, 15 );#}
{#//create a point to lookAt#}
{#var focalPoint = new THREE.Vector3(cylinder.position.x + vector.x, cylinder.position.y + vector.y, cylinder.position.z + vector.z );#}
{#//all that remains is setting the up vector (if needed) and use lookAt#}
{#cylinder.up = new THREE.Vector3(0,0,1);//Z axis up#}
{#cylinder.lookAt(focalPoint);#}


</script>

</body></html>



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