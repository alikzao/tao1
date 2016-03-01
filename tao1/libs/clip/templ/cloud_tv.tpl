{% extends "layout.tpl" %}


{% block footer %}
	{{ super() }}
    <link href="/static/core/jplayer/jplayer.blue.monday.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/static/core/jquery/jquery-ui.js" ></script>

{% endblock %}


{% block content %}

<div class="colls" >

	<div style="width:1200px;">
		<div class="col_h blue2"><h2 style="font-weight: normal;">Видео редактор</h2></div>
		<div class="single_object ui-helper-clearfix " style=" background: rgba(255,255,255,.4); border: 1px solid #ddd; border-top:3px solid #008be0; box-shadow: 2px 2px 2px 2px #d8d8d8; margin: 5px 0;" >
            <div style="color:#666; margin:4px; padding:4px; ">
                <div class="" style="margin: 20px 5px; border: 0px solid #ddd;">

                    <div class="btn btn-default"><a href="/list/clips">Сисок всех клипов</a></div>

                    <div class="an_title" >
                        <div style="font-weight: bold;" class="">Заголовок:</div>
                        <input class="form-control" style="width: 96%; border: 1px solid #dddddd;" placeholder="Заголовок должен быть без пробелов и желатильно латинскими буквами" type="text" name="an_title" value="{{ h(ct(doc.head_field.title))}}" />
                    </div>

                    <div class="an_descr" style="margin-top: 10px;" >
                        <div style="font-weight: bold;" class="">Анонс:</div>
                        <textarea class="form-control" style="width: 96%; height: 90px; border: 1px solid #dddddd;" placeholder="Анонс необходим больше для социальной сети" name="an_descr">{{ h(ct(doc.head_field.descr))}}</textarea>
                    </div>
                    <div class="" style="margin-top: 10px; color:grey;" >
                        Канал euronewsru: <a target="_blank" href="http://www.youtube.com/euronewsru">на youtube.com</a><br>
                        Канал BBCRussian: <a target="_blank" href="http://www.youtube.com/user/BBCRussian">на youtube.com</a>
                    </div>

                    {% set mass =  {'wait':'Ожидает 0%', 'prepare':'Подготовка 1%', 'download':'Скачивание файлов 2%', 'fragments':'Вырезание нужных фрагментов 30%',
                        'start glue':'Склеивание аудио и видео дорожек поотдельности 50%', 'final glue':'Склеивание аудио и видео дорожек между собой 70%',
                         'uplouding':'Выгрузка готового файла на видеохостинги 90%', 'ready':'Операция завершена успешно 100%'} %}

                    <div class="status label label-success" style="margin:20px; ">{{ mass[doc['status']['s']] }}</div><br>
                    {% if doc['status']['s'] == 'ready' %}
                        <div class="status label label-success" style="margin:20px; ">Вы можете посмотреть видео по следующей ссылке: <a target="_blank" href="{{ doc['link_vk'] }}"><u style="color:#ffff00;">{{ doc['link_vk'] }}</u></a></div>
                        <br>


{#                        <iframe src="{{  doc.link_pl }}" width="400" height="320" frameborder="0"></iframe>#}

{#                      <iframe src="http://vk.com/video_ext.php?oid=-51306341&id=165187700&hash=ddd379f8fb12d0b5&hd=1" width="607" height="360" frameborder="0"></iframe>#}
{#                        <video style="border-radius: 10px;" id="movie" width="400" height="320" preload controls><source src="/static/static/clip/'+doc_id+'/final.webm" /></video>#}

                        <p>Загрузить видео себе на компьютер <a href="/static/static/clip/'+doc_id+'/final.avi">AVI</a>
                        <div class="btn btn-info add_vk"><i class="icon-cloud-upload"></i> Отправить Vkontakte</div>
                        <div class="btn btn-danger disabled"><i class="icon-youtube"></i> Отправить на Youtube</div>
{#                        <div class="btn btn-success pley_pley"><i class="icon-cloud-upload"></i> Просмотреть в плеере</div>#}
                        </p>
                    {% endif %}

                    <div class="kadr">
                        <div class="no_frag"><span>Выделите фрагмент</span></div>
                        <div class="edit_frag">
                            <div style="font-weight: bold; margin: 10px;" class="">Редактирование фрагмента</div>

                            <div class="clip" style="min-height: 100px; vertical-align:top;">
                                <label> Пометка: <input class="form-control input-sm" type="text" name="label" placeholder="Пометка о чем ролик (необязательно)"/></label>
                                <label> Ссылка: <input class="form-control input-sm" type="text" name="link" placeholder="Ссылка на нужный ролик"/></label>

                                Вырезать с:
                                <div class="from_time" style="display:inline-block;">
                                    <input class="form-control input-sm" style="width:82px; margin-bottom:0;" name="start" type="text" placeholder="00:00:00"/><br>
                                    <div class="btn btn-default btn-sm set_cur" data-content="Текущее время проигрывания взятое с плеера" data-placement="left" rel="popover" data-trigger="hover" title="Время начала"><i class="icon-circle-arrow-up"></i></div><div class="btn btn-default btn-sm set_play" data-content="Установить время из поля в проигрывателе" data-placement="bottom" rel="popover" data-trigger="hover" title="Установить время"><i class="icon-circle-arrow-right"></i></div><div class="btn btn-default btn-sm clear_time" data-content="Выставить нулевое время" data-placement="bottom" rel="popover" data-trigger="hover" title="Обнулить"><i class="icon-circle-blank"></i></div>
                                </div>
                                по:
                                <div class="to_time" style="display:inline-block;">
                                    <input class="form-control input-sm" style="width:82px;  margin-bottom:0;" type="text" name="end" placeholder="00:00:00"/> <br>
                                    <div class="btn btn-default btn-sm set_cur" data-content="Текущее время проигрывания взятое с плеера" data-placement="left" rel="popover" data-trigger="hover" title="Время начала"><i class="icon-circle-arrow-up"></i></div><div class="btn btn-default btn-sm set_play" data-content="Установить время из поля в проигрывателе" data-placement="bottom" rel="popover" data-trigger="hover" title="Установить время"><i class="icon-circle-arrow-right"></i></div><div class="btn btn-default btn-sm clear_time" data-content="Выставить нулевое время" data-placement="bottom" rel="popover" data-trigger="hover" title="Обнулить"><i class="icon-circle-blank"></i></div>
                                </div>
                                или длина:
                                <div class="len_time" style="display:inline-block;">
                                    <input class="form-control input-sm" style="width:82px; margin-bottom:0;" type="text" name="len" placeholder="00:00:00"/><br>
                                    <div class="btn btn-default btn-sm" data-content="Прибавитьсекунду к текущему времени" data-placement="bottom" rel="popover" data-trigger="hover" title="Прибавить секунду"><i class="icon-plus plus"></i></div><div class="btn btn-default btn-sm minus" data-content="Убавить секунду от длины текущего времени" data-placement="bottom" rel="popover" data-trigger="hover" title="Убавить секунду"><i class="icon-minus"></i></div><div class="btn btn-default btn-sm clear_time" data-content="Выставить нулевое время" data-placement="bottom" rel="popover" data-trigger="hover" title="Обнулить"><i class="icon-circle-blank"></i></div>
                                </div>
{#                                <div class="navbar navbar-inverse" style="margin: 5px 0 5px 0">#}
                                <div class="well well-sm" style="margin: 5px 0 5px 0">
                                    <div style="font-weight:bold; display:inline-block;">Управление плеером</div>
                                    <div class="btn-group manage_play" style="">
                                        <div class="btn btn-default play"><i class="icon-play"></i></div>
                                        <div class="btn btn-default pause"><i class="icon-pause"></i></div>
                                        <div class="btn btn-default stop"><i class="icon-stop"></i></div>
                                        <div class="btn btn-default step_b"><i class="icon-step-backward"></i></div>
                                        <div class="btn btn-default step_f"><i class="icon-step-forward"></i></div>
{#                                            <div class="btn btn-default fb"><i class="icon-fast-backward"></i></div>#}
{#                                            <div class="btn btn-default ff"><i class="icon-fast-forward"></i></div>#}
                                    </div>
                                </div>

                                <label> Убрать звук: <input type="checkbox" name="del_audio" checked="checked" /></label><br>
                                <div class="btn-group">
                                    <div class="btn btn-default my_clip"><i class="icon-film"></i> Загрузить своё</div>
                                        <form style="display:none;"><input class="fi form-control input-sm" type="file" style="display:none;"/></form>
                                    <div class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                                        <span class="caret"></span>
                                    </div>
                                    <ul class="dropdown-menu">
                                        <li class="draw_img">Нарисовать картинку</li>
                                    </ul>
                                </div>

                            </div>

                            <div class="block_frag" style="margin-top:20px;">
                                <div class="clip_pub btn btn-info"><i class="icon-film"></i> <span>Опубликовать</span> </div>
                                <div class="clip_up btn btn-info"><i class="icon-cloud-upload"></i> <span>Отправить</span> </div>
                                <div class="clip_del btn btn-danger"><i class="icon-remove"></i> <span>Удалить</span> </div>
                                <div class="clip_add btn btn-primary"><i class="icon-ok"></i> <span>Сохраниить</span> </div>
                            </div>
                        </div>

                        <div class="screen_frag">
                            {% include 'app.clip:player.tpl' %}
                        </div>
                    </div>


                    <div class="lenta_div">
                        <div class="">
                            <div class="btn btn-default zoom_plus"><i class="icon-plus"></i></div>
                            <div class="btn btn-default zoom_minus"><i class="icon-minus"></i></div>
                            <div class="btn btn-default prev_frag"><i class="icon-arrow-left"></i></div>
                            <div class="btn btn-default next_frag"><i class="icon-arrow-right"></i></div>
                        </div>
                        <div style="font-weight: bold; margin: 10px;" class="">Видео дорожка <span class="track_v"></span></div>
                        <div class="lenta" track="v">
                            <div class="time_line v"></div>
                            <div class="track">
                            {% for res in doc['data_v'] %}
                                <div class="fragment" del_audio="{{ h(res['del_audio'])}}"  title="{{ h(res['title'])}}"
                                     thumb="{{ h(res['thumb'])}}" frag="{{ res['frag']}}" link="{{ h(res['link'])}}"
                                     start="{{ res['start']}}" end="{{ res['end']}}" len="{{ res['len']}}" track="v"
                                     filename="{{ h(res['filename']) if 'filename' in res else '' }}"
                                     label="{{ h(res['label'])  if 'label' in res else '' }}">
                                    <span style="vertical-align: bottom;">{{ h(res['label'])}}</span>
                                </div>
                            {% endfor %}
                            </div>
                        </div>
                        <div style="margin:7px 0 0 3px;" class="btn btn-success add_frag"><i style="font-size:26px; padding-top:2px;" class="icon-plus icon-white"></i></div>

                        <div style="font-weight: bold; margin: 10px;" class="">Аудио дорожка <span class="track_a"></span></div>
                        <div class="lenta" track="a">
                            <div class="time_line a"></div>
                            <div class="track">
                            {% for res in doc['data_a'] %}
                                <div class="fragment" del_audio="{{ h(res['del_audio'])}}"
                                     title="{{ h(res['title'])}}" thumb="{{ h(res['thumb'])}}" frag="{{ res['frag']}}"
                                     link="{{ h(res['link'])}}" start="{{ res['start']}}" end="{{ res['end']}}" track="a" filename="{{ h(res['filename']) if 'filename' in res else '' }}"
                                     len="{{ res['len']}}" label="{{ h(res['label']) if 'label' in res else '' }}">
                                    <span style="vertical-align: bottom;">{{ h(res['label'])}}</span>
                                </div>
                            {% endfor %}
                            </div>
                        </div>
                        <div style="margin:7px 0 0 3px;" class="btn btn-success add_frag"><i style="font-size:26px; padding-top:2px;" class="icon-plus icon-white"></i></div>
                    </div>



                    <div class="save_all">
                        <div class="rolik_cancel btn btn-danger"><i class="icon-remove"></i> Очистить целиком</div>
                        <div class="rolik_pub btn btn-info"><i class="icon-ok"></i>&nbsp;Опубликовать на сайте</div>
                        <div class="rolik_add btn btn-success"><i class="icon-film"></i> Запустить в обработку</div>
                        <div class="rolik_down btn btn-primary"><i class="icon-cloud-download"></i> Загрузить ролики</div>
                    </div>


                </div>

            </div>
			<div class="" style="height: 40px;"></div>
		</div>
	</div>
</div>


{#{% set proc_id = doc.proc_id if doc.proc_id else 'des:obj' %}#}
{#{% if has_perm(doc.proc_id, 'create') %}#}


<script>

var doc_id = '{{ doc._id }}';
$(function() {

    $('.edit_frag').find('[rel="popover"]').popover();


{#    var pl = videojs("example_video_1");#}
{#    var pl = $('video,audio').mediaelementplayer(/* Options */);#}
    var pl_v = new MediaElementPlayer('#pl'/*, Options */);
    var pl_a = new MediaElementPlayer('#pl_a'/*, Options */);
    var pl = pl_v;
{#    $('.2').hide();#}
    $('.2').css({'visibility':'hidden'});
{#    var player = $("#jplayer").data().jPlayer;#}
{#    var $player = $("#jplayer");#}
    console.log('pl', pl);
    $('.lenta').on('click', '.fragment', select_frag );
    // управление плеером
    $('.block_frag .clip_pub').click(clip_pub);
    $('.save_all .rolik_pub').click(rolik_pub);

    $('.manage_play .play').click(function(){ pl.play() });
    $('.manage_play .pause').click(function(){ pl.pause() });
    $('.manage_play .stop').click(function(){ pl.stop() });
    $('.manage_play .step_b').click(function(){ pl.pause(); pl.setCurrentTime(parseInt(pl.getCurrentTime() - 1)); });
    $('.manage_play .step_f').click(function(){ pl.pause(); pl.setCurrentTime(parseInt(pl.getCurrentTime() + 1)); });
    $('.manage_play .fb').click(function(){ pl.pause(); pl.setCurrentTime(0) });
    $('.manage_play .ff').click(function(){ pl.pause(); pl.setCurrentTime(pl.media.duration); });
    //очистка полей
    $('.from_time .clear_time').click(function(){ $('.from_time input').val('00:00:00'); });
    $('.to_time .clear_time').click(function(){ $('.to_time input').val(sec2time(parseInt(pl.media.duration))); });
    $('.len_time .clear_time').click(function(){ $('.len_time input').val(sec2time(parseInt(pl.media.duration))); });

{#    jPlayer("play", [time]) immediately afterwards, just play it. Likewise, with jPlayer("pause", [time]),#}

    //получение начала
    $('.from_time .set_cur').click(function(){ $('.from_time input').val( sec2time(parseInt(pl.getCurrentTime() )) ); });
    $('.from_time .set_play').click(function(){pl.pause(); pl.setCurrentTime(time2sec($('.from_time input').val()) ); });
    $('.to_time .set_cur').click(function(){ $('.to_time input').val( sec2time(parseInt(pl.getCurrentTime() )) ); });
    $('.to_time .set_play').click(function(){pl.pause(); pl.setCurrentTime( time2sec($('.to_time input').val() ) ); });

    $('.len_time .plus').click(function(){ $('.len_time input').val(sec2time( time2sec($('.len_time input').val()) + 1 )); });
    $('.len_time .minus').click(function(){ $('.len_time input').val(sec2time( time2sec($('.len_time input').val()) - 1 )); });

{#    var ff = $('.kadr .fi');#}
    $('.kadr').on('click', '.my_clip', function(){ $('.kadr .fi').click() });
    $('.kadr').on('change', '.fi', file_changed);

    $( ".track" ).sortable({
        delay:50,
        cursor:"move",
        distance: 0,
        axis: "x",
        stop: function(e, ui){
{#            var $frag = $(e.srcElement);#}
            var $frag = $(ui.item);
            if (!$frag.is('.fragment')) $frag = $frag.closest('.fragment');
            if (!$frag.length) alert('fragment not found')
            var track = $frag.attr('track');
            var frag = $frag.attr('frag');
            var place = $(this).find('.fragment').index($frag);
            var fff = $(this).find('.fragment').attr('frag');
            console.log(fff, frag, track, place, this, e, ui);
            $.ajax({
                type: "POST", dataType: "json", url: '/clip/drag/fragment/'+doc_id,
                data: { track: track, frag: frag, place: place },
                success: function (data) {
                    if (data.result == 'ok') {

                    }
                }
            });
        }
    });
    $( ".track" ).disableSelection();

    var $cur = null;
    var zoom = 1;

    $('.zoom_plus').click(function(){
        zoom = zoom*2;
        update_time();
        return false;
    });
    $('.zoom_minus').click(function(){
        zoom = zoom/2;
        update_time();
        return false;
    });
    $('.next_frag').click(function(){
        if (!$cur) return
        $cur.next().click();
    });
    $('.prev_frag').click(function(){
        if (!$cur) return
        $cur.prev().click();
    });
    $('.lenta_div .add_frag').click(function(){
        console.log('add_frag');
        var $lenta = $(this).prev();
        $cur = $('<div class="fragment" start="00:00:00" end="00:00:30" len="00:00:30" ><span style="vertical-align: bottom;"></span></div>');
        $cur.appendTo($lenta.find('.track'));
        $cur.attr('track', $lenta.attr('track'))
        $cur.click();
        update_time();
        save_clip();
    });

    $('.lenta').scroll(function(){
        var $lenta = $(this);
        $('.lenta').each(function(i, v){
            var $v = $(v);
{#            if ($v.scrollTop > 0) $v.scrollTop(0);#}
            if ($v.is($lenta)) return;
            $v.scrollLeft($lenta.scrollLeft());
        });
    });
    $('.lenta').scrollLeft(0);
    $('input[name=start], input[name=end], input[name=len]').keyup(time_changed).blur(time_changed);

    update_time();
    function update_time(){
        var ln = {'a':0, 'v':0};
        $('.fragment').each(function(i, v){
            var $v = $(v);
            var l = time2sec($v.attr('len'));
            var t = $v.attr('track');
            ln[t] += l;
            $v.css({'width':l * zoom + 'px'});
        });
        $('.track_v').text(sec2time(ln.v));
        $('.track_a').text(sec2time(ln.a));
        for (var t in ln) {
            var $track = $('.time_line.' + t);
            $track.empty();
            for (var i = 0; i < ln[t] || i < 1200; i += 60) {
                var $min = $('<div class="min"><span class="title"></span><div class="sec"></div></div>').appendTo($track);
                $min.find('.title').text(i / 60);
                var $sec = $min.find('.sec');
                for (var e = 0; e < 6; e++) {
                    $('<div class="sec"></div>').appendTo($sec);
                }
            }
        }
        $('.time_line .min').css({width: 60 * zoom});
        $('.time_line .sec').css({width: 10 * zoom});
    }

    function rolik_pub(){
        $.ajax({
            type: "POST", dataType: "json", url: '/rolik/pub/'+doc_id,
            data: { },
            success: function (data) {
                if (data.result == 'ok') {

                }
            }
        });
    }
    function clip_pub(){
        $.ajax({
            type: "POST", dataType: "json", url: '/clip/pub/'+doc_id,
            data: {
                frag:$cur.attr('frag'),
                track:$cur.attr('track')
            },
            success: function (data) {
                if (data.result == 'ok') {
                    alert('Опубликовано');
                }
            }
        });
    }

    function time_changed(e){
        var $kadr = $(this).closest('.kadr');
        var is_blur = e.type == 'blur';
        var start = time2sec($kadr.find('input[name=start]').val());
        var end= time2sec($kadr.find('input[name=end]').val());
        var len = time2sec($kadr.find('input[name=len]').val());
        if (!$(this).is('[name=end]')) end = start + len;
        else if (!$(this).is('[name=len]')) len = end - start;
        update_input_status($kadr, start, end, len);
        if (is_blur || !$(this).is('[name=start]')) $kadr.find('input[name=start]').val(sec2time(start));
        if (is_blur || !$(this).is('[name=end]')) $kadr.find('input[name=end]').val(sec2time(end));
        if (is_blur || !$(this).is('[name=len]')) $kadr.find('input[name=len]').val(sec2time(len));
    }

    function update_input_status($kadr, start, end, len) {
        if (start === null) $kadr.find('input[name=start]').addClass('err');
        else $kadr.find('input[name=start]').removeClass('err');
        if (end === null) $kadr.find('input[name=end]').addClass('err');
        else $kadr.find('input[name=end]').removeClass('err');
        if (len === null) $kadr.find('input[name=len]').addClass('err');
        else $kadr.find('input[name=len]').removeClass('err');
    }

    function time2sec(tm) {
        tm = ''+tm;
        var res = null;
        if (tm.match(/^[0-9]+$/)) res = parseInt(tm);
        if (res === null){
            tm = tm.replace(/(\.|,|\/|-| )/, ':');
            if (!tm.match(/^[0-2]\d:[0-5]\d:[0-5]\d$/)) return null;
            res = parseInt(tm.substr(0, 2)) * 3600 + parseInt(tm.substr(3, 2)) * 60 + parseInt(tm.substr(6, 2));
        }
        return res;
    }
    function sec2time(s) {
        return ('0' + parseInt(s / 3600 % 60)).slice(-2)+':'+('0' + parseInt(s / 60 % 60)).slice(-2)+':'+('0' + parseInt(s % 60)).slice(-2);
    }

    function clean_fragment(){
        $('.kadr').find('input').val('');
        $('.kadr').find('del_audio').removeAttr('checked');
        $('.thumb .title').text('');
        $('.thumb .img').empty();
        $cur = null;
    }

    function update_fragment($div, data) {
        var frag = data['frag'];
        var thumb = data['thumb'];
        var title = data['title'];
        var label = data['label'];
        $div.attr('filename', data.filename);
        $div.attr('label', label);
        $div.attr('link', data['link']);
        $div.attr('start', data['start']);
        $div.attr('end', data['end']);
        $div.attr('len', data['len']);
        $div.attr('del_audio', data['del_audio']);
        if(frag) $div.attr('frag', frag);
        if(thumb) $div.attr('thumb', thumb);
        if(title) $div.attr('title', title);
        $div.find('span').text(label);
        $div.click();
    }

    function save_clip(cb){
        if(!$cur) return
        var frag = $cur.attr('frag');
        var $kadr = $('.kadr');
        var track = $cur.attr('track');
        var link = $kadr.find('[name=link]').val();
        var label = $kadr.find('[name=label]').val();
        var start = $kadr.find('[name=start]').val();
        var end = $kadr.find('[name=end]').val();
        var len = $kadr.find('[name=len]').val();
        var del_audio = $kadr.find('[name=del_audio]').is(':checked') ? '1' : '0';
        var img_large = $('<div style="background:rgba(0,0,0,0.8); position:fixed; top:0;left:0;bottom:0;right:0; z-index:10000; text-align:center; ">' +
                '<img src="/static/core/img/wait.gif" style="position:relative; margin-top:10%;" alt="image01" />' +
                '</div>').appendTo($('body'));
        $.ajax({
            type: "POST", dataType: "json", url: frag ? '/clip/edit/fragment/'+doc_id : '/clip/add/fragment/'+doc_id,
            data: { link: link,label:label, start: start, end: end, len:len, track:track, frag:frag, del_audio:del_audio},
            success: function (data) {
                if (data.frag) update_fragment($cur, data)
                else alert(data.error);
                img_large.remove();
                update_time()
                if (typeof cb == 'function') cb();
            }
        });
    img_large.click(function(){img_large.remove();});
    }

    $('.kadr .clip_add').click(function(){
        console.log('clip_add');
        save_clip();
    });

    $('.draw_img').click(function(){
        var dialog = $('<div class="modal hide fade " style="">'+
            '<div class="modal-header">'+
            '<button class="close" data-dismiss="modal">×</button><h3>Добавление картинки</h3></div>' +
            '<div class="modal-body" style=""></div>' +
            '<div class="modal-footer"><div class="btn-group">'+
            '<span  class="btn ok_img" data-dismiss="modal">Добавить</span>'+
            '<span  class="btn cancel" data-dismiss="modal">Закрыть</span>'+
            '</div></div></div>'
        ).appendTo('body');
        var tube = $('<textarea name="tube" style="height:200px; width:250px;">').appendTo(dialog.find('.modal-body'));
        dialog.modal();
        dialog.find('.ok_img').click(function(){
            console.log('ok img');
            var that = this;
            save_clip(function(){
                var text = dialog.find('textarea').val();
                var frag = $cur.attr('frag');
                $.ajax({
                    type: "POST", dataType: "json", url: '/clip/add/img/'+doc_id,
                    data: {frag:frag, text:text },
                    success: function (data) {
                        if (data.result == 'ok') { }
                    }
                });
            });
        });

    });

    $('.kadr').on('click', '.clip_del', function(){
        var that = $(this);
        if(!$cur) return
        var track = $cur.attr('track');
        var frag = $cur.attr('frag');
        if(!frag){
            $cur.remove();
            clean_fragment();
            return
        }
        $.ajax({
            type: "POST", dataType: "json", url: '/clip/del/fragment/'+doc_id,
            data: { frag: frag, track:track },
            success: function (data) {
                if (data.result == 'ok'){
                    $cur.remove();
                    clean_fragment();
                }
            }
        });
    });



    function select_frag(){
        $('.no_frag').hide();
        var $v = $(this);
        $('.jp-title').text($v.attr('label'));
        $('.kadr').find('[name=label]').val($v.attr('label'));
        $('.kadr').find('[name=link]').val($v.attr('link'));
        $('.kadr').find('[name=start]').val($v.attr('start'));
        $('.kadr').find('[name=end]').val($v.attr('end'));
        $('.kadr').find('[name=len]').val($v.attr('len'));
        if( $v.attr('del_audio')=='1')
            $('.kadr').find('[name=del_audio]').attr('checked', 'checked');
        else
            $('.kadr').find('[name=del_audio]').removeAttr('checked');
        $('.lenta').find('.fragment.curr').removeClass('curr');
        $('.thumb .title').text($v.attr('title') ? $v.attr('title') : '');
        $('<img />').appendTo($('.thumb .img').empty()).attr('src', $v.attr('thumb'));
        $cur = $v;
        $v.addClass('curr');

            console.log($cur);

        var fn = $cur.attr('filename');
        var video = ['.flv', '.avi', '.mpg', '.mpeg', '.mp4']
        var audio = ['.mp3', '.ogg', '.flac', '.wav']
        var image = ['.jpg', '.png', '.jpeg']

        function fn_is(list) {
            if (!fn) return false;
            for (var i = 0; i < list.length; i++) {
                var ext = list[i];
                if (fn.substr(-ext.length) == ext) return ext;
            }
            return false;
        }

            console.log('pl', pl);
{#        pl.remove();#}
        if (fn_is(video)) {
            console.log($cur, 'filename', fn, 'is video');
            console.log('/static/static/clip/'+doc_id+'/in_'+$cur.attr('track')+'/'+$cur.attr('frag')+fn_is(video));

{#            pl.src( '/static/static/clip/'+doc_id+'/in_'+$cur.attr('track')+'/'+$cur.attr('frag')+fn_is(video) );#}
            if (typeof pl.stop == 'function') pl.stop();
{#            $('#pl').closest('.mejs-video').show();#}
{#            $('#pl_a').closest('.mejs-audio').hide();#}
            $('.1').css({'visibility':'visible'});
            $('.2').css({'visibility':'hidden'});
            pl = pl_v;
            pl.setSrc( '/static/static/clip/'+doc_id+'/in_'+$cur.attr('track')+'/'+$cur.attr('frag')+fn_is(video) );
        } else if (fn_is(audio)) {
            console.log('filename', fn, 'is audio');
            if (typeof pl.stop == 'function') pl.stop();
{#            $('#pl').closest('.mejs-video').hide();#}
{#            $('#pl_a').closest('.mejs-audio').show();#}
            $('.2').css({'visibility':'visible'});
            $('.1').css({'visibility':'hidden'});
            pl = pl_a;
            pl.setSrc('/static/static/clip/'+doc_id+'/in_'+$cur.attr('track')+'/'+$cur.attr('frag')+fn_is(audio));
        } else if (fn_is(image)) {
            console.log('filename', fn, 'is image');
            if (typeof pl.stop == 'function') pl.stop();
            // TODO А здесь вообще оба спрятать и показать просто картинку
            $('#pl').closest('.mejs-video').hide();
            $('#pl_a').closest('.mejs-audio').show();
            pl = pl_a;
            pl.setSrc('/static/static/silence.mp3');
{#                poster: '/static/static/clip/'+doc_id+'/in_'+$cur.attr('track')+'/'+$cur.attr('frag')+fn_is(image)#}
        } else {
            console.log('filename', fn, 'is video');
        }

        return false;
    }
    $('.save_all .rolik_cancel').click(function(){
        $.ajax({
            type: "POST", dataType: "json", url: '/rolik/del/'+doc_id,
            data: { },
            success: function (data) {
                if (data.result == 'ok') {
                    window.location.reload();
                }
            }
        });
    });
    //запускает весь процес в работу.
    $('.save_all .rolik_add').click(function(){
        $.ajax({
            type: "POST", dataType: "json", url: '/add/clip/'+doc_id,
            data: { },
            success: function (data) {
                if (data.result == 'ok') {
                    start_proc('s');
                }
            }
        });
    });
    //запускает закачку.
    $('.save_all .rolik_down').click(function(){
        $.ajax({
            type: "POST", dataType: "json", url: '/down/clip/'+doc_id,
            data: { },
            success: function (data) {
                if (data.result == 'ok') {
                    start_proc('s');
                }
            }
        });
    });

    var status_kind = 's';
    function start_proc(kind){
        alert('Обработка запущена. Следите за статусом. По окончании обработки страница будет перегружена.');
                    var img_large = $('<div style="background:rgba(0,0,0,0.8); position:fixed;top:0;left:0;bottom:0;right:0; z-index:10000; text-align:center; ">' +
                        '<img src="/static/core/img/wait.gif" style="position:relative; margin-top:10%;" alt="image01" />' +
                        '<br><div class="progress1 label label-info" style="margin:20px; "></div><br>' +
                        '</div>').appendTo($('body'));
        status_kind = kind;
        setTimeout(check_status, 3000);
    }

    var mass =  {'wait':'Ожидает 0%', 'prepare':'Подготовка 1%', 'downloading':'Скачивание файлов 2%', 'fragments':'Вырезание нужных фрагментов 30%',
                            'start glue':'Склеивание аудио и видео дорожек поотдельности 50%', 'final glue':'Склеивание аудио и видео дорожек между собой 70%',
                             'uplouding':'Выгрузка готового файла на видеохостинги 90%', 'ready':'Операция завершена успешно 100%'};


{#                        if( doc['status'] == 'ready')#}
{#                            <div class="status label" style="margin:20px; ">Вы можете посмотреть видео по следующей ссылке: <a target="_blank" href="{{ doc['link_vk'] }}">{{ doc['link_vk'] }}</a></div>#}


    function check_status(){
        $.ajax({
            type: "POST", dataType: "json", url: '/rolik/get/status/'+doc_id, data: { kind: status_kind },
            success: function (data) {
                if (data.status == 'ready') {
                    window.location.reload();
                }
                $('.progress1').text(mass[data.status]);
                setTimeout(check_status, 10000);
            }
        });
    }

    $(".an_title input, .an_descr textarea").change(function(){
        // отправка описания и заголовка на сервер
        var title = $('.an_title input').val();
        var descr = $('.an_descr textarea').val();
        $.ajax({
            type: "POST", dataType: "json", url: '/clip/add/descr/'+doc_id,
            data: { title:title, descr:descr},
            success: function (data) {
                if (data.result == 'ok') { }
            }
        });
    });

    $('.add_vk').click(function(){ add_vk('vk'); });
    function add_vk(soc){
        $.ajax({
            type: "POST", dataType: "json", url: '/clip/upload/'+doc_id, data: { soc:name},
            success: function () {
                start_proc();
            }
        });
    }
    $('.clip_up').click(function(){ add_vk1('vk'); });
    function add_vk1(soc){
        $.ajax({
            type: "POST", dataType: "json", url: '/clip/upload/'+doc_id,
            data: { soc:name, frag:$cur.attr('frag'), track:$cur.attr('track')},
            success: function () {
                start_proc();
            }
        });
    }

     function progress_bar(target){
        var pb = $('<div class="progress progress-striped active" style="top:300px; position:relative; z-index:100000">'+
            '<div class="bar" style="width: 40%;"></div>'+
        '</div>').appendTo(target);
        return pb.find('.bar');
    }

    function af(url, data, cb, pb){
        $.ajax({
            xhr: function(){
                var xhr = new window.XMLHttpRequest();
                // Upload progress
                xhr.upload.addEventListener('progress', function(e){ if (pb) pb(e.loaded, e.total); }, false);
                return xhr;
            },
            type: 'POST', dataType: 'json', url: url, data: data,
            cache: false, contentType: false, processData: false,
            success: function(data) {if (cb) cb(data, false);},
            error: function(jqXHR, textStatus, errorThrown){
                dao.log(jqXHR, textStatus, errorThrown);
                if (cb) cb({}, true);
            }
        })
    }

    function file_changed(){
        if(!$cur)return
        var that = this;
        save_clip(function(){
            form = new FormData();
            form.append('MAX_FILE_SIZE', '1000000');
            form.append('action', 'add_file');
            form.append('proc_id', 'des:clips');
            form.append('doc_id', doc_id);
            form.append('track', $cur.attr('track'));
            form.append('frag', $cur.attr('frag'));
            $.each(that.files, function(i, file) {
                form.append('file', file);
            });
            var bef = $('<div style="position:fixed; background-color:white; left:20px; right:20px; top:50px; bottom:20px; z-index:1000000;"></div>').appendTo($('body'));
            var pb = progress_bar(bef);
            af('/clip/add/file/'+doc_id, form, function(data, error){
                console.log('================ already uploaded');
                bef.remove();
                if(data.result == 'fail'){
                    alert(data.error);
                    return
                }
                $cur.attr('title', data.title);
                $cur.attr('del_audio', data.del_audio);
                $cur.attr('thumb', '');
                $(that).parent()[0].reset();
                $cur.attr('filename', data.filename);
                $cur.click();
            }, function(progress, total) {
                console.log('progress', progress, total, progress / total * 100 + '%');
                pb.css({'width': progress / total * 100 + '%'});
            });
        })
    }

});


</script>






<style type="text/css">
.block_frag div{
{#    padding:0;#}
}
.block_frag span{
    font-size:12px;
}
.kadr{
    position:relative;
}
.no_frag span{ margin-top:200px; display:inline-block; font-size:36px; font-weight:bold;}
.no_frag{
    z-index:1000000;
    border-radius:10px;
    text-align:center;
    position:absolute; top:0px; left:0px; bottom:0px; right:0px;
    background-color:rgba(0,0,0,.8); color:white;
}
.lenta{
    position: relative;
    overflow-x: auto;
    overflow-y: hidden;
    white-space: nowrap;
    display: inline-block; width: 1030px;vertical-align: top;
    padding: 3px; padding-top: 13px;
    font-size: 0;
}
.lenta_div .icon-plus{vertical-align: top; margin-left: 5px;}
{#.lenta{ overflow: scroll; }#}
.save_all>*{ cursor: pointer; width:220px; }
.save_all{ text-align: right; padding: 5px 50px; }
.clip_add{ cursor: pointer; }
.edit_frag{ display:inline-block; width:500px;
    padding:5px 5px 20px 5px;  background-color: #ddd; border: 1px solid #ccc; border-radius:10px; }
.lenta_div{ display:inline-block;width:1100px; padding:5px; min-height:100px; background-color: #ddd; border: 1px solid #ccc; border-radius:10px; margin-top:20px; }
.screen_frag{
    display:inline-block; vertical-align:top; width:450px; background-color: #ddd; border: 1px solid #ccc; border-radius:10px;
}
.time_line {
    white-space: nowrap;
    position: absolute;
    height: 8px; top: 0; left: 0;
    padding: 0;
    margin-left: 1px;
}
.time_line .min .title{
    margin-left: 2px;
    font-size: 10px;
    line-height: 10px;
    font-weight: bold;
}
.time_line .min{
    position: relative;
    display: inline-block;
    height: 8px;
    width: 60px;
    margin-left: -1px;
    padding: 0;
    border-top: 1px solid black;
    border-left: 1px solid black;
}
.time_line .sec{ vertical-align: top; position: absolute; left: 0; top: 0; }
.time_line .sec .sec{
    vertical-align: top;
    position: static;
    display: inline-block;
    height: 4px;
    width: 10px;
    margin-left: -1px;
    padding: 0;
    border-left: 1px solid #666;
}
.fragment span{ margin: 3px 3px; display: inline-block; }
.fragment.curr{
    border: 3px solid red;
    margin: -3px;
    z-index: 100500;
}
.fragment{
{#    min-width:120px;#}
    font-size: 12px;
    height:35px;
    vertical-align:top;
    display:inline-block;
{#    display:block;#}
    color:white;
    border-radius:6px;
    padding:0;
    cursor: pointer;
    overflow: hidden;
    border: 1px solid white;
    margin: -1px;
}
.fragment:nth-child(3n){ background-color: #2a2; }
.draw_img{ cursor: pointer; }
.err{ background-color: #fcc !important; border: 1px solid red !important; }
.fragment:nth-child(3n+1){ background-color: #084; }
.fragment:nth-child(3n+2){ background-color: #048; }
</style>

{% endblock %}
