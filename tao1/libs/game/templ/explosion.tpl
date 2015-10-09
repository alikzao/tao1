
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Shoot</title>
{#    <script src="/static/game/babylon/water/hand.minified-1.1.0.js"></script>#}

    <script src="/static/game/babylon1-debug.js"></script>
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
var lmesh, camera, mesh;
function run() {
        var canvas = document.getElementById("renderCanvas");
        var engine = new BABYLON.Engine(canvas, false);
        // Resize
        window.addEventListener("resize", function () { engine.resize(); });
        // Scene, light and camera
        var scene = new BABYLON.Scene(engine);
        var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);
        camera = new BABYLON.ArcRotateCamera("Camera", 0, Math.PI / 2, 100, new BABYLON.Vector3(0, 0, 0), scene);
        camera.attachControl(canvas);


{#        mesh = BABYLON.Mesh.CreateSphere("sphere1", 16, 2, scene);#}
{#        mesh.position = new BABYLON.Vector3( 1, 1, 2);#}
{#        mesh.scaling.x = -3;#}
{#        mesh.scaling.z = -3;#}
{#        mesh.material = new BABYLON.StandardMaterial("texture1", scene);#}
{#        mesh.material.diffuseTexture = new BABYLON.Texture("/static/game/babylon/ufo_t.png", scene);#}


        // Assets manager
        var loader =  new BABYLON.AssetsManager(scene);
{#        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "gun.babylon");#}
{#        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/img/", "aaa.babylon");#}
{#        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "ufo.babylon");#}
        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "q.babylon");


{#        mesh.material =  new BABYLON.StandardMaterial('texture1', scene);#}
{#        mesh.material.diffuseColor = new BABYLON.Color3(1, 1, 0);#}

{#        mesh.material.diffuseTexture.uOffset = 1.5;#}
{#        mesh.material.diffuseTexture.vOffset = 0.5;#}
{#        mesh.material.diffuseTexture.uScale = 5.0;#}
{#        mesh.material.diffuseTexture.vScale = 5.0;#}



         loader.onFinish = function (tasks) {
            engine.runRenderLoop(function () { scene.render(); });
        };
        // Just call load to initiate the loading sequence
        loader.load();

        // Just call load to initiate the loading sequence

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
