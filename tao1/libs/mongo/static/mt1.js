
var f = function(){

    /**
     * 1) Рисуем коллекцию в шаблоне и вешаем на клик по ней UpdateList.
     * 2) В упдейтлист вызываем dr - рисование списка документов.
     * 3) В dr вешаем события на раскрытие документа и на все что с ним происходит  ( удаление редактирование  прочее ).
     * 4) В dr рисуем документ если щелкнули по шапке ul_doc.
     * 5) В ul_doc вызываем dr_doc.
     * 6) В dr_doc вешаем события на редактирование документа двойной клик по полю и прочие.
     */

    $('.collection').click(function(){
        ul( $(this).attr('coll_id'));
    });
    var tb = $('.toolbar_b');
    $('<div class="import_db">Импорт базы</div>').appendTo(tb);
    $('<div class="export_db">Экспорт базы</div>').appendTo(tb);
    var db_list = $('.import_db, .export_db');
    db_list.button();
    $('.import_db').click(function(){
        import_db('import_db');
    });
    $('.export_db').click(function(){
        ie_coll_db('export_db');
    });

    function ie_coll_db(action){
        var path
        var coll = $('.docs').attr('coll_id');
//        var db_id = $('.db').attr('db_id');
        var db_id = 'formemob';
        $.ajax({
            type: "POST", url: '/mongo/'+action, dataType: "json",
            data: { coll: coll, db_id:db_id, path:path},
            success: function(data){
                if(data.result=="ok"){
                    window.location = data['link']
//                    dr(data);
                }else{ alert(data.error); }
            }
        });
    }

    function import_db(){
        var dialog = $("<div></div>");
        dialog.attr('title', ''+dao.translate('load_file')+'');

        var uploadForm = $('<form action="/mongo/import_db" enctype="multipart/form-data" method="POST">' +
            '<input name="MAX_FILE_SIZE" value="1000000000" type="hidden" />' +
            '<input name="db_id" value="'+'formemob'+'" type="hidden" />' +
//            '<input name="doc_id" value="'+ curent_doc_id +'" type="hidden" />' +
            '<label>Файл:  <input name="file" class="MultiFile" type="file" /></label>' +
            '</form>').appendTo(dialog);
        //форма загрузки картинок
        uploadForm.ajaxForm({
            type: "POST",
            dataType: "html",
//            beforeSubmit: function(){ img_large.attr('src', '/static/core/img/wait.gif'); },
            success: function(data){ dialog.dialog('close'); }
        });
        dialog.dialog({
            autoOpen: true, height: 200, width: 300, modal: true,
            close: function(){
                delete uploadForm;
                delete dialog;
            },
            buttons: { 'Загрузить':function(){ uploadForm.submit(); } }
        });
    }

    $('.search input').keydown(function(e){
        if(e.which == 13){
            search_mongo();
        }
    });
    function search_mongo(){
        on_update = search_mongo;
        $.ajax({
            type: "POST", url: '/mongo/search_docs', dataType: "json",
            data: { condition: $('.search input[name="id"]').val(), field:$('.search [name=field]').val()},
            success: function(data){
                if(data.result=="ok"){
                    tb.empty();
                    dr(data);
                }else{ alert(data.error); }
            }
        });
    }
    var coll;
    function ul(_coll){
        on_update = ul;
        coll = _coll;
        $.ajax({
            type: "POST", url: '/mongo/get_coll', dataType: "json",
            data: { coll: coll },
            success: function(data){
                if(data.result=="ok"){
                    tb.empty();
                    dr(data, coll);
                }else{ alert(data.error); }
            }
        });
    }


    function dr(data, coll, db_id){
        var docs = $('.docs').empty();
        $('.docs').attr('coll_id', coll);
//        var docs = $('.db_id').empty();
        $('.docs').attr('db_id', db_id);
        for(var res in data['docs']){
            var aaa = data.docs[res];
            var doc = $('<div class="doc collapsable collapsed" doc_id="'+aaa['_id'] +'"></div>').appendTo(docs);
            var t = $('<div class="title"> '+aaa['_id']  +' </div>').appendTo(doc);
            var edit = $('<div class="img_edit" style="display:inline-block;"> <img class="edit_doc"src="/static/core/img/edit.png"/></div>').appendTo(t);
            var del = $('<div class="img" style="display:inline-block;"> <img class="del_doc"src="/static/core/img/cancel.png"/></div>').appendTo(t);
            if( aaa['_coll']){
                doc.attr('coll_id', aaa['_coll']);
                t.append(' ('+aaa['_coll']+')');
                delete aaa['_coll'];
            }else{
                doc.attr('coll_id', coll);
            }
            $('<div class="content"></div>').appendTo(doc);
        }
        $('.doc > .title').click(function(){
            if ($(this).closest('.collapsable').toggleClass('collapsed expanded').is('.collapsed')) return;
            ul_doc(
                $(this).closest('.collapsable').attr('doc_id'),
                $(this).closest('.collapsable').find('.content:first'),
                $(this).closest('.collapsable').attr('coll_id')
            );
        });
        $('.del_doc').click(function(){
            if(confirm('Хотите удалить документ?')){
                del_doc(
                    $(this).closest('.doc').attr('doc_id'),
                    $(this).closest('.doc'),
                    $(this).closest('.doc').attr('coll_id'));
            }
            return false;
        });
        $('<div class="import_coll">Импорт колекции</div>').appendTo(tb);
        $('<div class="import_coll">Експорт колекции</div>').appendTo(tb);
        $('<div class="create_doc">Создать </div>').appendTo(tb);
        var coll_list = $('.import_coll, .export_coll, .create_doc');
        db_list.remove();

        coll_list.button();
        $('.create_doc').click(function(){
            create_docm('/mongo/create_doc');
        });
        $('.edit_doc').click(function(){
            edit_docm('/mongo/edit_doc', doc=$(this).closest('.doc').attr('doc_id') );
            return false;
        });
        $('.import_coll').click(function(){
            ie_coll_db('import');
        });
        $('.export_coll').click(function(){
            ie_coll_db('export');
        });
    }

    function del_doc( doc_id, target,  _coll){
        $.ajax({
            type: "POST", url: '/mongo/del_doc', dataType: "json",
            data: { coll: _coll ? _coll : coll, doc_id:doc_id },
            success: function(data){
                if(data.result=="ok"){
                    target.remove();
                }else{ alert(data.error); }
            }
        });
    }
    function ul_doc( doc_id, target, _coll){
        $.ajax({
            type: "POST", url: '/mongo/get_doc', dataType: "json",
            data: { coll: _coll ? _coll : coll, doc_id:doc_id },
            success: function(data){
                if(data.result=="ok"){
                    $(target).empty();
                    dr_doc(data['doc'], target);
                }else{ alert(data.error); }
            }
        });
    }

    function dr_doc( data, target, collapsed){
        var doc = $(target);//.empty();
        for(var res in data){
            var r = $('<div class = "row collapsable"></div>').appendTo(doc);
            var t = $('<div class = "title">'+res+'</div>').appendTo(r);
            var c = $('<div class = "content "></div>').appendTo(r);
            if (typeof data[res] == 'object') {
                dr_doc (data[res], c, true);
                r.addClass('complex collapsed')
                if(res != '_id' ) t.data('edit_value', res);
            }else {
                c.text( '"'+data[res] + '"');
                c.data('edit_value', data[res]);
                if(res != '_id' ) t.data('edit_value', res);
                r.addClass('primitive')
            }
        }
        $(' > .row > .title', target).click(function(){
            $(this).closest('.collapsable').toggleClass('collapsed expanded')
        });
        $(' > .row > .title', target).dblclick(function(e){
            edit_key($(this));
            var old_val = $(this).find('input').val();
            $(this).find('input').keydown(function(e){
                if(e.which == 13){
//                    dao.vd(get_path_doc($(this)));
                    end_edit_key(
                        $(this).val(),
                        get_path_doc($(this)),
                        $(this).closest('.doc').attr('doc_id'),
                        $(this).closest('.collapsable').find('.title:first'),
                        $(this).closest('.doc').attr('_coll')

                    )
                }else if(e.which == 27){
                    target.find('.editor').remove();
                }
            });
        });
        $(' > .row > .content', target).dblclick(function(e){
            edit_val($(this));
            $(this).find('input').val();
            $(this).find('input').keydown(function(e){
                if(e.which == 13){
//                    dao.vd(get_path_doc($(this)));
                    end_edit_val(
                        $(this).val(),
                        get_path_doc($(this)),
                        $(this).closest('.doc').attr('doc_id'),
                        $(this).closest('.collapsable').find('.content:first'),
                        $(this).closest('.doc').attr('_coll')
                    )
                }else if(e.which == 27){
                    target.find('.editor').remove();
                }
            });
        });
    }

    function get_path_doc(target){
        var path = []; var cursor = target;
        while( cursor.length && !cursor.is('.doc')){
            if(cursor.is('.row')) path.push(cursor.find('.title:first').data('edit_value'));
            cursor = cursor.parent();
        }
        return path;
    }
    function edit_key(target){
        var d = target.data('edit_value');
        if(!d) return;
        var e = $('<div class = "editor"></div>').appendTo(target);
        var i = $('<input type="text" />').appendTo(e);
        i.val(d);
    }
    function end_edit_key(new_val, old_path, doc_id, target, _coll){
        if (!old_path.length) return;
        var new_path = old_path.slice();
        new_path[0] = new_val;
        $.ajax({
            type: "POST", url: '/mongo/edit_key', dataType: "json",
            data: { coll: _coll ? _coll : coll, new_val:JSON.stringify(new_path), old_val:JSON.stringify(old_path), doc_id:doc_id},
            success: function(data){
                target.empty().text(new_val);
                target.data('edit_value', new_val);
            }
        });
    }
    function edit_val(target){
        var d = target.data('edit_value');
        if(!d) return;
        var e = $('<div class = "editor"></div>').appendTo(target);
        var i = $('<input type="text" />').appendTo(e);
        i.val(d);
    }

    function end_edit_val(new_val, old_path, doc_id, target, _coll){
        if (!old_path.length) return;
        $.ajax({
            type: "POST", url: '/mongo/edit_val', dataType: "json",
            data: { coll: _coll ? _coll : coll, new_val:new_val, old_val:JSON.stringify(old_path), doc_id:doc_id},
            success: function(data){
                target.empty().text(new_val);
                target.data('edit_value', new_val);
            }
        });
    }

    function create_docm(url){
        var dialog = $("<div></div>");
//        var row_id = $('input:checked', grid_left).closest('.check').attr('recid');
        dialog.attr('title', 'Редактированме документа');
        dialog.dialog({
            bgiframe: true, autoOpen: true, height: 500, width: 600, modal: true,
            buttons: {
                'Ok': function(){
                    $.ajax({
                        type: "POST", dataType: "json", url: url,
                        data: { coll: $('.docs').attr('coll_id'), doc:texta.val(), doc_id:''},
                        success: function(data){
                            if(data.result=="ok"){
                                ul(data.coll);
                                dialog.dialog('close');
                            }else{ alert(data.error); }
                        }
                    });
                }, 'Отмена': function(){ $(this).dialog('close'); }
            }, close: function(){ delete dialog; }
        }); //$('<div>Подтвердите '+mess+'</div>').appendTo(dialog);

        var form = $('<form><fieldset><div></div></fieldset><form>').appendTo(dialog);
        var formbody = $('fieldset', form);
        var nest = $('div', formbody);
        var text = $('<div style="border: 1px solid red;"> </div>').appendTo(nest);
        var texta = $('<textarea style="width: 400px; height: 400px;"> </textarea>').appendTo(text);
    }
    var on_update = ul;
    function edit_docm(url, doc_id){
        var dialog = $("<div></div>");
        dialog.attr('title', 'Редактированме документа');
        var coll = $('.docs').find('[doc_id="'+doc_id+'"]').attr('coll_id');
        dialog.dialog({
            bgiframe: true, autoOpen: true, height: 500, width: 600, modal: true,
            buttons: {
                'Ok': function(){
                    $.ajax({
                        type: "POST", dataType: "json", url: url,
                        data: { coll: coll, doc:texta.val(), doc_id:doc_id },
                        success: function(data){
                            if(data.result=="ok"){
                                on_update(data.coll);
                                dialog.dialog('close');
                            }else{ alert(data.error); }
                        }
                    });
                }, 'Отмена': function(){ $(this).dialog('close'); }
            }, close: function(){ delete dialog; }
        }); //$('<div>Подтвердите '+mess+'</div>').appendTo(dialog);

        var form = $('<form><fieldset><div style="font-size: 14px; font-weight: bold;"></div></fieldset><form>').appendTo(dialog);
        var formbody = $('fieldset', form);
        var nest = $('div', formbody);
        var doc_idd = $('<label style="margin:10px;"> "_id":"'+doc_id+'"</label>').appendTo(nest);
        var text = $('<div style=""> </div>').appendTo(nest);
        var texta = $('<textarea style="width: 100%; height: 400px;"> </textarea>').appendTo(text);
        get_doc(doc_id, coll, function(doc){texta.val(doc);} );
    }
    function get_doc(doc_id, coll, aaa){
        $.ajax({
            type: "POST", dataType: "json", url: '/mongo/get_docm',
            data: { coll: coll, doc_id:doc_id },
            success: function(data){
                if(data.result=="ok"){
                    aaa(data['doc']);
//                    edit_doc = data['doc'];
                }else{ alert(data.error); }
            }
        });
    }

};

$(document).ready(function () {
    if (f) {
        var t = f;
        f = undefined;
        t();
    }
});

function clone(obj) {
    if(obj == null || typeof(obj) != 'object') { return obj; }
    var temp = {};
    for(var key in obj) {
        temp[key] = clone(obj[key]);
    }
    return temp;
}

//;(function($){
//
//    var defaults = {
//    };
//    var default_filter = {
//    };
//    window.dao.tableprocessor = tableprocessor;
//    function mongo(parent, params){
//        var options = $.extend({}, defaults, params);
//        var instance = {
//
//        };
//        return instance;
//    }; //tableprocessor
//})(jQuery);

