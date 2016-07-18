;(function(){
var defaults = {};

window.dao.add_processor = function(params){

    var options = $.extend({}, defaults, params);

    var width_window = document.body.clientWidth;
    var height_window = document.body.clientHeight;

    function move_field(){ }

    function edit_field(){
        var edit_field_d = $(
            '<div class="modal">'+
                '<div class="modal-dialog">'+
                    '<div class="modal-content">'+
                        '<div class="modal-header"><button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Редактирование поля</h3></div>' +
                        '<div class="modal-body "><div class="inner nest"></div></div>' +
                        '<div class="modal-footer"><div class="btn-group">'+
                            '<span  class="btn yes btn-primary" data-dismiss="modal">Редактировать</span><span  class="btn cancel btn-danger" data-dismiss="modal">Отмена</span>'+
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>'
        ).appendTo('body');
        edit_field_d.modal();
        edit_field_d.on('click', '.btn.yes', function(){
            var inputs = edit_field_d.find('input,select,textarea');
            var data = {};
            inputs.each(function(){
                if ($(this).attr('type') == 'radio' && !$(this).attr('checked')) {	}
                else { data[$(this).attr('name')] = $(this).val(); }
            });
            var field_id = edit_field_d.find('.nest option:selected').val();
            console.error(['field_id', field_id]);
            $.ajax({
                type: "POST", dataType: "json", url: '/table/edit_field', 
                data: {
                    proc_id: options.id,
                    data: JSON.stringify(data),
                    field_id: field_id
                },
                success: function(data){
                    if (data.result == 'ok') window.location.reload();
                    else console.error(data.error, data.need_action);  //  else dao.error_status(data.error, data.need_action);
                }
            });
        });

        var nest = $('.nest');
        var sel = $('<select class="form-control"></select>').appendTo(nest);
        dao.list_field(options.id, sel);
        var field_id;
        sel.on('mouseup', function(){
            field_id = $('option:selected', nest).val();
            console.log('field_id', field_id);
            $.ajax({
                type:"POST", dataType:"json", url:'/table/get_field',
                data: { proc_id: options.id, field_id: field_id },
                success: function(data){
                    if (data.result == 'ok') {
                        nest.find('.inner').remove();
                        show_add_field(data.val_field, nest);
                        // window.location.reload();
                    }else console.error(data.error, data.need_action);
                }
            });
        });
    }


    function show_add_field(val_field, _nest){

        $('<div class="form-group"><label>'+dao.ct('field_id')+'</label><input class="form-control" type="text" name="id" value="'+val_field.id+'" ></div>'+
            '<label>'+dao.ct('name_field')+'</label><br/>'+
            'рус<br/> <input class="form-control" type="text" name="title_ru" value="'+val_field.title.ru+'"/><br/>'+
            'en<br/>  <input class="form-control" type="text" name="title_en" value="'+val_field.title.en+'"/>'+
            '<label>'+dao.ct('hint_field')+'</label><br/>'+
            'рус <br/> <input class="form-control" type="text" name="hint_ru" value="'+val_field.hint.ru+'"/><br/>'+
            'en  <br/> <input class="form-control" type="text" name="hint_en" value="'+val_field.hint.en+'"/>'+
            '<label>'+dao.ct('edit')+'</label><input class="form-control" type="text" name="oncreate" value="edit" >').appendTo(_nest);

        var nest = $('.nest');
        var label_type = $('<div class="form-group" style="margin-top:8px">'+                       dao.ct('type_field')+
                '<div class="radio"><label><input type="radio" name="type" value="string" checked>'+dao.ct('text')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="type" value="date" >'+         dao.ct('date')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="type" value="passw" >'+        dao.ct('Пароль')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="type" value="rich_edit" >'+    dao.ct('editor')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="type" value="select" >'+       dao.ct('select')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="type" value="cascad_select" >'+dao.ct('Каскадный выбор')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="type" value="checkbox" >'+     dao.ct('flag')+'</label></div>'+
            '</div>').appendTo(_nest);
        var label_visible = $('<div class="form-group">'+                                                   dao.ct('is_visible')+
              '<div class="radio"><label><input type="radio" name="visible" value="true" checked >'+        dao.ct('yes')+'</label></div>'+
              '<div class="radio"><label><input type="radio" name="visible" value="false" >'+               dao.ct('no')+'</label></div></div>').appendTo(_nest);
        var label_is_translate = $('<div class="form-group">'+                                              dao.ct('is_translate')+
                '<div class="radio"><label><input type="radio" name="is_translate" value="true"  >'+        dao.ct('yes')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="is_translate" value="false" checked>'+ dao.ct('no')+'</label></div></div>').appendTo(_nest);
        var label_is_editable = $('<div class="form-group">'+                                               dao.ct('is_edit')+
                '<div class="radio"><label><input type="radio" name="is_editable" value="true" checked />'+ dao.ct('yes')+'</label></div>'+
                '<div class="radio"><label><input type="radio" name="is_editable" value="false" />'+        dao.ct('no')+'</label></div></div>').appendTo(_nest);

        var ddd  = $('<label>'+dao.translate('target_select')+'&nbsp</label>').appendTo(label_type);
        var ggg = $('<select name="relation"/>').appendTo(ddd);
        dao.get_list_rb(ggg, '/menu');
        ddd.hide();
        label_type.find('[value="select"]').on('change', function(){
            ddd.show();
        });

        // todo тут создание еще одного поля  просто собирает значение последнего  а значение поледнего сео,
        // поэтому нужно просто наверно оставить дополнительный и все и не дублировать
        var c_sel_title_label  = $('<label>'+dao.ct('Связанное поле')+'&nbsp</label><br/>').appendTo(label_type);
        var c_sel_title = $('<select name="relation_field"/>').appendTo(c_sel_title_label);
        dao.list_field(options.id, c_sel_title);
        c_sel_title_label.hide();

        label_type.find('[value="cascad_select"]').on('change', function(){
            ddd.show();
            c_sel_title_label.show();
        });

        $('[type=radio]', label_type).removeAttr('checked')         .filter('[value='+val_field.type+']')         .attr('checked', 'checked');
        $('[type=radio]', label_visible).removeAttr('checked')      .filter('[value='+val_field.visible+']')      .attr('checked', 'checked');
        $('[type=radio]', label_is_editable).removeAttr('checked')  .filter('[value='+val_field.is_editable+']')  .attr('checked', 'checked');
        $('[type=radio]', label_is_translate).removeAttr('checked') .filter('[value='+val_field.is_translate+']') .attr('checked', 'checked');
    }

    function add_field(){
         var add_field_d = $(
        	'<div class="modal">'+
        		'<div class="modal-dialog">'+
        			'<div class="modal-content">'+
        				'<div class="modal-header"><button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Добавление поля</h3></div>' +
        				'<div class="modal-body nest" >' +
                            '<label>'+dao.ct('field_id')+'</label><input class="form-control" type="text" name="id" >'+
                            '<label>'+dao.ct('name_field')+'</label>'+
                            '<br/><b>рус</b><input class="form-control" type="text" name="title_ru"/>'+
                            '<b>en</b><input class="form-control" type="text" name="title_en"/>'+
                            '<label>'+dao.ct('hint_field')+'</label>' +
                                                '<br/><b>рус</b><input class="form-control" type="text" name="hint_ru"/>'+
                                                '<b>en</b> <input class="form-control" type="text" name="hint_en"/>'+
                            '<label>'+dao.ct('edit')+'</label><input class="form-control" type="text" name="oncreate" value="edit" >'+
                            '<div class="form-group">'+                                                                     dao.ct('is_visible')+
                                '<div class="radio"><label><input type="radio" name="visible" value="true" checked >'+      dao.ct('yes')+'</label></div>'+
                                '<div class="radio"><label><input type="radio" name="visible" value="false" >'+             dao.ct('no')+'</label></div></div>'+
                            '<div class="form-group">'+                                                                     dao.ct('is_translate')+
                                '<div class="radio"><label><input type="radio" name="is_translate" value="true"  >'+        dao.ct('yes')+'</label></div>'+
                                '<div class="radio"><label><input type="radio" name="is_translate" value="false" checked>'+ dao.ct('no')+'</label></div></div>'+
                            '<div class="form-group">'+                                                                     dao.ct('is_edit')+
                                '<div class="radio"><label><input type="radio" name="is_editable" value="true" checked />'+ dao.ct('yes')+'</label></div>'+
                                '<div class="radio"><label><input type="radio" name="is_editable" value="false" />'+        dao.ct('no')+'</label></div></div>'+
                        '</div>' +
        				'<div class="modal-footer"><div class="btn-group">'+
        				    '<span  class="btn yes btn-primary" data-dismiss="modal">Добавить</span><span  class="btn cancel btn-danger" data-dismiss="modal">Отмена</span>'+
        				'</div>' +
        			'</div>' +
        		'</div>' +
        	'</div>'
        ).appendTo('body');
        add_field_d.modal();
        add_field_d.on('click', '.btn.yes', function(){
            var inputs = add_field_d.find('input,select,textarea');
            var data = {};
            inputs.each(function(){
                if ($(this).attr('type') == 'radio' && !$(this).attr('checked')) { }
                else data[$(this).attr('name')] = $(this).val();
            });
            $.ajax({
                type: "POST",
                url: '/table/add_field',
                data: { proc_id: options.id, data: JSON.stringify(data) },
                dataType: "json",
                success: function(data){
                    if (data.result == 'ok') {
                        //window.location.reload();
                    }
                    else console.error(data.error, data.need_action);
                }
            });
        });
        var label_type = $('<div class="form-group" style="margin-top:8px" class="form-group checkbox">'+   dao.ct('type_field')+
            '<div class="radio"><label><input type="radio" name="type" value="string" checked="checked">'+  dao.ct('text')+'</label></div>'+
            '<div class="radio"><label><input type="radio" name="type" value="html" >'+                     dao.ct('HTML')+'</label></div>'+
            '<div class="radio"><label><input type="radio" name="type" value="date" >'+                     dao.ct('date')+'</label></div>'+
            '<div class="radio"><label><input type="radio" name="type" value="passw" >'+                    dao.ct('Пароль')+'</label></div>'+
            '<div class="radio"><label><input type="radio" name="type" value="rich_edit" >'+                dao.ct('editor')+'</label></div>'+
            '<div class="radio"><label><input type="radio" name="type" value="checkbox" >'+                 dao.ct('flag')+'</label></div>' +
            '<div class="radio"><label><input type="radio" name="type" value="select" >'+                   dao.ct('select')+'</label></div>'+
            '<div class="radio"><label><input type="radio" name="type" value="cascad_select" >'+            dao.ct('Каскадный выбор')+'</label></div>'+
            '</div>').appendTo($('.nest'));

        $('.nest').on('click', '.radio', function(){
            $(this).find('input').attr("checked", "checked");
        });

        var ddd  = $('<label>'+dao.ct('target_select')+'&nbsp</label>').appendTo(label_type);
        var ggg = $('<select name="relation"/>').appendTo(ddd);
        dao.get_list_rb(ggg, '/menu');
        ddd.hide();
        label_type.find('[value="select"]').on('change', function(){
            ddd.show();
        });

        // todo тут создание еще одного поля
        var c_sel_title_label  = $('<label>'+dao.translate('Связанное поле')+'&nbsp</label><br/>').appendTo(label_type);
        var c_sel_title = $('<select name="relation_field"/>').appendTo(c_sel_title_label);
        dao.list_field(options.id, c_sel_title);

        c_sel_title_label.hide();
        label_type.find('[value="cascad_select"]').on('change', function(){
            //c_sel_rb_label.show();
            c_sel_title_label.show();
        });

    }


    function del_field(){
        var del_field_d = $(
        	'<div class="modal">'+
        		'<div class="modal-dialog">'+
        			'<div class="modal-content">'+
        				'<div class="modal-header"><button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Удаление поля</h3></div>' +
        				'<div class="modal-body nest" ></div>' +
        				'<div class="modal-footer"><div class="btn-group">'+
        				    '<span  class="btn yes btn-primary" data-dismiss="modal">Удалить</span><span  class="btn cancel btn-danger" data-dismiss="modal">Отмена</span>'+
        				'</div>' +
        			'</div>' +
        		'</div>' +
        	'</div>'
        ).appendTo('body');
        del_field_d.modal();
        del_field_d.on('click', '.btn.yes', function(){
            var field_id = del_field_d.find('.nest option:selected').val();
            $.ajax({
                type: "POST",
                url: '/table/del_field',
                data: { proc_id:options.id, field_id:field_id },
                dataType: "json",
                success: function(data){
                    if (data.result == 'ok') $('[column_name="' + field_id+'"]').remove();
                    else console.error(data.error, data.need_action);
                }
            });
        });
        var sel = $('<select class="form-control"></select>').appendTo($('.nest'));
        dao.list_field(options.id, sel);
    }


    this.edit_field = edit_field;
    this.add_field = add_field;
    this.del_field = del_field;
}//f = function()
//	$.extend( window.dao, f(jQuery)	);  // расширяем
})($);//(function()



