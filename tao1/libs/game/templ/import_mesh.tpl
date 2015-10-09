
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Shoot</title>
    <script src="/static/game/babylon/water/hand.minified-1.1.0.js"></script>

    <script src="/static/game/babylon/babylon1-debug.js"></script>
{#    <script src="/static/game/babylon/water/Shaders/Water/waterMaterial.js"></script>#}
    <style>
        html, body { width: 100%; height: 100%; padding: 0; margin: 0; overflow: hidden; }
        #renderCanvas { width: 100%; height: 100%; touch-action: none; }
    </style>
</head>
<body>
    <canvas id="renderCanvas"></canvas>
<script>

"use strict";

document.addEventListener("DOMContentLoaded", run, false);
var lmesh, camera;
function run() {
    if (BABYLON.Engine.isSupported()) {
        BABYLON.Engine.ShadersRepository = "/Babylon/Shaders/";
        var canvas = document.getElementById("renderCanvas");
        var engine = new BABYLON.Engine(canvas, false);
        // Resize
        window.addEventListener("resize", function () { engine.resize(); });
        // Scene, light and camera
        var scene = new BABYLON.Scene(engine);
        var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);
        camera = new BABYLON.ArcRotateCamera("Camera", 0, Math.PI / 2, 100, new BABYLON.Vector3(0, 0, 0), scene);
{#      	camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(10, 10, 10), scene);#}
{#        camera.setTarget(BABYLON.Vector3.Zero());#}
{#        camera.ellipsoid = new BABYLON.Vector3(2, 2, 1);#}
{#        camera.checkCollisions = true;#}
{#        camera.applyGravity = true;#}
{#        camera.keysUp =    [38, 87];#}
{#        camera.keysDown =  [40, 83];#}
{#        camera.keysLeft =  [37, 65];#}
{#        camera.keysRight = [39, 68];#}



        camera.attachControl(canvas);
        // Assets manager
        var loader =  new BABYLON.AssetsManager(scene);
{#        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "gun.babylon");#}
{#        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/img/", "aaa.babylon");#}
{#        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "ufo.babylon");#}
        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "q.babylon");
{#        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "ufo3.babylon");#}

{#        var assetsManager = new BABYLON.AssetsManager(scene);#}
{#        var meshTask = assetsManager.addMeshTask("skull task", "", "./", "skull.babylon");#}
{#        var meshTask = assetsManager.addMeshTask("fly", "", "static/game/babylon/img/", "fly.babylon");#}
{#        var meshTask = assetsManager.addMeshTask("a", "", "static/game/babylon/img/", "a.babylon");#}
{#        var meshTask = assetsManager.addMeshTask("aaa", "", "/static/game/babylon/img/", "aaa.babylon");#}

        meshTask.onSuccess = function (task) {
{#            task.loadedMeshes[0].position = new BABYLON.Vector3(100, -1000, 0);#}
{#            lmesh = task.loadedMeshes[0];#}
{#            lmesh.position = new BABYLON.Vector3(0, 0, 0);#}
{#            lmesh.scaling.x = -100;#}
{#            lmesh.scaling.y = -100;#}
{#            lmesh.scaling.z = -100;#}
            task.loadedMeshes[0].parent = camera;
{#            task.loadedMeshes[0].scaling.x = 100;#}
{#            task.loadedMeshes[0].scaling.y = 100;#}
{#            task.loadedMeshes[0].scaling.z = 100;#}
        };

        loader.onTaskError = function (task) {
            console.log("error while loading " + task.name);
        };

{#        var textTask = assetsManager.addTextFileTask("text task", "msg.txt");#}
{#        textTask.onSuccess = function(task) {#}
{#            console.log(task.text);#}
{#        };#}

{#        var binaryTask = assetsManager.addBinaryFileTask("binary task", "grass.jpg");#}
{#        binaryTask.onSuccess = function (task) { };#}

        loader.onFinish = function (tasks) {
            engine.runRenderLoop(function () { scene.render(); });
        };
        // Just call load to initiate the loading sequence
        loader.load();
    }
};

{#var canvas, scene, camera, engine, light, box;#}
{#canvas = document.getElementById("renderCanvas");#}
{#engine = new BABYLON.Engine(canvas, true);#}
{#scene = new BABYLON.Scene(engine);#}
{#camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);#}
{#camera.setTarget(new BABYLON.Vector3.Zero());#}
{#camera.attachControl(canvas);#}
{#light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);#}
{#light.intensity = .5;#}
{#box = BABYLON.Mesh.CreateBox("box2", 2.0, scene);#}
{#box.position = new BABYLON.Vector3(2, 1, 0);#}
{#box.material =   new BABYLON.StandardMaterial('texture1', scene);#}
{#box.material.diffuseColor = new BABYLON.Color3(0, 1, 0);#}
{#var ground = BABYLON.Mesh.CreateGround("ground1", 250, 250, 2, scene);#}
{#var assetsManager = new BABYLON.AssetsManager(scene);#}
{#var meshTask = assetsManager.addMeshTask("fly1", "", "static/game/babylon/img/", "fly1.babylon");#}
{#meshTask.onSuccess = function (task) {#}
{#    task.loadedMeshes[0].position = new BABYLON.Vector3(1, 1, 1);#}
{# };#}
{#BABYLON.SceneLoader.ImportMesh("fly1", "static/game/babylon/img/", "fly1.babylon", scene, function (newMeshes) {#}
{#    camera.target = newMeshes[0];#}
{# }); #}


{#assetsManager.onFinish = function (tasks) {#}
{#    engine.runRenderLoop(function () {#}
{#        scene.render();#}
{#    });#}
{# };#}

</script>
</body>
</html>


{#    SaaS#}
{#       e-commerc#}
{#   linux#}
{#       самые оригиналные решения#}
{#      не всегда самые дорогие#}
{#       креативность не всегда означает#}
{#       самопиар#}


{#            lmesh = new BABYLON.Mesh.CreateBox(name, 1.0, scene);#}
{#            lmesh.position = new BABYLON.Vector3( 1, -1, 5);#}
{#            lmesh.parent = camera;#}
{#            lmesh.checkCollisions = true;#}
{#            lmesh.material =  new BABYLON.StandardMaterial('texture1', scene);#}
{#            lmesh.material.diffuseColor = new BABYLON.Color3(0, 0, 1);#}
