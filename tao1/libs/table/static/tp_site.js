;(function($) {
    // используется для создания удаления и редактирования документов
    var defaults = {}
    window.dao.tp_site = function (parent, params){
        //10 миллионов местные, выше федеральные власти.
        var options = $.extend({}, defaults, params);
        var width_window = document.body.clientWidth;
        var height_window = document.body.clientHeight;
        var dialog;
        // window.onunload = function() {

        function error_status(mess, action){
            dao.error_status(mess, action);
        }
        function pub(row_id, action){
            $.ajax({
                type: "POST", url: '/table/pub', dataType: "json",
                data: {
                    proc_id: options.proc_id,
                    action: action,
                    row_id: row_id
                },
                beforeSend: function(){
                    dao.status_bar('В процессе', true);
                },
                success: function(data){
                    if (data['result'] == 'ok') {
                        dao.status_bar('', false);
                        // window.location.reload();
                    }else{
                        dao.error_status(data.error, data.need_action)
                    }
                }
            });
        }
        function show_doc(row_id){
            var new_tab = window.open('/mongodb#find/_id/'+row_id);
//                    var class_name = new_tab.document.getElementsByClassName('search');
//                    $(class_name).find('[name="find"]').click();
        }

        function duplicate_all(doc_id, parent){
            console.log(   {'data':{'proc_id':options.proc_id, 'parent':parent, 'doc_id':doc_id }} );
            $.ajax({
                type: "POST", url: '/table/copy/doc', dataType: "json",
                data: {
                    proc_id: options.proc_id,
                    parent: parent,
                    doc_id: doc_id
                },
                beforeSend: function(){
                    dao.status_bar_box('Дублируется', true);
                },
                success: function(data) {
                    if (data.result == 'ok'){
                        alert('Документ скопирован');
                        if(options.on_success && options.on_success.call){options.on_success(data);}
                    }else dao.error_status(data.error, data.need_action)
                }
            });
        }

        function duplicate(old_row_id, parent){
            $.ajax({
                type: "POST", url: '/table/get_row', dataType: "json",
                data: {
                    proc_id: options.proc_id,
                    parent: parent,
                    action: 'duplicate_doc',
                    row_id: old_row_id
                },
                beforeSend: function(){
                    dao.status_bar_box('Дублируется', true);
                },
                success: function(data){
                    if (data.result == 'ok') {
                        init_cr(data.row_id, false, data.updated, parent);
                    }else{
                        dao.error_status(data.error, data.need_action)
                    }
                }
            });
        }

        function edit(row_id, parent){
            $.ajax({
                type: "POST", dataType: "json", url: '/table/get_row',
                data: {
                    proc_id: options.proc_id,
                    // action: 'get_edit_row',
                    row_id: row_id
                },
                beforeSend: function(){
                    dao.status_bar_box('Редактируется', true);
                },
                success: function(data){
                    if (data.result == 'ok') {
                        init_cr(row_id, true,  data.updated, parent, data.branch_id);
                        //init_cr(row_id, false, data.updated, bid,   parent,       cb);
                    }else{
                        dao.error_status(data.error, data.need_action)
                    }
                }
            });
        }
        function create(par, owner, parent, bid, cb){
            // bid - branch_id
                                        console.log('parent0000======================>', parent);

            $.ajax({
                type: "POST", dataType: "json", url: '/table/add_row',
                data: {
                    proc_id: options.proc_id,
                    do_create: 1,
                    owner:owner,
                    defaults: JSON.stringify(par)
                },
                beforeSend: function(){
                    dao.status_bar_box('Создается', true);
                },
                success: function(data){
                    if (data.result == 'ok') {
                        var row_id = data.id;
                        init_cr(row_id, false, data.updated, parent, bid, cb );
                    }else{
                        dao.error_status(data.error, data.need_action)
                    }
                }
            });
        }
        function init_cr(row_id, fill, pre_fill, parent, bid, cb){
                            console.log('parent1111======================>', parent);

            var height_ = document.body.clientHeight;
            var width_ = document.body.clientWidth;
            var row;
            var ctr = 0;
            var dialog_open = false;
            var created = false;
            //вызываем диалог для занесения данных

            dialog = $(
                '<div class="modal" style="width:100%; height:100%; display:none;">'+
        		'<div class="modal-dialog" style="width:70%; height:100%;" >'+
        			'<div class="modal-content" style="width:100%; height:90%;">'+
        				'<div class="modal-header">'+
                            '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Создание документа</h3></div>' +
                            '<div class="modal-body row" style="overflow:auto; position:absolute; top:50px; right:20px; left:20px; bottom:60px;" ></div>' +
                            '<div class="modal-footer" style="position:absolute; bottom:0px; right:0;">' +
                                '<div class="btn-group">'+
                                    '<span  class="btn btn-default cancel" data-dismiss="modal">Закрыть</span>'+
                                    '<span class="btn btn-primary save" data-dismiss="modal">Сохранить</span>'+
                                '</div>' +
        				    '</div>' +
        			    '</div>' +
        		    '</div>' +
        	    '</div>'
            ).appendTo('body');
            dialog.modal();
            dialog.find('.btn.save').on('click', do_ok);
            dialog.find('.btn.cancel').on('click', end_dialog);
            //$(document).on('hidden.bs.modal', function () { });
            //$(document).on('hidden.bs.modal', end_dialog);


            make_fields(row_id, pre_fill, bid);

            window.onbeforeunload = function() { end_dialog(); }

            function end_dialog(){
//                if (!dialog_open) return;
//                dialog_open = false;
                if(!fill && !created){
                    var ids = {};
                    ids[row_id] = row_id;
                    var idsn = [];
                    idsn.push(row_id);
                    $.ajax({
                        type:"POST",  dataType:"json", url:'/table/del_row/'+options.proc_id,
                        data: {
                            idsn:JSON.stringify(idsn),
                            ids:JSON.stringify(ids)
                        },
                        success: function(data){
                            if (data.result == 'ok') { dialog.modal('hide'); }
                        }
                    });
                } else dialog.modal('hide');
            }

            // если функция пишется без скобок то мы её просто передаем
            function do_ok(){
                var inputs = dialog.find('input[type=text],input[type=password],input[type=hidden],input[type=checkbox]:checked,input[type=radio]:checked,select,textarea, div[name]');
//                var inputs = dialog.find('input[type=text],input[type=password],input[type=hidden],input[type=checkbox]:checked,input[type=radio]:checked,select,textarea');
                var data = {};
                var body = '';
                inputs.each(function(){
                    var name = $(this).attr('name');

                    if( $(this).is(':input')) data[name] = $(this).val();
                    else {
                        if ($(this).find('textarea').length) {
                            var ta = $(this).find('textarea');
                            if (ta.data('rich_edit')) data[name] = ta.data('rich_edit').getValue();
                            else data[name] = ta.val();
                        } else {
                            data[name] = $(this).html();
                        }
                    }

//                    if (name == 'body') body = $(this).val();
//                    else data[name] = $(this).val();//.replace('"', '\\"');
                });
                console.log('parent======================>', parent);
                $.ajax({
                    type: "POST", dataType: "json",
                    url: '/table/edit_row/'+options.proc_id,
                    data: {
                        proc_id: options.proc_id,
                        row_id:row_id, parent:parent,
                        do_create:1,
                        data: JSON.stringify( data ),
                        body: body
                    },
                    beforeSend: function(){ dao.status_bar_box('В процессе', true); },
                    success: function(data){
                        if (data.result == 'ok') {
                            created = true;
                            if(options.on_success && options.on_success.call){options.on_success(data);}
                            if (cb && cb.call) cb(row_id);
//                            dialog.dialog('close');
                        }
                        else if (data.result == 'fail') {
                            dao.error_status(data.error, data.need_action)
                        }
                    }
                });
            }
        }
        function make_fields(row_id, pre_fill, bid){
            var form = $('<form><fieldset><div></div></fieldset><form>').appendTo(dialog.find('.modal-body'));
            var formbody = $('fieldset', form);
            var nest = $('div', formbody);
            prepare_form_(row_id, pre_fill);
            //				if(options.proc_id == 'des:obj'){
            //					$('<div> <b>Опубликовать в ЖЖ</b></div>').appendTo(nest);
            //					input = $('<input type="checkbox" value="true" name="jj"/>').appendTo(nest);
            //				}
            if(options.proc_id != 'des:PM'){
                if(bid){
                    input = $('<input type="hidden" value="'+bid+'" name="branch_id"/>').appendTo(nest);
                }else{
                    $('<label><h1>' + dao.translate('Категория') + '</h1></label>').appendTo(nest);
                    var sel1 = $('<select class="form-control" name="branch_id"><option value=""></option></select>').appendTo(nest);
                    dao.get_list_branch(sel1, options.proc_id, bid);
                }
            }
            if(options.proc_id == 'des:ware_class'){
                $('<label><h1>' + dao.translate('Категория') + '</h1></label>').appendTo(nest);
                var sel1 = $('<select class="form-control" name="parent_id"><option value="_">Корень</option></select>').appendTo(nest);
                dao.get_list_doc(sel1, options.proc_id, bid);
            }
            for( var k in prepare_form){
                var v = prepare_form[k];

                // if (v.type == 'label' || v.is_editable == 'false') {
                $('<label><h1>' + v.title + '</h1></label>')
                    .appendTo(nest).attr('title', dao.translate(v.hint)).attr('for', v.field);
                if (v.type == 'label' || v.oncreate != 'edit') {
                    // if (v.type == 'label' ) {
                    $('<p>' + v.value + '</p>').attr('title', v.hint).appendTo(nest);
                } else {
                    if (v.type == 'select') {
                        input = $('<select class="form-control" name="' + v.field + '"></select>').appendTo(nest);
                        init_select(input, v.field, v.value);
                    } else if (v.type == 'cascad_select') {
                        input = $('<select class="form-control" name="' + v.field + '"></select>').appendTo(nest);
                        init_select(input, v.field, v.value);
                        var select_target = options.columns[ v.field]['relation'];
                        dao.get_list_cascad_doc(input, select_target, v.value);
                    } else if (v.type == 'passw') {
                        input = $('<input class="form-control" type="password" name="' + v.field + '"/>').appendTo(nest);
                    } else if (v.type == 'checkbox') {
                        input = $('<input class="form-control" type="checkbox" value="true" name="'+v.field+'"'+ (v.value == 'true' ? " checked='true'" : '')+' enabled="true"/>').appendTo(nest);
                        if(v.field == 'pub') input.attr('checked', 'checked');
                    } else if (v.type == 'rich_edit') {
//                        input = $('<textarea class="t_rich_edit"/>').appendTo(nest).val(v.value).attr('name', v.field);
                        input = $('<div class="t_rich_edit" style="min-height:200px; max-height:500px; border:3px solid #bbb; overflow:auto;"></div>').appendTo(nest).html(v.value).attr('name', v.field);
                        var par = { //опции нужны для файлого менеджера для добавления картинок
                            url: options.url,
                            id: options.proc_id,
                            doc_id: row_id,
                            is_show_close:false
                        };
//                        dao.edit_processor(input, par);
                        var te_new = new dao.te_new(input, par);
                        te_new.show();

//                        (function(input, par){
//                            setTimeout(function(){dao.edit_processor(input, par)}, 300);
//                        })(input, par);
                    } else {
                        var _type = 'text';

                        input = $('<input class="form-control" type="' + _type + '" />').css({'width':'100%'}).appendTo(nest).val(v.value).attr('name', v.field);
                        if (v.type == 'date') {
                            // input.datepicker();
                            input.datetimepicker({
                                showSecond: true, timeFormat: "hh:mm:ss", dateFormat: "yy-mm-dd",
                                stepHour: 1, stepMinute: 1, stepSecond: 1, hourMin: 0, hourMax: 23,
                                closeText:"Готово", currentText: "Сейчас", timeOnlyTitle: "Выберите время",
                                timeText: "Время", hourText: "Часы", minuteText: "Минуты", secondText: "Секунды",
                                monthNames: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"],
                                monthNamesShort: ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"],
                                dayNamesMin: ["Пн", "Вт", "Ср", "Чт","Пт","Сб","Вс"],
                                onClose: function(){
                                    // $(this).attr("isdate", null);
                                    // _saveField(iddname, input.val(), idd, $(cell));
                                },
                                onSelect: function(d){
                                    // _endEdit(a_cell);
                                }
                            });
                        }
                    }
                    $('[name=simple_style]').attr("checked","checked");
//                    input.addClass("text ui-widget-content ui-corner-all");
                }
            }
        }

        function init_select(input, field_id, edit_value){
            var select_target = options.columns[field_id]['relation'];
            dao.get_list_doc(input, select_target, edit_value);
        }

        var prepare_form = {};
        var ctr = 0;

//                if(options.proc_id != 'des:credit_invoice_ware'){
//                    stock_in_dialog(nest);
//                }
        function table_in_dialog(params){
            var table_id = 'des:credit_invoice_ware';
            dialog = $("<div class='jdialog'></div>");
            dialog.attr('title', 'Добавление');
            var form = $('<form><fieldset><div></div></fieldset><form>').appendTo(dialog);
            var formbody = $('fieldset', form);
            var nest = $('div', formbody);

            dialog.dialog({
                bgiframe: true, autoOpen: true, //		height: 500, width: 750,
                height: document.body.clientHeight-50,
                width: document.body.clientWidth ,
                modal: true,
                buttons: {
                    'Опубликовать': function(){
                        var ids = {};
                        $('.dl input').each(function(){
                            ids[$(this).closest('[recid]').attr('recid')] = $(this).val();
                        });
                        $.ajax({
                            type: "POST", dataType: "json",
                            url: '/table/add_rows/',
                            data: {
                                proc_id:options.proc_id, owner:$('.dl').attr('owner'), ids:JSON.stringify(ids)
                            },
                            beforeSend: function(){ dao.status_bar_box('В процессе', true); },
                            success: function(data){
                                if (data['result'] == 'ok') {
                                    if(options.on_success && options.on_success.call){options.on_success();}

                                    //                                        if (cb && cb.call) cb(row_id);
                                    dialog.dialog('close');
                                }
                                else if (data['result'] == 'fail') { dao.error_status(data.error, data.need_action) }
                            }
                        });
                    },
                    'Отмена': function(){ dialog.dialog('close'); }
                },
                close: function(){ dialog.remove(); delete dialog; }
            });
            var tp = $('<div class="dr" style="position:absolute; left:400px; right:0px; top:0px; bottom:0px; border-left: 1px solid #20b2aa;"></div>').appendTo(nest);
            var dl = $('<div class="dl" owner="'+params.doc_id+'"style="position:absolute; width:400px; left:0px; top:0px; bottom:0px; border-left: 1px solid #20b2aa; padding-top:30px;"></div>').appendTo(nest);

            get_map( function(meta){
                var table = dao.tableprocessor(tp, {
                    url:		window.location.protocol + window.location.host + '/report/ware_stock', //
                    id:		   'ware_stock',
                    columns:meta['map'],
                    actions: meta['actions'],
                    table_in_dialog: true,
                    ajax_url:'/report/',
                    pre_sub:true,
                    parts:{},
                    check_tree: false,
                    has_tree: false,
                    view_mode: 'table',
                    is_editable: true,
                    id_tree: null,
                    hidden_id: true,
                    expanded: true,
                    filt_dates: true,
                    file_manager: { img:false, other:false },
                    dumb:''
                });
            });
            dl.click(function(e){
                var target = $(e.target)
                if (target.is('.del_ware_tid')) {
                    var t = target.closest('[recid]')
                    var recid = t.attr('recid');
                    dialog.find('.column.cb').find('[recid="'+recid+'"]').find(':checkbox').removeAttr('checked');
                    t.remove();

                }
                //                    www.remove();
            });
        }


        function get_map(aaa){
            $.ajax({
                type: "POST", dataType: "json", url: '/report/ware_stock_map',
                data: { },
                success: function(data){
                    if(data.result=="ok"){
                        aaa({'map': data['map'], 'actions': []});
                        //                    edit_doc = data['doc'];
                    }else{ alert(data.error); }
                }
            });
        }
        function prepare_form_(row_id, pre_fill){

            var aaa = [];
            for (var field in options.columns) {
                var val;
                value = options.columns[field];
                if (!value['oncreate'] || value['oncreate'] == 'hide') continue;
                //if (fill) { //если включена опция редактирования или дублирования поля.
                // val = aaa[ctr++]
                // val = pre_fill[field]['value'];
                //}else
                if(pre_fill[field]){
                    val = pre_fill[field]['value'];
                }else {
                    val = value['default'] ? value['default'] : ""
                }
                var element = {
                    'field': value.id,
                    'type': value['type'],
                    'title': value['title'],
                    'hint': value['hint'],
                    'oncreate': value['oncreate'],
                    'is_editable': value['is_editable'],
                    'value': val
                };

                if (value['oncreate'] == 'show' || value['oncreate'] == 'edit') {
                    if (value['oncreate'] == 'show') {
                        element['type'] = 'label';
                    }
                    prepare_form[field] = element;
                }
            }
        }

        function del(ids, idsn){
            $.ajax({
                type: "POST", dataType:"json", url: '/table/del_row',
                data: {
                    proc_id:options.proc_id,
                    ids:JSON.stringify(ids),
                    idsn:JSON.stringify(idsn)
                },
                success: function(data){
                    if (data.result == "ok") {
                        if(options.on_success && options.on_success.call){options.on_success();}
                    } else {
                        dao.error_status(data.error, data.need_action)
                    }
                }
            });
        }

//        function transfer_doc(ids){
//            $.ajax({
//                type: "POST", dataType:"json", url:'/table/transfer',
//                data: { ids:JSON.stringify(ids) },
//                success: function(data){
//                    if (data.result == 'ok') {
//                        dialog.dialog('close');
////                                    window.location.reload();
//                    }else{
//                        dao.error_status(data.error, data.need_action);
//                    }
//                }
//            });
//        }

        function transfer_doc(ids){
            var dialog = $("<div></div>");
            dialog.attr('title', params.title);
            var sel = $('<select class="form-control"><option value="des:obj"></option></select>').appendTo(dialog);
            var url = options['url'].split('/');
            dao.get_list_rb(sel, options.proc_id);

            dialog.dialog({
                bgiframe: true, autoOpen: true, height: 500, width: 300, modal: true,
                buttons: {
                    'Опубликовать': function(){
                        var dialog = $(this); // var to = $(' option:selected').val();
                        var to = sel.val();
                        $.ajax({
                            type: "POST", dataType:"json", url:'/table/transfer',
                            data: {
                                proc_id: options.proc_id,
                                ids: JSON.stringify(ids) ,
                                to: to
                            },
                            success: function(data){
                                if (data['result'] == 'ok') {
                                    if(options.on_success && options.on_success.call){options.on_success(data);}
                                    dialog.dialog('close');
//                                    window.location.reload();
                                }else{
                                    dao.error_status(data.error, data.need_action);
                                }
                            }
                        });
                    },
                    'Отмена': function(){ $(this).dialog('close'); }
                },
                close: function(){ dialog.remove(); delete dialog; }
            });
        }

        this.edit = edit;
        this.show_doc = show_doc;
        this.transfer_doc = transfer_doc;
        this.duplicate = duplicate;
        this.duplicate_all = duplicate_all;
        this.table_in_dialog = table_in_dialog;
        this.del = del;
        this.pub = pub;
        this.create = create;
    } //	$.extend( window.dao, f(jQuery) ); // расширяем
})(jQuery);//(function()



