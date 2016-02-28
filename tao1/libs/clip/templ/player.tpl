

<script type="text/javascript">
//<![CDATA[
onready(function(){

});
//]]>
</script>

<div class="1">
    <video id="pl" class="video-js vjs-default-skin" data-setup='{"example_option":true}' controls preload="none" width="600" height="380"
           poster="/static/static/clip/{{doc._id}}/screen.jpg">
{#           poster="http://video-js.zencoder.com/oceans-clip.png">#}

    {#    <source src="/static/static/clip/{{doc._id}}/{{doc.final_name}}"  type='video/flv' />#}
        <source src="/static/static/clip/ruric_.flv" type='video/flv' />
    {#     <source src="/static/static/clip/{{doc._id}}/{{doc.final_name}}" type="video/mp4">#}

        <object width="640" height="264" type="application/x-shockwave-flash" data="/static/core/mel/flashmediaelement.swf">
            <param name="movie" value="/static/core/mel/flashmediaelement.swf" />
            <param name="flashvars" value="controls=true&file=myvideo.mp4" />
            <!-- Image as a last resort -->
            <img src="http://video-js.zencoder.com/oceans-clip.png" width="640" height="264" title="No video playback capabilities" />
        </object>

    {#    <source src="/static/static/clip/{{doc_id}}'/{{doc.final_name}}" type='video/mp4' />#}
    {#    <source src="http://video-js.zencoder.com/oceans-clip.webm" type='video/webm' />#}
    {#    <source src="http://video-js.zencoder.com/oceans-clip.ogv" type='video/ogg' />#}
    </video>
</div>

<div class="2">
    <audio id="pl_a" controls style="display:none;">
        <source src="" type="audio/mpeg">
    </audio>
</div>


{#loop="loop" controls="controls" tabindex="0"#}

{#<video id="pl" class="video-js vjs-default-skin" data-setup='{"example_option":true}' controls preload="none" width="600" height="380" poster="">#}
{#    <source src="/static/static/clip/ruric_.flv" type='video/flv' />#}
{#    <object width="640" height="264" type="application/x-shockwave-flash" data="/static/core/mel/flashmediaelement.swf">#}
{#        <param name="movie" value="/static/core/mel/flashmediaelement.swf" />#}
{#        <param name="flashvars" value="controls=true&file=myvideo.mp4" />#}
{#    </object>#}
{#    <source src="/static/static/clip/bercut.mp4" type='video/mp4' />#}
{#</video>#}


{#<div id="container">#}
{#	<div id="content_main">#}
{#		<section>#}
{#		<div id="jp_container_1" class="jp-video jp-video-360p">#}
{#			<div class="jp-type-single">#}
{#				<div id="jplayer" class="jp-jplayer"></div>#}
{#				<div class="jp-gui">#}
{#					<div class="jp-video-play">#}
{#						<a href="javascript:;" class="jp-video-play-icon" tabindex="1">play</a>#}
{#					</div>#}
{#					<div class="jp-interface">#}
{#						<div class="jp-progress">#}
{#							<div class="jp-seek-bar">#}
{#								<div class="jp-play-bar"></div>#}
{#							</div>#}
{#						</div>#}
{#						<div class="jp-current-time"></div>#}
{#						<div class="jp-duration"></div>#}
{#						<div class="jp-title">#}
{#							<ul>#}
{#								<li>Название</li>#}
{#							</ul>#}
{#						</div>#}
{#						<div class="jp-controls-holder">#}
{#							<ul class="jp-controls">#}
{#								<li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>#}
{#								<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>#}
{#								<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>#}
{#								<li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>#}
{#								<li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>#}
{#								<li><a href="javascript:;" class="jp-volume-max" tabindex="1" title="max volume">max volume</a></li>#}
{#							</ul>#}
{#							<div class="jp-volume-bar">#}
{#								<div class="jp-volume-bar-value"></div>#}
{#							</div>#}
{##}
{#							<ul class="jp-toggles">#}
{#								<li><a href="javascript:;" class="jp-full-screen" tabindex="1" title="full screen">full screen</a></li>#}
{#								<li><a href="javascript:;" class="jp-restore-screen" tabindex="1" title="restore screen">restore screen</a></li>#}
{#								<li><a href="javascript:;" class="jp-repeat" tabindex="1" title="repeat">repeat</a></li>#}
{#								<li><a href="javascript:;" class="jp-repeat-off" tabindex="1" title="repeat off">repeat off</a></li>#}
{#							</ul>#}
{#						</div>#}
{#					</div>#}
{#				</div>#}
{#				<div class="jp-no-solution">#}
{#					<span>Update Required</span>#}
{#					To play the media you will need to either update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.#}
{#				</div>#}
{#			</div>#}
{#		</div>#}
{##}
{#			<div id="jplayer_inspector"></div>#}
{##}
{#		</section>#}
{#	</div>#}
{##}
{#</div>#}
{#<script type="text/javascript" src="/js/prettify/prettify-jPlayer.js"></script>#}



