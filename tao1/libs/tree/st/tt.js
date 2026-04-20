;
(function($) {
        var defaults = {};
        window.dao.tree_processor = function(parent, body, params) {
            var options = $.extend({}, defaults, params);
            var dialog;
            /* Legacy comment translated from Russian. */
            if (parent) {
                parent = $(parent);
                var element = $('<div/>').appendTo(parent);
                parent.css('overflow', 'hidden');
                var toolbar = null;
                var preheader = null;
                var cursor = null;
                var cursor_id = options.id_tree ? options.id_tree : 0;
                var link = '';
                var link2 = '';

                var defaultCreateParams = {
                    title: dao.ct('create_new_rec')
                };
                var tree_toolbar = $(
                    '<div class="well btn-group btn-group-sm" style="position:absolute; top:0px; left:0px; right:0px; overflow:hidden; display:block;' +
                    'padding:2px; text-align:left; height:38px;"></div>').appendTo(parent);
                var tree_body = $('<div style="position:absolute; top:36px; left:0px; right:0px; overflow:hidden; display:block; bottom:0px; ' +
                    'background-color:white;"></div>').appendTo(parent);
                var add_branch = $('<div class="btn btn-default"   title=""><div class="icon-plus-sign"/>&nbsp;</div>').appendTo(tree_toolbar);
                var del_branch = $('<div class="btn btn-default"   title=""><div class="icon-trash "/>&nbsp;</div>').appendTo(tree_toolbar);
                var edit_branch = $('<div class="btn btn-default"  title=""><div class="icon-edit"/>&nbsp;</div>').appendTo(tree_toolbar);
                var refresh_tree = $('<div class="btn btn-default" title=""><div class="icon-refresh "/>&nbsp;</div>').appendTo(tree_toolbar);
                add_branch.click(function() {
                    var branchId = cursor_id;
                    createBranch(branchId);
                });
                edit_branch.click(function() {
                    var branchId = cursor_id;
                    editBranch(branchId);
                });
                del_branch.click(function() {
                    var branchId = cursor_id;
                    deleteBranch(branchId);
                });
                var tree = $('<div class="doc_button ui-button ui-state-default ui-corner-all" style="position:absolute; ' +
                    'top:4px; bottom:0px; right:0px; font-size:12px;">' + dao.ct('categories') + '</div>').appendTo(toolbar);
                var is_recursive = false;

                //XXX
                refresh_tree.click(function() {
                    updatetree();
                });
                // Legacy comment translated from Russian.
                var show_all = options.check_tree;
            }

            function updatelist() {
                if (options.on_change)
                    options.on_change(show_all ? null : cursor_id, is_recursive);
            }

            function postupdatetree() {
                var t = tree_body.find("[branch_id=" + cursor_id + "]");
                if (t.length > 0) set_widget_cursor(t);
                else updatelist();

                // Legacy comment translated from Russian.
                tree_body.find("[branch_id]").each(function() {

                    $(this).find(".inter").droppable({
                        hoverClass: "ui-state-highlight",
                        drop: function(event, ui) {
                            // Legacy comment translated from Russian.
                            if (ui.draggable.parent().parent().hasClass('tree_item')) {
                                var top_neighbor = $(this).parent().parent().attr("branch_id");
                                var current_id = ui.draggable.parent().parent().attr("branch_id");
                                $.ajax({
                                    // Legacy comment translated from Russian.
                                    type: "POST",
                                    url: '/tree/order_branch',
                                    data: {
                                        proc_id: options['id'], // Legacy comment translated from Russian.
                                        current_id: current_id,
                                        top_neighbor: top_neighbor
                                    },
                                    dataType: 'json',
                                    beforeLoad: function() {},
                                    success: function(data) {
                                        if (data.result == "ok") {
                                            updatetree();
                                        } else {
                                            alert("" + dao.ct('not_move') + ": " + data.status);
                                        }
                                    }
                                });
                            } else { // Legacy comment translated from Russian.
                                if (options.on_drop) {
                                    var branch_id = $(this).parent().parent().attr("branch_id");
                                    options.on_drop(branch_id)
                                }
                            }
                        }
                    });
                    $(this).find("a:first").droppable({
                        hoverClass: "ui-state-highlight",
                        drop: function(event, ui) {
                            // Legacy comment translated from Russian.
                            if (ui.draggable.parent().parent().hasClass('tree_item')) {
                                var branch_id = $(this).parent().parent().attr("branch_id");
                                var current_id = ui.draggable.parent().parent().attr("branch_id");
                                $.ajax({
                                    type: "POST",
                                    url: '/tree/move_branch',
                                    dataType: 'json',
                                    data: {
                                        proc_id: options['id'], // Legacy comment translated from Russian.
                                        current_id: current_id,
                                        new_parent_id: branch_id
                                    },
                                    beforeLoad: function() {},
                                    success: function(data) {
                                        if (data.result == "ok") {
                                            updatetree();
                                        } else {
                                            alert("" + dao.translate('not_move') + ": " + data.status);
                                        }
                                    }
                                });
                            } else { // Legacy comment translated from Russian.
                                if (options.on_drop) {
                                    var branch_id = $(this).parent().parent().attr("branch_id");
                                    options.on_drop(branch_id)
                                }
                            }
                        }
                    }).draggable({
                        start: function() {
                            branch_id = $(this).parent().parent().attr("branch_id");
                        },
                        helper: function() {
                            var helper = $('<div class="ui-state-highlight ui-corner-all">[]</div>')
                                .css({
                                    "z-index": 9999,
                                    "padding": "4px;"
                                });
                            return helper;
                        }
                    });
                });
            }

            function updatetree() {
                if (options.url == '/tree/data/menu:root:left_menu') url = '/menu/iface'
                else url = options.url
                $.ajax({
                    url: url,
                    type: "POST",
                    dataType: "json",
                    data: {
                        proc_id: options.id,
                        owner: options.owner,
                        action: "tree"
                    },
                    beforeSend: function() {},
                    success: function(answer) {
                        if (answer.proc_id) {
                            options.id = answer.proc_id;
                            options.owner = undefined;
                        }
                        _drawtree(answer.content);
                        postupdatetree();
                    }
                });
            }

            function set_widget_cursor(widget) {
                //XXX
                var branch_id;
                var old_id = cursor_id;
                if (widget != undefined && (branch_id = widget.attr('branch_id'))) {
                    cursor = widget;
                    cursor_id = branch_id;
                    $(tree_body).find(".ui-state-default").removeClass("ui-state-default");
                    cursor.find("a:first").addClass("ui-state-default");
                } else {
                    cursor = null;
                    cursor_id = 0;
                }
                if (old_id != cursor_id) {
                    updatelist();
                }
            }



            function _drawtree(content, root) {
                //            console.log('content', content, 'root', root);
                if (root == undefined) {
                    tree_body.empty();
                    tree_body.css({
                        'overflow': 'auto'
                    });
                    var show_all_branch = $('<label> <input type="checkbox" ' + (options.check_tree ? 'checked = "true"' : '') + ' /> ' + dao.ct('all_rec') + '</label>')
                        .appendTo(tree_body).find('input:first')
                        .change(function() {
                            show_all = $(this).attr('checked');
                            updatelist();
                        });
                    var show_recursive = $('<label> <input type="checkbox"/> ' + dao.ct('wish_in') + '</label>')
                        .appendTo(tree_body).find('input:first')
                        .change(function() {
                            is_recursive = $(this).attr('checked');
                            updatelist();
                        });
                    // Legacy comment translated from Russian.
                    var ul = $('<ul class = "tree"/>').appendTo(tree_body);
                    _drawtree([content], ul);
                    return;
                }
                for (var index in content) {
                    var branch = content[index];
                    var is_branch = !(branch.children === undefined || branch.children.length == 0);

                    /* Legacy comment translated from Russian. */
                    var dialog = $("<div></div>");
                    var form = $('<form><fieldset><div></div></fieldset></form>').appendTo(dialog);
                    var formbody = $('fieldset', form);
                    var nest = $('div', formbody);
                    var t;
                    if (cursor == null && action != 'edit_comm') {
                        set_widget_cursor(tree_body.find('.tree:first li:first'));
                    }
                    if (cursor_id == 0) {
                        alert('Select a branch');
                        return;
                    }
                    t = cursor_id + '._' + cursor.find(".cm-menu-header:first").text();
                    $("<div>" + dao.ct('add_new_group') + "</div>").appendTo(nest);

                    $("<label>" + dao.ct('header') + "</label>").appendTo(nest);
                    var title = $('<input class="inp1" />').appendTo(nest).val(title);

                    $("<label>" + dao.ct('Description') + "</label>").appendTo(nest);
                    var descr = $('<textarea class="inp1" />').appendTo(nest).val(descr);

                    if (options.is_add_link) {
                        select_menu(dialog, linkk, title);
                    }
                    dialog.dialog({
                        bgiframe: true,
                        autoOpen: true,
                        height: 600,
                        width: 400,
                        modal: true,
                        buttons: {
                            'Ok': function() {
                                var new_body = $('.t_rich_edit1[name="body1"]').val();
                                $.ajax({
                                    type: "POST",
                                    dataType: "json",
                                    url: url,
                                    data: {
                                        proc_id: url = "/tree/data/menu:root:left_menu" ? "menu:root:left_menu" : options.id,
                                        parent_id: cursor_id,
                                        doc_id: '',
                                        title: title.val(),
                                        descr: descr.val(),
                                        link: options.is_add_link ? link : '',
                                        link2: options.is_add_link ? link2 : '',
                                        branch_id: branch_id,
                                        body: new_body
                                    },
                                    success: function(data) {
                                        if (data.result == "ok") {
                                            cursor_id = data.id;
                                            updatetree();
                                            dialog.dialog('close');
                                        } else {
                                            alert(data.error);
                                        }
                                    }
                                });
                            },
                            'Cancel': function() {
                                $(this).dialog('close');
                            }
                        },
                        close: function() {
                            delete dialog;
                        }
                    });
                }

                function deleteBranch(branchId) {

                    if (options.inframe_mode) return;
                    var ids = [];
                    if (branchId) { // Legacy comment translated from Russian.
                        ids.push(branchId);
                    } else {
                        return;
                    }
                    $.ajax({
                        url: '/tree/del',
                        type: "POST",
                        dataType: "json",
                        data: {
                            action: 'delete_branch',
                            proc_id: (options.is_add_link || options.is_full_id) ? options['id'] : options['id'],
                            ids: JSON.stringify(ids)
                        },
                        success: function(msg) {
                            if (msg.counter > 0) {
                                updatetree();
                                set_widget_cursor(tree_body.find('.tree:first li:first'));
                            } else {
                                alert(msg.status);
                            }
                        }
                    });
                }

                function example_link(dialog) {
                    $('<label> ' + dao.ct('example_out_link') + '</label>').appendTo(dialog);
                    $('<label><a href="#">http://google.com</a></label>').appendTo(dialog);
                    $('<label> ' + dao.ct('example_list_object') + '</label>').appendTo(dialog);
                    $('<label><a href="#">/show/des:obj/list</a></label>').appendTo(dialog);
                    $('<label> ' + dao.ct('example_list_categories') + '</label>').appendTo(dialog);
                    $('<label><a href="#">/show/des:obj/branch/3</a></label>').appendTo(dialog);
                    $('<label> ' + dao.ct('example_single_object') + '</label>').appendTo(dialog);
                    $('<label><a href="#">/show_object/3</a></label>').appendTo(dialog);
                    $('<label> ' + dao.ct('Tag example') + '</label>').appendTo(dialog);
                    $('<label><a href="#">"/show/des:obj/tags/transport</a></label>').appendTo(dialog);
                    // $('.aa').css({'color':'#ccc'});
                }

                this.edit = edit_comm;
                this.del_comm = del_comm;
                this.update = function(opt) {
                    updatetree.call(this);
                    if (opt.success !== undefined) {
                        opt.success.call(this);
                    }
                }

            };
            // Legacy comment translated from Russian.
        })($);