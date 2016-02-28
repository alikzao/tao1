
<div class="add_func" proc_id="{{proc_id}}"> </div>


<script type="text/javascript">
$(function(){

    add_func();

    function add_func(){
        var aaa = $('.add_func');
        var mainw = $('<div style="position:relative; margin:20px;"></div>').appendTo(aaa);
        var rb_id = null;
        var form = $('<form></form>').appendTo(mainw);
        var formbody = $('<fieldset></fieldset>').appendTo(form);
        var nest = $('<div class="nest"></div>').appendTo(formbody);

        var rb_id, event_id, func_id;
        $('<label>Название функции</label>').appendTo(nest);
        var sel_func = $('<select id="sel_func" class="form-control"><option value="des:obj"></option></select>').appendTo(nest);
        $('<div class="crf">Новая функция</div>').appendTo(nest); $('.crf').button();
        var sss = $('<label>Название</label>').appendTo(nest);
        var title = $('<input type=text name="name" class="form-control"/>').appendTo(nest);
        var ss = $('<label>Описание</label>').appendTo(nest);
        var descr = $('<input type=text name="descr" class="form-control"/>').appendTo(nest);
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
        var code = $('<textarea id="func_a" name="func" class="form-control" style="height:200px; width:350px; border:1px solid blue; text-align:left;"/>').appendTo(nest);
        var myCodeMirror = CodeMirror.fromTextArea(document.getElementById('func_a'), {
            lineNumbers: true,               // показывать номера строк
            matchBrackets: true,             // подсвечивать парные скобки
            mode:  "python",
            theme: "rubyblue",
            //mode: 'application/x-httpd-php', // стиль подсветки
            indentUnit: 4                    // размер табуляции
        });
        var ok = $('<div class="btn btn-default" style="margin-top:10px;">Сохранить</div>').appendTo(nest).wrap('<div></div>');
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
                    if (data.result == 'ok') {alert('Функция сохранена'); }
                }
            });
        });
    }
});


</script>






