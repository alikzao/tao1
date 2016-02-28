{% extends "base.tpl" %}
{% block content %}
	<div id="login" width=100% align=center >
	<div style="padding-bottom: 10px;">
		<a href="/signup" style="padding-bottom: 10px;" target="">Регистрация</a>
		<a href="/login" style="padding-bottom: 10px;" target="">Войти</a>
	</div>
		<form action="/recover" method="POST" id="ddd">
			<table border=0>
				{% if mess %}
					<tr><td colspan=2 align="center"><font color=red>{{mess}}</font></td></tr>
				{% endif %}
				<tr><td style="color:black; height: 30px; ">{{ ct( 'email') }}<span class="star_s">*</span></td><td> <input style="box-shadow: 2px 2px #ccc;" type="text" name="email" /> </td></tr>
				<tr><td style="color:black; height: 30px;">{{ ct( 'name') }}<span class="star_s">*</span></td><td> <input style="box-shadow: 2px 2px #ccc;" type="text" name="name" /> </td></tr>
				<tr><td colspan="2" align="center"> <input type="submit" value="Востановить" /> </td></tr>
			</table> 
		</form>
	</div>
	<style type="text/css">.star_s{color:red;}</style>
{% endblock %}
