<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="icon" href="/static/img/favicon.ico" type="image/x-icon">
	<link rel="shortcut icon" href="/static/img/favicon.ico" type="image/x-icon">

	{% if doc.proc_id == 'des:comments'%}
	    <title> {{ ct(doc.doc.body)[:40]}} (Print version)</title>
	{% else %}
	    <title> {{ ct(doc.doc.title)}} (Print version)</title>
	{% endif %}

</head>

<body style="">


<div style="border-bottom:1px solid grey; text-align: center;">{{ domain }}&nbsp;&nbsp;&nbsp;News. </div>

<div>
	{% if doc.proc_id == 'des:comments'%}
        <h1 style="margin:1mm; font-size: 6mm; text-align: center;">
	        <a style="text-decoration: none; " href="#">{{ct(doc.doc.body)[:40]}}</a></h1>
	{% else %}
        <h1 style="margin:1mm; font-size: 6mm; text-align: center;"><a style="text-decoration: none; " href="http://{{ domain }}/news/{{doc.id}}">{{ct(doc.doc.title)}}</a></h1>
	{% endif %}
    <div style="margin-bottom: 10mm;">{{doc.doc.date[:10]}}</div>

    <div>{{ct(doc.doc.body)}} </div>
</div>

<div style="border-top:1px solid grey; text-align: center;" >When using materials in full or in part, a link (for online media: a hyperlink) to
    <a href="{{ domain }}">{{domain}}</a> is required.</div>


</body>
</html>

<script type="text/javascript">print();</script>
