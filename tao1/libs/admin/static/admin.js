
var Page_coll = Backbone.Collection.extend({  });

var Actions_model = Backbone.Collection.extend({  });

var Map_view = Backbone.View.extend({
    // рисует   вкладку карты саму.
//    el: '#_',
//    model:Actions_model,
    initialize: function(){
        this.model.bind("reset", this.render, this);

    },
    events:{
        'click .add_rb':'open_tab',
        'click #ss_add_rb':'open_tab_add_rb',
        'click #ss_del_rb':'open_tab_del_rb',
        'click #ss_conf_adm':'open_tab_conf',
        'click #ss_add_func':'open_tab_add_f',
        'click #ss_in_sandbox':'open_tab_in_sb',
        'click #ss_add_role':'open_tab_add_role',
        'click #ss_change_pass':'open_tab_change_pass'
    },

    open_tab_add_rb: function(){
        page_view.open_tab('add_rb');
        return false;
    },
    open_tab_del_rb: function(){
        page_view.open_tab('del_rb');
        return false;
    },
    open_tab_conf: function(){
        page_view.open_tab('conf_rb_doc');
        return false;
    },
    open_tab_add_f: function(){
        page_view.open_tab('add_func');
        return false;
    },
    open_tab_in_sb: function(){
        page_view.open_tab('sandbox');
        return false;
    },
    open_tab_add_role: function(){ return false;},
    open_tab_change_pass: function(){
        page_view.open_tab('change_pass_admin');
        return false;
    },
    open_tab: function(e){
        var ds_id = $(e.target).attr('ds_id') || $(e.target).closest('.add_rb').attr('ds_id');
        page_view.open_tab(ds_id);
        return false;
    },
    render: function(){
        var docs = ''; var rb = ''; var rep = '';
        var h = {};
        var ctr = {};
        var all_docs = this.model.toJSON();
        all_docs = all_docs[0];
        for (var i in all_docs) {
            var v = all_docs[i];
//            if (v.type=='set_templ')
//                vd(v);
            if (!h[v.type]) {
                h[v.type] = '';
                ctr[v.type] = 0;
            }
            h[v.type] += '<div class="add_rb" style="font-weight:normal; " ds_id="'+ v.id+'">'+v.title+'</div>';
            ctr[v.type] += 1;
        }
        this.$el.html(
            '<div id = "present_view" >'+
                '<div class = "show_main_doc" >'+
//                (h['doc'] ? '<div class="all_view"> <h2>Документы</h2></div>'+ h['doc'] : '') +

                (h['doc'] ? '<div class = "set_auth" style="margin:12px;">' +
                    '<div class = "work_rb do_open">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Документы <div class="line_work_rb" style="padding:6px; color:green;">'+ctr['doc']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['doc'] +'</div>' +
                    '</div>' : '') +



//                    (h['rb'] ? '<div class="all_view"> <h2>Справочники</h2></div>'+ h['rb'] : '') +
                (h['rb'] ? '<div class = "set_auth" style="margin:12px;">' +
                    '<div class = "work_rb do_open">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Справочники <div class="line_work_rb" style="padding:6px; color:green;">'+ctr['rb']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['rb'] +'</div>' +
                    '</div>' : '') +


                '</div>'+
                '<div class = "show_main_settings" >' +
                (h['rep'] ? '<div class = "show_main_report" >' +
                    '<div class = "work_rb"> ' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Отчёты<div class="line_work_rb" style="padding:6px; color:green;">'+ctr['rep']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['rep'] + '</div>' +
                    '</div>'  : '') +
                (h['rep_tax'] ? '<div class = "show_main_tax" >' +
                    '<div class = "work_rb">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Отчёты для налоговой<div class="line_work_rb" style="padding:6px; color:green;">'+ctr['rep_tax']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['rep_tax'] +'</div>' +
                    '</div>' : '') +
                '</div>'+

                '<div class = "show_main_settings" >' +


                (h['set_auth'] ? '<div class = "set_auth" style="margin:12px;">' +
                    '<div class = "work_rb">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'ACL — контроля доступа <div class="line_work_rb" style="padding:6px; color:green;">'+ctr['set_auth']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['set_auth'] +'</div>' +
                    '</div>' : '') +

                (h['set_templ'] ? '<div class = "set_templ" style="margin:12px;">' +
                    '<div class = "work_rb">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Внешний вид(шаблоны) <div class="line_work_rb" style="padding:6px; color:green;">'+ctr['set_templ']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['set_templ'] +'</div>' +
                    '</div>' : '') +

                (h['set_conf'] ? '<div class = "set_conf" style="margin:12px;">' +
                    '<div class = "work_rb">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Настройки конфигурации<div class="line_work_rb" style="padding:6px; color:green;">'+ctr['set_conf']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['set_conf'] +'</div>' +
                    '</div>' : '') +

                (h['set_sandbox'] ? '<div class = "set_conf" style="margin:12px;">' +
                    '<div class = "work_rb">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Песочница<div class="line_work_rb" style="padding:6px; color:green;">'+ctr['set_sandbox']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['set_sandbox'] +'</div>' +
                    '</div>' : '') +

                (h['set_rb'] ? '<div class = "set_rb" style="margin:12px;">' +
                    '<div class = "work_rb">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Настройки справочников<div class="line_work_rb" style="padding:6px; color:green;">'+ctr['set_rb']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['set_rb'] +'</div>' +
                    '</div>' : '') +

                (h['set_menu'] ? '<div class = "set_menu" style="margin:12px;">' +
                    '<div class = "work_rb">' +
                    '<div class="ui-icon ui-icon-triangle-1-s" style="float: left;"></div> '+
                    'Настройки меню<div class="line_work_rb" style="padding:6px; color:green;">'+ctr['set_menu']+' обьектов </div>' +
                    '</div>' +
                    '<div>'+ h['set_menu'] +'</div>' +
                    '</div>' : '') +

                '</div>'+

                '</div>'
        );
        $('.add_rb').addClass('ui-state-default ui-corner-all');
        $('.work_rb').click(toggle_admin).click();
        $('.work_rb').find(':last').toggle();
        $('.work_rb').addClass('ui-corner-top ui-corner-bottom');
        $('.work_rb.do_open').click();
        function toggle_admin(){
            $(this).find(':first').toggleClass('ui-icon-triangle-1-s ui-icon-triangle-1-e');
            $(this).find(':last').toggle();
            $(this).next().toggle();
            $(this).toggleClass('ui-corner-bottom');
        }
    }
});


var Page_view = Backbone.View.extend({
    //рисует табы
    model:Page_coll,
//    el:$('#tabs'),
    initialize: function(){
        var that = this;
//        this.$el.tabs();
        that.tabs = this.$el.find('.tabs_ul')
        that.tabs.addClass('tabs_ul ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all');
        that.$el.addClass('ui-tabs ui-widget ui-widget-content ui-corner-all');
        $(that.tabs).click(function(e){
            var target = $(e.target);
            if(target.is('.tab')){
                var ds_id = target.attr('href');
                that.tabs.find('li').removeClass('ui-state-active');
                that.tab_id = target.closest('li').addClass('ui-state-active').attr('ds_id');
                that.$el.find('>div').css({'visibility':'hidden'});
                $(ds_id).css({'visibility':'visible'});
            }
        });
        // когда выполняется метод модели   мы перерисовуем рендером своим.
//        this.model.bind("reset", this.render, this);
        this.model.bind("reset", this.reset, this);
        this.model.bind("add", this.new_tab, this);
        this.restore_tabs();
        window.onbeforeunload = window.onunload = function(){ that.save_tabs(); }

    },

    events:{
        'click .closes':'close_tab_e',
        'click .update':'update_tab_e'
    },

    render: function(){
        dao.log('render');
//        dao.log(ds_id );
        var that = this;
        this.tabs.empty();
        var tab = $('<li style="display:inline-block;" ds_id="_" class="ui-corner-top ui-state-default"><a class="tab" href="#_"><i class="icon-home icon-blue"></i>'+'Карта'+'</a></li>').appendTo(this.tabs);
        var models = this.model.toJSON();
        for( var res in models ){
//            if (res != 0) this.new_tab(null, null, {index: res}, true);
            this.new_tab(null, null, {index: res}, true);
        }
        that.$el.find('>div').css({'visibility':'hidden'});
        that.tabs.find('li[ds_id="'+this.tab_id+'"] a:first').click();
    },
    reset: function(){
        this.render();
    },
    restore_tabs: function(){
        dao.log('restore_tabs');
        var tabs = localStorage.getItem('tabs');
        if(!tabs) return; // Запустить создание вида в первой вкладке
        this.tab_id = localStorage.getItem('tab_id');
        try {tabs = JSON.parse(tabs); }
        catch(e) {tabs={}; }
        this.model.reset(tabs);
    },

    tab_id:  '_',
    save_tabs: function(){
        dao.log('save_tabs');
        dao.log(this.tab_id);
        localStorage.setItem('tabs', JSON.stringify( this.model.toJSON() ) );
        localStorage.setItem('tab_id', this.tab_id );
    },
    open_tab: function(ds_id, open_id){ // создает новую модель добавляет её в коллекцию.
        var ds_idd = '#'+ds_id.replace(/:/g, '_');
        var tab = this.model.where({id:ds_id});
        if(tab.length){
            tab = tab[0];
            tab.set('open_id', open_id);
            var _tab = this.$el.find('a[href="'+ds_idd+'"]').parent();
            // Показывает нужную вкладку
            _tab.find('a:first').click();
            // Обновляет вкладку с новым id документа для выделения
            _tab.find('div.update').click();
        } else {
            if (this.res_coll && this.res_coll[ds_id])
                this.model.push(this.res_coll[ds_id]);
        }
    },

    new_tab: function (e, a, b, no_click){
        var model = this.model.at(b.index);
        var ds_id = model.get('id');
        dao.log('new_tab');
        dao.log(model);
        dao.log(ds_id );
        var title_tab = model.get('title');
        var ds_idd = ds_id.replace(/:/g, '_');
//        that.$el.tabs( "add" , ds_idd, title_tab );
        var tab = $('<li style="display:inline-block;" class="ui-corner-top ui-state-default" ds_id="'+ds_id+'"><a class="tab" href="#'+ds_idd+'">'+title_tab+'</a></li>').appendTo(this.tabs)
        $('<div id="'+ds_idd+'"></div>').appendTo(this.$el)
        $('<div class="" style="display: inline; vertical-align: top; cursor: pointer;  padding:2px;">' +
            '<div class="update ui-icon ui-icon-refresh" style="display:inline-block;"></div>' +
            '<div class="closes ui-icon ui-icon-close" style="display:inline-block;"></div>' +
            '</div>').appendTo(tab);
        if(!no_click) tab.find('a').click();
        this.update_tab(ds_id);
    },
    update_tab: function(ds_id){
        var model = this.model.get(ds_id);
        var ds_idd = '#'+ds_id.replace(/:/g, '_');
        var select_id = model.get('open_id');
        var url = model.get('url');
        $.ajax({
            url: url+(select_id ? '?select_id='+select_id : ''),
            type:"get", dataType: "html", data:{select_id:select_id},
            success : function (data) {
                $(ds_idd).empty().append(data);
            }, error : function (xhr, status, err) {
                alert(err);
            }
        });
    },
    update_tab_e: function(e){
        // на событие обявленое в таблице евентс нам передается параметр events(e) такойже  как в jquery.
        dao.log('update_tab_e');
        var ds_id = $(e.target).closest('li').attr('ds_id');
        dao.log(ds_id);
        this.update_tab(ds_id);
    },
    close_tab: function(ds_id){
        dao.log('close_tab');
        dao.log(ds_id);
        var ds_idd = '#'+ds_id.replace(/:/g, '_');
        var model = this.model.get(ds_id);
        this.model.remove(model);
        var a = this.$el.find('a[href="'+ds_idd+'"]');
        var tab = a.parent();
        tab.remove();
        $(ds_idd).remove();
        this.tab_id = '_'
        this.tabs.find('a:first').click();
//        this.$el.tabs( "remove" , tab.index() );
    },
    close_tab_e: function(e){
        dao.log('close_tab');
        var ds_id = $(e.target).closest('li').attr('ds_id');
        dao.log(ds_id );
        this.close_tab(ds_id);
    },

    close_all_tabs: function(){
        dao.log('close_tab');
        this.tab_id = '_';
        dao.log(this.tab_id );
        this.model.reset();
    }
});
var page_view;

//Backbone.history.start();
function start_app(res){
    res_coll = {};
    for (var ds_id in res) {
        res_coll[ds_id] = $.extend({'id': ds_id}, res[ds_id]);//.reset(res);
    }
    page_view = new Page_view({ el:$('#tabs'), model:new Page_coll()});
    page_view.res_coll = res_coll;

    var actions = new Actions_model();
    map_view = new Map_view({model:actions, el: $('#_') });
    actions.reset(res_coll);
}
$(function(){
    var ta = dao.add_processor({
        url: window.location,
        proc_id: ''
    });
});

function change_pass_(aaa){
    var dialog = $("<div></div>").appendTo(aaa);
    var pass;
    var form = $('<form></form>').appendTo(dialog);
    var formbody = $('<fieldset></fieldset>').appendTo(form);
    var nest = $('<div class="nest"></div>').appendTo(formbody);
    $('<label> Пароль</label>').appendTo(nest);
    pass = $('<input type="password"/>').appendTo(nest);
    $('<label style="margin-top: 15px;"> Повторить пароль</label>').appendTo(nest);
    var pass1 = $('<input type="password"/>').appendTo(nest);
    var ok = $('<div class="btn btn-default">Ok</div>').appendTo(nest).wrap('<div></div>');
    ok.click(function(){
        if (pass.val() != pass1.val()) {alert('Пароли различаются'); return;}
        var passw = pass.val();
        $.ajax({
            type: "POST", url:'/change_pass_admin', dataType:"json",
            data:{ pass:passw},
            success: function(data){
                if (data.result == 'ok') { alert('Пароль успешно изменен.') }
                else { dao.error_status(data.error, data.need_action); }
            }
        });
    });
}

function add_func(aaa){
    var mainw = $('<div style="position: relative"></div>').appendTo(aaa);
    var rb_id = null;
    var form = $('<form></form>').appendTo(mainw);
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
    var ok = $('<div btn btn-default>Сохранить</div>').appendTo(nest).wrap('<div></div>');
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
function sandbox(aaa){
    var mainw = $('<div style="position: relative"></div>').appendTo(aaa);
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
    var ok = $('<div class="btn btn-default">Ok</div>').appendTo(nest).wrap('<div></div>');
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
}

function edit_conf( aaa){
    var mainw = $('<div style="position:relative"></div>').appendTo(aaa);
    var rb_id = null;
    var form = $('<form></form>').appendTo(mainw);
    var formbody = $('<fieldset></fieldset>').appendTo(form);
    var nest = $('<div class="nest"></div>').appendTo(formbody);

    var overall =$('<div></div>').appendTo(nest);
    dao.conf_docs(function(data){
        for (var res in data){
            var id_rb = $('<label style="margin-left:15px;"><input type="checkbox" '+ (data[res]['conf']['turn']=='true'?"checked='true'":'')+' name="'+data[res]['_id']+'"/> '+data[res]['conf']['title']['ru']+'</label>').appendTo(overall);
        }
    });
    var ok = $('<div class="btn btn-default">Ok</div>').appendTo(nest).wrap('<div></div>');
    ok.click(function(){
        var inputs = aaa.find('input:checkbox');
        var data = {};
        inputs.each(function(i, v){
            data[$(v).attr('name')] = $(v).is(':checked') ? 1 : 0;
        });
        $.ajax({
            type: "POST", dataType: "json", url: '/conf_rb_doc',
            data: { data: JSON.stringify(data) },
            success: function(data){
                if (data.result == 'ok') { alert('Конфигурация сохранена'); }
            }
        });
    });
}



function add_rb(is_role, is_rb, aaa){
    var mainw = $('<div class="row"></div>').appendTo(aaa);
    var rb_id = null;
    var form = $('<form class="form-horizontal" role="form"></form>').appendTo(mainw);
    var formbody = $('<fieldset></fieldset>').appendTo(form);
    var nest = $('<div class="nest col-xs-4" style="margin:20px;"></div>').appendTo(formbody);
    if (is_rb) {
        var overall =$('<div class="form-group "></div>').appendTo(nest);
        var id_rb = $('<label class="control-label ">Id</label><input class="form-control" type="text" name="id"/>').appendTo(overall);
        var name = $('<label class="control-label">Название</label>').appendTo(overall);
        var name_ru = $('<img src="/static/core/img/ru.png"><input class="form-control" type="text" name="name_ru"/><br/>').appendTo(overall);
        var name_en = $('<img src="/static/core/img/en.png"><input class="form-control" type="text" name="name_en"/>').appendTo(overall);
        var type_doc = $('<div class="rad"><label class="control-label">Тип</label></div>').appendTo(nest);
        $('<label class="control-label">Справочник</label><input class="form-control" type="radio" name="is_doc" value="rb" checked="checked" />' +
            '<label class="control-label">Форум</label><input class="form-control" type="radio" name="is_doc" value="forum"/>' +
            '<label class="control-label">Документ</label><input class="form-control" type="radio" name="is_doc" value="doc"/>').appendTo(type_doc);
        var label_visible = $('<div class="rad"><label class="control-label">Наличие коментариев</label></div>').appendTo(nest);
        $('<label class="control-label">Нет</label><input class="form-control" type="radio" name="is_comm" value="off"  checked="checked"/>' +
            '<label class="control-label">Да</label><input class="form-control" type="radio" name="is_comm" value="on"/>').appendTo(label_visible);

        var sel = $('<select class="form-control"><option value="des:obj"></option></select>').appendTo(nest);
        var urls = ''+document.location+'';
        var url = urls.split('/');
        dao.get_list_rb(sel);
        mainw.find('input[name=is_doc]').change(function(){
            if (mainw.find('input[name=is_doc]:checked').val() == 'forum' || mainw.find('input[name=is_doc]:checked').val() == 'obj') {
                label_visible.hide();
                overall.hide();
                sel.hide();
                id_rb.val('forum'); name_ru.val('Форум'); name_en.val('Forum');
            }
            if (mainw.find('input[name=is_doc]:checked').val() != 'obj' && mainw.find('input[name=is_doc]:checked').val() != 'forum') {
                label_visible.val('').show();
                overall.val('').show();
                sel.show();
            }
        });
        sel.change(function(){
            rb_id = sel.val();
        });
    }
    if (is_role) {
        $('<label>Название</label><input class="form-control" type="text" name="title"/>').appendTo(mainw);
        $('<label>Id</label><input class="form-control" type="text" name="id"/>').appendTo(mainw);
        $('<input type="text" name="role" value="role"/>').hide().appendTo(mainw);
    }
    var ok = $('<div class="btn btn-default">Ok</div>').appendTo(nest).wrap('<div></div>');
    ok.click(function(){
        var inputs = aaa.find('input,select,textarea');
        var data = { 'table':[] };
        inputs.each(function(){
            var n = $(this).attr('name');
            var v = $(this).val();
            if ($(this).attr('type') == 'radio' && !$(this).attr('checked')) {	}
            else{ 	data[$(this).attr('name')] = $(this).val(); 	}
        });
        $.ajax({
            type: "POST", dataType:"json", url:'/add_ref',
            data: {
                owner: rb_id, data:JSON.stringify(data)
            },
            success: function(data){
                if (data.result == 'ok') { alert('Справочник создан'); }
            }
        });
    });
}

function del_rb(aaa){
    var mainw = $('<div style="position: relative"></div>').appendTo(aaa);
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