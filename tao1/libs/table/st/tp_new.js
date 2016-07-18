;(function($){

    var defaults = {
        url: '',
        id: 'resultTable',
        ajax_url:'/table/data/',
        editUrl: null,
        inframe_mode: false,
        dynamic_mode: true,
        view_mode: "table",
        preloaded: false,
        max_width: 300,
        columns: {},
        id_tree: null,  //это текущая ветка из которой отображаеться ее же содержимое
        buttons: {}
    };

    // актуальные настройки, глобальные

    window.dao.tableprocessor = function (parent, params){

        this.transfer = transfer;
        this.show_doc = show_doc;
        this.show_doc_site = show_doc_site;
        this.updatelist = updatelist;
        this.duplicate = duplicate;
        this.duplicate_all = duplicate_all;
        this.postupdate = postupdate;

        var host = document.location.pathname;
        var options = $.extend({}, defaults, params);
        //var element = parent;			/** родительский контейнер */
        //var content = element.contents().detach();
        var data_values = {}; // одна из основных переменых для манипулирования данными таблицы
        var	column_indexes = {};
        var column_names = {};
        var searchbar = null;
        var col_filter = {};

//        var cursor = {  v: 0, h: 0 };
        var cursor_handler = null;
        var cursor_visible = false;
        var cursor_style = 'ui-state-active';
        var cursor_mouse = 'ui-state-hover';

        var checked = {};
        var checked_length = 0;

        var cell_height = 0;

        var toolbar = null;
        var preheader = null;

        var filter = {
            main: '',
            filt_dates:'day',
            column: {},
            page: {'current': 1},
            sort: { by: 'id', order: 'desck' },
            branch_id: null,
            selection: {},
            date : {"start":"", "end":""},
            str_option: {}
        };

        var file_manager = null;
        var filter_container = null;
        var filter_container_left = null;
        var filter_container_right = null;
        var filter_height = 0;

        var footer = null;
        var header = null;
        var header_checkbox = null;
        var is_editing_first = false; // Эта переменная устанавливается в истину после создания инпута
        var is_editing_last = false;
        var last_sort_column = undefined;
        var width_window = document.body.clientWidth;
        var height_window = document.body.clientHeight;

        var main = null;
        var old_filter_value = '';
        var row_id = null;
        var result_area = null;
        var searchbar_timer = null;
        var timer = {};

        var toolbar = $('<div id="'+options.id+'_'+options.doc_id+'_toolbar" style="background-color: #ddd;" class="ui-corner-all button_div"></div>').appendTo(parent);

        //рисование тулбара с кнопками
        var act = options.actions;
        var param = [];
        var _actions = {};

        var $act = $('<div style="margin-left:4px;" class="btn-group">' +
                '<a rel="tooltip" title="Создать новую запись"      class="btn btn-default btn-sm add_row"> <i class="fa fa-list-alt"></i></a>'+
                '<a rel="tooltip" title="Обновить"                  class="btn btn-default btn-sm refresh"> <i class="fa fa-refresh "></i></a>'+
                '<a rel="tooltip" title="Удалить выделенные записи" class="btn btn-default btn-sm del_row"> <i class="fa fa-trash "></i></a>'+
                '<a rel="tooltip" title="Редактировать"             class="btn btn-default btn-sm edit_row"><i class="fa fa-edit "></i></a>'+
            '</div>'+
            '<div class="btn-group"> ' +
                '<a title="" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" >' +
                    '<i class="fa fa-star"></i> <span style="color:#59b; padding-right:4px;">Ёще</span><span class="caret"></span>' +
                '</a>' +
                ' <ul class="dropdown-menu">' +
                    '<li class="duplicate_all"><a rel="tooltip" data-toggle="dropdown" href="#"><i class="fa fa-copy"></i> Дублировать полностью</a></li>' +
                    //'<li><a rel="tooltip" title="" data-toggle="dropdown" href="#"><i class="fa fa-copy  fa-mail-reply-all"></i> Дублировать</a></li>'+
                    '<li><a rel="tooltip" title="" data-toggle="dropdown" href="#"><i class="fa fa-print"></i> Печать в excel</a></li>'+
                    '<li><a rel="tooltip" title="" data-toggle="dropdown" href="#"><i class="fa fa-th-large"></i> Посмотреть в базе</a></li>'+
                    '<li><a rel="tooltip" title="" data-toggle="dropdown" href="#"><i class="fa fa-share-square-o"></i> Посмотреть на сайте</a></li>'+
                '</ul>' +
            '</div>'+
            '<div class="btn-group"> ' +
                '<a title="" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" ><i class="fa fa-wrench"></i> <span style="color:#59b; padding-right:4px;">Поля</span><span class="caret"></span></a>' +
                ' <ul class="dropdown-menu">' +
                    '<li class="add_field"><a rel="tooltip" data-toggle="dropdown" href="#"><i class="fa fa-plus-circle"></i> Добавить поле</a></li>'+
                    '<li class="del_field"><a rel="tooltip" data-toggle="dropdown" href="#"><i class="fa fa-close"></i> Удалить поле</a></li>'+
                    '<li class="edit_field"><a rel="tooltip" data-toggle="dropdown" href="#"><i class="fa fa-wrench"></i> Редактировать поле</a></li>'+
                '</ul>' +
            '</div>').appendTo(toolbar);

        var toolbar_height = toolbar.outerHeight();

        var statusbar = $('<div class="statusbar" style="text-align:left; bottom:73px; left:4px; right:4px; height:20px; position:absolute; font-size:12px;"></div>').appendTo(parent);
        var statusbar_message = $('<div style="top:4px; bottom:0px; left:0px; padding-left:12px; position:absolute;"></div>').appendTo(statusbar);

        main = $('<div class="grid_main"></div>').appendTo(parent);
        var div_grid = $('<div class="div_grid "></div>').appendTo(main);

        (cursor_handler = $('<input class="form-control" style="width: 0px; height: 0px; position: absolute; left:-1000px; "/>').appendTo(main)).focus();
        cursor_handler.keydown(function(event){
            return _keydown(event);
        });
//        main.click(function(){ focus(); });
        function focus(){ cursor_handler.focus(); }

        function date_changed(){
            filter.date.start = search_date_from.val();
            filter.date.end = search_date_to.val();
            updatelist();
        }
        //поиск по заданому периоду
        if(options.filt_dates){
            var filt_dates = $('<div id="filt_dates" style="top:4px; bottom:0px; right:650px; position:absolute; font-size:12px;"></div>').appendTo(toolbar);
            $('<select class="form-control"> <option value="day">По дням</option><option value="week">По неделям</option><option value="month">По месяцам</option><option value="quarter">По кварталам</option><option value="year">По годам</option> </select>').appendTo(filt_dates );
            filt_dates.find('select').change(function(){
                filter.filt_dates = $(this).val();
                updatelist();
            });
        }
        //поиск по диапазону дат
        var searchdiv_date = $('<div id="searchdiv_date" style="top:4px; bottom:0px; right:100px; position:absolute; font-size:12px;"></div>').appendTo(toolbar);
        var search_date_from = $('<input class="form-control input-sm" class="search-query" placeholder="Дата от" ' +
            'style="text-align:right; padding:1px 6px; margin-right:4px; width:85px; height:24px; border-radius:10px;  display:inline-block;" type="text" />').appendTo(searchdiv_date).attr('date_from', '');
        search_date_from.datepicker({
            dateFormat: "yy-mm-dd",
            onSelect: function(){
                if(search_date_from.val() > search_date_to.val())  search_date_to.val(search_date_from.val());
                search_date_from.datepicker("hide");
                date_changed();
            }
        });
        var search_date_to = $('<input class="form-control input-sm search-query" placeholder="Дата до"' +
            'style="text-align:right; padding:1px 6px; height:24px; border-radius:10px;  margin-right:4px;width:85px; display:inline-block;" type="text" />').appendTo(searchdiv_date).attr('date_to', '');
        search_date_to.datepicker({
            dateFormat: "yy-mm-dd",
            onSelect: function(){
                if(search_date_to.val() < search_date_from.val())  search_date_from.val(search_date_to.val());
                search_date_to.datepicker("hide");
                date_changed();
            }
        });
        search_date_from.change(date_changed);
        search_date_to.change(date_changed);
        var searchbar = $('<input class="form-control input-sm search-query" placeholder="Искать по всей таблице" ' +
            'style="display:inline-block; text-align:right; height:24px; border-radius:10px; width:200px; padding:1px 6px; " type="text" />').appendTo(searchdiv_date).attr('oldsearch', '');

        var pages = $('<ul style="z-index:1; top:0px; bottom:0px; right:0px; padding-right:20px; position:absolute;" class="pagination pagination-sm"></ul>').appendTo(statusbar);


        //			main.empty();

//        header_checkbox = $('<input type="checkbox" class="cb"\>').appendTo(header_checkbox);
//        header_checkbox.click(function(){
//            var cb = grid_left.find(".cb");
//            if ($(this).attr("checked"))
//                cb.attr("checked", true);
//            else
//                cb.attr("checked", false);
//            cb.trigger('change');
//        });

        var grid_hidden = $('<div class="grid hidden_ "></div>').appendTo(main );
        var grid_left   = $('<div class="grid left "></div>').appendTo(main );
        var grid_center = $('<div class="grid center "></div>').appendTo(main);
        var grid_right  = $('<div class="grid right "></div>').appendTo(main );

        grid_center.columns  = {};
        grid_left.columns    = {};
        grid_right.columns   = {};
        grid_hidden.columns  = {};

        grid_left.columns['cb'] = make_column('cb', {'title':'<input type="checkbox" />'}, grid_left);
        grid_hidden.columns['h'] = make_column('h', {'title':''}, grid_hidden);
        if(!options.hidden_id){
            grid_left.columns['id'] = make_column('id', {'title':'id'}, grid_left);
        }
        // создаём центральную часть
        head_(options.columns);

        grid_right.columns['img'] = make_column('img', {'title':'Изоб.'}, grid_right);
        grid_right.columns['img'].head.sort.remove();
        grid_right.columns['act'] = make_column('act', {'title':'Действие'}, grid_right);
        grid_right.columns['act'].head.sort.remove();

        init_event();

        var row_id;
        var is_tree_visible;

        function init_event(){
            grid_center.dblclick(function(e){
                var target = $(e.target);
                var cell = null;
                if (target.is('.cell')) cell = target;
                else cell = target.closest('.cell');
                if(cell.length){
                    editCell();
                    return false;
                }
            });

            //main.on('click', '.fa-trash', function() { // удалить документ

                console.warn('delete doc test tables');

            //$act.on('click', '.del_row', function() { // удалить документ
            //    var ids = {};
            //    //var recid = $(this).closest('.cell').attr('recid');
            //    var recid = $('.grid.left').closest('.cell').attr('recid');
            //    ids[recid] = recid;
            //    console.warn('delete doc', ids);
            //
            //    crn.del(ids);
            //    return false;
            //});
            main.on('click', '.column.img .val',  function() { // вызвать галерею для просмотра
                file_manager.show( $(this).closest('.cell').attr('recid') );         return false;
            });
            main.on('click', '.fa-folder-open', function() { // вызвать галерею
                file_manager.show( $(this).closest('.cell').attr('recid') );         return false;
            });
            //main.on('click', '.fa-share-alt',   function() {  // дублировать документ
            //    crn.duplicate(     $(this).closest('.cell').attr('recid') );         return false;
            //});
            main.on('click', '.fa-mail-reply-all', function() {  // дублировать документ полностью
                crn.duplicate_all( $(this).closest('.cell').attr('recid') );         return false;
            });
            $('[proc_id="'+options.id+'"]').on('click', '.duplicate_all', function() {  // дублировать документ полностью
                duplicate_all( );         //return false;
            });

            $act.on('click', '.refresh',  function() { updatelist(); return false; });
            $act.on('click', '.add_row',  function() { createRow();  return false; });
            $act.on('click', '.del_row',  function() {
                console.warn('delete doc');

                deleteRow();  return false;
            });
            $act.on('click', '.edit_row', function() { editRow();    return false; });

            $act.on('click', '.add_field',  function() { add_field();  return false; });
            $act.on('click', '.edit_field', function() { edit_field(); return false; });
            $act.on('click', '.del_field',  function() { del_field();  return false; });

            main.on('click', '.fa-th-large',    function() { //просмотреть в базе
                crn.show_doc(      $(this).closest('.cell').attr('recid') );         return false;
            });
            main.on('click', '.fa-share',       function() { // просмотреть на сайте
                window.open('/news/'+$(this).closest('.cell').attr('recid'), '_blank');  return false;
            });
            main.on('click', '.rows .val .button_div_icon_inner2', function() {
                $(this).toggleClass('fa-minus-sign fa-plus-sign');
                var rec_id = $(this).closest('.cell').attr('recid');
                var row_hidden = main.find('.hidden_[recid="'+rec_id+'"]');
                var is_visible = row_hidden.is(":visible");
                if (is_visible) {
                    row_hidden.hide();
                }
                else {
                    row_hidden.show();
                    var row_hidden1 = grid_hidden.find('.hidden_[recid="'+rec_id+'"]');//.css({'border':'1px solid red', 'height':'50px'});
                    // если подстрока открыта и еще небыла загружена получаем данные с аякса и вставляем в таблицу.
                    if (!row_hidden1.attr('is_loaded')) {
                        $('<div class="ui-state-active" style="position:absolute; left:0px; top:0px;  right:0px; bottom:0px;"></div>').appendTo(row_hidden1);
                        var div_tabs = $('<div class="khkjkh" style="position:absolute; left:12px; right:2px; top:2px; bottom:2px; "></div>').appendTo(row_hidden1);
                        var ul = $('<ul/>').appendTo(div_tabs);
                        var subs = [];
                        for(var i in options.parts){
                            row_id = rec_id;
                            var part = options.parts[i];
                            $('<li><a style="height:50px; padding-top:2px;" href="#tabs-'+i+'-'+row_id+'">'+ part.title +'</a></li>').appendTo(ul);
                            var tp1 = $('<div id = "tabs-'+ i +'-'+row_id+'" style="position:absolute; left:0px; right:0px; top:35px; bottom:0px;"></div>').appendTo(div_tabs);
                            var tp = $('<div class="" style="position:absolute; left:0px; right:0px; top:0px; bottom:0px;"></div>').appendTo(tp1);

                            if(part.type == 'table'){
                                subs[i] = new dao.tableprocessor(tp, a={
                                    url:    '/table/data/'+part.id,
                                    id:	    part.id,
                                    doc_id:	row_id,
                                    columns:  part.conf.columns,
                                    has_tree: false, view_mode:	'table',
                                    is_editable: true, id_tree:	  null,
                                    sub_table_class: true,
                                    hidden_id:	true, has_img:false,
                                    file_manager: { img:true, other:false },
                                    dumb:''
                                });
                            }
                        }
                        div_tabs.tabs({
                            select: function(event, ui) {
                                if(subs[ui.index].postupdate){
                                    subs[ui.index].updatelist()
                                }
                            },
                            selected: 0
                        });
                    }
                }
                return false;
            });

            main.on('click', function(e){
                //        main[0].onclick = (function(e){
                var target = $(e.target);
                var cell = null;
                if (target.is('.cell')) cell = target;
                else cell = target.closest('.cell');
                var recid = cell.attr('recid');
                if(target.is('.row_tree')){
//                    var child = cell.data('child');
                    collapse_sub_rows( recid);
                    if(options.pre_sub || target.data('loaded')){
                        $('[parent="'+cell.attr('recid')+'"]', main).not('.hidden_').toggle();
                        //target.toggleClass('collapsed expanded');
                        target.toggleClass('fa-plus-square-o fa-minus-square-o');
                    }else load_sub_row(target);
                }

                if (options.table_in_dialog && target.closest('.column').is('.cb')) {
                    var recid= cell.attr('recid');
                    if( !$('.dl [recid="'+recid+'"]').length){
                        var name = grid_center.find('.column._title').find('[recid="'+recid+'"]').find('.val').text();
                        var dialog = $('.dl')
                        $('<div recid="'+recid+'" style="display: inline-block; width: 350px; padding:0px 20px 0 20px">'+name+'' +
                            '<input class="form-control" type="text" style="margin-left:30px;" value="1"/><div class="del_ware_tid" style="display: inline-block; padding:0px 20px 0 20px;">' +
                            '<i class="fa fa-remove del_ware_tid" style="color:red;"/></div></div>').appendTo(dialog);
                        return true;
                    }
                }
                if (target.is(':input')) return true;
                if (target.closest('.column').is('.act')) {
                    var recid = cell.attr('recid');
                    var button = target.closest('[action]');
                    var action = button.attr('action');
                    if (typeof (_actions[action]) != 'function') return false;
                    action = _actions[action];
                    var _opt = JSON.parse(button.attr('options'));
                    grid_left.find('[recid='+recid+'] :checkbox.cb').attr("checked", true);
                    action(_opt);
                    return false;
                }
                //            var end = new Date();
                if(cell.length){ // выделение ячейки при щелчке кнопко мыши.
                    //                dao.trace('scursor', 1, function() {scursor(cell)});
                    //                scursor(cell);
                    $('.cell.ui-state-active', grid_center[0]).removeClass('ui-state-active');
                    cell.addClass('ui-state-active');
                    check_scroll();
                    focus();
                    return false;
                }
            });
        }

        var cursor = null;
        function scursor(cell){
            if(cursor) cursor.removeClass('ui-state-active');
            cursor = cell;
            cursor.addClass('ui-state-active');
            check_scroll();
            focus();
        }

        //$('.cell').sortable();
    //grid_left.find('.cell').sortable({
        //tolerance: 'pointer',
        //revert: 'invalid',
        //placeholder: 'cell',
        //forceHelperSize: true
    //});

        function head_ (columns) {
            // draw head
            options.columns = columns;
            grid_center.empty();
            console.log( 'options.columns', options.columns);
            for(var i in options.columns){
                var opt  = options.columns[i];
                // console.log('opt->', opt);
                grid_center.columns[i] = make_column(i, opt, grid_center);
            }
            grid_center.spring = $('<div class="spring">&nbsp;</div>').appendTo(grid_center );
            // говорим что столбцы перетягиваемые и отправляем значение .
            grid_center.sortable({
                cursor: 'move', axis: 'x',
                handle:'.head',
                update : function () {
                    var order = [];
                    grid_center.find('>.column').each(function(i, v) {
                        order[order.length] = $(v).attr('column_name');
                    });
                    $.ajax({
                        url: '/table/sort_columns', type: "POST", dataType:'json',
                        data: {'order': JSON.stringify(order), 'proc_id':options.id},
                        success: function(data){
                            if(data['result'] == 'ok'){
                                updatelist();
                            }
                        }
                    });
                }
            });
            grid_center.find('>*').resizable({
                handles:'e'
                //                ghost:true
            });

            // фильтры над колонками   //время
            grid_center.find('.filter .search').on('keyup', function(e){
                console.log('key upped');
                switch (e.which) {
                    case dao.key_codes.ESCAPE:
                        $(this).val('');
                    case dao.key_codes.ENTER:
                        break;
                }
                var t = $(this).closest('.column').attr('column_name');
                if (timer[t]) clearTimeout(timer[t]);
                var val = $(this).val();
                if(!filter.column[t]) filter.column[t] = {};
                filter.column[t]['val'] = val ? val : undefined;
                timer[t] = setTimeout(function(){ updatelist(); }, 1000);
            });

        }

        function make_column(res, opt, target){
            var col = $('<div class="column"></div>').appendTo(target);
            if(res=='img'){
                col.addClass('img');
            }
            col.attr('column_name', res);
            col.head = $('<div class="head well">' + opt['title'] + '</div>').appendTo(col);
            col.filter = $('<div class="filter "></div>').appendTo(col);

            if(res == 'img' || res == 'act' || res == 'cb' || res == 'h'){}
            else{
                var s_div = $('<div class="search_div"></div> ').appendTo(col.filter);
                var des = $('<input class="form-control input-sm search '+res+'" style="height:18px;" type="text"  /> ').appendTo(s_div);
                if (filter.column[res]) des.val(filter.column[res].val);
                var btn_filter = $('<div class="btn-group">' +
                    '<div class="btn btn-default btn-sm show_filter" style="font-size:10px; padding:0px; margin:0px; line-height:16px;"><i class="fa fa-caret-down"></i></div>' +
                    '</div>').appendTo(col.filter);
//                make_column_filter(col.filter);
                make_column_filter(btn_filter, col.filter);
            }
            col.rows = $('<div class="rows"></div>').appendTo(col);
            col.footer= $('<div class="footer"> </div>').appendTo(col);
            make_header(col);
            return col;
        }
        function make_header(col){
            col.head.sort = $('<div class="sort"></div>').appendTo(col.head);
            col.head.sort.up = $('<div class="up">▵</div>').appendTo(col.head.sort);
            col.head.sort.down = $('<div class="down">▿</div>').appendTo(col.head.sort);
        }

        $('<div style="background-color:white; position:absolute; height:20px; bottom:0px;  left:0px; right:0px; cursor:default;"></div>').appendTo(main);
        var layout_bottom = $('<div class="h_scroll" style="position:absolute; height:20px; bottom:0px; left:0px; right:22px; cursor:default;"></div>').appendTo(main);
        $('<div style="background-color:white; position:absolute; width:20px; bottom:0px; right:0px; top:0px; cursor:default;"></div>').appendTo(main);
        var layout_aside = $('<div style="position:absolute; width:20px; bottom:22px; right:0px; top:0px; cursor:default;"></div>').appendTo(main).mouseup(function(event){
            event.preventDefault();
            cursor_handler.focus();
        });

        //вызываем плагин скролла передаем горизонтальные параметры вертикальные для рисования и тело что прокручивать
        var scroll = new dao.scroll(layout_aside, layout_bottom, {
            proc_id:options.id,
            horizontal_target:grid_center,
            vertical_target:grid_left.columns['cb'].rows,
            onscroll:function(left, top){
                for( var res in grid_center.columns)
                    grid_center.columns[res].rows.scrollTop(top);
                for( var res in grid_left.columns)
                    grid_left.columns[res].rows.scrollTop(top);
                grid_hidden.columns['h'].rows.scrollTop(top);
                for( var res in grid_right.columns)
                    grid_right.columns[res].rows.scrollTop(top);
//                for( var res in body_hidden.columns) body_hidden.columns[res].rows.scrollTop(top);
            },
            stopscroll:function(){
                cursor_handler.focus();
            }
        });
//        grid_center.scroll();

        // Главный поиск:   реакция процесора при щелчке на клавишу при главном поиске
        searchbar.keyup(function(e){
            if (e.which == dao.key_codes.ENTER) {
                e.preventDefault();
                cursor_handler.focus();
                return false;
            }
            if (searchbar_timer) clearTimeout(searchbar_timer);
            filter.main = $(this).val();
            searchbar_timer = setTimeout(function(){
                if (searchbar.attr('oldsearch') != searchbar.val()) {
                    _status('input waiting timed out: search expression was changed');
                    searchbar.attr('oldsearch', searchbar.val());
                    updatelist();
                }
                else _status('input waiting timed out: search expression was not changed');

            }, 1500);
        });

        function updatetree(){
            if (options.has_tree) {
                tree.update({ })
            } else updatelist();
        }
        //тут происходит вызов дерева
        var tree;
        var tree_button;
        var tree_place;
        if (options.has_tree) {
            tree_place = $('<div style="position:absolute; top:'+toolbar_height+'px; bottom:23px; width:200px; right:0px; overflow:hidden; display:none;"></div>').appendTo(parent);
            tree_button = $('<div class="btn btn-info btn-sm" style="margin-left:25px;"><i class="fa fa-list-alt"></i> '+dao.ct('categories')+'</div>').appendTo(searchdiv_date);
            tree_button.click(function(){ _toggle_tree(); });
            var url_ = '/tree/data/tree:'+options.id;
            if(options.id == 'permission') url_ = '/group_perm';
            tree = new dao.tree_processor(tree_place, main, {
                url: url_,
                // id: options.id,
                id: 'tree:'+options.id,
                check_tree: options.check_tree,
                id_tree: options.id_tree,
                on_drop: function(branch_id){
                    move_to_branch(branch_id);
                },
                on_change: function(branch_id, is_recursive){
                    filter.branch_id = branch_id;
                    filter.is_recursive = is_recursive;
                    updatelist();
                }
            });
            updatetree();
            _show_tree();
        }else updatelist();

        function move_to_branch(branch_id){
            $.ajax({
                type: "POST",
                url: '/tree/move_leaf',
                data: {
                    proc_id: options['id'],
                    // action: 'movetobranch',
                    row_id: row_id,
                    branch_id: branch_id
                },
                dataType: 'json',
                beforeLoad: function(){ _status('Save...'); },
                success: function(data){
                    _status(data.debug);
                    _status(data.result);
                    if (data.result == 'ok') updatelist();
                    else error_status(dao.error, data.need_action)
                }
            });
        }


        if (options.file_manager !== undefined) {
            file_manager = new dao.file_processor({
                url: options.url,
                id: options.id,
                has_toolbar: true,
                on_change: function(){ }
            });
        }


        function make_column_filter(parent, c_filter){
            var editor = c_filter.find('.search');
            var column_name = parent.closest('.column').attr('column_name');
            var column = options.columns[column_name];
            if (!column){ return; }
            if (column.type == "select") {
                editor.autocomplete({
                    source:[], minLength:0,
                    open: function(event, ui) { editor.blurable = false; },
                    close: function(){
                        setTimeout(function() { editor.trigger('keyup');}, 100);
                        editor.blurable = true; focus(); },
                    select: function( event, ui ){
                        editor.data('new_value', ui.item.id);
                        $(this).autocomplete('close');
                    }
                });
                dao.get_select(editor, options.columns[column_name]['relation']);
                //t.autocomplete('search', '');
                c_filter.find('.show_filter').on('click', function(){
                    if(editor.autocomplete( "widget" ).is(':visible'))   {
                        editor.autocomplete('close');
                    } else {
                        console.log('wwwwwwwwwwwwwwwwwwwwwwwww');
                        editor.autocomplete('search', '');
                    }
                });
            } else if (column.type == "checkbox") {
                var div = $('<ul class="dropdown-menu filt_col_check" role="menu" style="padding:6px;">'+
                                "<li class='t'><span style='color:green; font-size:20px; cursor:pointer;'><i class='fa fa-check'></i> Да</span></li>"+
                                "<li class='f'><span style='color:red;   font-size:20px; cursor:pointer;'><i class='fa fa-remove'></i> Нет</span></li>"+
                                "<li class='clean'><span style='color:gray; font-size:20px; cursor:pointer;'><i class='fa fa-eraser'></i> Очистить</span></li>"+
                            "</ul>").appendTo(parent);
//                div.hide();
                c_filter.on('click', '.show_filter', function(){ div.toggle(); });
                c_filter.on('click', '.filt_col_check .t', function(){
                    editor.val('t'); div.toggle(); editor.trigger('keyup');
                });
                c_filter.on('click', '.filt_col_check .f', function(){
                    editor.val('f'); div.toggle(); editor.trigger('keyup');
                });
                c_filter.on('click', '.filt_col_check .clean', function(){
                    editor.val(''); div.toggle(); editor.trigger('keyup');
                });
            } else if(column.type == "date") {
                parent.append(' ');
                var div = $('<ul class="dropdown-menu filt_col_date" role="menu">'+
                                "<li>От <input class='form-control input-sm col_from' type='text'/></li>"+
                                "<li>До <input class='input-sm col_to form-control' type='text'/></li>"+
                                "<li><div class='btn btn-default search_d'>Поиск</div></li>"+
                            "</ul>").appendTo(parent);
                div.css({'overflow':'hidden'});
                $('.search_d').button();
//                div.hide();
                parent.find('.show_filter').click(function(){ div.toggle(); });
                try{
                    $('.col_from, .col_to').datetimepicker({
                        showSecond: true, timeFormat: "hh:mm:ss", dateFormat: "yy-mm-dd", stepHour:1, stepMinute: 1, stepSecond: 1, hourMin: 0, hourMax: 23,
                        closeText:"Готово", currentText: "Сейчас", timeOnlyTitle: "Выберите время", timeText:"Время", hourText: "Часы", minuteText: "Минуты",
                        secondText: "Секунды",
                        monthNamesShort: ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"],
                        dayNamesMin:["Пн", "Вт", "Ср", "Чт","Пт","Сб","Вс"],
                        monthNames: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"],
                        beforeShow: function() { editor.blurable = false; },
                        onClose: function(){ editor.blurable = true; editor.blur(); },
                        onSelect: function(){ }
                    });
                }catch(e){}
                parent.find('.search_d').click(function(){
                    if(! filter.column[column_name]) filter.column[column_name]= {};
                    filter.column[column_name ]['range'] = {'from':$('.col_from', parent).val(), 'to':$('.col_to', parent).val()};
                    div.hide();
                    editor.trigger('keyup');
                });
            } else { // С начала строки c конца строки по подстроке и по полному совпадению.
                var div = $('<ul class="dropdown-menu filt_col_text" role="menu">'+
                                '<li class="substr"><a><input class="" type="radio" checked name = "'+column_name+'_str" value = "substr"/> Подстрока </a></li>'+
                                '<li class="eq">    <a><input class="" type="radio" name = "'        +column_name+'_str" value = "eq"/>     Точно     </a></li>'+
                                '<li class="start"> <a><input class="" type="radio" name = "'        +column_name+'_str" value = "start"/>  Начало    </a></li>'+
                                '<li class="end">   <a><input class="" type="radio" name = "'        +column_name+'_str" value = "end"/>    Конец     </a></li>'+
                            '</ul>').appendTo(parent);
//                div.hide();
                parent.find('.show_filter').click(function(){ div.toggle(); });
                parent.find(':radio').click(function(){
//                parent.find(':radio[name="' + column_name + '_str"]').click(function(){
                    if(! filter.column[column_name]) filter.column[column_name]= {};
                    filter.column[column_name ]['str_option'] = $(this).val();
                    div.toggle();
                    editor.trigger('keyup');
                });
            }
        }

        /* ********************************************
         * Реализация методов
         * Устанавливает обработчики после загрузки таблицы
         */

        function style_page_number(){
            // стилизация номеров страниц
            pages.find('li.cerp-ui-pages-current').addClass('active');

            pages.find('a').click(function(){
                filter.page.current = parseInt($(this).text());
                updatelist();
                return false
            });
        }

        function job_cb(){
            // Расставляем чеки Назначаем обработку выделения чекбокса
            grid_left.find(".head input").change(function(){
                if($(this).is(':checked')){
                    grid_left.find(".cb").attr('checked', true);
                }else{
                    grid_left.find(".cb").removeAttr('checked');
                }
            });
        }



        function postupdate(){
            // работаем с элементами которые меняем динамически.
            style_page_number();
            job_cb();
            var cells = grid_center.find('.cell');
            // Подсветка строки при наведении мыши
            $([cells, grid_left.find('.cell'), grid_right.find('.cell')]).each(function(i, v) {
                $(v).hover(cell_in, cell_out);
            });
            function cell_in () {
                var recid = $(this).attr('recid');
                main.find('.cell[recid="'+recid+'"]').addClass('ui-state-hover');
            }
            function cell_out (){
                cells.removeClass('ui-state-hover');
                grid_left.find('.cell').removeClass('ui-state-hover');
                grid_right.find('.cell').removeClass('ui-state-hover');
                grid_hidden.find('.cell').removeClass('ui-state-hover');
            }
            if(options.select_id){
                grid_left.find('.cb.column').find('[recid="'+options.select_id+'"]').find(':checkbox').attr('checked', true);
                delete options.select_id;
            }
            scroll.reinit();
        }

        function collapse_sub_rows (parent) {
            $('.column:first', grid_center).find('[parent="'+parent+'"]').each(function(i, v){
                var btn = $(v).find('.row_tree');                           //fa-plus-square-o fa-minus-square-o
                if (btn.is('.fa-minus-square-o')) btn.click();
            });
        }

        function load_sub_row(button){
            var parent = button.closest('.cell').attr('recid');
            var level = 1+parseInt(button.attr('level') ? button.attr('level') : 0);
            console.warn('url: options.ajax_url+options.id', options.ajax_url+options.id);
            $.ajax({
                type: "POST", dataType: "json",
                url: options.ajax_url+options.id,
                data: {
                    proc_id: options.id,
                    view_mode: options.view_mode,
                    filter: JSON.stringify(filter),
                    parent:parent,
                    doc_id: options.doc_id
                },
                beforeSend: function(){ dao.status_bar('Подгружается', true); },
                success: function(data){
                    if(data.result =='ok'){
                        draw(data.data, parent, level);
                        postupdate();
                        dao.status_bar('', false);
                        button.data('loaded', true);
                        button.click();
                    }else console.error('load_sub_row(button)', data.error, data.need_action);
                },
                error:function(data, status, error){ console.error(data.responseText); }
            });
        }


        function check_scroll(){
            var cell = $('.ui-state-active', grid_center);
            if( !cell.length) return undefined;
            var top = cell.position().top - cell.closest('.rows').position().top;
            var left = cell.closest('.column').position().left - grid_center.position().left;
            var width = cell.width();
            var f_height = grid_center.height() - 83;//cell.closest('.column').find('.footer').height();
            var f_width = grid_center.width() - grid_right.width() - 20 - grid_left.width();
            var dx = 0, dy = 0;
            if (top < 0) dy = top;
            else
            if (top + cell_height >  f_height) { dy = top + cell_height - f_height; }
            if (left < 0) dx = left;
            else if (left + width > f_width)  dx = left + width - f_width;
            grid_center.stop().scrollTo({
                top: '+=0px',
                left: '+=' + dx + 'px'
            }, 100);
            main.find('.column .rows').stop().scrollTo({
                top: '+=' + dy + 'px',
                left: '+=0px'
            }, 100);
        }

        //Изменить состояние чекбокса в текущей строке
        function _invertCheckBox(){
            var rec_id = $('.ui-state-active', grid_center).closest('.cell').attr('recid');
            var cb = grid_left.find('.check[recid="'+rec_id+'"]').find(".cb");
            cb.click();
            cb.trigger('change');
        }

        /**
         * Обработчик нажатия клавиши
         * @param {Event} e объект события
         * @return {Boolean} признак продолжения обработки событий
         */
        function _keydown(e){
            // TODO сделать исключение для управляющих клавиш (например F5)
            //                return false;
            switch (e.which) {
                case dao.key_codes.UP:
                    $('.ui-state-active', grid_center).prev().prev().addClass('ui-state-active');
                    $('.ui-state-active', grid_center).next().next().removeClass('ui-state-active');
                    break;
                case dao.key_codes.DOWN:
                    $('.ui-state-active', grid_center).next().next().addClass('ui-state-active');
                    $('.ui-state-active', grid_center).prev().prev().removeClass('ui-state-active');
                    break;
                case dao.key_codes.LEFT:
                    var del_el = $('.ui-state-active', grid_center).attr('recid');
                    $('.ui-state-active', grid_center).closest('.column').prev().find('.cell[recid="'+del_el+'"]').addClass('ui-state-active');
                    $('.ui-state-active', grid_center).closest('.column').next().find('.cell[recid="'+del_el+'"]').removeClass('ui-state-active');
                    break;
                case dao.key_codes.RIGHT:
                    var del_el = $('.ui-state-active', grid_center).attr('recid');
                    $('.ui-state-active', grid_center).closest('.column').next().find('.cell[recid="'+del_el+'"]').addClass('ui-state-active');
                    $('.ui-state-active', grid_center).closest('.column').prev().find('.cell[recid="'+del_el+'"]').removeClass('ui-state-active');
                    break;
                case dao.key_codes.PAGE_UP:
                    var rows = '';
                    break;
                case dao.key_codes.PAGE_DOWN:
                    var rows = '';
                    break;
                case dao.key_codes.HOME:
                    break;
                case dao.key_codes.END:
                    break;
                case dao.key_codes.ENTER:
                // Закрытие с текущим элементом
                case dao.key_codes.F2:
                    editCell();
                    break;
                case dao.key_codes.DELETE:
                    alert(''+dao.translate('key_up')+' DELETE');
                    break;
                case dao.key_codes.INSERT:
                    //					   $('<div/>').css({'width':'100px', 'height':'100px', 'z-index':'10000', 'border':'red 3px solid'}).appendTo(body_hidden);
                    alert(''+dao.translate('key_up')+' INSERT');
                    break;
                case dao.key_codes.F5:
                    //					case dao.key_codes.F5:
                    updatelist();
                    break;
                case dao.key_codes.F6:
                    //					case dao.key_codes.F5:
                    alert('f6');
                    break;
                case dao.key_codes.F7:
                    e.preventDefault();
                    searchbar.focus();
                    break;
                case dao.key_codes.F1:
                case dao.key_codes.F3:
                case dao.key_codes.F4:
                case dao.key_codes.F6:
                case dao.key_codes.F8:
                case dao.key_codes.F9:
                case dao.key_codes.F10:
                case dao.key_codes.F11:
                case dao.key_codes.F12:
                case dao.key_codes.SHIFT:
                case dao.key_codes.CONTROL:
                case dao.key_codes.ALT:
                    // Запрещаем использование этих клавиш - они зарезервированы или мешают
                    break;
                case dao.key_codes.SPACE:
                    _invertCheckBox();
                    break;
            }
            check_scroll();
        }

        // * Инициализация редактирования
        function editCell(){
            var cell = $('.ui-state-active', grid_center);
            if(!cell.length) return undefined;
            var before_edit = true;
            var rec_id = cell.attr('recid');
            var column_name = cell.closest('.column').attr('column_name');
            var edit_value = data_values[rec_id][column_name];
            var column = options.columns[column_name];
            var is_editable = column['is_editable'] != "false" && column.type !='rich_edit';
            // проверяем что статус не проведен если проведен то нельзя редактировать.
            if ('status' in options.columns) {
                var status_ = $('.column[column_name="status"] .cell[recid="'+rec_id+'"]');
                if (status_.length) {
                    var status = data_values[rec_id]['status'];
                    is_editable = is_editable && (status == "Черновик" ||status == "");
                }
            }
            if(!is_editable) return;
            // Начало вставки инпута
            var div = $('<div class="editor"></div>').appendTo(cell);
            var editor;

            if (column.type == "select") {
//                editor = $("<select class="form-control"> </select>");
//                init_select(editor, column_name, edit_value);
                editor = $('<input class="" type="text" />');
                var t = editor.autocomplete({
                    source: [], minLength: 0,
                    open: function (event, ui) { editor.blurable = false; },
                    close: function () {
                        editor.blurable = true;
                        editor.blur();
                    },
                    select: function (event, ui) {
                        console.error('ui', ui);
                        //console.error( ui.item.id);
                        editor.data('new_value', ui.item.id);
                        $(this).autocomplete('close');
                    }
                });
                dao.get_select(editor, options.columns[column_name]['relation'], true);
            } else if (column.type == "cascad_select" ) {
                editor = $('<input class="" type="text" />');
                var filter = '';
                var t = editor.autocomplete({
                    source: [], minLength: 0,
                    open: function (event, ui) { editor.blurable = false; },
                    close: function () { editor.blurable = true; editor.blur(); },
                    select: function (event, ui) {
                        console.error('ui', ui);
                        editor.data('new_value', ui.item.id);
                        $(this).autocomplete('close');
                    }
                });

                dao.get_select_cacad(editor, options.columns[column_name]['relation'], rec_id, column['relation_field'], true);

            } else if (column.type == "checkbox") {
                editor = $("<input type='checkbox' "+(edit_value == 'true' ? "checked='true'" : '')+" enabled='true'/>");
            } else if (column.type == "passw") {
                editor = $("<input type='password' enabled='true'/>");
            } else if(column.type == "date") {
                editor = $('<input type="text" />'); // editor.datepicker();
                editor.datetimepicker({
                    showSecond: true, timeFormat: "hh:mm:ss", dateFormat: "yy-mm-dd",
                    stepHour: 1, stepMinute: 1, stepSecond: 1, hourMin: 0, hourMax: 23,
                    closeText:"Готово", currentText: "Сейчас", timeOnlyTitle: "Выберите время",
                    timeText: "Время", hourText: "Часы", minuteText: "Минуты", secondText: "Секунды",
                    monthNames: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"],
                    monthNamesShort: ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"],
                    dayNamesMin: ["Пн", "Вт", "Ср", "Чт","Пт","Сб","Вс"],
                    beforeShow: function() { editor.blurable = false; },
                    onClose: function(){ editor.blurable = true; editor.blur(); },
                    onSelect: function(){ }
                });
            } else {
                editor = $('<input type="text" />').val(edit_value);
            }
            editor.appendTo(div);
            editor.blurable = true;

            editor.focus();
            if(column.type == 'select'){}
            else if(column.type == 'cascad_select'){}
            else {
                editor.val( edit_value ).select();
            }

            editor.blur(function(){ if (editor.blurable) { save(); } });

            editor.click(function(){ if (column.type != 'checkbox' ){ return false; } });

            editor.dblclick(function(){ return false });
            editor.mousedown(function(){ // Если не вернуть фальш до клика в хроме не дойдет очередь.
                return false;
            });
            editor.keypress(function(event){
                }).keydown(function(event){
                    if (event.which == dao.key_codes.ENTER) {
                        if(before_edit) return false;
                        if(column.type == 'select') return true;
                        save();
                        return false;
                    }
                    // Новое значение в поле редактирования только при отпускании клавиши
                    // Проверяем значение
                    if (event.which == dao.key_codes.TAB) {
                        save();
                        var del_el = $('.ui-state-active', grid_center).attr('recid');
                        $('.ui-state-active', grid_center).closest('.column').next().find('.cell[recid="'+del_el+'"]').addClass('ui-state-active');
                        $('.ui-state-active', grid_center).closest('.column').prev().find('.cell[recid="'+del_el+'"]').removeClass('ui-state-active');
//                    editCell();
                        return false;
                    }
                    if (event.keyCode == dao.key_codes.ESCAPE) {
                        end_edit();
                    }
                });
            before_edit = false;
            if(column.type == 'checkbox') {
                editor.attr('checked') ? editor.removeAttr('checked') : editor.attr('checked', true);
//                editor.click();
                editor.blur();
            }
            function end_edit(){
                cell.addClass('ui-state-active');
                editor.remove();
                div.remove();
                focus();
            }
            function save() {
                if (dao.checkValue(editor)) {
                    var text;
                    if (column.type == "checkbox") text = editor.is(':checked');
                    else if (column.type == "select")        text = editor.data('new_value');
                    else if (column.type == "cascad_select") text = editor.data('new_value');
                    else text = editor.val();
                    saveField(column_name, text, rec_id, cell);
                    end_edit()
                }
            }
        }

        /**
         * Сохранение значение по завершению ввода
         * @param {String} fieldname Имя поля в таблице БД
         * @param {String} value Значение
         * @param {Number} recid id записи
         */
        function saveField(fieldname, value, recid){
            //this._status('savefield');
            var url = '/table/update_cell/'+options.id;
            if (options.id=='users_group'){url='/users_group/update_cell';}
            else if (options.id=='group_perm'){url='/group_perm/update_cell';}
            var bbb = recid.search(/\//);
            $.ajax({

                type: "POST",dataType: 'json', url:url,
                data: {
                    id: recid.substr(bbb+1), // от найденого сибвола и дальше
                    branch_id: recid.substr(0, bbb), // вырезаем с начала строки до найденого симбвола
                    field: fieldname,
                    value: encodeURIComponent(value)
                },
                beforeLoad: function(){ _status('Сохраняется...'); },
                success: function(data){
                    if (data.result == 'ok') {
                        var updated    = data.updated;
                        console.log( updated );
                        var field_name = updated.field_name;
                        var formatted  = updated.formatted;
                        var value      = updated.value;

                        var cell = $('.column[column_name="'+field_name+'"] .cell[recid="'+recid+'"]');
                        data_values[recid][field_name] = value;
                        cell.find('.val').html(formatted);
                    }
                }
            });
        }

        //function update_updated(updated_, recid){
        //    for(var field_name in updated_){
        //        var updated = updated_[field_name];
        //        var cell = $('.column[column_name="'+field_name+'"] .cell[recid="'+recid+'"]');
        //        data_values[recid][field_name] = updated['value'];
        //        cell.find('.val').html(updated.formatted)
        //    }
        //}

        var _counter = 0;
        function _status(message, is_error, do_count){
            if (do_count == null) {	 do_count = false; }
            //dao.message((this._counter++)+': '+message, (is_error ? 'error' : 'warning'));
            if (!do_count) {	 statusbar_message.html('' + message + '');   }
        }

        function updatelist(){
         // Обновляет таблицу на экране
            console.log(options.ajax_url+options.id);
            $.ajax({
                url: options.ajax_url+options.id, // url: '/table/data/'+options.id,
                type: "POST", dataType:"json",
                data: {
                    proc_id: options.id,
                    action: 'table',
                    view_mode: options.view_mode,
                    filter: JSON.stringify(filter),
                    doc_id: options.doc_id
                },
                beforeSend: function(){
                    dao.status_bar('Подгружается', true);
                },
                success: function(data){
                    if(data.result =='ok'){
                        console.warn('log_dada_table', data );
                        if (data.head) head_(data.head);
                        data_values = {};
                        draw(data.data, '_', 0);
                        pag(data.pages['count'], data.pages['current']);
                        postupdate();
                        grid_center.find('.column:first .cell:first').addClass('ui-state-active');
                        dao.status_bar('', false);
                    }else{
                        console.error('server_error: '+data.error, data.need_action);
                    }
                },
                error:function(data, status, error){
                    var aaa = data.responseText.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                    console.error('ajax_error: ('+status+') '+aaa);
                }
            });
        }


//<nav>
  //<ul class="pagination">
  //  <li class="disabled"> <span> <span aria-hidden="true">&laquo;</span> </span> </li>
  //  <li class="active"> <span>1 <span class="sr-only">(current)</span></span> </li>
  //  ...
  //</ul>
//</nav>


        // рисует пагинацию
        function pag(count, current){
            pages.empty();
            //pages.addClass('ui-widget ui-widget-default');
            if(count > 1){
                pag_link(1);
                // рисуем промежуточные сылки
                if (count > 3) {
                    var start = current - 5;
                    if (start < 2) start = 2;
                    var end = start + 10;
                    if ( end >= count) end = count - 1;
                    if(start > 2){ pag_dot(); }
                    for(var i= start; i<= end; i++){
                        pag_link(i);
                    }
                    if(count -1 > end){ pag_dot(); }
                }
                if (count == 3) pag_link(2);
                pag_link(count)
            }
            function pag_link(i) {
                var a = $('<li class=""> <a href="#page'+i+'">  '+i+' </a></li>').appendTo(pages);
                if (i==current){ a.addClass('active'); }
                //else { a.addClass('disabled'); }
            }
            function pag_dot() {
                var a = $('<li><a>  ... </a></li>').appendTo(pages);
                //a.addClass('ui-state-default');
            }
        }


        var cache;
        function draw(data, parent, level){

            if(!parent){
                cache = { center: {}};
                for (var res in grid_center.columns) {
                    grid_center.columns[res].rows.empty();
                }
                for (var res in grid_left.columns) {
                    grid_left.columns[res].rows.empty();
                }
                for (var res in grid_right.columns) {
                    grid_right.columns[res].rows.empty();
                }
                grid_hidden.columns['h'].rows.empty();
            }
            //                // бежим по всем чтрочкам потом бежим по всем столбцам из шапки и есл есть даные вставляем.
//            dao.vd(dao.keys(data));
            make_center_html(data);
            make_left_html(data);
            make_right_html(data);
            make_hidden_html(data);

            $('.column .rows', main ).each(function(i, v){
                if($(this).find('.zaebalo').length) return;
                $('<div class="zaebalo"></div>').appendTo($(v));
            });

            function make_center_html(data){
                var first = true; var ctr = 0;
                console.log('data->', data);
                // var rl = data.length;
                console.log('data.length->', data.length);
                for(var ci in options.columns){
                    var html = ''; ctr += 1;
                    for(var ri = 0; ri < data.length; ri++){
                        var row = data[ri];
                        // console.log('row->', row, ctr);

                        if (first) data_values[row['id']] = {};
                        var cell = null;
                        var dl = row['doc'].length; // row['doc']  кол-во списков со словарями внутри в которых значения полей  [{'edit_value':'false','formatted':'ture'},{},{}]
                        for(var di = 0; di < dl; di++){
                            if (row['doc'][di]['id'] == ci) {
                                cell = row['doc'][di];  //в док хранятся столбцы.
                                break;
                            }
                        }
                        if (!cell) { cell = { 'edit_value':null, 'formatted': '-' } }
                        var _hidden = (row['parent'] != '_') && !options.expanded;
                        var btn = '', stl = '';
                        if( first){
                            stl = 'text-align: left;';
                            //if( parent == '_'){
                            //    btn = '<i style="cursor:pointer; margin-right:6px; color:grey;" class="fa fa-move"></i>' + btn;
                                btn = '<i style="cursor:pointer; margin-right:6px; color:#8258FA;" class="fa fa-arrows"></i>' ;
                            //}
                            if( row['child'] && row['child'].length){
                                var exp = options.expanded  ? 'fa-minus-square-o' : 'fa-plus-square-o';
                                //btn += '<div level="'+level+'" class="row_tree '+exp+'"></div>';
                                btn += '<div level="'+level+'" style="cursor:pointer; margin-top:3px; color:blue;" class="row_tree fa '+exp+'"></div>';
                            }
                            if(level || options.pre_sub){
                                var l = options.pre_sub ? parseInt(row['level']) : level;
                                //btn += '<div style="display: inline-block; width:'+16*l + 'px"></div>' + btn;
                                btn = '<div style="display:inline-block; width:'+16*l + 'px"></div>' + btn;
                            }
                        }

                        var td = '<div recid="'+row['id']+'" class="cell table-mause-cursor ui-draggable"  ' +
                            'style=" '+stl+'; color:inherit;  ' + (_hidden ? 'display:none; ' : ' ')+'" '+(row['parent'] ? ' parent="'+row['parent']+'"' : '')+'>' +
                            btn + '<div class="val">'+cell['formatted']+'</div></div>';
                        data_values[row['id']][ci] = cell['edit_value'];
                        html += td;
                        html += create_hidden_html(row['id']);
                    }
//                    html += '<div class="fut" style="height:300px;"> &nbsp;</div>';
                    if(parent && parent != '_'){ //работаем с вложеными подстрочками
                        var aaa = $('[recid="'+parent+'"]:last', grid_center.columns[ci].rows[0]);
                        aaa.after(html);
                        if (ctr>1) continue;
                    } else {
                        console.log('proc_id->', options.id);
                        grid_center.columns[ci].rows[0].innerHTML = html;
                    }

                    first = false;
                }
            }


            function make_left_html(data, parent1){
                var columns = {'cb':  {}};
                if(!options.hidden_id) columns['id'] = {};
                for(var ci in columns){
                    var html = '';
                    var rl = data.length;
                    for(var ri = 0; ri < rl; ri++){
                        var row = data[ri];
                        var cell = null;
                        var dl = row['doc'].length;
                        if( ci == 'cb'){
                            var _cell = '<div class="row_button">' +
                                    '<input class="cb" type="checkbox" />';
                                if (options.parts && options.parts.length) {
                                    _cell += '<div class="button_div_icon_inner2 fa fa-plus-circle uiicon"></div>';
                                }
                            _cell += '</div>';
                            cell = { 'edit_value':null, 'formatted': _cell } }
                        if( ci == 'id'){ cell = { 'edit_value':null, 'formatted': row['id'] } }
                        if (!cell) { cell = { 'edit_value':null, 'formatted': '-' } }
                        var _hidden = (row['parent'] != '_') && !options.expanded;
                        var btn = '', stl = '';
                        var td = '<div recid="'+row['id']+'" class="check table-mause-cursor cell ui-draggable" ' +
                            'style=" '+stl+' ' + (_hidden ? 'display: none; ' : '')+'" '+(row['parent'] ? ' parent="'+row['parent']+'"' : '')+'>' +
                            btn + '<div class="val">'+cell['formatted']+'</div></div>';
//                        td.data('edit_value', data_cell['edit_value']);
                        html += td;
                        html += create_hidden_html(row['id']);
                    }
                    if(parent && parent != '_'){
                        var aaa = $('[recid="'+parent+'"]:last', grid_left.columns[ci].rows[0]);
                        aaa.after(html);
                    } else grid_left.columns[ci].rows[0].innerHTML = html;
                }
            }

            function make_right_html(data){
//                console.warn(data);
                var columns = {'img':{}, 'act':{}};
                for(var ci in columns){
                    var html = '';
                    var col = options.columns[ci];
                    var rl = data.length;
                    for(var ri = 0; ri < rl; ri++){
                        var row = data[ri];
                        var cell = null;
                        var dl = row['doc'].length;
                        if( ci == 'img'){
                            var _cell = '<div class="row_button " >';
                            for(var res in row['imgs']){
                                _cell += '<img style="height:16px; margin-right:2px;" src="/img/'+options.id+'/'+row['id']+'/'+res+'/thumb_img"/>';
                            }
                            _cell += '<div class="uiicon fa fa-folder-open"></div>';
                            _cell += '</div>';
                            cell = { 'edit_value':null, 'formatted': _cell };
//                            var _cell =
//                                '<div class="row_button " ><img style="height:16px; margin-right:2px;" src="'+row.imgs.thumb+'">' +
//                                    '<div class="uiicon icon-folder-open"></div></div>';
//                            cell = { 'edit_value':null, 'formatted': _cell };
                        }
                        if( ci == 'act'){
                            _cell = '<div class="row_button" title="Посмотреть в базе">   <div><i class="fa fa-th-large"></i></div> </div>'+
                                    '<div class="row_button" title="Посмотреть на сайте"> <div><i class="fa fa-share-square-o"></i></div></div>'+
                                    '<div class="row_button" title="Удалить">             <div><i class="fa fa-trash"></i></div></div>'+
                                    '<div class="row_button" title="Редактировать">       <div><i class="fa fa-edit"></i></div></div>';

                            cell = { 'edit_value':null, 'formatted': _cell };
                        }
                        if (!cell) { cell = { 'edit_value':null, 'formatted': '-' }; }
                        var _hidden = (row['parent'] != '_') && !options.expanded;
                        var btn = '', stl = '';

                        var td = '<div recid="'+row.id+'" class="cell table-mause-cursor ui-draggable"  ' +
                            'style="text-align:right; '+stl+' ' + (_hidden ? 'display:none; ' : '')+'" '+(row.parent ? ' parent="'+row.parent+'"' : '')+'>' +
                            btn + '<div class="val">'+cell.formatted+'</div>' +
                            '</div>';
                        html += td;
                        html += create_hidden_html(row.id);

                    }
                    if(parent && parent != '_'){
                        var aaa = $('[recid="'+parent+'"]:last', grid_right.columns[ci].rows[0]);
                        aaa.after(html);
                    } else grid_right.columns[ci].rows[0].innerHTML = html;
                }
            }

            function create_hidden_html(id){ // рисование заглушки везде для скрытой ячейки.
                var is_child = parent && parent != '_';
                var p = is_child ? ' parent="' + parent +'"' : '';
                var hidden = '<div class="hidden_" recid="'+id+'"'+p+' style="display:none;"></div>';
                return hidden;
            }

            function make_hidden_html(data){ // скрытая строчка.
                var columns = {'h':{}};
                for(var ci in columns){
                    var html = '';
                    var col = options.columns[ci];
                    var rl = data.length;
                    for(var ri = 0; ri < rl; ri++){
                        var row = data[ri];
                        var cell = null;
                        var dl = row['doc'].length;
                        if( ci == 'h'){
                            cell = { 'edit_value':null, 'formatted': '&nbsp;' };
                        }

                        if (!cell) { cell = { 'edit_value':null, 'formatted': '-' } }
                        var _hidden = (row['parent'] != '_') && !options.expanded;
                        var btn = '', stl = '';

                        var td = '<div recid="'+row['id']+'" class="cell table-mause-cursor ui-draggable"  ' +
                            'style=" '+stl+' ' + (_hidden ? 'display: none; ' : '')+'" '+(row['parent'] ? ' parent="'+row['parent']+'"' : '')+'>' +
                            btn + '<div class="val">'+cell['formatted']+'</div></div>';
                        html += td;
                        if (options.parts && options.parts.length) {
                            var is_child = parent && parent != '_';
                            var p = is_child ? ' parent="' + parent +'"' : '';
                            html += '<div class="hidden_" recid="'+row['id']+'"'+p+' style="display: none;"></div>';
                        } else html += create_hidden_html(row['id']);
                    }
                    if(parent && parent != '_'){
                        var aaa = $('[recid="'+parent+'"]:last', grid_hidden.columns[ci].rows[0]);
                        aaa.after(html);
                    } else grid_hidden.columns[ci].rows[0].innerHTML = html;
                }
            }
        }

        var crn = new dao.tp_site('aaa', {
            url:options.url,
            proc_id: options.id,
            columns: options.columns,
            on_success: function(){
                updatelist();
            },
            mess:'mess'
        });

        function deleteRow(){
            if (!confirm('Вы действительно хотите удалить?')) return;
            if (options.inframe_mode) return;
            var ids = {};
            var idsn = [];
            $('input:checked', grid_left).each( function(i, v){
                var recid = $(v).closest('.check').attr('recid');
                ids[recid] = recid;
                idsn.push(row_id);
                console.warn(idsn);
            });
            crn.del(ids, idsn);
        }

        function transfer(){
//            if (!confirm('Вы действительно хотите перенести документ?')) return;
            if (options.inframe_mode) return;
            var ids = {};
            $('input:checked', grid_left).each( function(i, v){
                var recid = $(v).closest('.check').attr('recid');
                ids[recid] = recid;
            });
            crn.transfer_doc(ids);
        }

        function createRow(){
            var owner = options.doc_id;
            var parent = $('input:checked', grid_left).closest('.check').attr('recid');
            console.log( 'owner: ', owner, 'parent: ', parent);
            crn.create( {}, owner, parent, undefined, undefined );
        }
        function editRow(){
            var parent = $('input:checked', grid_left).closest('.check').attr('parent');
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            crn.edit(row_id, parent);
        }
        function duplicate_all(){
            var parent = $('input:checked', grid_left).closest('.check').attr('parent');
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            crn.duplicate_all(row_id, parent);
            updatelist();

        }
        function duplicate(){
            var parent = $('input:checked', grid_left).closest('.check').attr('parent');
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            crn.duplicate(row_id, parent);
        }
//        function transfer(){
//            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
//            crn.transfer(row_id);
//        }
        function show_doc(){
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            crn.show_doc(row_id);
        }
        function show_doc_site(){
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            window.open('/news/'+row_id, '_blank');
            crn.show_doc(row_id);
        }


        var rows = document.querySelectorAll('.rows');
        for (var i = 0; i < rows.length; i++) {
            Sortable.create(rows[i], {
                onEnd: function (evt) {
                    // if move up the works next
                    // if move down the works prev
                    // down - next, up - prev.  !!!!!!!!!   TODO если тянуть верх то верзний не надоит, если тянуть вниз то нижний
                    //console.log('evt.oldIndex, evt.newIndex==========>>>');
                    console.log('evt.item', evt.item);
                    var $p = $(evt.item).prev('.cell').attr('recid');
                    var $n = $(evt.item).next('.cell').attr('recid');
                    var doc_id = $(evt.item).attr('recid');
                    console.log('prev()===>', $(evt.item).prev('.cell'), 'next()===>', $(evt.item).next('.cell') , 'doc_id', doc_id);
                    //console.log('prev()===>', $p, 'next()===>', $n , 'doc_id', doc_id);
                    sort_date($p, $n, doc_id);
                },
                onUpdate: function (/**Event*/evt) { },
                handle: '.fa-arrows',
                //draggable: ".cell",
                animation: 150
            });
        }
        function sort_date($p, $n, doc_id){
            $.ajax({
                url: '/table/sort/date',
                type: "POST", dataType:"json",
                data: {
                    doc_id: doc_id,
                    prev:$p,
                    next:$n
                },
                beforeSend: function(){
                    dao.status_bar('Подгружается', true);
                },
                success: function(data){
                    if(data.result =='ok') updatelist();
                    else  console.error('server_error: '+data.error, data.need_action);
                },
                error:function(data, status, error){
                    console.error('ajax_error: ('+status+') '+aaa);
                }
            });

        }


        var ta = new dao.add_processor({
            url:'/view_table',
            id: options.id
            // columns: pm_map
        });
        function edit_field(){ ta.edit_field(); }

        function add_field(){ ta.add_field(); }

        function del_field(){ ta.del_field(); }

        function bulk_rows(){ crn.table_in_dialog(options); }

        function error_status(mess, action){ dao.error_status(mess, action); }

        function make_in(){ work_invoice("/make_in", "изготовление") }

        function make_out(){ work_invoice("/make_out", "разборку") }

        function checkout(){
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            if(!data_values[row_id]['status']) work_invoice("/check_invoice", "проведение");
            else dao.error_status('Документ уже проведен');
        }

        function work_invoice(action, mess){
            var dialog = $("<div></div>");
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            dialog.attr('title', params.title);
            dialog.dialog({
                bgiframe: true, autoOpen: true, height: 200, width: 200, modal: true,
                buttons: {
                    'Ok': function(){
                        $.ajax({
                            type: "POST", dataType: "json",
                            url: action,
                            data: { proc_id: options.id, doc_id: row_id },
                            success: function(data){
                                if (data.result == 'ok') {
                                    dialog.dialog('close');
                                    updatelist();
                                }else{
                                    error_status(data.mess, data.need_action);
                                    dialog.dialog('close');
                                }
                            }
                        });
                    }, 'Отмена': function(){ $(this).dialog('close'); }
                }, close: function(){ delete dialog; }
            }); $('<div>Подтвердите '+mess+'</div>').appendTo(dialog);
        }
        // document.title; document.location.href; window.location.hash
        function di_from_free_stock(){
            transition_doc('ci_from_free_stock');
        }
        function make_income_cash_order(pw){
            transition_doc('auto_fill_cash_order', 'income_cash');
        }
        function make_outcome_cash_order(pw){
            transition_doc('auto_fill_cash_order', 'outcome_cash');
        }
        function transition_doc(action, tab){
//            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            var row_id = $('input:checked', grid_left);
            var proc_id = '';
            if(tab=='income_cash') proc_id = 'des:income_cash_order';
            if(tab=='outcome_cash') proc_id = 'des:outcome_cash_order';
            var ids = {};
            $.each(row_id, function(i, v){
                var per = $(v).closest('.cell').attr('recid');
                ids[per] = per;
            });
            $.ajax({
                type: "POST", dataType: "json", url: '/table/add_cash_rows/',
                data: {
                    proc_id: proc_id,
//                    action: action, //                    doc_id: row_id,
                    ids: JSON.stringify(ids)
                },
                success: function(data){
                    if (data['result'] == 'ok') {
//                        window.open('http://'+window.location.host+'/table/data/'+data['link']+'#select_id='+data['id']);
                        if(tab=='income_cash') open_tab('des:income_cash_order', data['id']);
                        if(tab=='outcome_cash') open_tab('des:outcome_cash_order', data['id']);
                    }else{ error_status(data['mess'], data.need_action); }
                }
            });
        }

        function print_excel(){ work_print("print_excel"); }

        function print_excel_list(){ work_print("print_excel_list"); }

        function print_pdf(){ work_print("print_pdf"); }

        function work_print(action){
            var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
            if(action == 'print_excel') url = row_id ? '/report_doc' : '/report_list';
            else url = row_id ? '/report_doc_pdf' : '/report_list_pdf';
            $.ajax({
                type: "POST", dataType: "json", url: url,
                data: { proc_id: options['id'], action: action, doc_id: row_id, filter: JSON.stringify(filter) },
                success: function(data){
                    if (data.result == 'ok') {
                        $('<iframe src = "'+data.link+'" />').appendTo("body"); //удалить фрейм если что.
                    }else{ error_status(data['mess'], data.need_action); }
                }
            });
        }

        function _toggle_tree(){ return _is_tree_visible() ? _hide_tree() : _show_tree(); }

        function _is_tree_visible(){ return tree_place.is(':visible') }

        function _show_tree(){
            if (!_is_tree_visible()) {
                tree_place.show();
                main.css('right', tree_place.width()+4+'px');
                updatelist();
            }
        }

        function _hide_tree(){
            if (_is_tree_visible()) {
                tree_place.hide();
                main.css('right', '0px');
                updatelist();
            }
        }
    };
})(jQuery);

