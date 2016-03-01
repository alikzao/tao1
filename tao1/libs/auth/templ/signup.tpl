
{% extends "layout.tpl" %}
{% block content %}	

<style> #signup td {color:#000;} </style>
	<div id="signup" width=100% align=center style="color:black;">
		<form class="form-group" action="/signup" method="POST"  id="ddd" style="width: 380px;">

            {% if mess %}
                <div align="center" style="color:red;">{{mess}}</div>
            {% endif %}
            <label style="vertical-align:middle; margin-top: 10px;">
               <div style="display: inline-block; width: 150px;" >{{ ct( 'name') }}</div>
               <input class="form-control input-sm" type="text" name="name"  value='{{name}}' style="display: inline-block; width: 200px;" /></label>

            <label style="vertical-align:middle; margin-top: 10px; ">
               <div style="display: inline-block; width: 150px;" >{{ ct( 'password') }}</div>
               <input class="form-control input-sm" type="password" name="password" style="display: inline-block; width: 200px;" /></label>

            <label style="vertical-align:middle; margin-top: 10px;">
               <div style="display: inline-block; width: 150px;" >{{ ct( 'mail') }}</div>
               <input class="form-control input-sm" type="text" name="mail"  value='{{mail}}' style="display: inline-block; width: 200px;" /></label>

		    <label style="vertical-align:middle; margin-top: 10px;">
               <div style="display: inline-block; width: 150px;" >{{ ct( 'phone') }}</div>
               <input class="form-control input-sm" type="text" name="phone"  value='{{phone}}' style="display: inline-block; width: 200px;" /></label>

		    <label style="vertical-align:middle; margin-top: 10px;">
               <div style="display: inline-block; width: 150px;" >{{ ct( 'address') }}</div>
               <input class="form-control input-sm" type="text" name="addres"  value='{{address}}' style="display: inline-block; width: 200px;" /></label>

			<label style="vertical-align:middle; margin-top: 10px;">
                <img src="/captcha?hash={{hash}}" alt="aaa"/>
               <input class="form-control input-sm" type="hidden" name="hash"  value='{{hash}}' style="display: inline-block; width: 200px;" /></label>

			<label style="vertical-align:middle; margin-top: 10px;">
               <div style="display: inline-block; width: 150px;" >{{ ct( 'captcha') }}</div>
               <input class="form-control input-sm" type="text" name="captcha" style="display: inline-block; width: 200px;" /></label>

            <div style="display: inline-block; width: 150px;" ></div>
		    <input class="btn btn-default" type="submit" value=" Register" style="margin-top: 10px; " />

		</form>
	</div>

{% endblock %}


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
       <input class="btn btn-default" type="submit" value="Enter" style="margin-top: 10px; " />
    </form>
</div>
