
var mongo_tree = function(){
(function () {
    var Coll_model = Backbone.Model.extend({ });
    var Doc_model = Backbone.Model.extend({

        update: function(){
            var that = this;
            $.ajax({
                type:"POST", url:'/mongo/get_doc', dataType:"json",
                data:{
                    coll:that.get('__coll_id'),
                    doc_id:that.get('_id')
                },
                success:function (data) {
                    if (data.result == "ok") {
                        that.set(data['doc']);
                    } else {
                        alert(data.error);
                    }
                }
            });
        }
    });

    var Docs_coll = Backbone.Collection.extend({ // Коллекция пользователей
        model:Doc_model,

        initialize:function(){ this.update = this.update_list; },
        search:function(field, value){
            if(!field) {field=this.field;value=this.value;}
            else {this.field=field; this.value=value}
            this.update = this.search;
            var that = this;
            $.ajax({
                type: "POST", url: '/mongo/search_docs', dataType: "json",
                data: { condition: value, field:field},
                success: function(data){
                    if(data.result=="ok"){
                        that.reset(data['docs']);
                    }else{ alert(data.error); }
                }
            });
        },
        update_list: function(coll){
            if(!coll) coll=this.coll;
            else this.coll=coll;
            this.update = this.update_list;
            var that = this;
            $.ajax({
                type:"POST", url:'/mongo/get_coll', dataType:"json",
                data:{ coll:coll },
                success:function (data) {
                    if (data.result == "ok") {
                        that.reset(data['docs']);
                    } else { alert(data.error); }
                }
            });
        }
    });
    var docs_coll = new Docs_coll();
    var Search_model = Backbone.Model.extend({
        defaults:{ field: '_id', value:''}
    });
    var search_model = new Search_model();
    var Search_view = Backbone.View.extend({
        model:Search_model,
        el:$('.toolbar'),
        initialize:function(){
            this.model.bind('change', this.render, this);
            this.render();
        },
        events:{ 'submit form':'search' },
        search:function(){
            docs_coll.search(this.field.val(), this.value.val());
            return false;
        },
        render: function(){
            this.$el.html('<form action=""><div class="search"><div> Jump to </div>' +
                '<div><input type="text" name="field" value="_id"/>:</div><div><input type="text" name="value"/></div> <div><input type="submit" value="find" /></div>' +
                '</div></form>');
            this.field = this.$el.find('[name="field"]');
            this.field.val(this.model.get('field'));
            this.value = this.$el.find('[name="value"]');
            this.value.val(this.model.get('value'));
        }
    });
    var search_view = new Search_view({model:search_model});
    var Doc_view = Backbone.View.extend({ // Коллекция пользователей
        model:Doc_model,
        initialize:function () {
            this.model.bind("toggle", this.update_doc, this);
            this.model.on("change", this.render_doc, this);
        },

        events:{
            "click .doc > .title":"update_doc",
            "click .img_edit":"edit_doc",
            "click .del_doc":"del_doc",
            "click .doc .collapsable >.title":"toggle_item",
            "dblclick .row > .content":"edit_cell",
            "dblclick .row > .title":"edit_cell",
            "keydown .row > .title":"end_edit_cell",
            "keydown .row > .content":"end_edit_cell"
        },
        toggle_item: function(event){
            console.log($(event.target));
            $(event.target).parent().toggleClass('collapsed expanded');
        },
        edit_cell: function(event){
            var data = $(event.target).data('edit_value');
            if(!data) return;
            var editor = $('<div class = "editor"></div>').appendTo($(event.target));
            var input = $('<input type="text" />').appendTo(editor);
            input.val(data);
        },
        end_edit_cell: function(e){
            var that = this;  var target = $(e.target);
            if(e.which == 13){
                var old_path = get_path_doc(target);
                var new_val = target.val();
                target = target.parent().parent();
                if (!old_path.length) return;
                if(target.is('.title')){
                    var new_path = old_path.slice();
                    new_path[0] = new_val;
                    new_val = JSON.stringify(new_path);
                }
                console.log('new_val', new_val);
                $.ajax({
                    type: "POST", url: target.is('.title')?'/mongo/edit_key':'/mongo/edit_val', dataType: "json",
                    data: {
                        coll: that.model.get('__coll_id'),
                        new_val:new_val,
                        old_val:JSON.stringify(old_path), doc_id:that.model.get('_id')},
                    success: function(data){
                        target.empty().text(new_val);
                        target.data('edit_value', new_val);
                    }
                });
            }
        },

        del_doc:function(){
            var that = this;
            $.ajax({
                type: "POST", url: '/mongo/del_doc', dataType: "json",
                data: { coll: that.model.get('__coll_id'), doc_id:that.model.get('_id') },
                success: function(data){
                    if(data.result=="ok"){
                        docs_coll.remove(that.model);
                        docs_view.render();
                    }else{ alert(data.error); }
                }
            });
        },
        edit_doc:function(){
            var that = this;
            var dialog = $("<div title='Редактированме документа'></div>");
            dialog.dialog({
                bgiframe: true, autoOpen: true, height: 500, width: 600, modal: true,
                buttons: {
                    'Ok': function(){

                        $.ajax({
                            type: "POST", dataType: "json", url:'/mongo/edit_doc',
                            data: { coll: that.model.get('__coll_id'), doc:texta.val(), doc_id:that.model.get('_id') },
                            success: function(data){
                                if(data.result=="ok"){
                                    that.model.update();
                                    dialog.dialog('close');
                                }else{ alert(data.error); }
                            }
                        });
                    }, 'Отмена': function(){ $(this).dialog('close'); }
                }, close: function(){ delete dialog; }
            });
            var form = $('<form><fieldset><div style="font-size: 14px; font-weight: bold;"></div></fieldset><form>').appendTo(dialog);
            var formbody = $('fieldset', form);
            var nest = $('div', formbody);
            var doc_idd = $('<label style="margin:10px;"> "_id":"'+that.model.get('_id')+'"</label>').appendTo(nest);
            var text = $('<div style=""> </div>').appendTo(nest);
            var texta = $('<textarea style="width: 100%; height: 400px;"> </textarea>').appendTo(text);
            get_doc(that.model.get('_id'), that.model.get('__coll_id'), function(doc){texta.val(doc);} );
        },
        update_doc:function () {
            var model = this.model;
            model.set('__expanded', !model.get('__expanded')) // !$(this).closest('.collapsable').toggleClass('collapsed expanded').is('.collapsed')
            this.$el.toggleClass('collapsed expanded');
            if (!model.get('__expanded')) return;
            model.update();
        },
        render:function () {
            var aaa = this.model;
            this.setElement( $('<div class="doc collapsable ' + (aaa.get('__expanded') ? 'expanded' : 'collapsed') + '" doc_id="' + aaa.get('_id') + '"></div>'));
            var doc = this.$el;
            var t = $('<div class="title"> ' + aaa.get('_id') + ' </div>').appendTo(doc);
            var edit = $('<div class="img_edit" style="display:inline-block;"> <img class="edit_doc"src="/static/core/img/edit.png"/></div>').appendTo(t);
            var del = $('<div class="img" style="display:inline-block;"> <img class="del_doc"src="/static/core/img/cancel.png"/></div>').appendTo(t);
            this.content = $('<div class="content"></div>').appendTo(doc);
            return this;
        },

        render_doc: function(){
            // вызывается для двух разных обектов и заголовок сворачивается и разворачивается.
            if(!this.content)return;
            this.content.empty();
            this.render_content(this.content, this.model.attributes);
        },
        render_content: function(target, data, collapsed){
            var doc = $(target);//.empty();
            for(var res in data){
                if (res.indexOf('__')==0) continue;
                var r = $('<div class = "row "></div>').appendTo(doc);
                var t = $('<div class = "title">'+res+'</div>').appendTo(r);
                var c = $('<div class = "content "></div>').appendTo(r);
                if (typeof data[res] == 'object') {
                    this.render_content (c, data[res], true);
                    r.addClass('collapsable complex collapsed')
                    if(res != '_id' ) t.data('edit_value', res);
                }else {
                    c.text( '"'+data[res] + '"');
                    c.data('edit_value', data[res]);
                    if(res != '_id' ) t.data('edit_value', res);
                    r.addClass('primitive')
                }
            }
        }

    });
    var Docs_view = Backbone.View.extend({ // Коллекция пользователей
        el:$('.docs'),
        model: Docs_coll,
        initialize:function () {
            this.model.bind("reset", this.render, this);
//            this.model.bind("change", this.render, this);  // если модель изменилась перересовать её.
        },
        events:{
            "click .del_db":"del_db",
            "click .create_doc":"create_doc",
            "click .clean_coll":"clean_coll",
            "click .import_coll":"import_coll",
            "click .export_coll":"export_coll",
            "click .export_db":"export_db"
        },
        create_doc:function(){
            var that = this;
            var dialog = $("<div title='Редактированме документа'></div>");
            dialog.dialog({
                bgiframe: true, autoOpen: true, height: 500, width: 600, modal: true,
                buttons: {
                    'Ok': function(){
                        $.ajax({
                            type: "POST", dataType: "json", url: '/mongo/create_doc',
                            data: {
                                coll: that.model.at(0).get('__coll_id') ,
                                doc:texta.val()
                            },
                            success: function(data){
                                if(data.result=="ok"){
                                    that.model.update_list();
                                    dialog.dialog('close');
                                }else{ alert(data.error); }
                            }
                        });
                    }, 'Отмена': function(){ $(this).dialog('close'); }
                }, close: function(){ delete dialog; }
            });

            var form = $('<form><fieldset><div></div></fieldset><form>').appendTo(dialog);
            var formbody = $('fieldset', form);
            var nest = $('div', formbody);
            var text = $('<div style="border: 1px solid red;"> </div>').appendTo(nest);
            var texta = $('<textarea style="width: 400px; height: 400px;"> </textarea>').appendTo(text);
        },
        del_db:function(){
            if (confirm('Вы точно хотите удалить БАЗУ ?')){
                $.ajax({
                    type: "POST", dataType: "json", url: window.location+'/del_db', data:{ },
                    success: function(data){
                        if(data.result=="ok"){ window.location('/mongodb')
                        }else{ alert(data.error); }
                    }
                });
            }
        },
        clean_coll:function(){},
        import_coll:function(){},
        export_db:function(){
                var path;
                var coll = $('.docs').attr('coll_id');
//        var db_id = $('.db').attr('db_id');
                var db_id = 'db_name';
                $.ajax({
                    type: "POST", url: '/mongo/export_db', dataType: "json",
                    data: { coll: coll, db_id:db_id, path:path},
                    success: function(data){
                        if(data.result=="ok"){
                            window.location = data['link']
//                    dr(data);
                        }else{ alert(data.error); }
                    }
                });
        },
        export_coll:function(){},
        render:function () {
            this.$el.empty();
            var data_docs = this.model.models;
            var t_but = $('<div class="t_but"></div>').appendTo(this.$el);
            $('<div class="create_doc">Создать документ</div>').appendTo(t_but);
            $('<div class="clean_coll">Очистить колекцию</div>').appendTo(t_but);
            $('<div class="import_coll">Импорт коллекции</div>').appendTo(t_but);
            $('<div class="export_coll">Экспорт коллекции</div>').appendTo(t_but);
//            $('.clean_coll, .import_coll, .export_coll, .create_doc').button();
            t_but.find('>div').button();
            for (var res in  data_docs) {
                this.render_doc_(data_docs[res]);
            }
        },
        render_doc_:function (item) {
            var doc_view = new Doc_view({ model:item });
            this.$el.append(doc_view.render().el);
        }
    });
    var docs_view = new Docs_view({model:docs_coll});

    var App_route = Backbone.Router.extend({
        routes:{
            "update_list/:coll_id":"update_list",
            "find/:field/:value":"find"
        },
        find: function(field, value){
             docs_coll.search(field, value);
        },
        update_list:function (_coll) {
//            dao.vd(_.functions(docs_view.model));
            docs_view.model.update(_coll);

        },
        search:function (query, page) { }
    });
    var app_route = new App_route();
    Backbone.history.start();

    $('.collection').click(function () {
        app_route.navigate('update_list/' + $(this).attr('coll_id'), {trigger:true});
    });
    $('.db').click(function () {
        window.location = '/mongodb/'+$(this).attr('db_id');
    });

    function get_path_doc(target){
        var path = []; var cursor = target;
        while( cursor.length && !cursor.is('.doc')){
            if(cursor.is('.row')) path.push(cursor.find('.title:first').data('edit_value'));
            cursor = cursor.parent();
        }
        return path;
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


})();
};

$(document).ready(function () {
    if (mongo_tree) {
        var t = mongo_tree;
        mongo_tree = undefined;
        t();
    }
});




