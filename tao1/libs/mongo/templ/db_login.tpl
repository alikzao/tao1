
	<div id="login" width=100% align=center >
		<form action="/mongodb/login" method="POST" id="ddd">
		<input type="hidden" name="db_id" value="{{ db_id }}"/>
			<table border=0>
				{% if mess %}
					<tr><td colspan=2 align="center"><font color=red>{{mess}}</font></td></tr>
				{% endif %}
				<tr><td>{{ ct( 'name') }}</td><td> <input type="text" name="name" /> </td></tr>
				<tr><td>{{ ct( 'password') }}</td><td> <input type="password" name="passw" /> </td></tr>
				<tr><td colspan="2" align="center"> <input type="submit" value="OK" /> </td></tr>
			</table> 
		</form>
	</div>




