
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
    <canvas id="renderCanvas"></canvas>
{#    <audio controls="controls" autoplay="" src="http://78.129.224.15:3491/;stream.nsv&amp;type=mp3"></audio>#}
<script>
window.addEventListener('DOMContentLoaded', function(){});
var canvas = document.getElementById('renderCanvas');
var engine = new BABYLON.Engine(canvas, true);
window.addEventListener("resize", function () { engine.resize(); });
var scene = new BABYLON.Scene(engine);
var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);


var camera =  new BABYLON.FreeCamera("Camera",  new BABYLON.Vector3(0, 0, 150), scene);
var camera2 = new BABYLON.FreeCamera("Camera2", new BABYLON.Vector3(0, 0, -15), scene);

camera2.viewport = new BABYLON.Viewport(0.4, 0.2, 0.5, 0.5);

scene.activeCameras.push(camera);
scene.activeCameras.push(camera2);


camera.rotation = new BABYLON.Vector3(0, Math.PI, 0);
camera.attachControl(canvas, true);

{#var loader = new BABYLON.AssetsManager(scene);#}
{#dom1mesh = loader.addMeshTask('dom1', "", "/static/game/dom1/", "dom2.babylon");#}
{##}
{#function func() {#}
{#    var name = parseInt( Math.random() * (999 - 100) + 100);#}
{#    var pos  = parseInt(Math.random()*100/2);#}
{#    console.log( 'func_'+name );#}
{#    mesh = BABYLON.Mesh.CreateSphere(name, 8, 2, scene);#}
{#    mesh.position = new BABYLON.Vector3( pos, 1, pos);#}
{#    dom1mesh.onSuccess = function (task) {#}
{#        var nm = task.loadedMeshes[0].clone('n'+name);#}
{#        nm.parent = mesh;#}
{#    };#}
{# }#}
{##}
{#setTimeout(func, 2000);#}
{#setTimeout(func, 4000);#}
{#setTimeout(func, 6000);#}
{#setTimeout(func, 8000);#}



var loader = new BABYLON.AssetsManager(scene);
meshl = loader.addMeshTask('dom1', "", "/static/game/dom1/", "dom2.babylon");
meshl.onSuccess = function (task) {
    function spawn() {
        var name = parseInt(Math.random() * (999 - 100) + 100);
        var pos = parseInt(Math.random() * 100 / 2);
        console.log('spawn_' + name);
        mesh = BABYLON.Mesh.CreateSphere(name, 8, 2, scene);
        mesh.position = new BABYLON.Vector3(pos, 1, pos);
{#        meshl.onSuccess = function (task) {#}
            var nm = task.loadedMeshes[0].clone('n' + name);
            nm.parent = mesh;
{#        };#}
    }

    setTimeout(spawn, 2000);
    setTimeout(spawn, 4000);
    setTimeout(spawn, 6000);
    setTimeout(spawn, 8000);
};






{##}
{#mesh1 = BABYLON.Mesh.CreateSphere(name, 8, 2, scene);#}
{#mesh1.position = new BABYLON.Vector3( 15, 1, 15);#}
{#dom1mesh.onSuccess = function (task) {#}
{#    var nm = task.loadedMeshes[0].clone('2');#}
{#    nm.parent = mesh1;#}
{# };#}
{# };#}
{##}
{#mesh2 = BABYLON.Mesh.CreateSphere(name, 8, 2, scene);#}
{#mesh2.position = new BABYLON.Vector3( 25, 1, 25);#}
{#dom1mesh.onSuccess = function (task) {#}
{#    var nm = task.loadedMeshes[0].clone('3');#}
{#    nm.parent = mesh2;#}
{# };#}
{##}
{#mesh3 = BABYLON.Mesh.CreateSphere(name, 8, 2, scene);#}
{#mesh3.position = new BABYLON.Vector3( 35, 1, 35);#}
{#dom1mesh.onSuccess = function (task) {#}
{#    var nm = task.loadedMeshes[0].clone('4');#}
{#    nm.parent = mesh3;#}
{# };#}
{##}


{#var alpha = 0;#}
{#cube.scaling.x = 0.5;#}
{#cube.scaling.z = 3.5;#}
{#scene.beforeRender = function() {#}
{#    cube.rotation.x = alpha;#}
{#    cube.rotation.y = alpha;#}
{##}
{#    alpha += 0.01;#}
{# };#}



loader.onFinish = function (tasks) {
    engine.runRenderLoop(function () { scene.render(); });
 };



engine.loadingUIBackgroundColor = "Purple";
loader.load();









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


{#<canvas id="renderCanvas"></canvas>#}
{#<div id="infos"></div>#}
{#<script>#}
{#var configObject = { targetFPS: 50, useSIMD: false};#}
{#var SIMDCheck = document.getElementById("SIMDCheck");#}
{#var canvas = document.getElementById("renderCanvas");#}
{#var engine = new BABYLON.Engine(canvas, true);#}
{#var total = 1;#}
{#var dancer;#}
{#var scene;#}
{#var groundMaterial;#}
{#var dancers = [];#}
{##}
{#window.addEventListener("resize", function () { engine.resize(); });#}
{##}
{#var addDancer = function () {#}
{#    var newOne = dancer.clone("clone" + total);#}
{#    newOne.skeleton = dancer.skeleton.clone("skeleton" + total);#}
{##}
{#    newOne.position.x = 250 - Math.random() * 500;#}
{#    newOne.position.z = 250 - Math.random() * 500;#}
{#    groundMaterial.reflectionTexture.renderList.push(newOne);#}
{#    scene.beginAnimation(newOne.skeleton, 2, 100, true, 0.05);#}
{##}
{#    dancers.push(newOne);#}
{##}
{#    total++;#}
{# };#}
{##}
{#var removeDancer = function () {#}
{#    var dancer = dancers[0];#}
{#    scene.stopAnimation(dancer);#}
{#    dancer.dispose();#}
{#    dancers.splice(0, 1);#}
{#    total--;#}
{# };#}
{##}
{#BABYLON.SceneLoader.Load("http://az612410.vo.msecnd.net/wwwbabylonjs/Scenes/DanceMoves/", "DanceMoves.babylon", engine, function (newScene) {#}
{#    scene = newScene;#}
{#    newScene.activeCamera.maxZ = 10000.0;#}
{#    newScene.activeCamera.position.z = 600.0;#}
{##}
{#    // Mirror#}
{#    groundMaterial = new BABYLON.StandardMaterial("ground", newScene);#}
{#    groundMaterial.reflectionTexture = new BABYLON.MirrorTexture("mirror", 1024, newScene, true);#}
{#    groundMaterial.reflectionTexture.mirrorPlane = new BABYLON.Plane(0, -1.0, 0, 0);#}
{#    groundMaterial.reflectionTexture.level = 0.5;#}
{##}
{#    // Ground#}
{#    var ground = BABYLON.Mesh.CreateGround("ground", 1000, 1000, 1, newScene, false);#}
{##}
{#    groundMaterial.diffuseColor = new BABYLON.Color3(1.0, 1.0, 1.0);#}
{#    groundMaterial.specularColor = new BABYLON.Color3(0, 0, 0);#}
{##}
{#    ground.material = groundMaterial;#}
{##}
{#    dancer = newScene.meshes[1];#}
{##}
{#    groundMaterial.reflectionTexture.renderList.push(dancer);#}
{#    newScene.beginAnimation(dancer.skeleton, 2, 100, true, 0.05);#}
{##}
{#    newScene.executeWhenReady(function () {#}
{#        newScene.activeCamera.attachControl(canvas);#}
{#        engine.runRenderLoop(function () { newScene.render(); });#}
{#    });#}
{#    // Let's start the cloning galore!#}
{#    var downCounter = 0;#}
{#    setInterval(function () {#}
{#        var fps = Math.floor(engine.getFps());#}
{##}
{#        if (fps >= configObject.targetFPS) {#}
{#            downCounter = 0;#}
{#            addDancer();#}
{#        } else {#}
{#            downCounter++;#}
{#            if (downCounter === 3) { // FPS down for 3s ?#}
{#                removeDancer();#}
{#                downCounter = 0;#}
{#            }#}
{#        }#}
{#    }, 1000);#}
{# }, function (evt) {#}
{#    if (evt.lengthComputable) {#}
{#        engine.loadingUIText = "Loading, please wait..." + (evt.loaded * 100 / evt.total).toFixed() + "%";#}
{#    } else {#}
{#        dlCount = evt.loaded / (1024 * 1024);#}
{#        engine.loadingUIText = "Loading, please wait..." + Math.floor(dlCount * 100.0) / 100.0 + " MB already loaded.";#}
{#    }#}
{# });#}
{#</script>#}
