<!DOCTYPE html>
<head>
	<link rel="stylesheet" type="text/css" href="css/style.css" />
	<script src="js/babylon.1.14-beta-debug.js"></script>

    <script src="js/Player.js"></script>
    <script src="js/Target.js"></script>
    <script src="js/Weapon.js"></script>
    <script src="js/Arena.js"></script>
    <script src="js/Game.js"></script>
</head>
<body>
    <img id="viseur" src="assets/viseur.png" />
    <!--<canvas id="guiCanvas"></canvas>-->
    <canvas id="renderCanvas"></canvas>

<script type="text/javascript">

Player = function(game, spawnPoint) {
    if (!spawnPoint) spawnPoint = new BABYLON.Vector3(0,10,-10);
    // The player spawnPoint
    this.spawnPoint = spawnPoint;
    this.scene = game.scene;
    this.game = game;
    this.height = 2;
    this.speed = 1;
    this.inertia = 0.9;
    this.angularInertia = 0;
    this.angularSensibility = 1000;
    this.camera = this._initCamera();
    this.controlEnabled = false;
    this.weapon = new Weapon(game, this);
    var _this = this;
    var canvas = this.scene.getEngine().getRenderingCanvas();
    canvas.addEventListener("click", function(evt) {
        var width = _this.scene.getEngine().getRenderWidth();
        var height = _this.scene.getEngine().getRenderHeight();
        if (_this.controlEnabled) {
            var pickInfo = _this.scene.pick(width/2, height/2, null, false, _this.camera);
            _this.handleUserMouse(evt, pickInfo);
        }
    }, false);
    this._initPointerLock();
    // The representation of player in the minimap
    var s = BABYLON.Mesh.CreateSphere("player2", 16, 4, this.scene);
    s.position.y = 10;
    s.registerBeforeRender(function() {
        s.position.x = _this.camera.position.x;
        s.position.z = _this.camera.position.z;
    });
    var red = new BABYLON.StandardMaterial("red", this.scene);
    red.diffuseColor = BABYLON.Color3.Red();
    red.specularColor = BABYLON.Color3.Black();
    s.material = red;
    s.layerMask = 1;
    // Set the active camera for the minimap
    this.scene.activeCameras.push(this.camera);
    this.scene.activeCamera = this.camera;
};
Player.prototype = {
    _initPointerLock : function() {
        var _this = this;
        var canvas = this.scene.getEngine().getRenderingCanvas();
        canvas.addEventListener("click", function(evt) {
            canvas.requestPointerLock = canvas.requestPointerLock || canvas.msRequestPointerLock || canvas.mozRequestPointerLock || canvas.webkitRequestPointerLock;
            if (canvas.requestPointerLock) canvas.requestPointerLock();
        }, false);

        // Event listener when the pointerlock is updated.
        var pointerlockchange = function (event) {
            _this.controlEnabled = (document.mozPointerLockElement === canvas || document.webkitPointerLockElement === canvas || document.msPointerLockElement === canvas || document.pointerLockElement === canvas);
            if (!_this.controlEnabled) _this.camera.detachControl(canvas);
            else _this.camera.attachControl(canvas);
        };
        document.addEventListener("pointerlockchange", pointerlockchange, false);
        document.addEventListener("mspointerlockchange", pointerlockchange, false);
        document.addEventListener("mozpointerlockchange", pointerlockchange, false);
        document.addEventListener("webkitpointerlockchange", pointerlockchange, false);
    },
    _initCamera : function() {
        var cam = new BABYLON.FreeCamera("camera", this.spawnPoint, this.scene);
        cam.attachControl(this.scene.getEngine().getRenderingCanvas());
        cam.ellipsoid = new BABYLON.Vector3(2, this.height, 2);
        cam.checkCollisions = true;
        cam.applyGravity = true;
        cam.keysUp = [90]; // Z
        cam.keysDown = [83]; // S
        cam.keysLeft = [81]; // Q
        cam.keysRight = [68]; // D
        cam.speed = this.speed;
        cam.inertia = this.inertia;
        cam.angularInertia = this.angularInertia;
        cam.angularSensibility = this.angularSensibility;
        cam.layerMask = 2;
        return cam;
    },
    handleUserKeyboard : function(keycode)    { switch (keycode) { } },
    handleUserMouse : function(evt, pickInfo) { this.weapon.fire(pickInfo); }
};

Target = function(game, posX, posZ) {
    this.game = game;
    BABYLON.Mesh.call(this, "target", game.scene);
    var vd = BABYLON.VertexData.CreateSphere(16, 5);
    vd.applyToMesh(this, false);
    // The game
    this.game = game;
    // Target position
    this.position = new BABYLON.Vector3(posX, 4, posZ);
    this.checkCollisions = true;
    var _this = this;
    this.game.scene.registerBeforeRender(function() {
        _this.rotation.y += 0.01;
    });
};
// Our object is a BABYLON.Mesh
Target.prototype = Object.create(BABYLON.Mesh.prototype);
// And its constructor is the Ship function described above.
Target.prototype.constructor = Target;
Target.prototype.explode = function() {
    this.dispose();
};
Weapon = function(game, player) {
    this.game = game;
    this.player = player;
    // The weapon mesh
    var wp = game.assets["gun"][0];
    wp.isVisible = true;
    wp.rotationQuaternion = null;
    wp.rotation.x = -Math.PI/2;
    wp.rotation.y = Math.PI;
    wp.parent = player.camera;
    wp.position = new BABYLON.Vector3(0.25,-0.4,1);
    this.mesh = wp;
    // The initial rotation
    this._initialRotation = this.mesh.rotation.clone();
    // The fire rate
    this.fireRate = 250.0;
    this._currentFireRate = this.fireRate;
    this.canFire = true;
    // The particle emitter
    var scene = this.game.scene;
    var particleSystem = new BABYLON.ParticleSystem("particles", 100, scene );
    particleSystem.emitter = this.mesh; // the starting object, the emitter
    particleSystem.particleTexture = new BABYLON.Texture("assets/particles/gunshot_125.png", scene);
    particleSystem.emitRate = 5;
    particleSystem.blendMode = BABYLON.ParticleSystem.BLENDMODE_STANDARD;
    particleSystem.minEmitPower = 1;
    particleSystem.maxEmitPower = 3;
    particleSystem.colorDead = new BABYLON.Color4(1, 1, 1, 0.0);
    particleSystem.minLifeTime = 0.2;
    particleSystem.maxLifeTime = 0.2;
    particleSystem.updateSpeed = 0.02;
    this.particleSystem = particleSystem;
    var _this = this;
    this.game.scene.registerBeforeRender(function() {
        if (!_this.canFire) {
            _this._currentFireRate -= BABYLON.Tools.GetDeltaTime();
            if (_this._currentFireRate <= 0) {
                _this.canFire = true;
                _this._currentFireRate = _this.fireRate;
            }
        }
    });
};

Weapon.prototype = {
    // Animate the weapon
    animate : function() {
        this.particleSystem.start();
        var start = this._initialRotation.clone();
        var end = start.clone();
        end.x += Math.PI/10;
        // Create the Animation object
        var display = new BABYLON.Animation("fire", "rotation", 60, BABYLON.Animation.ANIMATIONTYPE_VECTOR3, BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT);
        // Animations keys
        var keys = [{ frame: 0, value: start}, {frame: 10, value: end}, {frame: 100, value: start}];
        // Add these keys to the animation
        display.setKeys(keys);
        // Link the animation to the mesh
        this.mesh.animations.push(display);
        // Run the animation !
        var _this = this;
        this.game.scene.beginAnimation(this.mesh, 0, 100, false, 10, function() {
            _this.particleSystem.stop();
        });
    },
    // Fire the weapon if possible. The mesh is animated and some particles are emitted.
    fire : function(pickInfo) {
        if (this.canFire) {
            if (pickInfo.hit && pickInfo.pickedMesh.name === "target") {
                pickInfo.pickedMesh.explode();
            } else {
                var b = BABYLON.Mesh.CreateBox("box", 0.1, this.game.scene);
                b.position = pickInfo.pickedPoint.clone();
            }
            this.animate();
            this.canFire = false;
        } else { }
    }
};
/**
 * The arena is the world where the player will evolve
 * @param scene
 * @constructor
 */
Arena = function(game) {
    this.game = game;
    // The arena size
    this.size = 100;
    // The ground
    var ground = BABYLON.Mesh.CreateGround("ground",  this.size,  this.size, 2, this.game.scene);
    this._deactivateSpecular(ground);
    ground.checkCollisions = true;
    var _this = this;
    setInterval(function() {
        var posX = _this._randomNumber(-_this.size/2, _this.size/2);
        var posZ = _this._randomNumber(-_this.size/2, _this.size/2);
        var t = new Target(_this.game, posX, posZ);
    }, 1000);
    // Minimap
    var mm = new BABYLON.FreeCamera("minimap", new BABYLON.Vector3(0,100,0), this.game.scene);
    mm.layerMask = 1;
    mm.setTarget(new BABYLON.Vector3(0.1,0.1,0.1));
    mm.mode = BABYLON.Camera.ORTHOGRAPHIC_CAMERA;
    mm.orthoLeft = -this.size/2;
    mm.orthoRight = this.size/2;
    mm.orthoTop =  this.size/2;
    mm.orthoBottom = -this.size/2;
    mm.rotation.x = Math.PI/2;
    var xstart = 0.8, ystart = 0.75;
    var width = 0.99-xstart, height = 1-ystart;
    mm.viewport = new BABYLON.Viewport(xstart, ystart, width, height);
    this.game.scene.activeCameras.push(mm);
};


Arena.prototype = {
    /** Generates a random number between min and max
     * @param min
     * @param max
     * @returns {number}
     */
    _randomNumber : function (min, max) {
        if (min == max) return (min);
        var random = Math.random();
        return ((random * (max - min)) + min);
    },
    _deactivateSpecular : function(mesh) {
        if (!mesh.material) mesh.material = new BABYLON.StandardMaterial(mesh.name+"mat", this.game.scene);
        mesh.material.specularColor = BABYLON.Color3.Black();
    }
};

var VERSION = 1.0, AUTHOR = "temechon@pixelcodr.com";
// The function onload is loaded when the DOM has been loaded
document.addEventListener("DOMContentLoaded", function () {
    new Game('renderCanvas');
}, false);

Game = function(canvasId) {
    var canvas = document.getElementById(canvasId);
    var engine = new BABYLON.Engine(canvas, true);
    this.scene = this._initScene(engine);
    var _this = this;
    this.loader =  new BABYLON.AssetsManager(this.scene);
    // An array containing the loaded assets
    this.assets = {};
    var meshTask = this.loader.addMeshTask("gun", "", "./assets/", "gun.babylon");
    meshTask.onSuccess = function(task) {
        _this._initMesh(task);
    };
    this.loader.onFinish = function (tasks) {
        // Player and arena creation when the loading is finished
        var player = new Player(_this);
        var arena = new Arena(_this);
        engine.runRenderLoop(function () {
            _this.scene.render();
        });
        window.addEventListener("keyup", function(evt) {
            _this.handleUserInput(evt.keyCode);
        });
    };
    this.loader.load();
    // Resize the babylon engine when the window is resized
    window.addEventListener("resize", function () {
        if (engine) engine.resize();
    },false);
};
Game.prototype = {
    // Init the environment of the game / skybox, camera, ...
    _initScene : function(engine) {
        var scene = new BABYLON.Scene(engine);
        axis(scene, 5);
        // Update the scene background color
        scene.clearColor=new BABYLON.Color3(0.8,0.8,0.8);
        // Hemispheric light to light the scene
        new BABYLON.HemisphericLight("hemi", new BABYLON.Vector3(1, 2, 1), scene);
        // Skydome
        var skybox = BABYLON.Mesh.CreateSphere("skyBox", 50, 1000, scene);
        skybox.layerMask = 2;
        // The sky creation
        BABYLON.Engine.ShadersRepository = "shaders/";
        var shader = new BABYLON.ShaderMaterial("gradient", scene, "gradient", {});
        shader.setFloat("offset", 200);
        shader.setColor3("topColor", BABYLON.Color3.FromInts(0,119,255));
        shader.setColor3("bottomColor", BABYLON.Color3.FromInts(240,240, 255));
        shader.backFaceCulling = false;
        skybox.material = shader;
        return scene;
    },
    handleUserInput : function(keycode) { switch (keycode) { } },
    _initMesh : function(task) {
        this.assets[task.name] = task.loadedMeshes;
        for (var i=0; i<task.loadedMeshes.length; i++ ){
            var mesh = task.loadedMeshes[i];
            mesh.isVisible = false;
        }
    }
};
var axis = function(scene, size) {
        var x = BABYLON.Mesh.CreateCylinder("x", size, 0.1, 0.1, 6, scene, false);
        x.material = new BABYLON.StandardMaterial("xColor", scene);
        x.material.diffuseColor = new BABYLON.Color3(1, 0, 0);
        x.position = new BABYLON.Vector3(size/2, 0, 0);
        x.rotation.z = Math.PI / 2;
        var y = BABYLON.Mesh.CreateCylinder("y", size, 0.1, 0.1, 6, scene, false);
        y.material = new BABYLON.StandardMaterial("yColor", scene);
        y.material.diffuseColor = new BABYLON.Color3(0, 1, 0);
        y.position = new BABYLON.Vector3(0, size / 2, 0);
        var z = BABYLON.Mesh.CreateCylinder("z", size, 0.1, 0.1, 6, scene, false);
        z.material = new BABYLON.StandardMaterial("zColor", scene);
        z.material.diffuseColor = new BABYLON.Color3(0, 0, 1);
        z.position = new BABYLON.Vector3(0, 0, size/2);
        z.rotation.x = Math.PI / 2;
};

</script>

</body>
</html>
