<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
	<link rel="icon" href="/static/img/favicon.ico" type="image/x-icon">
	<link rel="shortcut icon" href="/static/img/favicon.ico" type="image/x-icon">

    <script type="text/javascript" src="/st/sites/jquery1.11.min.js"></script>
    <script type="text/javascript" src="/st/sites/jquery.mb.browser.min.js"></script>

    <script type="text/javascript"          src="/st/sites/bootstrap/js/bootstrap.min.js" ></script>
    <link rel="stylesheet" type="text/css" href="/st/sites/bootstrap/css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="/st/sites/bootstrap/css/bootstrap-theme.min.css" />

    <link rel="stylesheet" href="/st/sites/fa/css/font-awesome.min.css">


	<script type="text/javascript" src="/st/admin/jquery-ui/jquery-ui.min.js" ></script>
	<script type="text/javascript" src="/st/table/jquery.scrollTo.min.js" ></script>


	<script type="text/javascript" src="/st/admin/json2.js" ></script>
	<script type="text/javascript" src="/st/admin/underscore.js" ></script>
	<script type="text/javascript" src="/st/admin/backbone.js" ></script>
	<script type="text/javascript" src="/st/admin/jquery.datetimepicker.js" ></script>


	<script type="text/javascript" src="/st/admin/code_mirror/lib/codemirror.js"></script>
	<link   rel="stylesheet"        href="/st/admin/code_mirror/lib/codemirror.css">
	<link   rel="stylesheet"        href="/st/admin/code_mirror/theme/rubyblue.css">
	<script type="text/javascript" src="/st/admin/code_mirror/mode/python/python.js"></script>
	<script type="text/javascript" src="/st/admin/code_mirror/mode/css/css.js"></script>
	<script type="text/javascript" src="/st/admin/code_mirror/mode/javascript/javascript.js"></script>
	<script type="text/javascript" src="/st/admin/code_mirror/mode/xml/xml.js"></script>
	<script type="text/javascript" src="/st/admin/code_mirror/mode/htmlmixed/htmlmixed.js"></script>
	<script type="text/javascript" src="/st/admin/code_mirror/mode/jinja2/jinja2.js"></script>

	<script type="text/javascript" src="/st/contents/dao_ui.js" ></script>

{#	<script type="text/javascript" src="/static/contents/lang_{{lang}}.js"></script>  #}
{#	<script type="text/javascript" src="/static/tree/menu.js"></script>               #}
{#	<link   rel="stylesheet" type="text/css" href="/static/tree/lm.css" />            #}
{#	<script type="text/javascript" src="/static/sandbox/sb.js"></script>     /* function for sandbox */   #}

	<script type="text/javascript" src="/st/admin/sortable/Sortable.js"></script>

	<script type="text/javascript" src="/st/perm/ta.js"></script>   {#  /* add_processor add field*/   #}



      <script type="text/javascript" src="/st/table/ts_new.js"></script>
      <script type="text/javascript" src="/st/table/tp_new.js"></script>
      <script type="text/javascript" src="/st/table/tp_site.js"></script>



	<script type="text/javascript" src="/st/files/tf.js"></script>
	<script type="text/javascript" src="/st/contents/te_new.js"></script>

	<script type="text/javascript" src="/st/admin/chosen/chosen.jquery.min.js"></script>
	<link   rel="stylesheet" type="text/css" href="/st/admin/chosen/chosen.css" />

    <script type="text/javascript" src="/st/tree/tt.js"></script>
	<link   rel="stylesheet" type="text/css" href="/st/tree/tt.css" />

	<link   rel="stylesheet" type="text/css" href="/st/admin/cupertino/jquery-ui.custom.css" />


	<link   rel="stylesheet" type="text/css" href="/st/table/table.css" />
	<link   rel="stylesheet" type="text/css" href="/st/contents/content.css" />

    <script type="text/javascript" src="/st/contents/utils.js" ></script>


	<title>{{ title }} </title>

  </head>

  <body>







        <nav class="navbar navbar-inverse navbar-fixed-top">
            <div class="container-fluid">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar"
                            aria-expanded="false" aria-controls="navbar">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="#">Project name</a>
                </div>
                <div id="navbar" class="navbar-collapse collapse">
                    <ul class="nav navbar-nav navbar-right">
                        <li><a href="#">Dashboard</a></li>
                        <li><a href="#">Settings</a></li>
                        <li><a href="#">Profile</a></li>
                        <li><a href="#">Help</a></li>
                    </ul>
                    <form class="navbar-form navbar-right"><input type="text" class="form-control" placeholder="Search..."> </form>
                </div>
            </div>
        </nav>

        <div class="container-fluid">
            <div class="row">
                <div class="col-lg-2 sidebar">
                    <ul id="l_menu" class="nav nav-sidebar navbar-fixed-left" style="margin-top:45px;">
                        {% include 'libs.admin:left_menu.tpl' %}
                    </ul>

                </div>
{#        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main" style="margin-top:30px;">#}

{#        <div class="col-sm-10 col-sm-offset-3 col-md-10 col-md-offset-2 col-lg-offset-2 col-lg-10 main">#}
                <div class="col-lg-10 "  style="border:0px solid red; margin-top:103px;">

                                {% block content %}{% endblock %}

                </div>
            </div>
        </div>




<style type="text/css">

.nav-tabs li {
   background-color: white;
{#     z-index: 1030;#}
}
.nav-tabs{
    position: fixed;
{#    position: absolute;#}
    top:60px;
    left:225px; right:0px;
    bottom: 0;
    height: 100%;
 }

.tab-content .inner{
    position: fixed;
{#    position: absolute;#}
    top:106px;
    left:230px;
    right:1px;
    bottom:1px;
    overflow:auto;
}
.tab-content .grid.center{
    position: relative;
}
.statusbar{
{#    position: fixed;#}
{#    left:230px;#}
{#    right:1px;#}
{#    bottom:0px;#}
}



.navbar-fixed-left {
    width: 220px;
    position: fixed;
    left:0;
{#    right:0;#}
{#  border-radius: 0;#}
  height: 100%;
}

.navbar-fixed-left .navbar-nav > li {
{#  float: none;  /* Cancel default li float: left */#}
{#  width: 139px;#}
}
/* On using dropdown menu (To right shift popuped) */
/*.navbar-fixed-left .navbar-nav > li > .dropdown-menu {
  margin-top: -50px;
  margin-left: 140px;
}*/



.sidebar li > a:hover {
    background-color: #1c2128;
    color:white;
}
.sidebar li.active > a {
    background-color: #455264;
}
.sidebar li > a, .sidebar li  i {
    -webkit-font-smoothing: antialiased;
    line-height: 20px;
    color: rgb(139, 146, 154);
    cursor: auto;
{#    font-family: 'Quattrocento Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif;#}
    font-size: 14px;
    font-weight: 300;
}
.sidebar{
    background-color: #303946 !important;
}
.sidebar ul{
    background-color: #303946;
}


@media (min-width: 1200px) {
    .col-lg-2 { width:12%; }
    .col-lg-10 {
        width:88%;
        margin-left: 222px;
    }
 }




/* designer menu*/
#conf_menu {
    position: absolute;
    width: 250px;
    left: 0px;
    top: 30px;
    bottom: 20px;
    margin: 15px 0px 50px 50px;
}

/*configuration menu*/
.work_rb{
    text-align:left;
    cursor: pointer;
    border:1px solid #ccc;
    padding: 5px;
    box-shadow: 0 0 10px rgba(0,0,0,0.5)
}
.line_work_rb{
    margin-top: 6px;
    border-top: 1px solid #00dfcd;
}

.unable{
    color: #1E90FF;
    width: 120px;
    text-align: center;
    margin: 10px 10px 10px 10px;
    padding: 10px 10px 10px 10px;
    cursor: default;
}
.add_rb, .d_rb{
    color: #fff;
    width: 145px;
    text-align: center;
    margin: 10px 10px 10px 10px;
    padding: 10px 10px 10px 10px;
    cursor: pointer;
}
.add_block{
    color: #1E90FF;
    width: 160px;
    text-align: center;
    margin: 10px 10px 10px 0px;
    padding: 10px 10px 10px 0px;
}

.row_button {
    cursor: pointer;
    display: table-cell;
    padding: 0px 1px;
    margin: -2px 1px 0px 1px;
    border: transparent solid;
    border-width: 0px 1px;
    text-align: center;
    font-size: 13px;
}
</style>
  </body>
</html>
