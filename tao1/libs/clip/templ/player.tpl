


<div class="1">
    <video id="pl" class="video-js vjs-default-skin" data-setup='{"example_option":true}' controls preload="none" width="600" height="380"
           poster="/static/static/clip/{{doc._id}}/screen.jpg">
        <source src="/static/static/clip/ruric_.flv" type='video/flv' />
        <object width="640" height="264" type="application/x-shockwave-flash" data="/static/core/mel/flashmediaelement.swf">
            <param name="movie" value="/static/core/mel/flashmediaelement.swf" />
            <param name="flashvars" value="controls=true&file=myvideo.mp4" />
            <!-- Image as a last resort -->
            <img src="http://video-js.zencoder.com/oceans-clip.png" width="640" height="264" title="No video playback capabilities" />
        </object>

    </video>
</div>

<div class="2">
    <audio id="pl_a" controls style="display:none;">
        <source src="" type="audio/mpeg">
    </audio>
</div>

