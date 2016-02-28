

function add_func(aaa){
    var mainw = $('<div style="position: relative"></div>').appendTo(aaa);
    var rb_id = null;
    var form = $('<form><form>').appendTo(mainw);
    var formbody = $('<fieldset></fieldset>').appendTo(form);
    var nest = $('<div class="nest"></div>').appendTo(formbody);

    var rb_id, event_id, func_id;
    $('<label>Название функции</label>').appendTo(nest);
    var sel_func = $('<select id="sel_func"><option value="des:obj"></option></select>').appendTo(nest);
    $('<div class="crf">Новая функция</div>').appendTo(nest); $('.crf').button();
    var sss = $('<label>Название</label>').appendTo(nest);
    var title = $('<input type=text name="name" />').appendTo(nest);
    var ss = $('<label>Описание</label>').appendTo(nest);
    var descr = $('<input type=text name="descr" />').appendTo(nest);
    $('.crf').click(function(){
        myCodeMirror.setValue('');
        code.val('');
        title.val('');
        descr.val('');
    });
    dao.get_list_func(sel_func);
    sel_func.change(function(){
        dao.get_func_text(myCodeMirror, sel_func.val(), descr, title )
    });
    $('<label>Функция</label>').appendTo(nest);
    var code = $('<textarea id="func_a" name="func" style="height:200px; width:350px; border:1px solid blue; text-align:left;"/>').appendTo(nest);
    var myCodeMirror = CodeMirror.fromTextArea(document.getElementById('func_a'), {
        lineNumbers: true,               // показывать номера строк
        matchBrackets: true,             // подсвечивать парные скобки
        mode:  "python",
        theme: "rubyblue",
        //mode: 'application/x-httpd-php', // стиль подсветки
        indentUnit: 4                    // размер табуляции
    });
    var ok = $('<div>Сохранить</div>').button().appendTo(nest).wrap('<div></div>');
    ok.click(function(){
        var inputs = aaa.find('input,select,textarea');
        var data = { 'table':[] };
        inputs.each(function(){
            if ($(this).attr('name')) { data[$(this).attr('name')] = $(this).val(); }
        });
        data['func'] = myCodeMirror.getValue();
        $.ajax({
            type: "POST", dataType:"json", url:'/add_func',
            data:{ rb_id:rb_id, data:JSON.stringify(data) },
            success: function(data){
                if (data['result'] == 'ok') {alert('Функция сохранена'); }
            }
        });
    });
}
function sandbox(aaa){
    var mainw = $('<div style="position: relative"></div>').appendTo(aaa);
    var rb_id = null;
    var form = $('<form><form>').appendTo(mainw);
    var formbody = $('<fieldset></fieldset>').appendTo(form);
    var nest = $('<div class="nest"></div>').appendTo(formbody);

    var rb_id, event_id, func_id;
    var t_sel = $('<table><tr></tr></table>').appendTo(nest);
    var div_sel_rb = $('<td></td>').appendTo(t_sel);
    var div_sel_event = $('<td></td>').appendTo(t_sel);
    var div_sel_func = $('<td></td>').appendTo(t_sel);
    $('<label>Справочник</label>').appendTo(div_sel_rb);
    var sel_rb = $('<select size="9" id="sel_rb" name="proc_id"><option value="des:obj"></option></select>').appendTo(div_sel_rb);
    $('<label>Название события</label>').appendTo(div_sel_event);
    var sel_event = $('<select size="9" id="sel_event" name="event"><option value="des:obj"></option></select>').appendTo(div_sel_event);
    $('<label>Название функции</label>').appendTo(div_sel_func);
    var sel_func = $('<select size="9" id="sel_func"><option value="des:obj"></option></select>').appendTo(div_sel_func);

    dao.get_list_rb(sel_rb);
    dao.get_list_event(sel_event);
    dao.get_list_func(sel_func);

    sel_rb.change(function(){
        sel_event.empty();
        rb_id = $('.div_rb :selected').val();
        dao.get_list_event(sel_event);
    });
    sel_event.change(function(){
        event_id = sel_event.val();
        dao.get_event_text(myCodeMirror, event_id, sel_rb.val())
    });
    sel_func.dblclick(function(){
        var aaa = sel_func.find(':selected').val();
        myCodeMirror.replaceSelection(aaa);
    });
    $('<label>Функция</label>').appendTo(nest);
    var code = $('<textarea id="func_a" name="code" style="height:200px; width:350px; border:1px solid blue; text-align:left;"/>').appendTo(nest);
    //get(0) вернуть элемент который скрывается за jquery
    var myCodeMirror = CodeMirror.fromTextArea(code.get(0), {
        lineNumbers: true,               // показывать номера строк
        matchBrackets: true,             // подсвечивать парные скобки
        mode:  "python",
        theme: "rubyblue",
        //mode: 'application/x-httpd-php', // стиль подсветки
        indentUnit: 4                    // размер табуляции
    });
    var ok = $('<div>Ok</div>').button().appendTo(nest).wrap('<div></div>');
    ok.click(function(){
        var inputs = aaa.find('input,select,textarea');
        var data = { 'table':[] };
        inputs.each(function(){
            if ($(this).attr('name')) {
                data[$(this).attr('name')] = $(this).val();
            }
        });
        data['code'] = myCodeMirror.getValue();
        $.ajax({
            type: "POST", dataType: "json", url: '/sandbox',
            data: { data: JSON.stringify(data) },
            success: function(data){
                if (data['result'] == 'ok') { alert('Изменения сохранились') }
            }
        });
    });
}
