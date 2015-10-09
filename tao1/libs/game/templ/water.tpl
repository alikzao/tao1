
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Using babylon.js - Test page</title>
    <script src="/static/game/babylon/water/hand.minified-1.1.0.js"></script>

    <script src="/static/game/babylon/babylon1-debug.js"></script>
{#    <script src="/static/game/babylon/water/Shaders/Water/waterMaterial.js"></script>#}
    <script src="/static/game/babylon/waterMaterial.js"></script>
    <style>
        html, body { width: 100%; height: 100%; padding: 0; margin: 0; overflow: hidden; }
        #renderCanvas { width: 100%; height: 100%; touch-action: none; }
    </style>
</head>
<body>
    <canvas id="renderCanvas"></canvas>
    <script>
        if (BABYLON.Engine.isSupported()) {
            var canvas = document.getElementById("renderCanvas");
            var engine = new BABYLON.Engine(canvas, true);
            var scene = new BABYLON.Scene(engine);

            var camera = new BABYLON.ArcRotateCamera("Camera", 0, 0, 10, BABYLON.Vector3.Zero(), scene);
            var sun = new BABYLON.PointLight("Omni0", new BABYLON.Vector3(60, 100, 10), scene);

            camera.setPosition(new BABYLON.Vector3(-40, 40, 0));

            // Skybox
            var skybox = BABYLON.Mesh.CreateBox("skyBox", 1000.0, scene);
            var skyboxMaterial = new BABYLON.StandardMaterial("skyBox", scene);
            skyboxMaterial.backFaceCulling = false;
            skyboxMaterial.reflectionTexture = new BABYLON.CubeTexture("static/game/babylon/water/Assets/skybox/skybox", scene);
            skyboxMaterial.reflectionTexture.coordinatesMode = BABYLON.Texture.SKYBOX_MODE;
            skyboxMaterial.diffuseColor = new BABYLON.Color3(0, 0, 0);
            skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
            skybox.material = skyboxMaterial;

            // Ground
            var ground = BABYLON.Mesh.CreateGroundFromHeightMap("ground", "/static/game/babylon/water/Assets/heightMap.png", 100, 100, 100, 0, 10, scene, false);
            var groundMaterial = new BABYLON.StandardMaterial("ground", scene);
            groundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/babylon/water/Shaders/Ground/ground.jpg", scene);
            groundMaterial.diffuseTexture.uScale = 6;
            groundMaterial.diffuseTexture.vScale = 6;
            groundMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
            ground.position.y = -2.0;
            ground.material = groundMaterial;

            var extraGround = BABYLON.Mesh.CreateGround("extraGround", 1000, 1000, 1, scene, false);
            var extraGroundMaterial = new BABYLON.StandardMaterial("extraGround", scene);
            extraGroundMaterial.diffuseTexture = new BABYLON.Texture("/static/game/babylon/water/Shaders/Ground/ground.jpg", scene);
            extraGroundMaterial.diffuseTexture.uScale = 60;
            extraGroundMaterial.diffuseTexture.vScale = 60;
            extraGround.position.y = -2.05;
            extraGround.material = extraGroundMaterial;

            // Water
            BABYLON.Engine.ShadersRepository = "";
            var water = BABYLON.Mesh.CreateGround("water", 1000, 1000, 1, scene, false);
            var waterMaterial = new WaterMaterial("water", scene, sun);
            waterMaterial.refractionTexture.renderList.push(extraGround);
            waterMaterial.refractionTexture.renderList.push(ground);
            waterMaterial.reflectionTexture.renderList.push(ground);
            waterMaterial.reflectionTexture.renderList.push(skybox);
            water.material = waterMaterial;
            var beforeRenderFunction = function () {
                // Camera
                if (camera.beta < 0.1) camera.beta = 0.1;
                else if (camera.beta > (Math.PI / 2) * 0.9) camera.beta = (Math.PI / 2) * 0.9;
                if (camera.radius > 150) camera.radius = 150;
                if (camera.radius < 5) camera.radius = 5;
            };
            camera.attachControl(canvas);
            scene.registerBeforeRender(beforeRenderFunction);
            engine.runRenderLoop(function () { scene.render(); });
        }
    </script>
</body>
</html>
