
<div class="sandbox" proc_id="{{proc_id}}"> </div>


<script type="text/javascript">
$(function(){

    sandbox();

    function sandbox(){
        var aaa = $('.sandbox');
        console.log(aaa);
        var mainw = $('<div style="position:relative; margin:20px;"></div>').appendTo(aaa);
        var rb_id = null;
        var form = $('<form></form>').appendTo(mainw);
        var formbody = $('<fieldset></fieldset>').appendTo(form);
        var nest = $('<div class="nest"></div>').appendTo(formbody);

        var rb_id, event_id, func_id;
        var t_sel = $('<table><tr></tr></table>').appendTo(nest);
        var div_sel_rb = $('<td></td>').appendTo(t_sel);
        var div_sel_event = $('<td></td>').appendTo(t_sel);
        var div_sel_func = $('<td></td>').appendTo(t_sel);
        $('<label>Справочник</label>').appendTo(div_sel_rb);
        var sel_rb = $('<select class="form-control" size="9" id="sel_rb" name="proc_id"><option value="des:obj"></option></select>').appendTo(div_sel_rb);
        $('<label>Название события</label>').appendTo(div_sel_event);
        var sel_event = $('<select class="form-control" size="9" id="sel_event" name="event"><option value="des:obj"></option></select>').appendTo(div_sel_event);
        $('<label>Название функции</label>').appendTo(div_sel_func);
        var sel_func = $('<select class="form-control" size="9" id="sel_func"><option value="des:obj"></option></select>').appendTo(div_sel_func);

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
        var code = $('<textarea class="form-control" id="func_a" name="code" style="height:200px; width:350px; border:1px solid blue; text-align:left;"/>').appendTo(nest);
        //get(0) вернуть элемент который скрывается за jquery
        var myCodeMirror = CodeMirror.fromTextArea(code.get(0), {
            lineNumbers: true,               // показывать номера строк
            matchBrackets: true,             // подсвечивать парные скобки
            mode:  "python",
            theme: "rubyblue",
            //mode: 'application/x-httpd-php', // стиль подсветки
            indentUnit: 4                    // размер табуляции
        });
        var ok = $('<div class="btn btn-default" style="margin-top:10px;"><i class="icon-ok"></i> Ok</div>').appendTo(nest).wrap('<div></div>');
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
                    if (data.result == 'ok') { alert('Изменения сохранились') }
                }
            });
        });
        return false;
    }

});
</script>