<div class="inner">
    <div class="add_rb_" proc_id="{{proc_id}}"> </div>

    <div class="mainw" style="margin:20px; z-index:1;">

        <div class="overall">
            <h3>Идентификатор</h3>
            <div class="form-group">
                <label for="input1" class="col-sm-1 control-label">Id</label>
                <div class="col-sm-11"><input id="input1" class="form-control id_ref" type="text" name="id" placeholder="obj"> </div>
            </div>
            <h3>Название</h3>
            <div class="form-group">
                <label for="input2" class="col-sm-1 control-label">RU</label>
                <div class="col-sm-11"><input id="input2" class="form-control name_ru" type="text" name="name_ru" placeholder="Название"> </div>  <br/>
            </div>
            <div class="form-group">
                <label for="input2" class="col-sm-1 control-label">EN</label>
                <div class="col-sm-11"><input id="input2" class="form-control name_en" type="text" name="name_en" placeholder="Название"> </div>
            </div>
        </div>

        <h3>Тип справочника</h3>
        <div class="radio">
            <label> <input type="radio" name="is_doc" id="rad1" value="option1" checked> Справочник </label>
        </div>
        <div class="radio">
            <label> <input type="radio" name="is_doc" id="rad2" value="option2"> Документ </label>
        </div>
        <div class="radio disabled">
            <label> <input type="radio" name="is_doc" id="rad3" value="option3" > Форум </label>
        </div>

        <div class="is_comm">
            <h3>Наличие комментариев</h3>
            <div class="radio">
                <label> <input type="radio" name="is_comm" id="rad4" value="option4"> Yes </label>
            </div>
            <div class="radio disabled">
                <label> <input type="radio" name="is_comm" id="rad5" value="option5" checked> Not </label>
            </div>
        </div>

        <h3>Наследование документа</h3>
        <select class="form-control sel_ref"><option value="des:obj"></option></select> <br/>

        <div class="btn btn-default mainw_ok">Ok</div>
    </div>
</div>
<script type="text/javascript">
$(function() {

    var mainw = $('.mainw');
    var rb_id = null;
    var sel = $('.sel_ref');
    var label_visible = $('.is_comm');
    var overall = $('.overall');

    dao.get_list_rb(sel);
    mainw.find('input[name=is_doc]').change(function () {
        if (mainw.find('input[name=is_doc]:checked').val() == 'forum' || mainw.find('input[name=is_doc]:checked').val() == 'obj') {
            label_visible.hide();
            overall.hide();
            sel.hide();
            $('.id_ref').val('forum');
            $('.name_ru').val('Форум');
            $('.name_en').val('Forum');
        }
        if (mainw.find('input[name=is_doc]:checked').val() != 'obj' && mainw.find('input[name=is_doc]:checked').val() != 'forum') {
            label_visible.val('').show();
            overall.val('').show();
            sel.show();
        }
    });
    sel.on('change', function () {
        rb_id = sel.val();
    });
    mainw.on('click', '.mainw_ok', function () {
        var inputs = $('.mainw').find('input,select,textarea');
        var data = {'table': []};
        inputs.each(function () {
            var n = $(this).attr('name');
            var v = $(this).val();
            if ($(this).attr('type') == 'radio' && !$(this).attr('checked')) { }
            else   data[$(this).attr('name')] = $(this).val();
        });
        $.ajax({
            type: "POST", dataType: "json", url: '/add_ref',
            data: {owner: rb_id, data: JSON.stringify(data)},
            success: function (data) {
                if (data.result == 'ok') alert('Справочник создан');
            }
        });
    });

});
</script>






