<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Babylon</title>
    <style>
        html, body    { overflow: hidden; width: 100%; height: 100%; margin: 0; padding: 0; }
        #renderCanvas { width: 100%; height: 100%; touch-action: none; }
        #viseur       { position:absolute; top:50%; left:50%; margin-top:-37px; margin-left:-37px; }
        .stat, #chat, .chat  { background-color:#6ba5ff; opacity:0.5; border-radius:10px; padding:3px;}
        #blocker      { position: absolute; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        #instructions { width:100%; height:100%; display:-webkit-box; display:-moz-box; display:box; -webkit-box-orient:horizontal;
            -moz-box-orient:horizontal; box-orient:horizontal; -webkit-box-pack:center; -moz-box-pack:center; box-pack:center; -webkit-box-align:center;
            -moz-box-align:center; box-align:center; color:#ffffff; text-align:center; cursor:pointer; }

        #status       { color: gray; border: 1px solid gray; text-align: center; width: 300px; margin-left: 14px; margin-bottom: 24px; }
        #msg          { width: 220px; }
        .msg, input   { margin: 3px; }
        .local        { text-align: left; font-weight: bold; }
        .remote       { text-align: right; }
        .chat         { position:absolute; left:8px;bottom:8px;  width:300px; }
        #chat         { height:200px; }
    </style>


</head>

<body>

    <img id="viseur" src="/static/game/viseur.png" />
    <div id="stats" class="" style="position:absolute; left:8px; top:8px;"></div>

    <div id="chat" style="position:absolute; left:8px; bottom:80px;">
        <div id="status"></div>
        <div id="inbox"></div>
    </div>

    <div id="blocker">
        <div id="instructions">
            <span id="click_here" style="font-size:40px">Click to start the Game</span>
{#            <span id="click_here" style="font-size:40px">Click to play </span> <br/>#}
            {#            (W, A, S, D =  Движение, &nbsp; &nbsp; SPACE =  Прыжок, &nbsp;&nbsp;MOUSE = Look around || Движение вокруг)#}
                        (W, A, S, D =  Movement, &nbsp; &nbsp; MOUSE = Movement around)
{#            (W, A, S, D = Move &nbsp; &nbsp; SPACE = Jump  &nbsp;&nbsp;MOUSE = Look around )#}
            <span class="chat"> <input name="msg" id="msg" autocomplete="off"/> <input type="submit" value="Ok"/> </span>
        </div>
{#        <div id="miniMap" style="position:absolute; right:8px; top:8px; background-color:#6ba5ff; opacity:0.5; border-radius:10px; padding:3px;"></div>#}

    </div>

    <canvas id="renderCanvas"></canvas>

    <!--<script src="/static/game/babylon1-debug.js"></script>-->
    <script src="/static/game/babylon.2.3.js"></script>
    <script src="/static/game/waterMaterial.js"></script>
    <script src="/static/game/game.js"></script>
    <script src="/static/game/hand.js"></script>
    <script src="/static/game/Oimo.js"></script>

</body>
</html>

















