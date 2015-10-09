
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
var canvas, scene, camera, engine, light, box;
canvas = document.getElementById("renderCanvas");
engine = new BABYLON.Engine(canvas, true);
scene = new BABYLON.Scene(engine);
camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
camera.setTarget(new BABYLON.Vector3.Zero());
camera.attachControl(canvas);
light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
light.intensity = .5;
box = BABYLON.Mesh.CreateBox("box2", 2.0, scene);
box.position = new BABYLON.Vector3(2, 1, 0);
box.material =   new BABYLON.StandardMaterial('texture1', scene);
box.material.diffuseColor = new BABYLON.Color3(0, 1, 0);
var ground = BABYLON.Mesh.CreateGround("ground1", 500, 500, 2, scene);

window.addEventListener("click", function(){ new bullet(); });

engine.runRenderLoop(function () { scene.render(); });


function bullet(){
    console.log('shoot');
    var pos = box.position;
    var bul = new BABYLON.Mesh.CreateSphere('bullet', 3, 0.3, scene);
    bul.material =  new BABYLON.StandardMaterial('texture1', scene);
    bul.material.diffuseColor = new BABYLON.Color3(3, 2, 0);
    bul.position = new BABYLON.Vector3(pos.x, pos.y, pos.z)
    var dir = camera.cameraDirection;
    scene.registerBeforeRender(function(){
        bul.position.addInPlace(dir);
    });
}
</script>
</body>
</html>




    SaaS
       e-commerc
   linux

       самые оригиналные решения
      не всегда самые дорогие
       креативность не всегда означает
       самопиар

0,20-0,32

0,44-0,51

0,58-1,55
