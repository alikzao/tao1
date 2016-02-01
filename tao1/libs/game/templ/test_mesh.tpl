
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Test mesh</title>
{#    <script src="/static/game/babylon/water/hand.minified-1.1.0.js"></script>#}

    <script src="/static/game/babylon.2.2.js"></script>
    <style>
        html, body { width: 100%; height: 100%; padding: 0; margin: 0; overflow: hidden; }
        #renderCanvas { width: 100%; height: 100%; touch-action: none; }
    </style>
</head>
<body>
{#    <canvas id="renderCanvas"></canvas>#}
    <audio controls="controls" autoplay="" src="http://78.129.224.15:3491/;stream.nsv&amp;type=mp3"></audio>
<script>
{#window.addEventListener('DOMContentLoaded', function(){});#}
{#var canvas = document.getElementById('renderCanvas');#}
{#var engine = new BABYLON.Engine(canvas, true);#}
{#window.addEventListener("resize", function () { engine.resize(); });#}
{#var scene = new BABYLON.Scene(engine);#}
{#var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);#}
{#var camera = new BABYLON.FreeCamera("FreeCamera", new BABYLON.Vector3(0, 0, 5), scene);#}
{#camera.rotation = new BABYLON.Vector3(0, Math.PI, 0);#}
{#camera.attachControl(canvas, true);#}
{#mesh = BABYLON.Mesh.CreateSphere('name', 16, 0, scene);#}
{#mesh.material =  new BABYLON.StandardMaterial('texture1', scene);#}
{#mesh.material.diffuseColor = new BABYLON.Color3(0.5, 0.7, 0.4);#}
{#mesh.material.alpha = 0.3;#}
{#mesh.scaling.x = 2;#}
{#mesh.position    = new BABYLON.Vector3( 0, 0, 0);#}
{#var loader = new BABYLON.AssetsManager(scene);#}
{##}
{#loader.onFinish = function (tasks) {#}
{#    engine.runRenderLoop(function () { scene.render(); });#}
{# };#}
{#engine.loadingUIBackgroundColor = "Purple";#}
{#loader.load();#}


</script>
</body>
</html>

{#var camera = new BABYLON.ArcRotateCamera("Camera", 0, Math.PI / 2, 100, new BABYLON.Vector3(0, 0, 0), scene);#}
{#camera.attachControl(canvas);#}


{#g1 - трава норма#}
{#g6 - банан норма#}
{#g8 - кокос норма#}

{#var tree2mesh = loader.addMeshTask('dom3', "", "/static/game/t3/", "t.babylon");#}

{#var tree2mesh = loader.addMeshTask('treeMesh', "", "/static/game/g1/", "untitled.babylon");#}
{#tree2mesh.onSuccess = function (task) {#}
{#    task.loadedMeshes[0].position = new BABYLON.Vector3(0, 0, 0);#}
{# };#}












{#var createScene = function () {#}
{#     var scene = new BABYLON.Scene(engine);#}
{#     scene.clearColor = new BABYLON.Color3(0, 1, 0);#}
{#     var camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);#}
{#     camera.setTarget(BABYLON.Vector3.Zero());#}
{#     camera.attachControl(canvas, false);#}
{#     var light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);#}
{#     light.intensity = .5;#}
{#     BABYLON.SceneLoader.ImportMesh('t3', "/static/game/t3/", "untitled.babylon", scene, function (newMeshes) {#}
{#        camera.target = newMeshes[0];#}
{#     });#}
{#     scene.registerBeforeRender(function(){ });#}
{#    return scene;#}
{# };#}
{#var scene = createScene();#}
{#engine.runRenderLoop(function(){ scene.render(); });#}
{#window.addEventListener('resize', function(){ engine.resize(); });#}