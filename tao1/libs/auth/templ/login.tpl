{% extends "base.tpl" %}
{% block content %}
<div id="login" width=100% align=center >
    <form class="form-group" action="/login" method="POST" id="ddd" style="width: 300px;">
        {% if mess %}
            <div align="center" style="color:red;">{{mess}}</div>
        {% endif %}
       <label style="vertical-align:middle; margin-top: 10px;">
           <div style="display: inline-block; width: 80px;" >{{ ct( 'name') }}</div>
           <input class="form-control input-sm" type="text" name="name"  style="display: inline-block; width: 200px;" /></label>

       <label style="vertical-align:middle; margin-top: 10px; ">
           <div style="display: inline-block; width: 80px;" >{{ ct( 'password') }}</div>
           <input class="form-control input-sm" type="password" name="pasw" style="display: inline-block; width: 200px;" /></label>

        <div style="display: inline-block; width: 60px;" ></div>
       <input class="btn btn-default" type="submit" value="Войти" style="margin-top: 10px; " />
    </form>
</div>


{% endblock %}
