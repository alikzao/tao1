<div style="float:right;"><div class="save btn btn-primary">Сохранить</div></div>
<div class="switch_div" style="margin-bottom: 8px;">
	<div class="btn btn-primary a1" style=""> Главная страница   </div>
	<div class="btn btn-primary a2" > Страница метериала </div>
</div>

<div class="conf_t">
	<div class="main_page">
		<div id="he bor">
			<div class="col_h ">Верхняя прокрутка</div>
			<div slot="mp_0_1" class=" bor" style=" "></div>
		</div>
		<div class="main_col">

			<div class="col1 col_b bor1" style=" position:relative; width: 230px; display:inline-block;" >
				<div class="col_h ">Важно</div>
				<div slot="mp_1_1" class=" bor" ></div>
				<div class="col_h ">Интересно</div>
				<div slot="mp_1_2" class=" bor" ></div>
				<div class="col_h ">Новости</div>
				<div slot="mp_1_4" class=" bor" ></div>
				<div class="col_h ">Русская энциклопедия</div>
				<div slot="mp_1_3" class=" bor" ></div>
			</div>

			<div class="col2 bor1" style=" position:relative; width: 465px; display:inline-block;">
				<div class="col_h">Тема дня</div>
				<div slot="mp_2_0" class="bor" ></div>

				<div style="margin-top: 10px;"class="">
					<div class='' style="position:relative; width: 230px; min-height:200px; display:inline-block; vertical-align: top;">
						<div class="col_h ">Топ</div>
						<div slot="mp_2_1" class='bor col_b'></div>
					</div>
					<div class='' style="position:relative; width: 230px; min-height:200px;  display:inline-block; vertical-align: top;">
						<div class="col_h ">Дискусионное</div>
						<div slot="mp_3_1" class='bor col_b'></div>
					</div>
				</div>
				<div style="margin-top: 10px;"class="">
					<div class='' style="position:relative; width: 230px; min-height:200px; display:inline-block; vertical-align: top;">
						<div class="col_h ">Читаемое</div>
						<div slot="mp_2_2" class='bor col_b'></div>
					</div>
					<div class='' style="position:relative; width: 230px; min-height:200px;  display:inline-block; vertical-align: top;">
						<div class="col_h ">Авторы</div>
						<div slot="mp_3_2" class='bor col_b'></div>
					</div>
				</div>
			</div>

			<div class="col3 col_b bor1" style=" position:relative; width: 230px; ">
				<div class="blue col_h"> АРИ Радио</div>
				<div slot="mp_4_1" class="bor" ></div>
				<div class="blue col_h"> Голосование</div>
				<div slot="mp_4_2" class="bor" ></div>
				<div class="blue col_h"> Московская студия</div>
				<div slot="mp_4_3" class="bor" ></div>
			</div>

			<div class="col4 col_b bor1"style=" width: 230px; ">
				<div class="pink col_h">Горячее</div>
				<div slot="mp_5_1" class="bor" ></div>
				<div class="pink col_h">Баннеры</div>
				<div slot="mp_5_2" class="bor" ></div>
				<div class="pink col_h">Кругозор</div>
				<div slot="mp_5_3" class="bor" style=""></div>
			</div>

		</div>
	</div>

	<div class="sing_page">
		<div id="hebor"> <div class="topbg"></div> </div>
		<div class="main_col">

			<div class="col1 col_b bor1" style=" position:relative; width: 230px; display:inline-block;" >
				<div class="green col_h ">Важно</div>
				<div slot="sp_1_1" class=" bor"></div>
				<div class="green col_h ">Интересно</div>
				<div slot="sp_1_2" class=" bor"></div>
			</div>

			<div class="col2 bor1" style=" position:relative; width: 465px; display:inline-block;">
				<div class="lightblue col_h">Страница с материалом</div>
				<div  class="lightblue bor" style=" "></div>
			</div>

			<div class="col4 col_b bor1"style=" width: 230px; ">
				<div class="col_h">АРИ Радио</div>
				<div slot="sp_4_1" class="bor" style=""></div>
				<div class="pink col_h">Банеры</div>
				<div slot="sp_4_2" class="bor" style=""></div>

			</div>

		</div>
	</div>

</div>



{#{{ conf }}#}
<script type="text/javascript">
;$(function(){
	$('.a1').click(function(){

		$('.conf_t > div').css('height','0');
		$('.main_page').css('height','auto');
	});
	$('.a2').click(function(){
		$('.conf_t > div').css('height','0');
		$('.sing_page').css('height','auto');
	});
	$('.a1').click();


	$('.save').click(function(){
		var res = {}
		$('[slot]').each(function () {
			var n = $(this).attr('slot');
			var rs = {}
			$(':input', this).each(function() {
				var n = $(this).attr('name');
				if( !n) return ;
				var v = '';
				if($(this).is(':checkbox')) {
					v = $(this).is(':checked') ? 'true' : 'false';
				} else {
					v = $(this).val()
				}
//				if (!v) v = [];
				rs[n] = v;
			})
			res[n] = rs;
		});
		$.ajax({
			type: "POST",dataType: "json", url: '/conf_templ',
			data: { data:JSON.stringify(res) },
			success: function(data){
				if (data.result == 'ok'){ alert( 'Сохранено'); }
			}
		});
	});
//	<div class='clean_i'></div>   kind - разновидность
//	$('.clean_i').click(function(){ $(this).parent().find('input').val(''); });
	var t = "<div style='margin:10px;' class='sett'>" +
				"<select name='kind'>" +
					"<option value='obj'>Материалы</option>" +
					"<option value='banner'>Банеры</option>" +
					"<option value='radio'>Радио</option>" +
					"<option value='wiki'>Вики</option>" +
					"<option value='poll'>Голосование</option>" +
					"<option value='news'>Новости</option>" +
					"<option value='users'>Авторы</option>" +
				"</select>" +
				"<div>Шаблон:</div><select style='max-width:95%;'name='templ'>" +
					"<option value='slot1'>slot1-стандартный</option>" +
					"<option value='poll'>poll - голосование</option>" +
					"<option value='slot_n'>slot_n-стандартный новостной</option>" +
					"<option value='slot_m'>slot_m-стандартный мини</option>" +
					"<option value='slot_m2'>slot_m2-Улучшеный мини</option>" +
					"<option value='slot_mm'>slot_mm-стандартный мини мини</option>" +
					"<option value='slot_mm2'>slot_mm2-стандартный мини мини2</option>" +
					"<option value='slot_car'>slot_car-прокрутка</option>" +
					"<option value='slot_r'>slot_r-радио</option>" +
					"<option value='slot_r_mm'>slot_r_mm-радио мини</option>" +
					"<option value='slot_b'>slot_b-банеры</option>" +
					"<option value='slot_t'>slot_t-кругозор</option>" +
					"<option value='slot_l'>slot_l-Списком</option>" +
					"<option value='slot_tab1'>slot_tab1-Закладки</option>" +
					"<option value='slot_tab2'>slot_tab2-Закладки2</option>" +
					"<option value='slot_u'>slot_u-Пользователи</option>" +
				"</select>" +
				"<div>" +
					"<div>По тегам:</div><input type='text' name ='tag'/>" +
					"<div>По пользователю:</div><select name ='user' multiple='true' style='max-width:95%;'></select>" +
					"<div>По группам:</div><select name='by_group' ></select>" +
					"<div>По ролям:</div><select name='role' ></select>" +
					"<div>Сортировка:</div><select name='sort'>" +
                        "<option value='date'>По дате</option>" +
                        "<option value='rate'>По рейтингу</option>" +
                        "<option value='views'>По просмотрам</option>" +
                        "<option value='comm'>По коментариям</option>" +
			        "</select>" +
					"<div>По рейтингу:</div><input type='text' name ='vote' value='0'/>" +
					"<div>Лимит:</div><input type='text' name ='limit' value='5'/>" +
					"<div>Уникальный автор:</div><input type='checkbox' name ='last_art' />" +
					"<div>Срок показа(дней):</div><input type='text' name ='term' />" +
					"</div>" +
				"</div>" +
			"<style> .sett input, .sett select{margin-bottom:5px;}</style>";

	var conf = {{ jd(conf) }};
	$('[name="by_group"]').chosen();
	dao.log('start');
	$('[slot]').each(function(){
		$(this).html(_.template(t));
		var slot = conf[$(this).attr('slot')];
		if(!slot) return;
		dao.log( $(this).attr('slot') );
		$(':input', this).each(function () {
			// получаем имя инпута
			dao.log('f');
			var i = $(this).attr('name');
			dao.log(i);
			if (!i) return;

			if (slot && slot[i]) {
				dao.log('true');

				// вставляем значения полученые с сервера в инпуты
				if (i == 'kind') $(this).val(slot[i]);
				if (i == 'templ') $(this).val(slot[i]);
				if (i == 'sort') $(this).val(slot[i]);
				if (i == 'last_art') $(this).attr('checked', slot[i] == 'true');
				if (i == 'user') dao.get_list_doc_($(this), 'des:users', slot[i], true);
				if (i == 'by_group') dao.get_list_branch_( $(this), 'des:users', slot[i], false);
				if (i == 'role') dao.get_list_doc_( $(this), 'des:role', slot[i], false);

				else $(this).val(slot[i] );
			} else {
				dao.log('false');
				if (i == 'user') dao.get_list_doc_($(this), 'des:users', [], true);
				if (i == 'by_group')dao.get_list_branch_( $(this), 'des:users', '', false);
				if (i == 'role')dao.get_list_doc_( $(this), 'des:role', '', false);
			}
{#			if (i == 'templ') $(this).chosen();#}
{#			if (i == 'kind') $(this).chosen();#}
		})
		dao.log('slot ' + $(this).attr('slot'));
		dao.log(slot['by_group']);
	});


});

</script>
	













