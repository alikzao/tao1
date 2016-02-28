<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<LINK rel="shortcut icon" href="/static/core/img/icon.ico">

	<script type="text/javascript" src="/static/core/jquery/jquery1.js"></script>
{#	<script type="text/javascript" src="/static/core/jquery/jquery_dev.js"></script>#}

	<script type="text/javascript" src="/static/core/jquery/jquery-ui.js" ></script>
	<script type="text/javascript" src="/static/core/jquery/jquery.scrollTo-min.js" ></script>

	<script type="text/javascript" src="/static/core/jquery/json2.js" ></script>
	<script type="text/javascript" src="/static/core/jquery/underscore.js" ></script>
	<script type="text/javascript" src="/static/core/jquery/backbone.js" ></script>

	<script type="text/javascript" src="/static/core/jquery/jquery.multifile.js" ></script>
	<script type="text/javascript" src="/static/core/jquery/jquery.form.js" ></script>
	<script type="text/javascript" src="/static/core/jquery/jquery.datetimepicker.js" ></script>
	<script type="text/javascript" src="/static/core/flot/jquery.flot.js" ></script>
	<script type="text/javascript" src="/static/core/flot/jquery.flot.pie.js" ></script>

	<script type="text/javascript" src="/static/core/code_mirror/lib/codemirror.js"></script>
	<link rel="stylesheet"        href="/static/core/code_mirror/lib/codemirror.css">
	<link rel="stylesheet"        href="/static/core/code_mirror/theme/rubyblue.css">
	<script type="text/javascript" src="/static/core/code_mirror/mode/python/python.js"></script>

	<script type="text/javascript" src="/static/contents/dao_ui.js"></script>
	<script type="text/javascript" src="/static/core/lang_{{lang}}.js"></script>
	<script type="text/javascript" src="/static/contents/menu.js"></script>
	<script type="text/javascript" src="/static/core/lm.js"></script>
	<script type="text/javascript" src="/static/perm/ta.js"></script>
	<script type="text/javascript" src="/static/tree/tt.js"></script>

	<script type="text/javascript" src="/static/table/ts_new.js"></script>
	<script type="text/javascript" src="/static/table/tp_new.js"></script>
	<script type="text/javascript" src="/static/table/tp_site.js"></script>


	<script type="text/javascript" src="/static/files/tf.js"></script>
	<script type="text/javascript" src="/static/core/te.js"></script>
	<script type="text/javascript" src="/static/core/tl.js"></script>

	<link rel="stylesheet" type="text/css" href="/static/core/themes/cupertino/jquery-ui.custom.css" />
	<link rel="stylesheet" type="text/css" href="/static/core/reset.css" />
	<link rel="stylesheet" type="text/css" href="/static/core/main.css" />
	<link rel="stylesheet" type="text/css" href="/static/core/default.css" />

	<link rel="stylesheet" type="text/css" href="/static/table/table.css" />
	<link rel="stylesheet" type="text/css" href="/static/mongo_tree/mt.css" />
	<script type="text/javascript" src="/static/mongo_tree/mt.js"></script>

	<title>{{ title }} </title>

</head>
<body>



<div class="host"><a href="/mongodb">Хост</a></div>
<div class="dbs">
{% for res in db_list %}
		<div class="db {% if res == db_id %} current {% endif %}"  db_id='{{ res }}'>{{ res }}</div>
{% endfor %}
</div>

<div class="colls">Колекции</div>
<div class="collections">
{% for res in coll %}
		<div class="collection"  coll_id='{{ res }}'>{{ res }}</div>
{% endfor %}
</div>


<div class="toolbar"> </div> <!-- collapseble-сворачиваемое-->
<div class="toolbar_b"></div>
<div class="docs" coll_id="" db_id="">
	<div class="t_but">
		<div class="del_db">Удалить базу</div>
		<div class="clean_db">Очистить базу</div>
		<div class="import_db">Импорт базы</div>
		<div class="export_db">Экспорт базы</div>
	</div>
	{% for res in info %}
		<div>
			<div>{{ res }} </div>

			{% if type(info[res]) != str %}
				{% for rs in info[res] %}
					<div style="margin-left:50px; color:green;">{{ rs }}: {{ info[res][rs] }}</div>
				{% endfor %}
			{% else %}
				<div style="margin-left:50px; color:green;">{{ info[res ] }}</div>
			{% endif %}
		</div>
	{% endfor %}
</div>

<style> </style>


<script type="text/javascript">
//3ДА5ГГ49ЕА5Е
$('.t_but').find('> div').button();
//mongo_tree_();
</script>

</body>
</html>