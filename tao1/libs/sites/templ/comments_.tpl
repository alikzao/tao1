

{%  if is_comments==True %}
    <style type="text/css">
    ._comm_ li { list-style-type: none; }
    </style>
	<div class="comment_button"></div>
	<div comm_cont="_"></div>

	<ul class="_comm_"><a name="comments"></a>
		<li id="comments" id_comm="_" class="ui-corner-all " style="border: 1px solid #eee;">
{#			<!-- вначале выбираем корневой элемент а потом лупом указываем другой корневой элемент-->#}
{#	                                doc.title -  id пользователя     #}
{#				{%- for doc in tree.children recursive %}#}
			<ul class="ul_comments" >
                {% set ctr = doc.count_branch %}
				{%- for comm in tree.child recursive %}
                    {% set user=get_full_user( ct( comm.doc.user ), True) %}
					<li user_id="{{ user.id }}" {%   if not comm.doc.is_del %}id_comm="{{comm.id}}"{% endif %} class="one_comm">
                        <a name="comm_{{comm.id}}"></a>
                        <div class="body_comment ui-corner-all">
						    {%   if not comm.doc.is_del %}
                                <div class="comm_title" >
{#                                    <b>ctr={{ ctr }}</b>#}
                                    <b><a class="" id_comm="{{comm.id}}" > {{ ct(comm.doc.name) }} </a></b>
                                    {% include 'libs.sites:vote_comm.tpl' %}
{#                                    {% if ctr <= 25 %}#}
                                        <div style="float: left;  ">
{#                                            {% if not len(user.att)  or not user.att[0]%}#}
{#                                                <img src="/static/core/img/anonim.jpg" style="width: 24px; height: 24px; padding: 1px;"/>#}
{#                                            {% else %}#}
{#                                                <img src="/img/des:users/{{ user.id }}/{{user.att[0]}}/img" style="width: 24px; height: 24px; padding: 1px;"/>#}
{#                                            {% endif %}#}
                                        </div>
{#                                    {% endif %}#}
{#                                    <span style="margin-right:15px;">... {% if user.id == "user:pauluskp" %} 11.11 {% elif comm.doc.ip %} {{ comm.doc.ip[-6:] }} {% endif %}</span>#}
{##}
                                    <div class="in-toolbar"></div>
{#                                    {% set soc_name = ct( comm.doc.title) %}#}
{#                                    <div class="comm_name">#}
{##}
{#                                            {% if  soc_name.startswith('fb:')  %}#}
{#                                                <i class="icon-facebook-sign" style="font-size:18px;"></i>#}
{#                                                <b><a class="un" id_comm="{{comm.id}}" target="_blank" href="http://facebook.com/{{ ct( comm.doc.user)[3:] }}"> {{ ct(comm.doc.name) }} </a></b>#}
{#                                            {% elif  soc_name.startswith('vk:')  %}#}
{#                                                <i class="icon-vk" style="font-size:18px;"></i>#}
{#                                                <b><a class="un" id_comm="{{comm.id}}" target="_blank" href="http://vk.com/id{{ ct( comm.doc.user)[3:] }}"> {{ ct(comm.doc.name) }} </a></b>#}
{#                                            {% elif  soc_name.startswith('tw:')  %}#}
{#                                                <i class="icon-twitter-sign" style="font-size:18px;"></i>#}
{#                                                <b><a class="un" id_comm="{{comm.id}}" target="_blank" href="http://twitter.com/account/redirect_by_id?id={{ ct( comm.doc.user)[3:] }}"> {{ ct(comm.doc.name) }} </a></b>#}
{#                                            {% elif  soc_name.startswith('gl:')  %}#}
{#                                                <i class="icon-google-plus-sign" style="font-size:18px;"></i>#}
{#                                                <b><a class="un" id_comm="{{comm.id}}" target="_blank" href="http://plus.google.com/{{ ct( comm.doc.user)[3:] }}"> {{ ct(comm.doc.name) }} </a></b>#}
{#                                            {% else  %}#}
{#                                                {{ ct( doc.title) }}#}
{#                                            {% endif  %}#}
{#                                            {% if user.id != 'user:' %}#}
{#                                                {% set user_rate = (0 if not user.doc.rate else float(user.doc.rate)) %}#}
{#                                                <span class="{{'green' if user_rate >= 0 else 'red'}}" style="font-weight: bold; font-family: ubuntu; font-size: 10px;">#}
{#                                                    {{'+' if user_rate > 0 else ('-' if user_rate < 0 else '')}}{{user.doc.rate}}#}
{#                                                </span>#}
{#                                            {% endif %}#}
{#                                    </div>#}
{#                                    <div class="comm_date" >{{ comm.doc.date }}</div>#}
                                </div>
                                <div id_comm="{{comm.id}}" class="comm_comment ">{{ ct( comm.doc.body )}}</div>
                                <div  class="comm_answer ui-corner-all " style="cursor: pointer; padding-bottom:10px;"> <a href='#'>{{ ct('reply') }}</a></div>
                                <div comm_cont="{{comm.id}}">   </div>
                            {%  else %}
                                <div id_comm="{{comm.id}}" class="comm_comment ">Коментарий удален.</div>
                            {%  endif %}
                        </div>
                        <ul class="sub_comments ui-corner-all">{{ loop(comm.child) }}</ul>
					</li>
				{%- endfor %}
			</ul>

			<div comm_cont="__" style="visibility:hidden; height:0;">
                <div class="comm_editor" style="margin: 20px 10px; border: 1px solid #ddd; background: rgba(255,255,255,.4);">
                    <input class="hide_inp"/>
{#                    <div style="margin: 10px 0 0 10px;"> Комментировать через: {% include 'soc_icons.tpl' %} </div>#}
                    <div style="clear:both; float: left; padding: 20px 0 0 10px; font-weight: bold;">{{ ct( 'name')}}:</div>
                    <div class="comm_title" style="margin: 0; padding-left: 5px;">{# сюда добавляем через ява скрипт #}</div>
                    <div class="easewig" ></div>
                    <div class=""style="text-align: right; padding: 5px 50px;"><div class="comm_create btn btn-default" style="cursor: pointer; width:120px; font-size:14px; "> {{ ct( 'send') }}</div></div>
                    <input class="hide_inp"/>
                </div>
			</div>

		</li>
	</ul>
	{% if len(tree.child ) > 2 %} <div class="comment_button"></div> {% endif %}
{% endif %}
















