<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>Предисловие игры</title>
{#		<link rel="stylesheet" href="/static/game/game.css" />#}
        <script src="/static/game/detector.js"></script>
        <script src="/static/core/jquery/jquery1.js"></script>
		<script src="/static/game/bigscreen.min.js"></script>
		<script src="/static/game/pointerlock.js"></script>
		<script src="/static/game/three.min.js"></script>

        <script type="text/javascript" src="/static/core/bootstrap3/js/bootstrap.min.js" ></script>
        <link rel="stylesheet" type="text/css" href="/static/core/bootstrap3/css/bootstrap.min.css" />
        <link rel="stylesheet" type="text/css" href="/static/core/bootstrap3/css/bootstrap-theme.css" />
        <link rel="stylesheet" href="/static/core/font_icon/css/font-awesome.min.css">
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

    			<h3>О технологиях игры WebGL.</h3>
                <p>Для работы игр в браузере существует несколько технологий.
                    До недавнего времени в основном это была только одна технология это adobe flash.</p>
                <p>Но с развитием браузеров и интернета появились более мощная, быстрая и универсальная 3D технология WebGl и упрощенный 2D вариант Canvas.</p>

				<h3>Проверка наличия WebGL в браузере.</h3>
                <p>К сожалению старые версии браузеров эту технологию не поддерживают, а internet explorer только начиная с 11 версии поддерживает WebGl.
                    Но на этом минусы по сравнению с flash заканчиваются.</p>
                <p>Как правило могут быть несколько случаев отсутствия поддержки это либо старая графическая карточка, либо устаревший браузер. </p>
			</div>
            <div class="webgl">

            </div>
            <div class="">
                <a href="https://support.google.com/chrome/answer/1220892?hl=ru">О подержке WebGl google-chrome</a><br/>
                <a href="http://askubuntu.com/questions/299345/how-to-enable-webgl-in-chrome-on-ubuntu">Как включить WebGl в google-chrome</a>
            </div>
		</div>
{#    </div>#}


{#    <div class="row">#}
		<div class="regulate col-xs-5">
			<h3> Горячие клавиши для игры.</h3>

            <div class="row">
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; W &nbsp;</div> &nbsp; - Вперед<br/><br/>
                <div class="ctrl1 col-xs-2">&nbsp; A &nbsp;</div>
                <div class="ctrl1 col-xs-2">&nbsp; D &nbsp;</div>  &nbsp; - Влево вправо<br/> <br/>
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; S &nbsp;</div> &nbsp; - Назад
            </div> <br/>
            <hr/>
            <div class="row">
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; <i class="icon-long-arrow-up"></i> &nbsp;</div> &nbsp; - Вперед<br/><br/>
                <div class="ctrl1 col-xs-2">&nbsp; <i class="icon-long-arrow-left"></i> &nbsp;</div>
                <div class="ctrl1 col-xs-2">&nbsp; <i class="icon-long-arrow-right"></i> &nbsp;</div>  &nbsp; - Влево вправо<br/> <br/>
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-2">&nbsp; <i class="icon-long-arrow-down"></i> &nbsp;</div> &nbsp; - Назад
            </div> <br/>
            <hr/>
            <div class="row">
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-5">&nbsp; SPACE (Пробел) &nbsp;</div> &nbsp; - Поднятие в верх
            </div> <br/>
            <hr/>
            <div class="row">
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-6">&nbsp; Левая кнопка мышы &nbsp;</div> &nbsp; - Выстрел <br/><br/>
                <div class="col-xs-1"></div><div class="ctrl1 col-xs-6">&nbsp; Вращение мышы &nbsp;</div> &nbsp; - Вращение
            </div> <br/>

		</div><br/><br/>

    	<div class="regulate col-xs-3">
            <a href="/game" target="_blank" class="btn btn-success  btn-block"> Начать игру</a>
    	</div>

	</div>



</div>




<script type="text/javascript">
    text = '<div class="jumbotron"> <div class="btn btn-success btn-xs"><i class="icon-ok"></i></div> &nbsp Поздравляем, ваш браузер поддерживает технологию 3D WebGl.  </div>'
    text1 = '<div class="jumbotron"> <div class="btn btn-danger btn-xs"><i class="icon-remove"></i></div> &nbsp К сожалеию ваш браузер не поддерживает WebGl. ' +
            '<a href="https://support.google.com/chrome/answer/1220892?hl=ru">О подержке WebGl google-chrome</a><br/>  ' +
            '</div>'
    Detector.webgl ? $('.webgl').append(text) : $('.webgl').append(text1);

</script>

	</body>
</html>


{#   1) setup ->    #}