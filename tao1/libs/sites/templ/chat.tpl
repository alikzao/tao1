{% extends "layout.tpl" %}
{% block content %}
{#   это шаблон  для работы с общим чатом который видит администратор  #}

<input class="form-control input-sm" style="width:750px; margin:15px 20px 10px 15px;" type=text x-webkit-speech />
<div class="chat"> </div>

<div class="buttons_chat">
    <div class="refresh_chat btn btn-default"><i class="icon-refresh"></i>Обновить Чат</div>
    {% if env.user.is_admin %}
        <div class="clear_ban btn btn-default"><i class="icon-repeat"></i>Очистить бан</div>
        <div class="get_link btn btn-default"><i class="icon-share"></i>Дать ссылку</div> <div class="ready_link"></div>
        {% for res in ip %}
            <div class="ip_ban bans ">{{ res}}</div>
        {% endfor %}
	    {% for res in links %}
            <div class="links "><span link="{{ res['_id']}}" style="float:right;" class="del_links btn"><i class="icon-remove"></i>Удалить</span>{{ res['mess'] }}  {{ res['_id']}} (до: {{ res['end_time'] }})</div>
        {% endfor %}
    {% endif %}
</div>


<style type="text/css">
    .ready_link{ display: inline-block; padding: 5px; }

    .ready_link input{ width: 600px; }

    .chat{ display: inline-block; width: 750px; background-color: white; }

    .chat li{ border: 1px solid #eee; padding: 10px; margin: 2px; }

    .user_chat{ font-style: italic; font-weight: bold; color:#08f; }

    .date_chat{ color:#bbb; float:right; }
    .text_chat{ font-family: "Times New Roman"; padding: 10px; font-size: 16px; }

    .refresh_chat, .get_link{margin: 10px;}
	.chat{ margin:10px; padding: 10px; }
	.chat b{ color:#8bf; }
	.chat .text{ color:#444;}
	.chat .sun .text{ color:#444; font-weight: bold;}
	.ban_ip{ cursor: pointer; }
	.cloud, .cloud b{
		color:#a9a9a9;
	}
	.mark_b{ margin: 0 10px 10px 0; float: left; }
	.cloud .mark_b{
		display:inline-block;
		width:24px; height:24px;
		background-image:url(/static/static/img/cloud1.png);
		background-size: 100%;
	}
	.sun .mark_b{
		display:inline-block;
		width:24px; height:24px;
		background-image:url(/static/static/img/sun1.png);
		background-size: 100%;
	}
    .bans{
	    border: 1px solid #d3d3d3;
	    background-color: white;
	    width: 150px;
	    margin: 5px;
	    padding: 5px;
    }
    .links{
	    border: 1px solid #d3d3d3;
	    background-color: white;
	    width: 520px;
	    margin: 5px;
	    padding: 5px;
    }
</style>
<script type="text/javascript">
onready(function() {
{% if env.user.is_admin %}

		function del_link() {
            var that = $(this);
            var link = $(this).attr('link');
            $.ajax({
                type:"POST", dataType:"json", url:'/chat',
                data:{ action:'del_link', link:link},
                success:function (data) {
                    if (data['result'] == 'ok') {
                        that.parent().remove();
                    }
                }
            });
		}

        $('.chat').on('click', '.hide_mess', hide_mess);
		$('.del_links').click(del_link);

		$('.get_link').click(function(){
			var mess = prompt('Напишите пометку к ссылке');

			$.ajax({
				type:"POST", dataType:"json", url:'/chat',
				data:{ action:'get_link', mess:mess },
				success:function (data) {
					if (data['result'] == 'ok') {
						$('.ready_link').html('<input type="text" value="'+data.link+'"/>');
						var row = $('<div class="links "><span link="'+data.id+'" style="float:right;" class="del_links btn"><i class="icon-remove"></i>Удалить</span>'+data.mess +' '+data.id+' (до: '+data.end_time+')</div>')
						row.find('.del_links').click(del_link).button();
					    $('.buttons_chat').append(row);
					//	alert(data.link);
					}
				}
			});
		});
		$('.clear_ban').click(function(){
			$.ajax({
				type:"POST", dataType:"json", url:'/chat',
				data:{ action:'clear_ban'},
				success:function (data) {
					if (data['result'] == 'ok') {
					    $('.ip_ban').html('');
						alert('ip разбанены');
					}
				}
			});
		});
	{% endif %}
	var t;
	update_chat();
	$('.chat').click(function (e) {
		var target  = $(e.target);
		if (target.is('.mark_b'	)) {
			var mess_id = target.closest('[mess_id]').attr('mess_id');
			mark_mess(mess_id);
		};
		if (target.is('.ban_ip'	)) {
			var mess_id = target.closest('[mess_id]').attr('mess_id');
			ban_ip(mess_id);
		};
	});
	$('.refresh_chat').click(function (e) {
		if(t) clearTimeout(t);
		update_chat();
	});
	function hide_mess(){
        var mess = $(this).closest('[mess_id]');
        var mess_id = mess.attr('mess_id');
		$.ajax({
			type:"POST", dataType:"json", url:'/chat',
			data:{ key:'{{ key }}', action:'hide_mess', mess_id:mess_id},
			success:function (data) {
				if (data.result == 'ok') {
					mess.remove();
				}
			}
		});
	}
    function ban_ip(mess_id){
		$.ajax({
			type:"POST", dataType:"json", url:'/chat',
			data:{ key:'{{ key }}', action:'ban_ip', mess_id:mess_id},
			success:function (data) {
				if (data['result'] == 'ok') {
					$('.ip_ban').append('<div class="bans">'+data.ip+'</div>');
					alert('ip забанен');
{#					$('.chat [mess_id="'+mess_id+'"]').addClass('banned');#}
				}
			}
		});
	}
	function mark_mess(mess_id){
		$.ajax({
			type:"POST", dataType:"json", url:'/chat',
			data:{ key:'{{ key }}', action:'mark', mess_id:mess_id},
			success:function (data) {
				if (data['result'] == 'ok') {
					$('.chat [mess_id="'+mess_id+'"]').removeClass('cloud sun').addClass(data['mark']);
				}
			}
		});
	}

	function update_chat(){
		$.ajax({
			type:"POST", dataType:"json", url:'/chat',
			data:{ key:'{{ key }}', action:'update'},
			success:function (data) {
				if (data['result'] == 'ok') {
					$('.chat').html(data.chat);
				}else if(data.result == 'clear'){
					$('.chat').html('Чат завершен.');
				}
			}
		});
		t = setTimeout(update_chat, 10000);
	}
});
</script>

{% endblock %}