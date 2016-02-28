<!DOCTYPE html>
{#<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">#}
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="icon" href="/static/static/img/favicon.ico" type="image/x-icon">
	<link rel="shortcut icon" href="/static/static/img/favicon.ico" type="image/x-icon">

	{% if doc.proc_id == 'des:comments'%}
	    <title> {{ env.ct(doc.doc.body)[:40]}} (Версия для печати)</title>
	{% else %}
	    <title> {{ env.ct(doc.doc.title)}} (Версия для печати)</title>
	{% endif %}

</head>

<body style="">


<div style="border-bottom:1px solid grey; text-align: center;">{{ env.domain }}&nbsp;&nbsp;&nbsp;Новости. События. Комментарии.</div>

<div>
	{% if doc.proc_id == 'des:comments'%}
        <h1 style="margin:1mm; font-size: 6mm; text-align: center;">
	        <a style="text-decoration: none; " href="#">{{env.ct(doc.doc.body)[:40]}}</a></h1>
	{% else %}
        <h1 style="margin:1mm; font-size: 6mm; text-align: center;"><a style="text-decoration: none; " href="http://{{ env.domain }}/news/{{doc.id}}">{{env.ct(doc.doc.title)}}</a></h1>
	{% endif %}
    <div style="margin-bottom: 10mm;">{{doc.doc.date[:10]}}</div>

    <div>{{env.ct(doc.doc.body)}} </div>
</div>

<div style="border-top:1px solid grey; text-align: center;" >При полном или частичном использовании материалов ссылка (для интернет-изданий - гиперссылка) на <a href="{{ env.domain }}">{{env.domain}}</a> обязательна.</div>


</body>
</html>

<script type="text/javascript">print();</script>
