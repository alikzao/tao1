<!doctype html>
<html>
	<head>
		<title>Game</title>

{#{% extends "base.tpl" %}#}
{#{% block body %}#}
{#    {% block head %}#}
{#        {{ super() }}#}
        <script type="text/javascript" src="/static/core/jquery/jquery1.js"></script>
        <script type="text/javascript" src="/static/static/three/build/three.js"></script>
        <script type="text/javascript" src="/static/static/three/examples/js/detector.js"></script>
{#        <script type="text/javascript" src="/static/static/demo/three.js"></script>#}
        <script type="text/javascript" src="/static/contents/dao_ui.js" ></script>
        <script type="text/javascript" src="/static/core/keyboard_state.js" ></script>

        <script src="/static/core/tes/stats.js"></script>
        <script src="/static/core/tes/orbit_controls.js"></script>
        <script src="/static/core/tes/THREEx.FullScreen.js"></script>
        <script src="/static/core/tes/THREEx.WindowResize.js"></script>

        <script type="text/javascript" src="/static/game/game_.js" ></script>
{#    {% endblock %}#}

{#{% endblock %}#}
</head>
<body>

<style>
#aaaa {
    background: #000;
    width: 800px;
    height: 600px;
}
</style>
    <a href="https://support.google.com/chrome/answer/1220892?hl=ru">О подержке WEBGL</a>
    <a href="http://askubuntu.com/questions/299345/how-to-enable-webgl-in-chrome-on-ubuntu">Как включить WEBGL в google-chrome</a>
		<div id="aaaa"></div>

	</body>
</html>








