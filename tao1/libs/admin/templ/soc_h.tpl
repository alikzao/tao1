<div class="navbar navbar-fixed-top navbar-inverse" >
    <div class="navbar-inner" >
        <div class="container" style="">
            <ul class="nav navbar-nav pull-right">
	            <li><a class="pull-left brand" target="_blank" href="/" title=""><h1 id="" style="font-size: 20px">{{site_name}}</h1></a></li>

                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">{{ lang }} <b class="caret"></b>{{lang }}</a>
                    <ul class="dropdown-menu">
                        <li lang_id="ru"><a href="#">рус</a></li>
        			    <li lang_id="en"><a href="#">en</a></li>
                   </ul>
               </li>
                <li><a href="/news/3726395ef" ><i class="fa fa-question-sign"></i></a></li>
                <li><a href="/mongodb" target=_blank>{{ ct( 'Base') }}</a></li>
                <li><a class="close_all_tabs" title="Очистить все закладки" onclick="page_view.close_all_tabs();return false;"href="#">{{ ct( 'Clean') }}</a></li>
                <li><a href="/logout">{{ ct( 'logaut') }}</a></li>
                {% if is_logged   %}
                <li class="profile menu" >
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown"> <i class="fa fa-user"></i> <b class="caret"></b></a>
                        <ul class="dropdown-menu">
                        {% if is_logged and is_admin%}
                            <li class="ссh"><a href="/bug">Баг трекер</a></li>
                            <li class="ссh"><a href="/chat/admin">Смотерть чат</a></li>
                            <li class="edit_radio"><a href="#">Редактировать радио </a></li>
                            <li><a target="_blank" style="padding-right: 20px;" href="/conf">{{ct('admynka') }} </a></li>
                            <li class="import_radio"><a target="" style="padding-right: 20px;" href="#">Импорт радио</a></li>
                        {% endif  %}
                        <li><a  href="/logout">{{ ct('logaut') }}</a></li>
                       </ul>
                   </li>
                </li>
                {% else %}
                <li><div class="title">Войти</div>
                    <ul> <li><a href="/account/signup">Регистрация</a></li> </ul>
                </li>
                {% endif %}
            </ul>
            <ul  class="nav navbar-nav pull-right">
	            <li class="divider-vertical"></li>
                <li class="placeholder"></li>
            </ul>
        </div>
    </div>
</div>
{#</div>#}
<script type="text/javascript">
	$(function(){
		var dialog = $("<div title='Редактирование Радио'></div>");
		var link = $('<input type="text" />').appendTo(dialog);
		var text = $('<textarea style="width:400px; height:300px;" class="t_rich_edit"/>').appendTo(dialog);
		dialog.dialog({
			bgiframe: true, autoOpen: false, height: 500, width: 420, modal: true,
			buttons: {
				'Ok': function(){
					var dialog = $(this);
					$.ajax({
						type:"POST", dataType:"json", url:'/edit_radio/save',
						data:{ link:link.val(), text:text.val()},
						success:function (data) {
							if (data.result == 'ok') {
//								alert('Успешно отредактировано');
								dialog.dialog('close');
								return false;
							}
						}
					});
				},
				'Отмена': function(){ $(this).dialog('close'); }
			}
//			close: function(){ dialog.remove(); delete dialog; }
		});

		$('.repost_fb').click(function(){
			var aaa ;
			$.ajax({
				type:"POST", dataType:"json", url:"/repost/fb",
				data:{ },
				beforeSend:function(){ aaa = dao.bef();},
				success:function (data) {
					if (data.result == 'ok') {
						alert('Репост с фейсбука выполнен успешно');
					}
					aaa.click();
				}
			});
		});
		$('.edit_radio').click(function(){
			$.ajax({
				type:"POST", dataType:"json", url:'/edit_radio/read',
				data:{ },
				success:function (data) {
					if (data.result == 'ok') {
						link.val(data.link);
						text.val(data.text);
						dialog.dialog('open');
					}
				}
			});
		});

		$('.import_radio a').click(function(){
			var aaa ;
			$.ajax({
				type:"POST", dataType:"json", url:'/import_radio',
				data:{ },
				beforeSend:function(){ aaa = dao.bef();},
				success:function (data) {
					if (data.result == 'ok') {
						alert('Успешно импортировано');
						window.location.reload();
						aaa.click();
						return false;
					}
				}
			});

		});
	});
</script>