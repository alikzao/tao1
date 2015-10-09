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
        .gold { background-color: yellow; }
		hr{color:gray;}
    </style>
</head>
<body style="background-color:#eee;">
	<div class="container">
        <div class="row" style="margin-top:50px; padding:20px; height:550px !important;">
		    <div class="col-xs-6" style="height:500px !important;">
{#		        <canvas id="renderCanvas"></canvas>#}
		        <div id="renderCanvas"></div>
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

    <script src="/static/game/three.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <script type="text/javascript" src="http://andrewray.me/threejs-examples/font-example/js/OrbitControls.js"></script>
    <script type="text/javascript" src="http://andrewray.me/threejs-examples/font-example/js/janda_manatee_solid_regular.typeface.js"></script>



    <script type="text/javascript" src="http://getbootstrap.com/dist/js/bootstrap.min.js" ></script>
    <link rel="stylesheet" type="text/css" href="http://getbootstrap.com/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="/static/core/bootstrap3/css/bootstrap-theme.css" />








<script type="text/javascript">
     var container = document.getElementById( 'renderCanvas' );
     var scene = new THREE.Scene();
     var camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );
     var renderer = new THREE.WebGLRenderer({ antialias: true});
     renderer.setSize( 500, 500 );
     container.appendChild( renderer.domElement );

    var controls = new THREE.OrbitControls( camera, renderer.domElement );

    var material = new THREE.MeshPhongMaterial({ color: 0xdddddd});
    var textGeom = new THREE.TextGeometry( 'Hello, World!', {
        font:   'Lobster',
        size:   60,
        weight: normal
    });

    var textMesh = new THREE.Mesh( textGeom, material );

    textGeom.computeBoundingBox();
    var textWidth = textGeom.boundingBox.max.x - textGeom.boundingBox.min.x;

    textMesh.position.set( -0.5 * textWidth, 100, 0 );
    scene.add( textMesh );


     var geometry = new THREE.BoxGeometry( 1, 1, 1 );
     var material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
     var cube = new THREE.Mesh( geometry, material );
     scene.add( cube );
     camera.position.z = 5;
     var render = function () {
        requestAnimationFrame( render );
        renderer.render(scene, camera);
     };
     render();
</script>


</body>
</html>

















