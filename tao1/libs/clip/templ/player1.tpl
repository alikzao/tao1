

<script type="text/javascript">
//<![CDATA[
onready(function(){

	$("#jplayer").jPlayer({
		ready: function () {
			$(this).jPlayer("setMedia", {
                flv: "/static/static/evro.flv",
{#                flv: "/static/static/clip/in_v/evro.flv",#}
{#                m4a: "/static/static/clip/in_v/evro.mp4",#}
{#				m4v: "http://www.jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v",#}
{#				ogv: "http://www.jplayer.org/video/ogv/Big_Buck_Bunny_Trailer.ogv",#}
{#				webmv: "http://www.jplayer.org/video/webm/Big_Buck_Bunny_Trailer.webm",#}
{#				poster: "http://www.jplayer.org/video/poster/Big_Buck_Bunny_Trailer_480x270.png"#}
			});
		},
		swfPath: "/static/core/jplayer/Jplayer.swf",
        solution: 'flash, html',
        preload: 'metadata',
		supplied: "webmv, ogv, m4v, flv, mp3, m4a, fla",
        errorAlerts:true,
        warningAlerts:true,
        wmode: "window",
		size: {
			width: "640px",
			height: "360px",
			cssClass: "jp-video-360p"
		},
		smoothPlayBar:true,
		emulateHtml:true,
		keyEnabled: true,
        timeupdate: function(){
            var currTime = $('#jplayer').data().jPlayer.status.currentTime;
            var movieLength = $('#jplayer').data().jPlayer.status.duration;
            var timeRemaining = movieLength - currTime;
        }
	});

	$("#jplayer_inspector").jPlayerInspector({jPlayer:$("#jquery_jplayer_1")});

    function loadMotionsJplayer(id) {
      $('#' + id).jPlayer({
        ready: buildJPlayerMotions(id),
        swfPath: "/assets",
        supplied: "m4v",
        backgroundColor: "#FFFFFF",
        size: { width: '728px', height: '402px'},
        timeupdate: function(){
          var currTime = $('#' + id).data().jPlayer.status.currentTime;
          var movieLength = $('#' + id).data().jPlayer.status.duration;
          var timeRemaining = movieLength - currTime;
          if (timeRemaining < 0.5) {
                $('#' + id).jPlayer("pause");
                $('#' + id).jPlayer("play", 0 + (0.5 - timeRemaining));
          }
        }
     });
    }
});
//]]>
</script>
<script type="text/javascript">
(function() {
	var s = document.createElement('script'), t = document.getElementsByTagName('script')[0];
	s.type = 'text/javascript';
	s.async = true;
	s.src = 'http://api.flattr.com/js/0.6/load.js?mode=auto';
	t.parentNode.insertBefore(s, t);
})();
</script>


<div id="container">
	<div id="content_main">
		<section>
		<div id="jp_container_1" class="jp-video jp-video-360p">
			<div class="jp-type-single">
				<div id="jplayer" class="jp-jplayer"></div>
				<div class="jp-gui">
					<div class="jp-video-play">
						<a href="javascript:;" class="jp-video-play-icon" tabindex="1">play</a>
					</div>
					<div class="jp-interface">
						<div class="jp-progress">
							<div class="jp-seek-bar">
								<div class="jp-play-bar"></div>
							</div>
						</div>
						<div class="jp-current-time"></div>
						<div class="jp-duration"></div>
						<div class="jp-title">
							<ul>
								<li>Название</li>
							</ul>
						</div>
						<div class="jp-controls-holder">
							<ul class="jp-controls">
								<li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>
								<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>
								<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>
								<li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>
								<li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>
								<li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>
							</ul>
							<div class="jp-volume-bar">
								<div class="jp-volume-bar-value"></div>
							</div>

							<ul class="jp-toggles">
								<li><a href="javascript:;" class="jp-full-screen" tabindex="1" title="full screen">full screen</a></li>
								<li><a href="javascript:;" class="jp-restore-screen" tabindex="1" title="restore screen">restore screen</a></li>
								<li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>
								<li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>
							</ul>
						</div>
					</div>
				</div>
				<div class="jp-no-solution">
					<span>Update Required</span>
					To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.
				</div>
			</div>
		</div>

			<div id="jplayer_inspector"></div>

		</section>
	</div>

</div>
{#<script type="text/javascript" src="/js/prettify/prettify-jPlayer.js"></script>#}



