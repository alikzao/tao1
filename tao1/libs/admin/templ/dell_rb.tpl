<div class="inner">
    <div class="dell_rb" proc_id="{{proc_id}}"> </div>
</div>


<script type="text/javascript">
$(function(){

    dell_rb();

    function dell_rb(){
        var aaa = $('.dell_rb');
        var mainw = $('<div style="position:relative; margin:20px;"></div>').appendTo(aaa);
        var form = $('<form></form>').appendTo(mainw);
        var formbody = $('<fieldset></fieldset>').appendTo(form);
        var nest = $('<div class="nest"></div>').appendTo(formbody);

        var rb_id = null;
        var label_visible = $('<div class="rad" style="border: solid 1px black; width:100px; padding:4px; margin:4px;">Наличие коментариев</div>').addClass('ui-corner-all').appendTo(nest);
        $('<label>Удалить документы</label><input type="radio" name="is_del_doc" value="off" checked="checked" />' +
            '<label>Перенести в общий справочник</label><input type="radio" name="is_del_doc" value="on" />').appendTo(label_visible);

        var sel = $('<select ><option value="des:obj"></option></select>').appendTo(nest);
        var urls = ''+document.location+'';
        var url = urls.split('/');
        dao.get_list_rb(sel);
        sel.change(function(){
            rb_id = sel.val();
        });
        var ok = $('<div class="btn btn-default">Ok</div>').appendTo(nest).wrap('<div></div>');
        ok.click(function(){
            var is_del_doc=$("input:checked[name=is_del_doc]").val();;
            $.ajax({
                type: "POST", url:'/del_ref', dataType:"json",
                data:{
                    rb_id: rb_id,
                    is_del_doc: is_del_doc
                },
                success: function(data){
                    if (data.result == 'ok') {alert('Справочник удален'); }
                }
            });
        });
    }
});


</script>






