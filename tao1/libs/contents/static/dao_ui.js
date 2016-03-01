;(function($){

    window.dao = {
        fix_mous_event: function(e) {
            // получить объект событие для IE
            e = e || window.event

            // добавить pageX/pageY для IE
            if ( e.pageX == null && e.clientX != null ) {
                var html = document.documentElement
                var body = document.body
                e.pageX = e.clientX + (html && html.scrollLeft || body && body.scrollLeft || 0) - (html.clientLeft || 0)
                e.pageY = e.clientY + (html && html.scrollTop || body && body.scrollTop || 0) - (html.clientTop || 0)
            }
            // добавить which для IE
            if (!e.which && e.button) {
                e.which = e.button & 1 ? 1 : ( e.button & 2 ? 3 : ( e.button & 4 ? 2 : 0 ) )
            }
            return e
        },

        get_select1: function(parent){
            var cw = parent;
//            var cw = main2;
            var text = '';
            if (cw.getSelection) {
                text = cw.getSelection();
            } else if (cw.getSelection) {
                text = cw.getSelection();
            } else if (cw.selection) {
                text = cw.selection;
            }
            return text;
        },

        short_text: function( text, len ) {	// Encodes data with MIME base64
            text = text.replace(/<[^<>]+?>/, ' ');
            text = text.replace(/ +/, ' ');
            return text.substr(0, len);
        },
        ajax: function(url, data, success, error) {
            $.ajax({
                url: url,
                type: 'POST',
                dataType: 'json',
                data: data,
                success: function (result) {
                    if (typeof success == 'function') success(result);
                },
                error: function () {
                    // TODO уведомление об ошибке связи
                    if (typeof error == 'function') error();
                }
            });
        },
        base64_encode: function( data ) {	// Encodes data with MIME base64
            //
            // +   original by: Tyler Akins (http://rumkin.com)
            // +   improved by: Bayron Guevara

            var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/_";
            var o1, o2, o3, h1, h2, h3, h4, bits, i=0, enc='';

            do { // pack three octets into four hexets
                o1 = data.charCodeAt(i++);
                o2 = data.charCodeAt(i++);
                o3 = data.charCodeAt(i++);

                bits = o1<<16 | o2<<8 | o3;

                h1 = bits>>18 & 0x3f;
                h2 = bits>>12 & 0x3f;
                h3 = bits>>6 & 0x3f;
                h4 = bits & 0x3f;

                // use hexets to index into b64, and append result to encoded string
                enc += b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
            } while (i < data.length);

            switch( data.length % 3 ){
                case 1:
                    enc = enc.slice(0, -2) + '__';
                    break;
                case 2:
                    enc = enc.slice(0, -1) + '_';
                    break;
            }
            return enc;
        },
        user_mess: function(mess, type){
            // type:error, type:info
            var t = $('<div class="ui-corner-all mess_'+type +'"><img style="float:right;" onclick="$(this).parent().hide();" ' +
                'src="/static/core/img/cancel.png"> '+mess+' </div>').appendTo($('#user_mess'));
            (function(t){  setTimeout(function(){t.hide()}, 8000); })(t);

        },
         bef: function(target){
            target = target || 'body';
            var aaa = $(
                '<div style="position:fixed; left:0px; right:0; bottom:0px; top:0px; z-index:999999; background-color: rgba(0, 0, 0, .2)">' +
                '<div style="display:inline-table; height:100%; width:100%;">' +
                '<div class="ccc" style=" text-align:center; vertical-align:middle; display:table-cell; ">' +
                '<img src="/static/core/img/wait.gif">' +
                '</div></div></div>').appendTo($(target));
            aaa.click(function(){
            aaa.remove();
            });
            return aaa;
        },
        vd: function (v){
            try { alert(JSON.stringify(v, null, 2));  }
            catch(e) {  alert(e); }
        },

        keys: function(arr){
            var keys = [];
            for( var res in arr){ keys.push(res); }
            return keys;
        },

        trace: function(title, ctr, cb){
            alert('start '+title);
            var start = new Date();
            for (var i = ctr; i > 0; i--) { cb(i); }
            var end = new Date();
            var total = end - start;
            var per_one = total / ctr;
            alert('end '+title+'. Total: '+total+' ms, '+per_one+' ms per 1 iter');
        },

        colect: function(where){
            var inputs = where.find('input[type=text],input[type=password],input[type=hidden],input[type=checkbox]:checked,input[type=radio]:checked,select,textarea');
            var data = {};
            inputs.each(function(){
                data[$(this).attr('name')] = $(this).val();
                dao.log($(this));
            });
            data = JSON.stringify(data);
            return data;
        },

        log: function (mess){
//            if (!$.browser.msie && console && typeof(console.log) == 'function')
                console.log(mess);
        },
        status_bar: function (val, color){
            if (color == true)
                $('.status_bar').css({'background-color':'red'}).text(val);
            else
                $('.status_bar').css({'background-color':'transparent'}).text(val);
        },
        status_bar_box: function (val, color){
            var main = $('.ui-dialog-buttonpane')
            var bar = $('<div></div>');
            if (color == true){
                bar.empty().appendTo(main).css({'background-color':'red', 'width':'400px', 'height':'30px'}).text(val);
            }else
                bar.empty().appendTo(main).css({'background-color':'transparent'}).text(val);
        },

        error_status: function (mess, action){
            var dialog = $("<div></div>");
            dialog.attr('title', "Ошибка");
            dialog.dialog({
                bgiframe: true, autoOpen: true, modal: true, height: 500, width: 900,
                buttons: { 'Ok': function(){dialog.dialog('close');} },
                close: function(){
                    if(action == 'login'){ window.location = '/login'; }
                    delete dialog;
                }
            }); $('<div><h4 style="color:deepskyblue;"><pre style="max-height:400px; ">'+mess+'</pre></h4></div>').appendTo(dialog);
            $('pre pre').css({'height':'450px'})
        },

        conf_docs: function(cb){
            $.ajax({
                type: "POST", url: '/list/conf_docs', dataType: "json",
                data: { proc_id: ''  },
                success: function(data){
                    if (data.result == 'ok'){
                        cb( data.doc )
                    }
                }
            });
        },
        list_field: function(proc_id, sel, cb){
            $.ajax({
                type: "POST", url: '/list/field',dataType: "json",
                data: { proc_id: proc_id, action: 'get_field'  },
                success: function(data){
                    //data = JSON.parse(data);
                    if (data.result == 'ok'){
                        for(var i in data['list_field']){
                            $('<option value="'+data['list_field'][i]['id']+'"> '+data['list_field'][i]['title']+'</option>').appendTo(sel);
                        }
                        if (cb && cb.call) cb();
                    }
                }
            });
        },

        lang_res : [],
        translate: function (subject){

            if (typeof subject == 'object' && subject[this.get_lang()]) return subject[this.get_lang()];
            if (!dao.lang_res[subject])
                return subject;
            return dao.lang_res[subject]
        },

//		get_list_rb: function(sel, url, proc_id){
        get_list_rb: function(sel, type){
            $.ajax({
                type: "POST", dataType: "json", url: '/list/rb',
//				data: { proc_id: 'des:'+proc_id, action: 'get_list_rb'  },
                data: { type: type },
                success: function(data){
                    if (data.result == 'ok'){
                        data['list_rb'].sort(function (a, b) {
                            a = a['title'].toLowerCase(); b = b['title'].toLowerCase();
                            if (a < b) return -1; if (b < a) return 1; return 0;
                        });
                        for(var i in data['list_rb']){
                            $('<option value="'+data['list_rb'][i]['_id']+'"> '+data['list_rb'][i]['title']+'</option>').appendTo(sel);
                        }
//						sel.val(edit_value);
                    }
                }
            });
        },
        get_list_act: function(sel, filter){
            var coll = map_view.model.toJSON();
            for(var i in coll[0]){
                var v = coll[0][i];
                if(v['type'] == filter)
                    $('<option value="'+v['id']+'">'+v['title']+'</option>').appendTo(sel);
            }
        },
        get_list_branch: function (sel1, rb_id, bid, chosen){
            $.ajax({
                type: "POST", url: '/list/branch/'+rb_id, dataType: "json",
                // data: {  action: 'get_list_branch'},
                success: function(data){
                    if (data['result'] == 'ok'){
                        for(var i in data['list_branch']){
                            $('<option value="'+data['list_branch'][i]['id']+'"> '+data['list_branch'][i]['title']+'</option>').appendTo(sel1);
                        }
                        if(chosen) sel1.chosen();
                        sel1.val(bid);
                    }
                }
            });
        },
        list_b: {},
        get_list_branch_: function (sel1, rb_id, bid, chosen){
            var that = this;
            if (that.list_b[rb_id]) draw();
            else {
                $.ajax({
                    type: "POST", url: '/list/branch/'+rb_id, dataType: "json",
                    // data: {  action: 'get_list_branch'},
                    success: function(data){
                        if (data['result'] == 'ok'){
                            that.list_b[rb_id] = data['list_branch'];
                            draw()
                        }
                    }
                });
            }
            function draw() {
                var ld = that.list_b[rb_id];
                var html = '';
                for(var i in ld){
//                    $('<option value="'+ld[i]['id']+'"> '+ld[i]['title']+'</option>').appendTo(sel1);
                    html += '<option value="'+ld[i]['id']+'"> '+ld[i]['title']+'</option>'
                }
                sel1[0].innerHTML = html;
                sel1.val(bid);
                if(chosen) sel1.chosen();
            }
        },

        get_list_cascad_doc: function(rb_id, flter){
            // выбираем только те поля которые соотвествуют выбраному id в соседнем поле
            // id - соседнего поля находится в filter справочнике
            $.ajax({
                type: "POST",dataType: "json", url: '/list/cascad_doc',
                data: { filter:filter, rb_id:rb_id  },
                success: function(data){
                    if (data.result == 'ok'){
                        for(var i in data['list_doc']){
                            $('<option value="'+data['list_doc'][i]['id']+'"> '+data['list_doc'][i]['title']+'</option>').appendTo(sel1);
                        }
                        sel1.val(edit_value);
                        if(chosen) sel1.chosen();
                    }
                }
            });
        },

        get_list_doc: function(sel1, rb_id, edit_value, chosen){
            $.ajax({
                type: "POST",dataType: "json", url: '/list/doc',
                data: { action: 'get_list_doc', rb_id:rb_id  },
                success: function(data){
                    if (data.result == 'ok'){
                        var list_doc = JSON.parse( data.list_doc );
                        for(var i in list_doc){
                            $('<option value="'+list_doc[i].id+'"> '+list_doc[i].title+'</option>').appendTo(sel1);
                        }
                        sel1.val(edit_value);
                        if(chosen) sel1.chosen();
                    }
                }
            });
        },
        list_doc: {},
        get_list_doc_: function(sel1, rb_id, edit_value, chosen){
            // кеширование запросов   если такой запрос уже был то его значение лсохраняется в переменую.
            var that = this;
            if (that.list_doc[rb_id]) draw();
            else {
                $.ajax({
                    type: "POST",dataType: "json", url: '/list/doc',
                    data: { action: 'get_list_doc', rb_id:rb_id  },
                    success: function(data){
                        if (data['result'] == 'ok'){
                            that.list_doc[rb_id] = data['list_doc'];
                            draw()
                        }
                    }
                });
            }
            function draw() {
                var ld = that.list_doc[rb_id];
                var html = '';
                for(var i in ld){
//                    $('<option value="'+ld[i]['id']+'"> '+ld[i]['title']+'</option>').appendTo(sel1);
                    html += '<option value="'+ld[i]['id']+'"> '+ld[i]['title']+'</option>'
                }
                sel1[0].innerHTML = html;

                sel1.val(edit_value);
                if(chosen) sel1.chosen();
            }
        },

        get_select_cacad: function(target, rb_id, doc_id, rel_field, auto_open){
            $.ajax({
                type: "POST", dataType: "json", url:'/list/cascad_doc',
                data: { doc_id:doc_id, rb_id:rb_id, rel_field:rel_field  },
                success: function(data){
                    if (data.result == 'ok'){
                        var list = [];
                        for(var i in data['list_doc']){
                            list.push({'label':data['list_doc'][i]['title'], 'id':data['list_doc'][i]['id'], 'value':data['list_doc'][i]['title']});
                        }
                        target.autocomplete('option', 'source', list);
                        if (auto_open) target.autocomplete('search', '');
                    }
                }
            });
        },
        get_select: function(target, rb_id, auto_open){
            $.ajax({
                type: "POST", dataType: "json", url:'/list/doc',
                data: { action: 'get_list_doc', rb_id:rb_id  },
                success: function(data){
                    if (data.result == 'ok'){
                        var list = [];
                        var list_doc = JSON.parse(data['list_doc']);
                        for(var i in list_doc){
                            list.push({'label':list_doc[i]['title'], 'id':list_doc[i]['id'], 'value':list_doc[i]['title']});
                        }
                        target.autocomplete('option', 'source', list);
                        if (auto_open) target.autocomplete('search', '');
                    }
                }
            });
        },

        get_select_mult: function(target, rb_id, auto_open){
            $.ajax({
                type: "POST", dataType: "json", url:'/list/doc',
                data: { action: 'get_list_doc', rb_id:rb_id  },
                success: function(data){
                    if (data['result'] == 'ok'){
                        var list = [];
                        for(var i in data['list_doc']){
                            list.push({'label':data['list_doc'][i]['title'], 'id':data['list_doc'][i]['id'], 'value':data['list_doc'][i]['title']});
                        }
//                                target.autocomplete('option', 'source', list);
                        target.data('list', list)
                        if (auto_open) target.autocomplete('search', '');
                    }
                }
            });
        },

        get_list_event: function(sel1){
            $('<option value="on_create_row"> '+dao.ct('На создание')+'</option>'+
                '<option value="on_update_row"> '+dao.ct('На обновление')+'</option>'+
                '<option value="on_del_row"> '+dao.ct('На удаление')+'</option>'+
                '<option value="on_create_subtable"> '+dao.ct('На создание подтаблицы')+'</option>'+
                '<option value="on_del_subtable"> '+dao.ct('На удаление подтаблицы')+'</option>'+
                '<option value="on_update_subtable"> '+dao.ct('На обновление подтаблицы')+'</option>').appendTo(sel1);
            sel1.change();
        },
        get_list_func: function(sel1, rb_id, edit_value){
            $.ajax({
                type: "POST",dataType: "json", url: '/list/func',
                data: { action: 'get_list_func', rb_id:rb_id  },
                success: function(data){
                    if (data['result'] == 'ok'){
                        for(var i in data['list_func']){
                            $('<option value="'+data['list_func'][i]+'"> '+data['list_func'][i]+'</option>').appendTo(sel1);
                        }
                        sel1.val(edit_value);
                    }
                }
//				error: function () {alert('error get_list_func');	}
            });
        },
        get_event_text: function(obj_cm, name_func, proc_id){
            $.ajax({
                type: "POST",dataType: "json", url: '/get/event',
                data: { name_func:name_func, proc_id:proc_id },
                success: function(data){
                    if (data['result'] == 'ok'){
                        obj_cm.setValue(data['func_text']);
                    }
                },
                error: function () {obj_cm.setValue('');}
            });
        },
        get_func_text: function(obj_cm, name_func, descr, title, modul){
            $.ajax({
                type: "POST",dataType: "json", url: '/get/func',
                data: { name_func:name_func, modul:modul },
                success: function(data){
                    if (data['result'] == 'ok'){
                        obj_cm.setValue(data['func_text']);
                        descr.val(data['descr_text']);
                        title.val(name_func);
                    }
                },
                error: function () {
                    obj_cm.setValue('');
                    descr.val('');
                    title.val('Встроеная функция.');
                }
            });
        },
        checkInt:  function( value){
            var re = /^[-+]?[0-9]+$/;
            return re.test(value);
        },
        checkFloat: function( value){
            // TODO использование запятой как десятичного разделителя
            var re = /^[-+]?[0-9]+(\.[0-9]+)?$/;
            return re.test(value);
        },
        checkValue: function (editor){
            //this._status('checkvalue');
            var valid = true;
            var celltype = editor.parent().attr("celltype");
            var val = editor.val();
            if (celltype == 'int') { valid = checkInt(val); }
            if (celltype == 'float') { valid = checkFloat(val); }
            return valid;
        },

        key_codes: {
            A: 65,
            D: 68,
            W: 87,
            S: 83,
            BACKSPACE: 8,
            TAB: 9,
            ENTER: 13,
            SHIFT: 16,
            CONTROL: 17,
            ALT: 18,
            PAUSE: 19,
            CAPS_LOCK: 20,
            ESCAPE: 27,
            SPACE: 32,
            PAGE_UP: 33,
            PAGE_DOWN: 34,
            END: 35,
            HOME: 36,
            LEFT: 37,
            UP: 38,
            RIGHT: 39,
            DOWN: 40,
            INSERT: 45,
            DELETE: 46,
            NUMPAD_MULTIPLY: 106,
            NUMPAD_ADD: 107,
            NUMPAD_ENTER: 108,
            NUMPAD_SUBTRACT: 109,
            NUMPAD_DECIMAL: 110,
            NUMPAD_DIVIDE: 111,
            F1: 112,
            F2: 113,
            F3: 114,
            F4: 115,
            F5: 116,
            F6: 117,
            F7: 118,
            F8: 119,
            F9: 120,
            F10: 121,
            F11: 122,
            F12: 123,
            NUMLOCK: 144,
            SCROLLLOCK: 145,
            COMMA: 188,
            PERIOD: 190
        },

        lang: 'ru',

        set_lang: function (_lang) {
            this.lang = _lang;
        },

        get_lang: function () {
            return this.lang;
        },

        on_user_load: function (cb) {
            if(current_user.name) cb()
            else current_user.on_status.push(cb);
        }
    };




    dao.ct = dao.translate;
    window.vd = dao.vd;
    window.log = dao.log;
})(jQuery);

