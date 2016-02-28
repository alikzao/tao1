<!DOCTYPE html>
{#<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">#}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="icon" href="/static/static/img/favicon.ico" type="image/x-icon">
	<link rel="shortcut icon" href="/static/static/img/favicon.ico" type="image/x-icon">

    <script type="text/javascript" src="/static/sites/jquery1.11.min.js"></script>
    <script type="text/javascript" src="/static/sites/jquery.mb.browser.min.js"></script>

    <script type="text/javascript"          src="/static/sites/bootstrap/js/bootstrap.min.js" ></script>
    <link rel="stylesheet" type="text/css" href="/static/sites/bootstrap/css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="/static/sites/bootstrap/css/bootstrap-theme.min.css" />

    <link rel="stylesheet" href="/static/sites/fa/css/font-awesome.min.css">


	<script type="text/javascript" src="/static/admin/jquery-ui/jquery-ui.min.js" ></script>
	<script type="text/javascript" src="/static/admin/jquery.scrollTo-min.js" ></script>


	<script type="text/javascript" src="/static/admin/json2.js" ></script>
	<script type="text/javascript" src="/static/admin/underscore.js" ></script>
	<script type="text/javascript" src="/static/admin/backbone.js" ></script>
{#	<script type="text/javascript" src="/static/admin/jquery.multifile.js" ></script>#}
{#	<script type="text/javascript" src="/static/admin/jquery.form.js" ></script>#}
	<script type="text/javascript" src="/static/admin/jquery.datetimepicker.js" ></script>


	<script type="text/javascript" src="/static/admin/code_mirror/lib/codemirror.js"></script>
	<link   rel="stylesheet"        href="/static/admin/code_mirror/lib/codemirror.css">
	<link   rel="stylesheet"        href="/static/admin/code_mirror/theme/rubyblue.css">
	<script type="text/javascript" src="/static/admin/code_mirror/mode/python/python.js"></script>
	<script type="text/javascript" src="/static/admin/code_mirror/mode/css/css.js"></script>
	<script type="text/javascript" src="/static/admin/code_mirror/mode/javascript/javascript.js"></script>
	<script type="text/javascript" src="/static/admin/code_mirror/mode/xml/xml.js"></script>
	<script type="text/javascript" src="/static/admin/code_mirror/mode/htmlmixed/htmlmixed.js"></script>
	<script type="text/javascript" src="/static/admin/code_mirror/mode/jinja2/jinja2.js"></script>

	<script type="text/javascript" src="/static/contents/dao_ui.js" ></script>

{#	<script type="text/javascript" src="/static/contents/lang_{{lang}}.js"></script>#}
	<script type="text/javascript" src="/static/tree/menu.js"></script>
	<script type="text/javascript" src="/static/admin/conf_templ.js"></script>

	<script type="text/javascript" src="/static/admin/sortable/Sortable.js"></script>

	<script type="text/javascript" src="/static/perm/ta.js"></script>   {#  /* add_processor добавляет всякое*/   #}
	<script type="text/javascript" src="/static/tree/tt.js"></script>


	<script type="text/javascript" src="/static/table/ts_new.js"></script>

	<script type="text/javascript" src="/static/table/tp_new.js"></script>
	<script type="text/javascript" src="/static/table/tp_site.js"></script>

{#	<script type="text/javascript" src="/static/sandbox/sb.js"></script>    {#  /* функции для песочницы */   #}


	<script type="text/javascript" src="/static/files/tf.js"></script>
	<script type="text/javascript" src="/static/contents/te_new.js"></script>

	<script type="text/javascript" src="/static/admin/chosen/chosen.jquery.min.js"></script>
	<link   rel="stylesheet" type="text/css" href="/static/admin/chosen/chosen.css" />

	<link   rel="stylesheet" type="text/css" href="/static/tree/tt.css" />
	<link   rel="stylesheet" type="text/css" href="/static/tree/lm.css" />
	<link   rel="stylesheet" type="text/css" href="/static/admin/admin.css" />

	<link   rel="stylesheet" type="text/css" href="/static/admin/cupertino/jquery-ui.custom.css" />
{#	<link   rel="stylesheet" type="text/css" href="/static/contents/reset.css" />#}
{#	<link   rel="stylesheet" type="text/css" href="/static/contents/default.css" />#}

	<link   rel="stylesheet" type="text/css" href="/static/table/table.css" />
	<link   rel="stylesheet" type="text/css" href="/static/contents/content.css" />

    <script type="text/javascript" src="/static/contents/utils.js" ></script>


	<title>{{ title }} </title>
</head>
<body>
<style type="text/css">
#tabs {position: absolute; top:0; left:0; right:0; bottom: 0;}
#tabs > div {position: absolute; top:43px; left:0; right:0; bottom: 0; overflow: auto;}
.l_panel {
    position: absolute;
    left:0px;
    top:0px;
    bottom: 40px;
    border: #7ac9e6 solid 1px;
    margin: 36px 6px 8px 4px;
}
.m_panel {
    position: absolute;
    left:200px;
    top:36px;
    right:0px;
    bottom:40px;
    border: #7ac9e6 solid 1px;
    margin: 0px 5px 8px 10px;
}
.m_panel, .l_panel{
    background-color:white; padding:4px; border-radius:10px;
}
.r_panel {
    -webkit-font-smoothing: antialiased;
    bottom: 0px;
    box-sizing: border-box;
    color: rgb(51, 51, 51);
    display: block;
    font-family: 'Quattrocento Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif;
    font-size: 14px;
    font-weight: 300;
    height: 464px;
    left: 0px;
    line-height: 20px;
    outline: 0px none rgb(51, 51, 51);
    padding-top: 50px;
    position: fixed;
    top: 0px;
    width: 210px;
}
</style>
<p><noscript><strong style="color:red;">javascript disabled</strong></noscript></p>

{#<div class="container-fluid">#}
    <div class="row">
{#        <div class="l_panel">#}
        <div class="l1_panel col-xs-3">
            {% include 'libs.admin:left_menu.tpl' %}
    {#            <div class="btn btn-default action"><i class="fa fa-angle-left"></i></div>#}
        </div>
{#        <div class="m_panel">#}
        <div class="m_1panel col-xs-9">
            <div id="header"> {% include 'libs.admin:soc_h.tpl' %} </div>

            {% block content %}{% endblock %}
        </div>
    </div>

{#</div>#}








</body>
</html>

<script>
$(function(){
    $('.left_panel').on('click', '.action', function(){
        $('.left_panel').hide();
        $('.middle_panel').css({'left':'0px'});
    });
});
</script>
    <script type="text/javascript" src="/static/tree/lm.js"></script>



<!--<select name="select_l" id="select_l">  
<option value="ru" class="sel_lang ru_lang" selected >Русский</option>  
<option value="en" class="sel_lang en_lang" >USA</option>
</select>-->