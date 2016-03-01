{% extends "libs.admin:base.tpl" %}
{% block content %}

{#    conf.tpl -> /site/templ/conf_templ.tpl -> conf_templ.js#}
<style type="text/css">
{#        .tab-content{ position: absolute; top: 43px; left: 0; right: 0; bottom: 0; overflow:scroll; }#}
{#        .nav-tabs{    position: absolute; top: 0px; left: 0; right: 0; }#}
</style>



{#<div class="app" style="position:absolute; top:0px;">#}
<div class="app">
    <ul class="nav nav-tabs ">
        <li class="active"><a href="#home" ds_id="home" data-toggle="tab"><i class="fa fa-home"></i> Map</a></li>
    </ul>
    <!-- Tab panes -->
    <div class="tab-content" >
        <div class="tab-pane active" id="home" style="">
            <div class="inner">

            <div class="set_auth col-xs-3" style="margin:12px;">

                <div class="panel-group" id="accordion" style="margin-bottom:10px;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                                    <i class="fa fa-caret-down"></i> Docs <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  объектов </div>
                                </a>
                            </h4>
                        </div>
                        <div id="collapseOne" class="panel-collapse collapse out">
                            <div class="panel-body">
                                {%  for i in all_docs %}
                                    <div class="add_rb ar btn btn-info" ng-href="/table/in/{{i._id}}" d_id="{{ i._id }}">{{ ct( i.conf.title ) }}</div>
                                {% endfor %}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="panel-group" id="accordion">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
                                    <i class="fa fa-caret-down"></i> Справочники <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  объектов </div>
                                </a>
                            </h4>
                        </div>
                        <div id="collapseTwo" class="panel-collapse collapse in">
                            <div class="panel-body">
                                {%  for i in all_rbs %}
                                    <div class="add_rb ar btn btn-info" ng-href="/table/in/{{i._id}}" d_id="{{ i._id }}">{{ ct( i.conf.title ) }}</div>
                                {% endfor %}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="set_auth col-xs-3" style="margin:12px;">
{#                отчеты  #}
                <div class="panel-group" id="accordion" style="margin-bottom:10px;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#report">
                                    <i class="fa fa-caret-down"></i> Отчеты <div class="line_work_rb" style="padding:6px; color:green;"> 1 объект </div>
                                </a>
                            </h4>
                        </div>
                        <div id="report" class="panel-collapse collapse out">
                            <div class="panel-body">
{#                                {%  for i in all_rbs %}#}
{#                                    <div class="add_rb ar btn btn-info" ng-href="/table/in/{{i._id}}" d_id="{{ i._id }}">{{ ct( i.conf.title ) }}</div>#}
                                    <div class="add_rb ar btn btn-info" ng-href="" d_id="">While empty</div>
{#                                {% endfor %}#}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="panel-group" id="accordion">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#report_n">
                                    <i class="fa fa-caret-down"></i> Разное<div class="line_work_rb" style="padding:6px; color:green;"> 1 объект </div>
                                </a>
                            </h4>
                        </div>
                        <div id="report_n" class="panel-collapse collapse out">
                            <div class="panel-body">
                                <div class="add_rb ar btn btn-info" ng-href="/meal" d_id="conf_meal"><i class="fa fa-birthday-cake"></i> &nbsp; Meal</div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <div class="set_auth col-xs-3" style="margin:12px;">

{#            {%  for i in ss %}#}
{#            {% endfor %}#}

                <div class="panel-group" id="accordion">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#templ">
                                    <i class="fa fa-caret-down"></i> Внешний вид(шаблоны) <div class="line_work_rb" style="padding:6px; color:green;"> 2  обьекта </div>
                                </a>
                            </h4>
                        </div>
                        <div id="templ" class="panel-collapse collapse out">
                            <div class="panel-body">
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/conf_templ" d_id="conf_templ"> Шаблоны конфигурация </div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/edit_templ" d_id="edit_templ"> Шаблоны редактиование </div>
                            </div>
                        </div>
                    </div>

                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#acl">
                                    <i class="fa fa-caret-down"></i> ACL — контроля доступа <div class="line_work_rb" style="padding:6px; color:green;"> 4 обьекта </div>
                                </a>
                            </h4>
                        </div>
                        <div id="acl" class="panel-collapse collapse out">
                            <div class="panel-body">
    {#                            <div class="add_rb ar btn btn-info" style="width:240px;" ng-href="{{i.link}}" d_id="{{ i._id }}">Пользователи</div>#}
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/table/in/des:users"    d_id="create_user"> Пользователи</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/settings/users_group"  d_id="users_group"> Состав групп</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/settings/group_perm"   d_id="group_perm">  Права групп</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/table/in/des:role"     d_id="conf_role">   Роли пользователей</div>
                            </div>
                        </div>
                    </div>

                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#set_conf">
                                    <i class="fa fa-caret-down"></i> Настройки конфигурации <div class="line_work_rb" style="padding:6px; color:green;"> 2 обьекта </div>
                                </a>
                            </h4>
                        </div>
                        <div id="set_conf" class="panel-collapse collapse out">
                            <div class="panel-body">
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/conf_rb_doc" d_id="conf_conf">Конфигурация админки</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/table/in/des:conf" d_id="conf_rb_doc">Справочник настроек</div>
                            </div>
                        </div>
                    </div>
{#                {% if i._id == 'conf_adm' or i._id == '' or i._id == '' or i._id == ''%}#}
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#sandbox">
                                    <i class="fa fa-caret-down"></i> Песочница <div class="line_work_rb" style="padding:6px; color:green;"> 2 обьекта </div>
                                </a>
                            </h4>
                        </div>
                        <div id="sandbox" class="panel-collapse collapse out">
                            <div class="panel-body">
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/add_func" d_id="add_func">Создать функцию</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/sandbox"       d_id="sb">Песочница</div>
                            </div>
                        </div>
                    </div>

                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#set_ref">
                                    <i class="fa fa-caret-down"></i> Настройки справочников <div class="line_work_rb" style="padding:6px; color:green;"> 2 обьекта </div>
                                </a>
                            </h4>
                        </div>
                        <div id="set_ref" class="panel-collapse collapse out">
                            <div class="panel-body">
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/add_rb" d_id="add_rb">Создать справочник</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/del_rb" d_id="del_rb">Удалить справочник</div>
                            </div>
                        </div>
                    </div>

                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#set_menu">
                                    <i class="fa fa-caret-down"></i> Настройки меню <div class="line_work_rb" style="padding:6px; color:green;"> 3 обьекта </div>
                                </a>
                            </h4>
                        </div>
                        <div id="set_menu" class="panel-collapse collapse out">
                            <div class="panel-body">
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/menu/menu:site:left"      d_id="menu:site:left">Левое меню</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/menu/menu:site:top"       d_id="menu:site:top">Верхнее меню</div>
                                <div class="add_rb ar btn btn-info" style="width:180px;" ng-href="/menu/menu:root:left_menu" d_id="menu:root:left_menu">Внутренее меню</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            </div>
        </div>
    </div>


</div>


{#'[{'title': u'title', '_id': 'add_rb', 'link': '', 'id': 'ss_add_rb', 'class': 'd_rb'},#}
{#    {'title': u'title', '_id': 'del_rb', 'link': '', 'id': 'ss_del_rb', 'class': 'd_rb'},#}
{#    {'title': u'title', '_id': 'conf_adm', 'link': '', 'id': 'ss_conf_adm', 'class': 'd_rb'}]#}


<script type="text/javascript">

;$(function(){
    /**
     * init tabs
     */

     setTimeout( function(){ init_tabs(); }, 200);
     function init_tabs(){
         var tabs = JSON.parse(localStorage.getItem('tabs'));
         for(var i in tabs){
             $('[d_id="'+tabs[i]+'"]').click();
         }
{#         $('.nav-tabs a[ds_id="home"]').tab('show');#}
		 var curr_tab = localStorage.getItem('current_tab');
         $('.nav-tabs a[ds_id="'+curr_tab+'"]').tab('show');
     }

    /**
     * init events
     */
    window.add_tab = add_tab;
    $('.ar')          .on('click', { foo: "false" }, add_tab );
    $('.cm-menu-item').on('click', { foo: "www"   }, add_tab );
    $('.app')         .on('click', '.close_tab', close_tab);
    $('.nav-tabs')    .on('click', 'li', function(){ $('[proc_id="des:ware"] .fa-refresh').click(); });  // инициализирует прокрутку, типа хак
{#    $(document).on( 'shown.bs.tab', 'a[data-toggle="tab"]', function (e) {#}
    $(document).on( 'click', 'a[data-toggle="tab"]', function (e) {
		localStorage.setItem('current_tab', $(this).attr('ds_id') );
	});
    /**
     * events
     */
    function add_tab(event, tn){
        // проверяем что вкладка не открыта и если открыта то просто переклюючаем на нее
        // иначе открываем новую вкладку и заносим это дело в локалстораж
{#        console.warn(['if begin', $.type(event)]);#}
        var proc_id = ($.type(event) != 'string') ? $(this).attr('d_id') : event;
        var url = ($.type(event) != 'string') ? $(this).attr('ng-href'): '/table/in/'+proc_id  ;
        var tab_name = ($.type(event) != 'string') ? $(this).text(): tn  ;

        var tab = JSON.parse(localStorage.getItem('tabs'));
        if(tab != null && $('.nav-tabs [ds_id="'+proc_id+'"]').length) {
            //add in localStorage id last opened tab
	        localStorage.setItem('current_tab', proc_id );
{#            $('.nav-tabs a[ds_id="'+proc_id+'"]').tab('show');#}
        }else {
            var proc_idd = proc_id.replace(/:/g, '_');
{#            console.log(['url', url]);#}
            $('<li><a href="#' + proc_idd + '" ds_id="' + proc_id + '" data-toggle="tab">' + tab_name + '&nbsp;&nbsp; ' +
                    '<i style="color:green; cursor:pointer;" class="fa fa-refresh"></i> &nbsp;' +
                    '<i style="color:red; cursor:pointer;"   class="close_tab fa fa-remove"></i> ' +
                    '</a></li>').appendTo('.app .nav');
            $('<div class="tab-pane tab-pane1" id="' + proc_idd + '" ds_id="' + proc_id + '"></div>').appendTo('.tab-content');
            $('.nav-tabs a[ds_id="' + proc_id + '"]').tab('show');
            update_tab(proc_id, url);
        }

        if(tab != null && tab.indexOf(proc_id) != -1) return false;
        if(tab == null){
            localStorage.setItem('tabs', JSON.stringify( [] ) );
            tab = JSON.parse(localStorage.getItem('tabs'));
        }
        tab.push(proc_id);
        localStorage.setItem('tabs',  JSON.stringify(tab));
    }

    function close_tab(){
        // переключаем на соседнюю закладку
        var d_tab = $(this).closest('a').attr('ds_id');
        var ds_id = $('.nav-tabs [ds_id="'+d_tab+'"]').closest('li').prev().find('a').attr('ds_id');
        setTimeout( function(){   $('.nav-tabs [ds_id="'+ds_id+'"]').tab('show');   }, 200);
        // удаляем старую закладку и её содержимое
        $(this).closest('li').remove();
        $('.tab-pane[ds_id="'+d_tab+'"]').empty();
        // удаляем из локал сторадж лишнее
        var l_tab = JSON.parse(localStorage.getItem('tabs'));
        var index = l_tab.indexOf(d_tab);
        l_tab.splice(index, 1);
        localStorage.setItem('tabs',  JSON.stringify(l_tab));
    }

    function close_all(){
        localStorage.clear();
    }

    /**
     * model
     */
     function update_tab(proc_id, url){
        // select_id - различает справочник это или специальная таблица формируемая на сервере вручную
        var ds_idd = '#'+proc_id.replace(/:/g, '_');
        var select_id = '';
        console.log('url => ', url, 'proc_id: ', proc_id);
        $.ajax({
            url: url,
            type:"get", dataType: "html", data:{select_id:select_id},
            success : function (data) {
                $('.tab-pane[ds_id="'+proc_id+'"]').empty().html(data);
            },
            error : function (xhr, status, err) { alert(err); }
        });
     }

});


</script>


{% endblock %}






