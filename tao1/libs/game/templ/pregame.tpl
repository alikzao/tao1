<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>Start game page</title>


        <!--<script src="/static/game/detector.js"></script>-->

		<!--<script type="text/javascript" src="/static/sites/jquery1.11.min.js"></script>-->
		<script type="text/javascript" src="https://code.jquery.com/jquery-1.11.3.min.js"></script>

		<!--<script type="text/javascript"          src="/static/sites/bootstrap/js/bootstrap.min.js" ></script>-->
		<script type="text/javascript"   src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" ></script>
        <!--<link rel="stylesheet" type="text/css" href="/static/sites/bootstrap/css/bootstrap.min.css" />-->
        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" >

        <!--<link rel="stylesheet" type="text/css" href="/static/sites/bootstrap/css/bootstrap-theme.min.css" />-->

        <!--<link rel="stylesheet" href="/static/sites/fa/css/font-awesome.min.css">-->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

        <style type="text/css">
            .ctrl1 {
                border:1px solid #ccc;
                border-radius: 6px;
                margin: 3px;
                color:grey;
            }
        </style>

	</head>
	<body>


<div class="" style="width:1000px;">

    <div class="row" style="margin: 5px;">
		<div class="check_webgl col-xs-7" >
			<div class="">
				<h3>Check for WebGL in your browser.</h3>
                <p>Unfortunately, older versions of browsers that do not support technology, and internet explorer
                only starting with version 11 supports WebGl. </p>
                <p>Typically, there may be several cases of lack of support is either old graphic card,
                or an outdated browser. </p>
			</div>
            <div class="webgl"></div>
            <div class="">
                <a href="https://support.google.com/chrome/answer/1220892?hl=ru">Support for WebGl google-chrome</a><br/>
                <a href="http://askubuntu.com/questions/299345/how-to-enable-webgl-in-chrome-on-ubuntu">How to turn WebGl in google-chrome</a>
                <a href="http://superuser.com/questions/836832/how-can-i-enable-webgl-in-my-browser"> How to turn WebGl in google-chrome</a>
            </div>

            {{ room }}

            <div class="reg_game">
                <div style="width:200px; margin-top:20px;" class="btn btn-success  btn-block"> Start game</div>
    	    </div>

		</div>
        <script type="text/javascript">
        $(function(){
           $('.reg_game').on('click', 'div', function(){
               $.ajax({
                   type: "POST", dataType: "json", url: '/check_room',
                   data: {},
                   success: function (data) {
                       if (data.result == 'ok')
                           window.location = '/game#'+data.room;
                   }
               });
           });
        });

        </script>

		<div class="regulate col-xs-5">
			<h3> Keyboard shortcuts for the game.</h3>

            <div class="row">
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; W &nbsp;</div> &nbsp; - Forward<br/><br/>
                <div class="ctrl1 col-xs-2">&nbsp; A &nbsp;</div>
                <div class="ctrl1 col-xs-2">&nbsp; D &nbsp;</div>  &nbsp; - Left right<br/> <br/>
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; S &nbsp;</div> &nbsp; - Back
            </div>
            <hr/>
            <div class="row">
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; <i class="fa fa-long-arrow-up"></i> &nbsp;</div> &nbsp; - Forward<br/><br/>
                <div class="ctrl1 col-xs-2">&nbsp; <i class="fa fa-long-arrow-left"></i> &nbsp;</div>
                <div class="ctrl1 col-xs-2">&nbsp; <i class="fa fa-long-arrow-right"></i> &nbsp;</div>  &nbsp; - Left right<br/> <br/>
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; <i class="fa fa-long-arrow-down"></i> &nbsp;</div> &nbsp; - Back
            </div>
            <hr/>
{#            <div class="row">#}
{#                <div class="col-xs-1"></div><div class="ctrl1 col-xs-5">&nbsp; SPACE &nbsp;</div> &nbsp; - Поднятие в верх#}
{#            </div>#}
{#            <hr/>#}
            <div class="row">
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-6">&nbsp; Left mouse button &nbsp;</div> &nbsp; - Shot <br/><br/>
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-6">&nbsp; Rotation mouse &nbsp;</div> &nbsp; - Rotation
            </div>
		</div>


	</div>



</div>




<script type="text/javascript">
    text = '<div class="jumbotron"> <div class="btn btn-success btn-xs"><i class="fa fa-check"></i></div> &nbsp Congratulations, your browser supports WebGl 3D.  </div>'
    text1 = '<div class="jumbotron"> <div class="btn btn-danger btn-xs"><i class="fa fa-remove"></i></div> &nbsp Unfortunate enough your browser does not support WebGl. ' +
            '<a href="https://support.google.com/chrome/answer/1220892?hl=ru">About support for WebGl in google chrome</a><br/>  ' +
            '</div>'
    !!window.WebGLRenderingContext ? $('.webgl').append(text) : $('.webgl').append(text1);


</script>

	</body>
</html>

