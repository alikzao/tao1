;(function($){
    var defaults = { };
    window.dao.left_menu = left_menu;
    function left_menu(parent, params){
        // Правильное создание нового объекта с присвоением ему значений по-умолчанию и частично указанных новых значений
        var options = $.extend({}, defaults, params);
        var left_menu_body = $('<div></div>').appendTo(parent);
        update();

        function update() {
            $.ajax({
                url: '/menu/iface',
                type: "POST",
                dataType: "json",
                data:{},
                success: function(data){
                    console.warn(data.content);
                    _draw(data.content);
                }
            });
        }
        function _draw(content, root) {
            if(root==undefined){ //проверяем что мы начинаем рисовать дерево
                var ul = $('<ul class="left_menu"></ul>').appendTo(left_menu_body);
                _draw(content.children, ul);
                 // по щелчку по папке сворачиваем и разварачиваем дерево.
                $('.cm-menu-header').click(function() {
                    $(this).find('.cm-menu-icon:first i')
                        .toggleClass('icon-folder-close icon-folder-open')
                        .closest('.tree_item')
                        .find('ul:first').toggle();
                });
                $('.cm-menu-header').each(function(){  });
                left_menu_body.find(':nth-child(1)>li').addClass('btn ');
                ul.children().each(function(){
                    $(this).find('h1:first').addClass('btn-info btn-xs').find('i').addClass('icon-white');
                });
                return false;
            }

            for(var index in content){
                var branch = content[index];
                var is_branch = !(branch.children === undefined || branch.children.length == 0);
                var li_tree = $('<li branch_id="'+branch.id+'" class="tree_item '+(is_branch?'tree_branch':'tree_leaf ')+'"></li>');
                var h1_tree = $('<h1 class="cm-menu-header" branch_id="'+index+'" style="padding:5px 0; text-align:left;"/>').appendTo(li_tree);
                if (is_branch)
                    var a_tree=$('<span class="cm-menu-folder">'+branch.title+'</span>').appendTo(h1_tree);
                else
                    var a_tree=$(
                        '<a class="cm-menu-item" d_id="'+content[index].link2+'" style="overflow:hidden; display:block;">'+branch.title+'</a>')
                        .appendTo(h1_tree);

                $('<div style="display:inline-table;">'+
                    '<div style = "display:inline-cell; margin-left: 5px; margin-right: 5px;" class="div-icon cm-menu-icon">'+
                        '<i class="'+(is_branch ?'icon-folder-close':'icon-list-alt')+'"></i>'+
                    '</div>'
                ).prependTo(a_tree);
                h1_tree.click(function(){ set_widget_cursor($(this).parent().parent()); });
                if(is_branch){
                    var children = $('<ul style="display: none;"></ul>').appendTo(li_tree);
                    _draw(branch.children, children);
                }
                $(root).append(li_tree);
            }
        }
        setTimeout(function(){
            $('.cm-menu-item').on('click', function(){
                var tab_name = $(this).closest('a').text();
                var tab_proc = $(this).closest('a').attr('d_id');
                window.add_tab(tab_proc, tab_name);
            });
        }, 1000);

        function set_widget_cursor(widget){ }
        var instance = {};
        return instance;
    };
})(jQuery);


