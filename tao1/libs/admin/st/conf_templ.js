function init_conf_templ(conf, conf_name) {

    $('.switch_template').on('click', '.btn', function() {
        var t_name = $(this).text();
        $('.templates').find('> *').hide()
        $('.templates').find('> [t_name="' + t_name + '"]').show()
        $(this).parent().find('*').removeClass('disabled');
        $(this).addClass('disabled');
        return false;
    });
    $('.templates').find('> *').hide().eq(0).show();

    $('body').on('click', '.switch_div .btn', function() {
        var a_name = $(this).attr('target');
        $(this).closest('[t_name]').find('[a_name]').hide();
        $(this).closest('[t_name]').find('[a_name="' + a_name + '"]').show()
        $(this).parent().find('*').removeClass('disabled');
        $(this).addClass('disabled');
        return false;
    });
    $('[t_name]').each(function() {
        $(this).find('[a_name]').hide().eq(0).show();
    });

    $('body').on('click', '.conf_templ_dialog', function(e) {
        var slot_name = $(this).closest('[slot]').attr('slot');
        var conf_name = $(this).closest('[t_name]').attr('t_name');
        get_data_dialog(slot_name, conf_name);
        //        e.stopPropagation();
        e.stopImmediatePropagation();
        return false;
    });


    var t = "<div class='<%= color%> col_h '>" +
        "<div class='conf_templ_dialog btn btn-small btn-info' style='margin-right:5px;'><i class='icon-white icon-star'></i></div><%= name %></div>" +
        "<div style='margin:10px;' class='single_slot sett'>" +

        "<div><div rel='popover' data-trigger='hover' title='Name' class='title'>Name: </div><div class='val'><%= slot_name %></div></div>" +

        "<div><div data-content='Reference from which data will be taken'                    data-placement='right' rel='popover' data-trigger='hover' title='Reference selection' class='title'>Reference: </div><div class='val'><%= kind_title %></div></div>" +
        "<div><div data-content='Template that will render this cell data'                 data-placement='right' rel='popover' data-trigger='hover' title='Template selection' class='title'>Template: </div><div class='val'><%= templ %></div></div>" +
        "<div><div data-content='Tags used to filter data in this cell'             data-placement='right' rel='popover' data-trigger='hover' title='Tags' class='title'>Tags: </div><div class='val'><%= tag %></div></div>" +
        "<div><div data-content='Users for additional data filtering' data-placement='right' rel='popover' data-trigger='hover' title='By users' class='title'>Authors: </div><div class='val'><%= user_title %></div></div>" +
        "<div><div data-content='Groups used to filter data'                   data-placement='right' rel='popover' data-trigger='hover' title='By groups' class='title'>Groups: </div><div class='val'><%= by_group %></div></div>" +
        "<div><div data-content='User roles used to filter this cell'            data-placement='right' rel='popover' data-trigger='hover' title='By roles' class='title'>Roles: </div><div class='val'><%= role %></div></div>" +
        "<div><div data-content='How data is sorted in the required order'                   data-placement='right' rel='popover' data-trigger='hover' title='Sorting' class='title'>Sorting: </div><div class='val'><%= sort %></div></div>" +
        "<div><div data-content='Minimum rating for showing in this cell'                data-placement='right' rel='popover' data-trigger='hover' title='Rating' class='title'>Rating: </div><div class='val'><%= vote %></div></div>" +
        "<div><div data-content='Number (limit) of records in the cell'                                data-placement='right' rel='popover' data-trigger='hover' title='Record limit' class='title'>Limit: </div><div class='val'><%= limit %></div></div>" +
        "<div><div data-content='Show each unique author only once or not' data-placement='right' rel='popover' data-trigger='hover' title='Unique author in cell' class='title'>Unique author: </div><div class='val'><%= last_art %></div></div>" +
        "<div><div data-content='Display period in days'                                              data-placement='right' rel='popover' data-trigger='hover' title='Display period' class='title'>Display period: </div><div class='val'><%= term %> days</div></div>" +
        "</div>" +
        "<style>" +
        ".single_slot .title{ display:inline-block; width: 93px; color:#48f; }" +
        ".single_slot > div{ margin-top:2px; padding:2px; border:1px solid #ddd; border-radius:3px;}" +
        ".single_slot .val{ display:inline; width: 150px; font-weight: normal; }" +
        "</style>";
    $('[name="by_group"]').chosen();
    dao.log('start');
    $('[t_name="' + conf_name + '"] [slot]').each(function() {
        var slot = conf[$(this).attr('slot')];
        draw_slot.call(this, slot ? slot : {}, $(this).attr('slot'));
    });

    function draw_slot(slot, slot_name) {
        log(slot);
        $(this).html(_.template(t, {
            slot_name: slot_name,
            kind: slot['kind'],
            templ: slot['templ'],
            tag: slot['tag'],
            user: slot['user'],
            by_group: slot['by_group'],
            role: slot['role'],
            sort: slot['sort_title'],
            limit: slot['limit'],
            vote: slot['vote'],
            term: slot['term'],
            last_art: slot['last_art_title'],
            color2: slot['color2'],
            color: slot['color'],
            name: slot['name'],
            kind_title: slot['kind_title'],
            user_title: slot['user_title']
        }));
        $(this).find('[rel="popover"]').popover();
    }

    function make_slot(slot) {
        if (!slot) return;
        $(':input', this).each(function() {
            // Legacy comment translated from Russian.
            dao.log('f');
            var i = $(this).attr('name');
            dao.log(i);
            if (!i) return;

            if (slot && slot[i]) {
                dao.log('true');

                // Legacy comment translated from Russian.
                if (i == 'kind') $(this).val(slot[i]);
                if (i == 'templ') $(this).val(slot[i]);
                if (i == 'sort') $(this).val(slot[i]);
                if (i == 'last_art') $(this).attr('checked', slot[i] == 'true');
                if (i == 'user') dao.get_list_doc_($(this), 'des:users', slot[i], true);
                if (i == 'by_group') dao.get_list_branch_($(this), 'des:users', slot[i], false);
                if (i == 'role') dao.get_list_doc_($(this), 'des:role', slot[i], false);

                else $(this).val(slot[i]);
            } else {
                dao.log('false');
                if (i == 'user') dao.get_list_doc_($(this), 'des:users', [], true);
                if (i == 'by_group') dao.get_list_branch_($(this), 'des:users', '', false);
                if (i == 'role') dao.get_list_doc_($(this), 'des:role', '', false);
            }
        })
        $('[name="color"]', this).find('option').each(function() {
            $(this).html('<div class="col_h ' + $(this).attr('value') + '">' + $(this).attr('value') + '</div>');
        });
        $('[name="color2"]', this).find('option').each(function() {
            $(this).html('<div class="col_h ' + $(this).attr('value') + '">' + $(this).attr('value') + '</div>');
        });

    }

    var t_dialog = "<div style='margin:10px;' class='sett'>" +
        "<div>Name:</div><input class='form-control input-sm' type='text' name ='name' />" +
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
        "</select>" +
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
        "<option value='obj'>Materials</option>" +
        "<option value='banner'>Banners</option>" +
        "<option value='header'>Homepage images</option>" +
        "<option value='clips'>Clips</option>" +
        "<option value='radio'>Radio</option>" +
        "<option value='ware'>Products</option>" +
        "<option value='wiki'>Wiki</option>" +
        "<option value='poll'>Voting</option>" +
        "<option value='news'>News</option>" +
        "<option value='users'>Authors</option>" +
        "<option value='maps'>Maps</option>" +
        "<option value='comments'>Comments</option>" +
        "</select>" +
        "<div>Template:</div>" +
        "<select class='form-control input-sm' style='max-width:95%;'name='templ'>" +
        "<option value='slot_header'>header-Header</option>" +
        "<option value='slot_b1'>slot_b1-standard blog</option>" +
        "<option value='slot_b2'>slot_b2-compact blog</option>" +
        "<option value='slot_b3'>slot_b3-small blog</option>" +
        "<option value='slot_c1'>slot_c1-small blog</option>" +
        "<option value='slot_c2'>slot_c2-small blog</option>" +
        "<option value='slot_n1'>slot_n1-standard news</option>" +
        "<option value='slot_n2'>slot_n2-compact news</option>" +
        "<option value='slot_n3'>slot_n3-small news</option>" +
        "<option value='slot_r1'>slot_r1-standard radio</option>" +
        "<option value='slot_r2'>slot_r2-compact radio</option>" +
        "<option value='slot_r3'>slot_r3-small radio</option>" +
        "<option value='slot_w1'>slot_w1-standard wiki</option>" +
        "<option value='slot_ww1'>slot_ww1-standard wiki</option>" +
        "<option value='slot_w2'>slot_w2-compact wiki</option>" +
        "<option value='slot_m1'>slot_m1-standard maps</option>" +
        "<option value='slot_m2'>slot_m2-compact maps</option>" +
        "<option value='slot_galery'>slot_galery-gallery</option>" +
        "<option value='slot_news_maps'>slot_news_maps-news for maps</option>" +
        "<option value='slot_row'>slot_row1-standard row</option>" +
        "<option value='slot_row'>slot_row2-compact row</option>" +
        "<option value='slot_row'>slot_row3-small row</option>" +
        "<option value='slot1'>slot1-old standard</option>" +
        "<option value='slot_n'>slot_n-old news</option>" +
        "<option value='slot_main'>slot_main- Main slot</option>" +
        "<option value='slot_main1'>slot_main1- Main slot 2</option>" +
        "<option value='slot_main2'>slot_main1- Main slot 3</option>" +
        "<option value='poll'>poll - voting</option>" +
        "<option value='slot_m'>slot_m-standard mini</option>" +
        "<option value='slot_mini'>slot_mini-improved mini</option>" +
        "<option value='slot_mm'>slot_mm-standard mini mini</option>" +
        "<option value='slot_mm2'>slot_mm2-standard mini mini2</option>" +
        "<option value='slot_car'>slot_car-carousel</option>" +
        "<option value='slot_r'>slot_r-radio</option>" +
        "<option value='slot_r_mm'>slot_r_mm-radio mini</option>" +
        "<option value='slot_b'>slot_b-banners</option>" +
        "<option value='slot_t'>slot_t-panorama</option>" +
        "<option value='slot_l'>slot_l-List view</option>" +
        "<option value='slot_tab1'>slot_tab1-Tabs</option>" +
        "<option value='slot_tab2'>slot_tab2-Tabs2</option>" +
        "<option value='slot_u'>slot_u-Users</option>" +
        "<option value='slot_m_mm'>slot_m_mm-Maps-mini</option>" +
        "<option value='slot_wr'>slot_wr-products on homepage</option>" +
        "<option value='slot_wr2'>slot_wr2-products on homepage</option>" +
        "<option value='slot_wr3'>slot_wr3-products on homepage</option>" +
        "<option value='slot_wr4'>slot_wr4-products on homepage</option>" +
        "<option value='slot_map_a'>slot_map_a-Maps-mini</option>" +
        "<option value='slot_line'>slot_line-blogs line</option>" +
        "<option value='slot_line_comm'>slot_line_comm-latest comments</option>" +
        "</select>" +
        "<div>" +
        "<div>By tags:</div><input class='form-control input-sm' type='text' name ='tag'/>" +
        "<div>By user:</div><select class='form-control input-sm' name ='user' multiple='true' style='max-width:95%; min-height:20px;'></select>" +
        "<div>By groups:</div><select class='form-control input-sm' name='by_group' ></select>" +
        "<div>By roles:</div><select class='form-control input-sm' name='role' ></select>" +
        "<div>Sorting:</div>" +
        "<select class='form-control input-sm' name='sort'>" +
        "<option value='none'>No sorting</option>" +
        "<option value='date'>By date</option>" +
        "<option value='rate'>By rating</option>" +
        "<option value='views'>By views</option>" +
        "<option value='comm'>By comments</option>" +
        "</select>" +
        "<div>By rating:</div><input class='form-control input-sm' type='text' name ='vote' value='0'/>" +
        "<div>Limit:</div><input class='form-control input-sm' type='text' name ='limit' value='5'/>" +
        "<div>Unique author:</div><input class='form-control input-sm' type='checkbox' name ='last_art' />" +
        "<div>Display period(days):</div><input class='form-control input-sm' type='text' name ='term' />" +
        "</div>" +
        "</div>" +
        "<style> .sett input, .sett select{margin-bottom:5px;}</style>";

    function get_data_dialog(slot_name, conf_name) {
        $.ajax({
            type: "POST",
            dataType: "json",
            url: '/get_data_slot',
            data: {
                slot_name: slot_name,
                conf_name: conf_name
            },
            success: function(data) {
                var dialog = $(

                    '<div class="modal">' +
                    '<div class="modal-dialog">' +
                    '<div class="modal-content">' +
                    '<div class="modal-header">' +
                    '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Edit template</h3></div>' +
                    '<div class="modal-body" ></div>' +
                    '<div class="modal-footer"><div class="btn-group">' +
                    '<span class="btn" data-dismiss="modal">Close</span>' +
                    '<span class="save btn btn-primary" data-dismiss="modal">Ok</span>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>'

                ).appendTo('body');
                dialog.modal();
                var modal_body = dialog.find('.modal-body');
                modal_body.html(_.template(t_dialog));
                make_slot.call(modal_body[0], data);
                dialog.find('.save').on('click', function() {
                    var rs = {};
                    $(':input', dialog).each(function() {
                        var n = $(this).attr('name');
                        if (!n) return;
                        var v = '';
                        if ($(this).is(':checkbox')) v = $(this).is(':checked') ? 'true' : 'false';
                        else v = $(this).val()
                        rs[n] = v;
                    });
                    $.ajax({
                        type: "POST",
                        dataType: "json",
                        url: '/save_slot',
                        data: {
                            slot_name: slot_name,
                            conf_name: conf_name,
                            data: JSON.stringify(rs)
                        },
                        success: function(data) {
                            if (data.result == 'ok') {
                                draw_slot.call($('[t_name="' + conf_name + '"] [slot="' + slot_name + '"]')[0], data.slot);
                            }
                        }
                    });
                })
            }
        });
    }
}