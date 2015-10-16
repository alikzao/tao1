
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Test mesh</title>
    <script src="/static/game/babylon/water/hand.minified-1.1.0.js"></script>

    <script src="/static/game/babylon.2.2.js"></script>
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
//        BABYLON.Engine.ShadersRepository = "/Shaders/";
        var canvas = document.getElementById("renderCanvas");
        var engine = new BABYLON.Engine(canvas, false);
        // Resize
        window.addEventListener("resize", function () { engine.resize(); });
        // Scene, light and camera
        var scene = new BABYLON.Scene(engine);
        var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);
        camera = new BABYLON.ArcRotateCamera("Camera", 0, Math.PI / 2, 100, new BABYLON.Vector3(0, 0, 0), scene);



        camera.attachControl(canvas);
        // Assets manager
        var loader =  new BABYLON.AssetsManager(scene);
//        var meshTask = loader.addMeshTask("gun", "", "static/game/babylon/", "q.babylon");
//        var meshTask = loader.addMeshTask("tt", "", "/static/game/m/", "untitled.babylon");
//        var meshTask = loader.addMeshTask("tt", "", "/static/game/leo/", "untitled.babylon");

       var meshTask = loader.addMeshTask("tt", "", "/static/game/m/", "untitled.babylon");
       // var meshTask = loader.addMeshTask("tt", "", "/static/game/a3/", "untitled.babylon");
        // var meshTask = loader.addMeshTask("tt", "", "/static/game/t902/", "untitled.babylon");
        meshTask.onSuccess = function (task) {
//            task.loadedMeshes[0].position = new BABYLON.Vector3(3, -3, 9);
//            task.loadedMeshes[0].parent = camera;
        };


        meshTask.onSuccess = function (task) {
            task.loadedMeshes[0].parent = camera;
        };

        loader.onTaskError = function (task) {
            console.log("error while loading " + task.name);
        };



        loader.onFinish = function (tasks) {
            engine.runRenderLoop(function () { scene.render(); });
        };
        loader.load();
    }
}




</script>
</body>
</html>


