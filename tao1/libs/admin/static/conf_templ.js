function init_conf_templ(conf, conf_name){

    $('.switch_template').on('click', '.btn', function(){
        var t_name = $(this).text();
        $('.templates').find('> *').hide()
        $('.templates').find('> [t_name="'+t_name+'"]').show()
        $(this).parent().find('*').removeClass('disabled');
        $(this).addClass('disabled');
        return false;
    });
    $('.templates').find('> *').hide().eq(0).show();

    $('body').on('click', '.switch_div .btn', function(){
        var a_name = $(this).attr('target');
        $(this).closest('[t_name]').find('[a_name]').hide();
        $(this).closest('[t_name]').find('[a_name="'+a_name+'"]').show()
        $(this).parent().find('*').removeClass('disabled');
        $(this).addClass('disabled');
        return false;
    });
    $('[t_name]').each(function(){ $(this).find('[a_name]').hide().eq(0).show(); });

    $('body').on('click', '.conf_templ_dialog', function(e){
        var slot_name = $(this).closest('[slot]').attr('slot');
        var conf_name = $(this).closest('[t_name]').attr('t_name');
        get_data_dialog( slot_name, conf_name);
//        e.stopPropagation();
        e.stopImmediatePropagation();
        return false;
    });


    var t = "<div class='<%= color%> col_h '>" +
        "<div class='conf_templ_dialog btn btn-small btn-info' style='margin-right:5px;'><i class='icon-white icon-star'></i></div><%= name %></div>" +
        "<div style='margin:10px;' class='single_slot sett'>" +

        "<div><div rel='popover' data-trigger='hover' title='Название' class='title'>Название: </div><div class='val'><%= slot_name %></div></div>" +

        "<div><div data-content='Справочник из которого будут братся данные'                    data-placement='right' rel='popover' data-trigger='hover' title='Выбор справочника' class='title'>Справочник: </div><div class='val'><%= kind_title %></div></div>" +
        "<div><div data-content='Шблн который будет рисовать даные этой ячейки'                 data-placement='right' rel='popover' data-trigger='hover' title='Выбор шаблона' class='title'>Шаблон: </div><div class='val'><%= templ %></div></div>" +
        "<div><div data-content='Тэги по которым будут фильтроватся даные в ячейке'             data-placement='right' rel='popover' data-trigger='hover' title='Тэги' class='title'>Теги: </div><div class='val'><%= tag %></div></div>" +
        "<div><div data-content='Пользователи по которым будет дополнительно фильтроватся даные' data-placement='right' rel='popover' data-trigger='hover' title='По полльзователям' class='title'>Авторы: </div><div class='val'><%= user_title %></div></div>" +
        "<div><div data-content='Группы по которым будут фильтроватся данные'                   data-placement='right' rel='popover' data-trigger='hover' title='По группам' class='title'>Группы: </div><div class='val'><%= by_group %></div></div>" +
        "<div><div data-content='Роли пользователей по которым отфильтруется ячейка'            data-placement='right' rel='popover' data-trigger='hover' title='По ролям' class='title'>Роли: </div><div class='val'><%= role %></div></div>" +
        "<div><div data-content='По чем отсортируются даные в нужном порядке'                   data-placement='right' rel='popover' data-trigger='hover' title='Сортировка' class='title'>Сортировка: </div><div class='val'><%= sort %></div></div>" +
        "<div><div data-content='Минимальный рейтинг для показа в данной ячейке'                data-placement='right' rel='popover' data-trigger='hover' title='Рейтинг' class='title'>Рейтинг: </div><div class='val'><%= vote %></div></div>" +
        "<div><div data-content='Кол-во(лимит) звписей в ячейке'                                data-placement='right' rel='popover' data-trigger='hover' title='Лимит записей' class='title'>Лимит: </div><div class='val'><%= limit %></div></div>" +
        "<div><div data-content='Показывать только один раз каждого уникального автора или нет' data-placement='right' rel='popover' data-trigger='hover' title='Уник. автор в ячейке' class='title'>Уник. автор: </div><div class='val'><%= last_art %></div></div>" +
        "<div><div data-content='Срок дней показа'                                              data-placement='right' rel='popover' data-trigger='hover' title='Срок показа' class='title'>Срок показа: </div><div class='val'><%= term %> дней</div></div>" +
        "</div>" +
        "<style>"+
        ".single_slot .title{ display:inline-block; width: 93px; color:#48f; }"+
        ".single_slot > div{ margin-top:2px; padding:2px; border:1px solid #ddd; border-radius:3px;}"+
        ".single_slot .val{ display:inline; width: 150px; font-weight: normal; }"+
        "</style>" ;
//    <a href="#" class="www" data-content="Привет" data-placement='right' rel="popover" data-trigger="hover" title="first tooltip">hover over me</a>

//    var conf = {{ env.jd(conf) }};
    $('[name="by_group"]').chosen();
    dao.log('start');
    $('[t_name="'+conf_name+'"] [slot]').each(function(){
        var slot = conf[$(this).attr('slot')];
//        if(!slot) return;
        draw_slot.call(this, slot ? slot : {}, $(this).attr('slot'));
    });

    function draw_slot(slot, slot_name){
        log(slot);
        $(this).html(_.template(t, {slot_name:slot_name, kind:slot['kind'], templ:slot['templ'], tag:slot['tag'], user:slot['user'], by_group:slot['by_group'],
            role:slot['role'], sort:slot['sort_title'], limit:slot['limit'], vote:slot['vote'], term:slot['term'],
            last_art :slot['last_art_title'], color2:slot['color2'],color:slot['color'], name:slot['name'], kind_title:slot['kind_title'], user_title:slot['user_title'] }));
    //    		$(this).html(_.template(t, {name:slot['name'], templ:slot['templ'], tag:slot['tags'], user:slot['user']}));
        $(this).find('[rel="popover"]').popover();
//        $('.single_slot [rel="popover"]').popover();
    }

    function make_slot(slot){
        if(!slot) return;
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
    //        			if (i == 'templ') $(this).chosen();
    //        			if (i == 'kind') $(this).chosen();
        })
        $('[name="color"]', this).find('option').each(function(){
            $(this).html('<div class="col_h '+$(this).attr('value')+'">'+$(this).attr('value')+'</div>');
        });
        $('[name="color2"]', this).find('option').each(function(){
            $(this).html('<div class="col_h '+$(this).attr('value')+'">'+$(this).attr('value')+'</div>');
        });

    }

    var t_dialog = "<div style='margin:10px;' class='sett'>" +
        "<div>Название:</div><input class='form-control input-sm' type='text' name ='name' />" +
        "<select class='form-control input-sm' name='color'>" +
        "<option class='col_h blue' value='blue'></option>" +
        "<option class='col_h blue1' value='blue1'></option>" +
        "<option class='col_h blue2' value='blue2'></option>" +
        "<option class='col_h SteelBlue' value='SteelBlue'></option>" +
        "<option class='col_h Chocolate' value='Chocolate'></option>" +
        "<option class='col_h IndianRed' value='IndianRed'></option>" +
        "<option class='col_h blue10' value='blue10'></option>" +
        "<option class='col_h Purple' value='Purple'></option>" +
        "<option class='col_h blue3' value='blue3'></option>" +
        "<option class='col_h blue4' value='blue4'></option>" +
        "<option class='col_h red' value='red'></option>" +
        "<option class='col_h red2' value='red2'></option>" +
        "<option class='col_h red3' value='red3'></option>" +
        "<option class='col_h grey' value='grey'></option>" +
        "<option class='col_h black' value='black'></option>" +
        "<option class='col_h green' value='green'></option>" +
        "<option class='col_h green2' value='green2'></option>" +
        "<option class='col_h orange' value='orange'></option>" +
        "<option class='col_h yellow' value='yellow'></option>" +
        "<option class='col_h violet' value='violet'></option>" +
        "<option class='col_h pink' value='pink'></option>" +
        "</select>"+
        "<select class='form-control input-sm' name='color2'>" +
        "<option class='col_h blue' value='blue'></option>" +
        "<option class='col_h blue1' value='blue1'></option>" +
        "<option class='col_h blue2' value='blue2'></option>" +
        "<option class='col_h SteelBlue' value='SteelBlue'></option>" +
        "<option class='col_h Chocolate' value='Chocolate'></option>" +
        "<option class='col_h IndianRed' value='IndianRed'></option>" +
        "<option class='col_h Purple' value='Purple'></option>" +
        "<option class='col_h blue3' value='blue3'></option>" +
        "<option class='col_h blue4' value='blue4'></option>" +
        "<option class='col_h red' value='red'></option>" +
        "<option class='col_h red2' value='red2'></option>" +
        "<option class='col_h red3' value='red3'></option>" +
        "<option class='col_h grey' value='grey'></option>" +
        "<option class='col_h black' value='black'></option>" +
        "<option class='col_h green' value='green'></option>" +
        "<option class='col_h green2' value='green2'></option>" +
        "<option class='col_h orange' value='orange'></option>" +
        "<option class='col_h yellow' value='yellow'></option>" +
        "<option class='col_h violet' value='violet'></option>" +
        "<option class='col_h pink' value='pink'></option>" +
        "</select>" +
        "<select class='form-control input-sm' name='kind'>" +
        "<option value='obj'>Материалы</option>" +
        "<option value='banner'>Банеры</option>" +
        "<option value='header'>Картинки главной</option>" +
        "<option value='clips'>Клипы</option>" +
        "<option value='radio'>Радио</option>" +
        "<option value='ware'>Товары</option>" +
        "<option value='wiki'>Вики</option>" +
        "<option value='poll'>Голосование</option>" +
        "<option value='news'>Новости</option>" +
        "<option value='users'>Авторы</option>" +
        "<option value='maps'>Карты</option>" +
        "<option value='comments'>Комментарии</option>" +
        "</select>" +
        "<div>Шаблон:</div>" +
        "<select class='form-control input-sm' style='max-width:95%;'name='templ'>" +
        "<option value='slot_header'>header-Шапка</option>" +
        "<option value='slot_b1'>slot_b1-стандартный блог</option>" +
        "<option value='slot_b2'>slot_b2-уменьшеный блог</option>" +
        "<option value='slot_b3'>slot_b3-маленький блог</option>" +
        "<option value='slot_c1'>slot_c1-маленький блог</option>" +
        "<option value='slot_c2'>slot_c2-маленький блог</option>" +
        "<option value='slot_n1'>slot_n1-стандартный новостной</option>" +
        "<option value='slot_n2'>slot_n2-уменьшеный новостной</option>" +
        "<option value='slot_n3'>slot_n3-маленький новостной</option>" +
        "<option value='slot_r1'>slot_r1-стандартный радио</option>" +
        "<option value='slot_r2'>slot_r2-уменьшеный радио</option>" +
        "<option value='slot_r3'>slot_r3-маленький радио</option>" +
        "<option value='slot_w1'>slot_w1-стандартный вики</option>" +
        "<option value='slot_ww1'>slot_ww1-стандартный вики</option>" +
        "<option value='slot_w2'>slot_w2-уменьшеный вики</option>" +
        "<option value='slot_m1'>slot_m1-стандартный карты</option>" +
        "<option value='slot_m2'>slot_m2-уменьшеный карты</option>" +
        "<option value='slot_galery'>slot_galery-галерея</option>" +
        "<option value='slot_news_maps'>slot_news_maps-новости для карт</option>" +
        "<option value='slot_row'>slot_row1-стандартный строка</option>" +
        "<option value='slot_row'>slot_row2-уменьшеный строка</option>" +
        "<option value='slot_row'>slot_row3-маленький строка</option>" +
        "<option value='slot1'>slot1-старый стандартный</option>" +
        "<option value='slot_n'>slot_n-старый новостной</option>" +
        "<option value='slot_main'>slot_main- Основной слот</option>" +
        "<option value='slot_main1'>slot_main1- Основной слот 2</option>" +
        "<option value='slot_main2'>slot_main1- Основной слот 3</option>" +
        "<option value='poll'>poll - голосование</option>" +
        "<option value='slot_m'>slot_m-стандартный мини</option>" +
        "<option value='slot_mini'>slot_mini-улучшеный мини</option>" +
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
        "<option value='slot_m_mm'>slot_m_mm-Карты-мини</option>" +
        "<option value='slot_wr'>slot_wr-товары на главной</option>" +
        "<option value='slot_wr2'>slot_wr2-товары на главной</option>" +
        "<option value='slot_wr3'>slot_wr3-товары на главной</option>" +
        "<option value='slot_wr4'>slot_wr4-товары на главной</option>" +
        "<option value='slot_map_a'>slot_map_a-Карты-мини</option>" +
        "<option value='slot_line'>slot_line-Блоги линией</option>" +
        "<option value='slot_line_comm'>slot_line_comm-Последние комментарии</option>" +
        "</select>" +
        "<div>" +
        "<div>По тегам:</div><input class='form-control input-sm' type='text' name ='tag'/>" +
        "<div>По пользователю:</div><select class='form-control input-sm' name ='user' multiple='true' style='max-width:95%; min-height:20px;'></select>" +
        "<div>По группам:</div><select class='form-control input-sm' name='by_group' ></select>" +
        "<div>По ролям:</div><select class='form-control input-sm' name='role' ></select>" +
        "<div>Сортировка:</div>" +
        "<select class='form-control input-sm' name='sort'>" +
        "<option value='none'>Без сортировки</option>" +
        "<option value='date'>По дате</option>" +
        "<option value='rate'>По рейтингу</option>" +
        "<option value='views'>По просмотрам</option>" +
        "<option value='comm'>По коментариям</option>" +
        "</select>" +
        "<div>По рейтингу:</div><input class='form-control input-sm' type='text' name ='vote' value='0'/>" +
        "<div>Лимит:</div><input class='form-control input-sm' type='text' name ='limit' value='5'/>" +
        "<div>Уникальный автор:</div><input class='form-control input-sm' type='checkbox' name ='last_art' />" +
        "<div>Срок показа(дней):</div><input class='form-control input-sm' type='text' name ='term' />" +
        "</div>" +
        "</div>" +
        "<style> .sett input, .sett select{margin-bottom:5px;}</style>";

    function get_data_dialog(slot_name, conf_name){
        $.ajax({
            type:"POST", dataType:"json", url:'/get_data_slot',
            data:{ slot_name:slot_name, conf_name: conf_name},
            success:function (data) {
                var dialog = $(

                    '<div class="modal">'+
                        '<div class="modal-dialog">'+
                            '<div class="modal-content">'+
                                '<div class="modal-header">'+
                                '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Edit template</h3></div>' +
                                '<div class="modal-body" ></div>' +
                                '<div class="modal-footer"><div class="btn-group">'+
                            '<span class="btn" data-dismiss="modal">Close</span>'+
                            '<span class="save btn btn-primary" data-dismiss="modal">Ok</span>'+
                                '</div>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>'

                ).appendTo('body');
                dialog.modal();
                var modal_body = dialog.find('.modal-body');
                modal_body.html(_.template(t_dialog ));
                make_slot.call(modal_body[0], data);
                dialog.find('.save').on('click', function () {
                    var rs = {};
                    $(':input', dialog).each(function() {
                        var n = $(this).attr('name');
                        if( !n) return ;
                        var v = '';
                        if($(this).is(':checkbox')) v = $(this).is(':checked') ? 'true' : 'false';
                        else v = $(this).val()
                        rs[n] = v;
                    });
                    $.ajax({
                        type:"POST", dataType:"json", url:'/save_slot',
                        data:{ slot_name:slot_name, conf_name:conf_name, data:JSON.stringify(rs)},
                        success:function (data) {
                            if (data.result == 'ok') {
                                draw_slot.call($('[t_name="'+conf_name+'"] [slot="'+slot_name+'"]')[0], data.slot);
                            }
                        }
                    });
                })
            }
        });
    }
}










