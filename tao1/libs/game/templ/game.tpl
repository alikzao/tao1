<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>Игра</title>
		<link rel="stylesheet" href="/static/game/game.css" />
{#        <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>#}
            <script type="text/javascript" src="/static/core/jquery/jquery1.js"></script>
        <style>
            body { font-family: "Courier New", courier, monospace; font-size: 18px; }
            #status { color: gray; border: 1px solid gray; text-align: center; width: 300px; margin-left: 14px; margin-bottom: 24px; background-color: #eee; }

            #input-holder { padding-left: 10px; }
            #msg { width: 300px; }
            #body { width: 350px; }
            #inbox {
                margin-right: 10px;
                opacity: 0.7;
                background-color: #f2f2f2;
                max-height: 200px;
            }
            .msg, input { margin: 10px; }
            .local { text-align: left; font-weight: bold; }
            .remote { text-align: right; }
        </style>
	</head>
	<body>



		<div id="start">
			<div id="instructions" class="center">
				Нажмите чтоб начать игру
			</div>
		</div>
		<div id="hud" class="hidden">

            <div id="body">
                <div id="status"></div>
                <div id="inbox"></div>
                <div id="input">
                    <form action="#" method="post" id="messageform"> <table>
                        <tr> <td><input name="msg" id="msg" autocomplete="off"/></td> <td id="input-holder"><input type="submit" value="Отправить"/> </td> </tr>
                    </table> </form>
                </div>
            </div>

{#            <input id="vvv" type="checkbox" />#}

			<div id="crosshairs"></div>
			<div id="upper-right">
				Здоровье: <span id="health">100</span>
			</div>
			<div id="respawn" class="center hidden">
				В вас попали! перезайдете через <span class="countdown">3</span>&hellip;
			</div>
			<div id="hurt" class="hidden"></div>
		</div>

        <script src="/static/game/detector.js"></script>            <!-- проверка подержки вебгл виеокарточкой-->
		<script src="/static/game/bigscreen.min.js"></script>       <!-- раскрытие на весь экран и сворачивание-->
		<script src="/static/game/pointerlock.js"></script>         <!-- тоже чтото техническое-->
		<script src="/static/game/three.min.js"></script>           <!-- сама библиотека для отрисовки вебгл-->
{#                <script type="text/javascript" src="/static/static/three/build/three.js"></script>#}
<!-- =================================  Рабочие файлы  ======================================================= -->
		<script src="/static/game/player.js"></script>              <!-- поведение игрока небольшой файлик-->
		<script src="/static/game/bullet.js"></script>              <!-- поведение пли тоже небольшой-->
		<script src="/static/game/game.js"></script>                <!-- сама логика игрушки-->
	</body>


<script type="text/javascript">

$(function() {
    var wwww;
    var url = 'ws://localhost:8765/';
{#    var url = 'ws://78.47.225.242:8765/';#}

    $(document).on('click', '#hud', function(e) { $('#vvv').focus() });
    $('#messageform').on('keypress', function(e) {
        if (e.keyCode == 13) {
            newMessage($(this));
            $('#msg').blur();
            return false;
        }
    });
    $(document).on('keyup', function(e) {
        if (e.keyCode == 16) {
            console.log('sssssssssssssssssssssssssshift');
            $('#msg').focus();
        }
    });
    $('#messageform').on('submit', function() {
        newMessage($(this));
        $('#msg').focus();
        return false;
    });

    $('#msg').on('keyup', function(e) { e.stopPropagation(); });
    $('#msg').on('keydown', function(e) { e.stopPropagation(); });
    $('#msg').on('keypress', function(e) {
        if (e.keyCode == 13) {
            newMessage($(this));
            $('#msg').blur();
            return false;
        }
        e.stopPropagation();
    });
    $('#msg').select();

    var ws = new WebSocket(url);
    ws.onmessage = function(event) {
{#        if (isFromRemote && msg!=undefined && !msg['msg']) return false;#}
{#        var msg = JSON.parse(event.data).msg;#}
        var msg = JSON.parse(event.data);
        if (msg['t'] != 'chat') {return false};
        showMessage(msg.m, true);
        setTimeout( function(){console.warn(JSON.parse(event.data))}, 1000);
    };
    ws.onopen = ws.onclose = ws.onerror = function() {
        var code = ws.readyState;
        var codes = { 0: "opening", 1: "open", 2: "closing", 3: "closed"};
        $('#status').html(codes[code]);
    };

    function newMessage(form) {
        var msg = $('#msg').val();
        showMessage(msg, false);
        $('#msg').val('').select();
        // Delay the response, for effect.
        setTimeout(function() {
            ws.send(JSON.stringify({'t':'chat', m: msg}));
        }, 200);
    }

    function showMessage(msg, isFromRemote) {
{#        console.error(msg);#}
        var node = $('<p>' + msg + '&nbsp;</p>');
        node.addClass('msg');
        node.addClass(isFromRemote ? 'remote': 'local');
        node.hide();
        $('#inbox').append(node);
        node.fadeIn();
    }
});


</script>




</html>


{#   1) setup ->    #}