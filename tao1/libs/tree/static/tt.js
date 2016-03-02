;(function($) {
    var defaults = {};
    window.dao.tree_processor = function(parent, body, params) {
        var options = $.extend({}, defaults, params);
        var dialog;
        /** {jQuery} родительский контейнер */
        if (parent){
            parent = $(parent);
            var element = $('<div/>').appendTo(parent);
            parent.css('overflow', 'hidden');
//				var	add_branch = null;
//				var	del_branch = null;
            var	toolbar = null;
            var	preheader = null;
            var	cursor = null;
            var	cursor_id = options.id_tree?options.id_tree:0;
            var link = '';
            var link2 = '';

            var defaultCreateParams = {	title: dao.ct('create_new_rec')  };
//				var defaultCreateParams = {	title: ""  };

            // var button_class = options.sub_table_class?'2':'';
            var tree_toolbar = $(
                '<div class="well btn-group btn-group-sm" style="position:absolute; top:0px; left:0px; right:0px; overflow:hidden; display:block;'+
                'padding:2px; text-align:left; height:38px;"></div>').appendTo(parent);
            var tree_body =    $('<div style="position:absolute; top:36px; left:0px; right:0px; overflow:hidden; display:block; bottom:0px; ' +
                'background-color:white;"></div>').appendTo(parent);
            var add_branch =   $('<div class="btn btn-default"   title=""><div class="icon-plus-sign"/>&nbsp;</div>').appendTo(tree_toolbar);
            var del_branch =   $('<div class="btn btn-default"   title=""><div class="icon-trash "/>&nbsp;</div>').appendTo(tree_toolbar);
            var edit_branch =  $('<div class="btn btn-default"  title=""><div class="icon-edit"/>&nbsp;</div>').appendTo(tree_toolbar);
            var refresh_tree = $('<div class="btn btn-default" title=""><div class="icon-refresh "/>&nbsp;</div>').appendTo(tree_toolbar);
            add_branch.click(function(){
                var branchId = cursor_id;
                createBranch(branchId);
            });
            edit_branch.click(function(){
                var branchId = cursor_id;
                editBranch(branchId);
            });
            del_branch.click(function(){
                var branchId = cursor_id;
                deleteBranch(branchId);
            });
            var tree = $('<div class="doc_button ui-button ui-state-default ui-corner-all" style="position:absolute; ' +
                'top:4px; bottom:0px; right:0px; font-size:12px;">'+dao.ct('categories')+'</div>').appendTo(toolbar);
            var is_recursive = false;

            //XXX
            refresh_tree.click(function(){	updatetree();	});
            // до установки ветки дерева - будет двойной вызов
//				tree.click(function(){	_toggle_tree(); });
            var show_all = options.check_tree;
//				updatetree();
        }
        function updatelist(){
            if(options.on_change)
                options.on_change(show_all ? null : cursor_id, is_recursive);
        }

        function postupdatetree() {
            var t = tree_body.find("[branch_id="+ cursor_id +"]");
            if(t.length > 0) set_widget_cursor(t);
            else updatelist();

            //назначаем обработчик перетаскивания
            tree_body.find("[branch_id]").each(function(){

                $(this).find(".inter").droppable({
                    hoverClass: "ui-state-highlight",
                    drop: function(event, ui){
                     //значит что мы тащим из дерева в дерево
                        if (ui.draggable.parent().parent().hasClass('tree_item')) {
                            var top_neighbor = $(this).parent().parent().attr("branch_id");
                            var current_id = ui.draggable.parent().parent().attr("branch_id");
                            $.ajax({
                                //id текущей ветки и новой
                                type: "POST", url: '/tree/order_branch',
                                data: {
                                    proc_id: options['id'], //в товарах все было ок.
                                    current_id: current_id,
                                    top_neighbor: top_neighbor
                                },
                                dataType: 'json',
                                beforeLoad: function(){	},
                                success: function(data){
                                    if (data.result == "ok") {
                                        updatetree();
                                    } else { alert("" + dao.ct('not_move')+": "+data.status); }
                                }
                            });
                        } else { //значит что мы тащим из таблицы а не дерева
                            if(options.on_drop){
                                var branch_id = $(this).parent().parent().attr("branch_id");
                                options.on_drop(branch_id)
                            }
                        }
                    }
                });
                $(this).find("a:first").droppable({
                    hoverClass: "ui-state-highlight",
                    drop: function(event, ui){
                     //значит что мы тащим из дерева в дерево
                        if (ui.draggable.parent().parent().hasClass('tree_item')) {
                            var branch_id = $(this).parent().parent().attr("branch_id");
                            var current_id = ui.draggable.parent().parent().attr("branch_id");
                            $.ajax({
                                type: "POST", url:'/tree/move_branch', dataType: 'json',
                                data: {
                                    proc_id: options['id'], //в товарах все было ок.
                                    current_id: current_id,
                                    new_parent_id: branch_id
                                },
                                beforeLoad: function(){ },
                                success: function(data){
                                    if (data.result == "ok") {
                                        updatetree();
                                    } else { alert("" + dao.translate('not_move')+": "+data.status); }
                                }
                            });
                        } else { //значит что мы тащим из таблицы а не дерева
                            if(options.on_drop){
                                var branch_id = $(this).parent().parent().attr("branch_id");
                                options.on_drop(branch_id)
                            }
                        }
                    }
                }).draggable({
                    start: function(){
                        branch_id = $(this).parent().parent().attr("branch_id");
                    },
                    helper: function() {
                        var helper = $('<div class="ui-state-highlight ui-corner-all">[]</div>')
                            .css({"z-index":9999, "padding":"4px;"});
                        return helper;
                    }
                });
            });
        }

        function updatetree() {
            if(options.url == '/tree/data/menu:root:left_menu') url = '/menu/iface'
            else url = options.url
            $.ajax({
//                url: options.url,
                url: url,
                type: "POST",
                dataType: "json",
                data: {
                    proc_id: options.id,
                    owner: options.owner,
                    action: "tree"
                },
                beforeSend: function(){ },
                success: function(answer){
                    if(answer.proc_id){
                        options.id = answer.proc_id;
                        options.owner = undefined;
                    }
                    _drawtree(answer.content);
                    postupdatetree();
                }
            });
        }

        function set_widget_cursor(widget){
            //XXX
            var branch_id;
            var old_id = cursor_id;
            if(widget!=undefined && (branch_id = widget.attr('branch_id'))){
                cursor = widget;
                cursor_id = branch_id;
                $(tree_body).find(".ui-state-default").removeClass("ui-state-default");
                cursor.find("a:first").addClass("ui-state-default");
            }else{
                cursor = null;
                cursor_id = 0;
            }
            if(old_id != cursor_id) {
                updatelist();
            }
        }



        function _drawtree(content, root) {
//            console.log('content', content, 'root', root);
            if(root==undefined){
                tree_body.empty();
                tree_body.css({'overflow':'auto'});
                var show_all_branch = $('<label> <input type="checkbox" '+(options.check_tree ? 'checked = "true"' : '')+' /> '+dao.ct('all_rec')+'</label>')
                    .appendTo(tree_body).find('input:first')
                    .change(function(){
                        show_all = $(this).attr('checked');
                        updatelist();
                    });
                var show_recursive = $('<label> <input type="checkbox"/> '+dao.ct('wish_in')+'</label>')
                    .appendTo(tree_body).find('input:first')
                    .change(function(){
                        is_recursive = $(this).attr('checked');
                        updatelist();
                    });
//							_drawtree({0:{id:"0", title:"корень", children:content}}, root);
                var ul = $('<ul class = "tree"/>').appendTo(tree_body);
                _drawtree([content], ul);
                return;
            }
            for(var index in content){
                var branch = content[index];
                var is_branch = !(branch.children === undefined || branch.children.length == 0);

         /**li*/var item = $('<li branch_id="'+ branch.id +'" class="tree_item '+(is_branch?'tree_branch ':'tree_leaf ')+'"branch_id="'+ index +'"/>');
//        /**h1*/	var header = $('<h1 class="cm-menu-header" branch_id="'+index+'" style="text-align: left;"></h1>').appendTo(item);
        /**h1*/	var header = $('<h1 class="cm-menu-header" style="text-align: left; "></h1>').appendTo(item);

        /**a*/  var header_title = $('<a href="#" class=" cm-menu-'+(is_branch?'folder':'item')+'"  style="display:block; ">'+
                                        '<div  a_link="'+branch.link+'" class="open_branch" style="display:inline-table; ">'+
                                           '<div class="div-icon cm-menu-icon '+(is_branch ?'icon-minus-sign':'icon-leaf')+
                                             '" style="display:inline-cell; "/>'+
                                        '</div>'+ branch.id + ') ' + branch.title +
                                       '</a>').appendTo(header)
                                            .attr({'a_title':branch.title, 'a_descr':branch.descr, 'a_link':branch.link, 'a_id': branch.id});
                var top_div = $('<div class="inter" branch_id="'+index+'" style="height:4px;" />').prependTo(header);
//						$('.div-icon').css()
                header_title.click(function(){
                    set_widget_cursor($(this).parent().parent());
                });

                if(is_branch){
                    //рекурсия для рисования дерева
                    var children = $('<ul/>').appendTo(item);
                    _drawtree(branch.children, children);
                }
                $(root).append(item);
            }
            // по щелчку по папке сворачиваем и разварачиваем дерево.
            $('.open_branch').on('click', function() {
                $(this).find('.cm-menu-icon:first')
                        .toggleClass('icon-minus-sign icon-plus-sign')
                        .closest('.tree_item')
                        .find('ul:first')
                        .toggle();
            }).find('.cm-menu-icon:first').css('cursor', 'pointer');

            $(root).find('li:last-child').css('border-width', '0px').each(function(){
                $(this).find('h1:first').css('border-width', '0px 0px 1px 1px')
            });
        }

        function edit_comm(branch_id){
            dialog = $("<div></div>");
            var form = $('<form><fieldset><div></div></fieldset></form>').appendTo(dialog);
            var formbody = $('fieldset', form);
            var nest = $('div', formbody);
            dialog.dialog({
                bgiframe: true, autoOpen: true, height: 400, width: 450, modal: true,
                buttons: {
                    'Ok': function() {
                        var new_body = input1.val();
                        $.ajax({
                            type: "POST", url: '/comm/edit', dataType: "json",
                            data: {
                                proc_id: options.id,
                                action: 'edit_comm', branch_id: branch_id, body: new_body
                            },
                            success: function(data){
                                if(data.result=="ok"){
                                    $(".comm_comment[id_comm="+branch_id+"]").html(new_body);
                                    dialog.dialog('close');
                                }else{ alert(data.error); }
                            }
                        });
                    },
                    'Отмена' : function() { $(this).dialog('close');	}
                },
                close: function() { delete dialog;  }
            });
            $("<label>"+dao.ct('Сообщение')+"</label>").appendTo(nest);
            var input1 = $('<textarea name="body1" style="width:100%; height:150px;" class="t_rich_edit1"/>')
                .appendTo(nest).val($(".comm_comment[id_comm="+branch_id+"]").html());
        }

        function del_comm(branch_id){
            var dialog = $("<div></div>");//.appendTo(pre_dialog);
            var form = $('<form><fieldset><div></div></fieldset></form>').appendTo(dialog);
            var formbody = $('fieldset', form);
            var nest = $('div', formbody);
//                  dialog.position({ my: "center", at: "center", of: window });
            dialog.dialog({
                bgiframe: true, autoOpen: true, height:200, width: 400, modal: true, position: ['center', 'center'],
                title:'Удалить комментарий',

                open: function(){
//                            dialog.closest('.ui-dialog').css({'border':'5px solid red'}).appendTo(pre_dialog);
                },
                buttons: {
                    'Ok': function() {
                        var new_body = $('.t_rich_edit1[name="body1"]').val();
                        $.ajax({
                            type: "POST", url: '/comm/del', dataType: "json",
                            data: {
                                proc_id: options['id'],
                                action: 'del_comm', branch_id: branch_id, body: 'Коментарий удален.'
                            },
                            success: function(data){
                                if(data.result=="ok"){
                                    if(data.action=="del_dom"){
                                        $("li[id_comm="+branch_id+"]").remove();
                                        dialog.dialog('close');
                                    }else{
                                        $(".comm_comment[id_comm="+branch_id+"]").text('Коментарий удален.');
                                        $(".un[id_comm="+branch_id+"]").text('');
                                        dialog.dialog('close');
                                    }
                                }else{ alert(data.error); }
                            }
                        });
                    },
                    'Отмена' : function() { $(this).dialog('close');	}
                },
                close: function() { delete dialog;  }
            });
            $("<label>"+dao.ct('Вы действительно хотите удалить комментарий?')+"</label>").appendTo(nest);
        }

        function select_menu(dialog, linkk, title){
            var action = 'show_single_list';
            var rb_id = ''; var branch_id = ''; var doc_id = ''; //					var link = '';
            // 1) выбор что за меню будет
            $('<label>'+dao.ct('select_type_menu')+'</label>').appendTo(dialog);
            var label_type = $('<div style="margin-top:8px;" class="radio">'+dao.ct('type_field')+'</div></br></br>').appendTo(dialog);
            $('</br></br><label><input type="radio" name="type" value="ref" >'+dao.ct('insert_link')+'</label></br></br>'+
              '<label><input type="radio" name="type" value="rb" >'+dao.ct('rb')+'</label></br></br>'+
              '<label><input type="radio" name="type" value="act" >'+dao.ct('act')+'</label></br></br>'+
              '<label><input type="radio" name="type" value="forum" >'+dao.ct('Форум')+'</label></br></br>'+
              '<label><input type="radio" name="type" value="branch" >'+dao.ct('categories_rb')+'</label></br></br>'+
              '<label><input type="radio" name="type" value="tag" >'+dao.ct('Теги')+'</label></br></br>'+
              '<label><input type="radio" name="type" value="doc" >'+dao.ct('single_object')+'</label></br></br>').appendTo(label_type);
            var div_sel = $('<div class="div_sel"></div> ').appendTo(dialog).hide();
            var div_rb = $('<div class="div_rb"></div> ').appendTo(div_sel).hide();
            //он появляется и заполняется когда мы создаем ветку    до этого просто очищается
            var div_branch_doc = $('<div class="div_branch_doc"></div> ').appendTo(div_sel).hide();
            dialog.find('input[name=type]').change(function(){
                $('.div_sel, .div_rb, .div_branch_doc').empty().show();
                if (dialog.find('input[name=type]:checked').val() == 'ref') { // создаем ссылку
                    $("<label>"+dao.ct('link')+"</label>").appendTo(div_sel);
                    var ref = ''
                    if(linkk == '') ref = $('<input class="inp1" value="/show/des:obj/list"/>');
                    else ref = $('<input class="inp1" aaa=aaa value="'+linkk+'"/>');
                    ref.appendTo(div_sel);
                    ref.keyup(function(){ link = ref.val(); })
                    example_link(div_sel);
                }
                if (dialog.find('input[name=type]:checked').val() == 'rb') { // создаем справочник
                    div_rb.appendTo(div_sel);
                    var sel = $('<select id="sel_rb"><option value="des:obj"></option></select>').appendTo(div_rb);
                    dao.get_list_rb(sel);
                    sel.change(function(){
                        div_branch_doc.empty();
                        rb_id = $('.div_rb :selected').val();
                        link = '/show/'+rb_id+'/list';
                        link2 = rb_id;
                    });
                }
                if (dialog.find('input[name=type]:checked').val() == 'act') { // создаем справочник
                    div_rb.appendTo(div_sel);
                    var sel = $('<select id="sel_rb"><option value="des:obj"></option></select>').appendTo(div_rb);
                    dao.get_list_act(sel, 'set');
                    sel.change(function(){
                        div_branch_doc.empty();
                        rb_id = $('.div_rb :selected').val();
                        link = '/show/'+rb_id+'/list';
                        link2 = rb_id;
                    });
                }
                if (dialog.find('input[name=type]:checked').val() == 'forum') { // создаем форум
                    // action = 'show_single_list';
                    div_rb.appendTo(div_sel);
                    var sel = $('<select id="sel_rb"><option value="des:obj"></option></select>').appendTo(div_rb);
                    dao.get_list_rb(sel);
                    sel.change(function(){
                        div_branch_doc.empty();
                        rb_id = $('.div_rb :selected').val();
                        // link = '/?action='+action+'&proc_id='+rb_id;
                        link = '/dir/'+rb_id;
                        link2 = rb_id;
                    });
                }
                if (dialog.find('input[name=type]:checked').val() == 'branch') { // создаем ветку
                    // action = 'show_single_list';
                    div_rb.appendTo(div_sel);
                    var sel = $('<select ><option value="des:obj"></option></select>').appendTo(div_rb);
                    dao.get_list_rb(sel);
                    sel.change(function(){
                        div_branch_doc.empty();
                        rb_id = $('.div_rb :selected').val();
                        var sel1 = $('<select><option value=""></option></select>').appendTo(div_branch_doc);
                        div_branch_doc.appendTo(div_sel);
                        dao.get_list_branch(sel1, rb_id);
                        sel1.change(function(){
                            branch_id = $('.div_branch_doc :selected').val();
                            // link = '/?action='+action+'&proc_id='+rb_id+'&branch_id='+branch_id;
                            link = '/show/'+rb_id+'/branch/'+branch_id;
//									link2 = rb_id+'/branch/'+branch_id;
                        });
                    });
                }
                if (dialog.find('input[name=type]:checked').val() == 'tag') {  // создаем в меню тег
                    // action = 'show_single_list';
                    div_rb.appendTo(div_sel);
                    var sel = $('<select ><option value="des:obj"></option></select>').appendTo(div_rb);
                    dao.get_list_rb(sel);
                    sel.change(function(){
                        div_branch_doc.empty();
                        rb_id = $('.div_rb :selected').val();
                        var sel1 = $('<input type="text" />').appendTo(div_branch_doc);
                        div_branch_doc.appendTo(div_sel);
                        // dao.get_list_branch(sel1, rb_id);
                        sel1.change(function(){
                            tags = $(sel1).val();
                            link = '/show/'+rb_id+'/tags/'+tags;
                        });
                    });
                }
                if (dialog.find('input[name=type]:checked').val() == 'doc') {  // создаем в меню документ
                    action = 'show_single_object';
                    div_sel.empty();
                    div_rb.appendTo(div_sel);
                    var sel = $('<select><option value="des:obj"></option></select>').appendTo(div_rb);
                    dao.get_list_rb(sel);
                    sel.change(function(){
                        div_branch_doc.empty();
                        rb_id = $('.div_rb :selected').val();
                        var sel1 = $('<select size=20 style="width:100%;"><option value=""></option></select>').appendTo(div_branch_doc);
                        div_branch_doc.appendTo(div_sel);
                        dao.get_list_doc(sel1, rb_id);
                        sel1.change(function(){
                            doc_id = $('.div_branch_doc :selected').val();
                            // link = '/?action='+action+'&proc_id='+rb_id+'&doc_id='+doc_id;
                            link = '/show_object/'+doc_id;
                            link2 = rb_id+'/'+doc_id;
                        });
                    });
                }
            });
            dialog.find('input[name=type]:checked').change();
        }

        function editBranch(branch_id){
            var e = $('.tree [a_id="'+branch_id+'"]');
            var title = e.attr('a_title');
            var link = e.attr('a_link');
            var descr = e.attr('a_descr');
            work_branch(branch_id, url='/tree/edit', link, title, descr);
        }
        function createBranch(branch_id){
            work_branch(branch_id, url='/tree/add', '', '', '');
        }
        function work_branch(branch_id, url, linkk, title, descr){
            /**
             * Главная рабочая функция по редактированию элементов
             * @type {*|jQuery|HTMLElement}
             */
            var dialog = $("<div></div>");
            var form = $('<form><fieldset><div></div></fieldset></form>').appendTo(dialog);
            var formbody = $('fieldset', form);
            var nest = $('div', formbody);
            var t;
            if(cursor==null && action!='edit_comm'){
                set_widget_cursor(tree_body.find('.tree:first li:first'));
            }
            if(cursor_id == 0){
                alert('Выделите ветку');
                return;
            }
            t = cursor_id+'._'+cursor.find(".cm-menu-header:first").text();
            $("<div>"+dao.ct('add_new_group')+"</div>").appendTo(nest);

            $("<label>"+dao.ct('header')+"</label>").appendTo(nest);
            var title = $('<input class="inp1" />').appendTo(nest).val(title);

            $("<label>"+dao.ct('Описание')+"</label>").appendTo(nest);
            var descr = $('<textarea class="inp1" />').appendTo(nest).val(descr);

            if(options.is_add_link){
                select_menu(dialog, linkk, title);
            }
            dialog.dialog({
                bgiframe: true, autoOpen: true, height: 600, width: 400, modal: true,
                buttons: {
                    'Ok': function() {
                    var new_body = $('.t_rich_edit1[name="body1"]').val();
                    $.ajax({
                        type: "POST", dataType: "json", url:url,
                        data:{
                            proc_id: url="/tree/data/menu:root:left_menu" ? "menu:root:left_menu" : options.id,
                            parent_id: cursor_id, doc_id: '',
                            title: title.val(), descr:descr.val(),
                            link: options.is_add_link?link:'',
                            link2: options.is_add_link?link2:'',
                            branch_id: branch_id, body:new_body
                        },
                        success: function(data){
                            if(data.result=="ok"){
                                cursor_id = data.id;
                                updatetree();
                                dialog.dialog('close');
                            }else{ alert(data.error); }
                        }
                    });
                },
                'Отмена' : function() { $(this).dialog('close');	}
            },
            close: function() { delete dialog;  }
            });
        }

        function deleteBranch(branchId) {

            if(options.inframe_mode) return;
            var ids = [];
            if(branchId) {// Если параметр указан, удаляется одна запись
                ids.push( branchId);
            }else{ return; }
            $.ajax({
                url: '/tree/del', type: "POST", dataType: "json",
                data: {
                    action: 'delete_branch',
                    proc_id: (options.is_add_link || options.is_full_id)?options['id']:options['id'],
                    ids: JSON.stringify(ids)
                },
                success: function(msg){
                    if( msg.counter > 0 ){
                        updatetree();
                        set_widget_cursor(tree_body.find('.tree:first li:first'));
                    }else{ alert(msg.status); }
                }
            });
        }

        function example_link(dialog){
            $('<label> '+dao.ct('example_out_link')+'</label>').appendTo(dialog);
            $('<label><a href="#">http://google.com</a></label>').appendTo(dialog);
            $('<label> '+dao.ct('example_list_object')+'</label>').appendTo(dialog);
            $('<label><a href="#">/show/des:obj/list</a></label>').appendTo(dialog);
            $('<label> '+dao.ct('example_list_categories')+'</label>').appendTo(dialog);
            $('<label><a href="#">/show/des:obj/branch/3</a></label>').appendTo(dialog);
            $('<label> '+dao.ct('example_single_object')+'</label>').appendTo(dialog);
            $('<label><a href="#">/show_object/3</a></label>').appendTo(dialog);
            $('<label> '+dao.ct('Пример тега')+'</label>').appendTo(dialog);
            $('<label><a href="#">"/show/des:obj/tags/транспорт</a></label>').appendTo(dialog);
            // $('.aa').css({'color':'#ccc'});
        }

        this.edit = edit_comm;
        this.del_comm = del_comm;
        this.update = function(opt){
            updatetree.call(this);
            if(opt.success !== undefined){
                opt.success.call(this);
            }
        }

	};
//	$.extend( window.dao, f(jQuery)	);// расширяем
})($);
