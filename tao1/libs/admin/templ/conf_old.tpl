{% extends "libs.admin:base.tpl" %}
{% block content %}
{#<script type="text/javascript" src="/static/core/angular.min.js"></script>#}

<div class="app">
    <ul class="nav nav-tabs">
        <li class="active"><a href="#home" ds_id="home" data-toggle="tab"><i class="icon-home"></i> Карта</a></li>
    </ul>
    <!-- Tab panes -->
    <div class="tab-content tab-content1" >
        <div class="tab-pane active" id="home" style="">
            <div class="set_auth col-xs-2" style="margin:12px;">

                <div class="panel-group" id="accordion">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                                    Collapsible Group Item #1
                                </a>
                            </h4>
                        </div>
                        <div id="collapseOne" class="panel-collapse collapse in">
                            <div class="panel-body">
                                123
                            </div>
                        </div>
                    </div>
                </div>

                <div class="work_rb do_open" data-toggle="collapse" data-target="#demo">
                    <i class="icon-caret-down"></i> Документы <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  обьектов </div>
                </div>
                <div id="demo" class="collapse out">
                {%  for i in all_docs %}
                    <div class="add_rb ar btn btn-info" ng-href="/table/in/{{i._id}}" d_id="{{ i._id }}">{{ ct( i.conf.title ) }}</div>
                {% endfor %}
                </div>
            </div>
            <div class="set_auth col-xs-2" style="margin:12px;">'
                <div class="work_rb do_open">
                    <i class="icon-caret-down"></i> Справочники <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  обьектов </div>
                </div>
                <div>
                {%  for i in all_rbs %}
                    <div class="add_rb ar btn btn-info" ng-href="/table/in/{{i._id}}" d_id="{{ i._id }}">{{ ct( i.conf.title ) }}</div>
                {% endfor %}
                </div>
            </div>
            <div class="set_auth col-xs-2" style="margin:12px;">'
{#                {{ ss }}#}
            {% set counter = 0 %}

            <div class="work_rb do_open"><i class="icon-caret-down"></i> Внешний вид(шаблоны) <div class="line_work_rb" style="padding:6px; color:green;"> 2  обьекта </div> </div>
            <div class="add_rb ar btn btn-info" style="width:240px;" ng-href="/conf_templ" d_id="conf_templ"> Шаблоны конфигурация </div>
            <div class="add_rb ar btn btn-info" style="width:240px;" ng-href="/edit_templ" d_id="edit_templ"> Шаблоны редактиование </div>

            {%  for i in ss %}
{#                     1111 {{ counter }}#}
                {% set counter = counter + 1 %}
                {% if i._id == 'conf_adm' %}
                     {% if counter == 3 %}
                        <div class="work_rb do_open"><i class="icon-caret-down"></i> Настройки конфигурации <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  обьектов </div> </div>
                    {% endif %}
                    <div class="add_rb ar btn btn-info" style="width:240px;" ng-href="{{i.link}}" d_id="{{ i._id }}">{{ ct( i.title ) }}</div>
                {% endif %}
{#                {% if i._id == 'conf_adm' or i._id == '' or i._id == '' or i._id == ''%}#}
                {% if i._id == 'in_sandbox' or i._id == 'add_func' %}
                    {% if counter == 6 %}
                        <div class="work_rb do_open"><i class="icon-caret-down"></i> Песочница <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  обьектов </div> </div>
                    {% endif %}
                    <div class="add_rb ar btn btn-info" style="width:240px;" ng-href="{{i.link}}" d_id="{{ i._id }}">{{ ct( i.title ) }}</div>
                {% endif %}
                {% if i._id == 'add_rb' or i._id == 'del_rb'%}
                    {% if counter == 1 %}
                        <div class="work_rb do_open"><i class="icon-caret-down"></i> Настройки справочников <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  обьектов </div> </div>
                    {% endif %}
                    <div class="add_rb ar btn btn-info" style="width:240px;" ng-href="{{i.link}}" d_id="{{ i._id }}">{{ ct( i.title ) }}</div>
                {% endif %}

                {% if i._id == 'users_group' or i._id == 'group_perm' or i._id == 'add_role' or i._id == 'create_user'%}
                         2222 {{ counter }}
                    {% if counter == 7 %}
                        <div class="work_rb do_open"><i class="icon-caret-down"></i> ACL — контроля доступа <div class="line_work_rb" style="padding:6px; color:green;"> ctr.doc  обьектов </div> </div>
                    {% endif %}
                    <div class="add_rb ar btn btn-info" style="width:240px;" ng-href="{{i.link}}" d_id="{{ i._id }}">{{ ct( i.title ) }}</div>
                {% endif %}
            {% endfor %}

            </div>
        </div>
{#        <div class="tab-pane" id="profile"></div>#}

    </div>
    <style type="text/css">
        .tab-content{
{#        .tab-pane{#}
            background-color:white;
            position: absolute;
            top: 43px;
            left: 0;
            right: 0;
            bottom: 0;
            overflow: auto;
        }
    </style>


</div>


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
     }


    /**
     * init event
     */
    $('.ar').on('click', add_tab );
    $('.app').on('click', '.close_tab', close_tab);
    $('.app').on('click', '.ddda', function(){
        alert('aaaaa');
    });

    /**
     * event
     */
    function add_tab(){
        // проверяем что вкладка не открыта и если открыта то просто переклюючаем на нее
        // иначе открываем новую вкладку и заносим это дело в локалстораж
        var proc_id = $(this).attr('d_id');
        var tab = JSON.parse(localStorage.getItem('tabs'));
        if(tab != null && $('.nav-tabs [ds_id="'+proc_id+'"]').length) {
             $('.nav-tabs a[ds_id="'+proc_id+'"]').tab('show');
        }else {
            var proc_idd = proc_id.replace(/:/g, '_');
            var url = $(this).attr('ng-href');
            $('<li><a href="#' + proc_idd + '" ds_id="' + proc_id + '" data-toggle="tab">' + $(this).text() + '&nbsp;&nbsp; ' +
                    '<i style="color:green; cursor:pointer;" class="icon-refresh"></i> &nbsp;' +
                    '<i style="color:red; cursor:pointer;"   class="close_tab icon-remove"></i> ' +
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
{#        var select_id = model.get('open_id');#}
{#        var url = model.get('url');#}
{#        console.log(proc_id)#}
        $.ajax({
{#            url: url+(select_id ? '?select_id='+select_id : ''),#}
            url: url,
            type:"get", dataType: "html", data:{select_id:select_id},
            success : function (data) {
{#                console.log(data);#}
{#                $('.tab-pane[ds_id="'+proc_id+'"]').empty().append(data);#}
                $('.tab-pane[ds_id="'+proc_id+'"]').empty().html(data);
            },
            error : function (xhr, status, err) { alert(err); }
        });
     }

});

{#$('.tab-pane[ds_id="des:obj"]')#}

</script>


{% endblock %}


ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=uftp --shell=/bin/false --home=/home/old_ari/boyar --uid=112 --gid=65500
uftpuser321
ftp://uftp:uftpuser321@144.76.43.183
ftp://anonymous:@144.76.43.183
ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=tester --uid=33 --gid=33 --home=/home/old_ari/boyar --shell=/bin/false
aaa




