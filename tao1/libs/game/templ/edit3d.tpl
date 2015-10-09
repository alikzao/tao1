<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link href='http://fonts.googleapis.com/css?family=Marck+Script|Lobster&subset=latin,cyrillic' rel='stylesheet' type='text/css'>
    <title>3d editor</title>
    <style>
{#        html, body    { width:100%; height:100%; margin:0; padding:0;}#}
{#		.col1, .col2, #renderCanvas {width: 50%;}#}
        #renderCanvas {
            height: 100%;  width:100%; background-color:#eee;
			border-radius:10px;
		    border: 1px solid #d3d3d3;
            cursor:pointer;
        }
        body, html {
		  margin: 0;
		  padding: 0;
		  background-color: #eee;
		  color: #333;
		  border-radius: 1px;
		}
        .panel11{
            width:70%;
            height: 100%;
		    font-size: 14px;
		    padding:50px;
		    border-radius:10px;
		    border: 1px solid #d3d3d3;
		    color: #939598;
		    background-color: #f6f6f6;
        }
        .col2 { }
        .gold, .silver {
            cursor: pointer;
{#            margin-top: -7px;#}
{#            margin-left: 10px;#}
            width: 32px;
            height: 32px;
		    border-radius:20px;
		    border: 1px solid #d3d3d3;
            display:inline-block;
			margin-right:10px;
        }
        .silver {

        }
        .gold {
            background-color: yellow;
        }
        hr{color:gray;}
    </style>
</head>
<body style="background-color:#eee;">
	<div class="container">
        <div class="row" style="margin-top:50px; padding:20px; height:550px !important;">
		    <div class="col-xs-6" style="height:500px !important;">
		        <canvas id="renderCanvas"></canvas>
		    </div>
		    <div class="col-xs-6 col2">
{#		        <input id="text-input" class="text-input" value="myo" onkeypress="if(event.keyCode==13||event.which==13){return false;}">#}
                <div class="panel11">
                    <form>
	                    <div class="form-group">
					        <label for="name">Название</label>
					        <input id="name" type="email" class="form-control"  value="Мое" onkeypress="if(event.keyCode==13||event.which==13){return false;}">
					    </div>
                    </form>

                    <div style="font-family:'Marck Script', cursive; font-size:20px;">Who I you  Материал</div>
                    <div style="font-family:'Lobster', cursive;      font-size:20px;">Who I you  Материал</div>

                    <form class="form-inline">
                        <div class="form-group">
                            <label for="color">Материал:</label>
{#                            <input id="color" type="text" class="form-control"  placeholder="Jane Doe">#}
							<div title="Золото" class="gold"></div>
                            <div title="Серебро" class="silver"></div>
                        </div>
                        <hr/>
					</form>
                 </div>
		    </div>
	    </div>
	</div>

{#    <script src="/static/game/babylon1-debug.js"></script>#}
    <script src="/static/game/babylon2.1-debug.js"></script>
{#    <script src="/static/game/babylon2-debug.js"></script>#}
    <script src="/static/game/hand.js"></script>
    <script src="/static/game/vtext.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <script type="text/javascript" src="http://getbootstrap.com/dist/js/bootstrap.min.js" ></script>
    <link rel="stylesheet" type="text/css" href="http://getbootstrap.com/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="/static/core/bootstrap3/css/bootstrap-theme.css" />








<script type="text/javascript">
{#    var text3d = new THREE.TextGeometry( theText, { size: 80, height: 20, curveSegments: 2, font: "helvetiker" });#}

	var canvas = document.querySelector("#renderCanvas");
	var engine = new BABYLON.Engine(canvas, true);
	var createScene = function () {
		var scene = new BABYLON.Scene(engine);
		scene.clearColor = new BABYLON.Color3(0.92, 0.92, 0.92);
{#        var camera = new BABYLON.ArcRotateCamera("Camera", 3*Math.PI/2, 0 , 200, BABYLON.Vector3.Zero(), scene);#}
        var camera = new BABYLON.ArcRotateCamera("ArcRotateCamera", 1, 0.8, 10, new BABYLON.Vector3(0, 0, 0), scene);

        camera.attachControl(canvas, true);

		var light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
		light.intensity = .7;

{#		var sphere = BABYLON.Mesh.CreateSphere("sphere1", 16, 2, scene);#}
{#		sphere.position.y = 1;#}
{#		var ground = BABYLON.Mesh.CreateGround("ground1", 6, 6, 2, scene);#}



       	var dyntex = new BABYLON.DynamicTexture("dt", 500, scene, true);
{#		dyntex.drawText('хуй', 5, 50, "bold 42px Arial", "white", "black", true);#}
{#		dyntex.drawText('длинное слово', 5, 50, "cursive 100px Lobster", "white", "black", true);#}
		dyntex.drawText('длинное слово', 5, 50, "cursive 100px Marck Script", "white", "black", true);
		var mesh = new BABYLON.Mesh("mesh", scene);
		var context = dyntex.getContext();
		var buffer = context.getImageData(0, 0, 512, 512).data;

{#		var plane = BABYLON.Mesh.CreateGround("plane", 100, 20, 600, scene, true);#}
{#		plane.applyDisplacementMapFromBuffer(buffer, 512, 100, 0, 10);#}

		var vertexData = BABYLON.VertexData.CreateGroundFromHeightMap(100, 20, 700, 0, 10, buffer, 512, 100);
		vertexData.applyToMesh(mesh, false);

		return scene;
	};
	var scene = createScene();
	engine.runRenderLoop(function(){  scene.render(); });
</script>

</body>
</html>

















