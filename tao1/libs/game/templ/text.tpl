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
            height: 100%;  width:100%;
        }
    </style>
</head>
<body>

	<canvas id="renderCanvas"></canvas>
    <script src="/static/game/babylon2.1-debug.js"></script>
{#    <script src="/static/game/babylon2-debug.js"></script>#}
    <script src="/static/game/hand.js"></script>
    <script src="/static/game/poly2tri.min.js"></script>
{#    <script src="/static/game/vtext.js"></script>#}
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <script type="text/javascript" src="http://getbootstrap.com/dist/js/bootstrap.min.js" ></script>
    <link rel="stylesheet" type="text/css" href="http://getbootstrap.com/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="/static/core/bootstrap3/css/bootstrap-theme.css" />



<script type="text/javascript">
{#    var text3d = new THREE.TextGeometry( theText, { size: 80, height: 20, curveSegments: 2, font: "helvetiker" });#}
	var createFreeGround = function(id, vList, scene, updatable) {
	    var ground = new BABYLON.Mesh(id, scene);
	    var normals = [];
	    var positions = [];
	    var uvs = [];
	    var indices = [];
	    //Get the uv map dimensions
	    var uvmapxmin = vList[0].x;
	    var uvmapzmin = vList[0].z;
	    var uvmapxmax = vList[0].x;
	    var uvmapzmax = vList[0].z;
	    vList.forEach(function(v) {
	        if(v.x < uvmapxmin) { uvmapxmin = v.x; }
	        else if(v.x > uvmapxmax) { uvmapxmax = v.x; }
	        if(v.z < uvmapzmin) { uvmapzmin = v.z; }
	        else if(v.z > uvmapzmax) { uvmapzmax = v.z; }
	    });
	    // Fill contours, normals, positions & uvs
	    var currentIndice = 0;
		// array contour is used to triangulate the polygon
	    var contours = [];
	    vList.forEach(function(v) {
	        contours.push({x:v.x, y:v.z, indice:currentIndice++});
			// This is a ground : normals up in the air !
	        normals.push(0, 1.0, 0);
	        positions.push(v.x, 0, v.z);
	        uvs.push((v.x - uvmapxmin) / (uvmapxmax - uvmapxmin), (v.z - uvmapzmin) / (uvmapzmax - uvmapzmin));
	    });

	    // Triangulate
	    var swctx = new poly2tri.SweepContext(contours);
	    swctx.triangulate();

	    // retrieve indices
	    var triangles = swctx.getTriangles();
	    triangles.forEach(function(t) {
			t.getPoints().forEach(function(p) { indices.push(p.indice); });
	    });

	    // Set data
	    ground.setVerticesData(positions, BABYLON.VertexBuffer.PositionKind, updatable);
	    ground.setVerticesData(normals, BABYLON.VertexBuffer.NormalKind, updatable);
	    ground.setVerticesData(uvs, BABYLON.VertexBuffer.UVKind, updatable);
	    ground.setIndices(indices);

	    // Set dimensions of the ground
	    //var width = uvmapxmax - uvmapxmin;
	    //var height = uvmapzmax - uvmapzmin;

	    return ground;
	}
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

















