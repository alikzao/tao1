{%  if is_comments==True %}
    
    <style type="text/css">
    .comm_comment img{
        max-width:100% !important;
    }
    </style>
    
	<div class="comment_button"></div>

	<div comm_cont="_"></div>

	<ul itemprop="comment" itemscope itemtype="http://schema.org/UserComments">
        <a name="comments"></a>
		<li id="comments" id_comm="_" class="ui-corner-all " style="border: 1px solid #eee;">
{#			<!-- вначале выбираем корневой элемент а потом лупом указываем другой корневой элемент-->#}
			<ul class="ul_comments" >
				{%- for item in tree.children recursive %}
{#					<!--<li><a href="{_{ item.link|e }_}">{_{ item.name }_}</a>-->#}
                    {% if item.pre == 'true' %}
{#                        <span>На модерации</span>#}
                    {% else %}

                    {% set user=get_full_user(ct(item.title), True) %}
					<li user_id="{{ user.id }}" {%   if not item.is_del %}id_comm="{{item.id}}"{% endif %} class="one_comm" >
                        <a name="comm_{{item.id}}"></a>
                        <div class="body_comment ui-corner-all" style="{{ 'background-color:#ff8;' if user.id == 'user:' else ''  }}">
						    {%   if not item.is_del %}
                                <div class="comm_title" >
                                    {% include 'libs.sites:vote_comm.tpl' %}
                                    <div style="float: left;  ">
                                        {% if not len(user.att)  or not user.att[0]%}
                                            <i class="icon-user icon-large"></i>
                                        {% else %}
                                            <img src="/img/des:users/user:{{ item.title}}/{{user.att[0]}}/img" style="width: 24px; height: 24px; padding: 1px;"/>
                                        {% endif %}
                                    </div>
{#	                                item.title -  id пользователя     #}
                                    <div class="in-toolbar"></div>
                                    {% set soc_name = ct( item.title) %}
                                    <div class="comm_name">
                                        {% if  soc_name.startswith('fb:')  %}
                                            <i class="icon-facebook-sign" style="font-size:18px;"></i>
                                            <b><a class="un" id_comm="{{item.id}}" target="_blank" href="http://facebook.com/{{ ct( item.title)[3:] }}" rel="nofollow"> {{ ct(item.name) }} </a></b>
                                        {% elif  soc_name.startswith('vk:')  %}
                                            <i class="icon-vk" style="font-size:18px;"></i>
                                            <b><a class="un" id_comm="{{item.id}}" target="_blank" href="http://vk.com/id{{ ct( item.title)[3:] }}" rel="nofollow"> {{ ct(item.name) }} </a></b>
                                        {% elif  soc_name.startswith('tw:')  %}
                                            <i class="icon-twitter-sign" style="font-size:18px;"></i>
                                            <b><a class="un" id_comm="{{item.id}}" target="_blank" href="http://twitter.com/account/redirect_by_id?id={{ ct( item.title)[3:] }}" rel="nofollow"> {{ ct(item.name) }} </a></b>
                                        {% elif  soc_name.startswith('gl:')  %}
                                            <i class="icon-google-plus-sign" style="font-size:18px;"></i>
                                            <b><a class="un" id_comm="{{item.id}}" target="_blank" href="http://plus.google.com/{{ ct( item.title)[3:] }}" rel="nofollow"> {{ ct(item.name) }} </a></b>
                                        {% elif  soc_name.startswith('ya:')  %}
                                            <i class="icon-sign-blank" style="font-size:18px;"><i>Y</i></i>
                                            <b><a class="un" id_comm="{{item.id}}" target="_blank" href="http://{{ ct( item.title)[3:] }}.ya.ru/" rel="nofollow"> {{ ct(item.name) }} </a></b>
                                        {% else  %}
                                            {{ct( item.title) }}
                                        {% endif  %}
                                        {% if user.id != 'user:' %}
                                            {% set user_rate = (0 if not user.doc.rate else float(user.doc.rate)) %}
                                            <span class="{{'green' if user_rate >= 0 else 'red'}}" style="font-weight: bold; font-family: ubuntu; font-size: 10px;">{{'+' if user_rate >= 0 else '-'}}{{user.doc.rate}}</span>
	                                    {% endif %}
                                    </div>
{#                                    <div class="comm_date" itemprop="datePublished" datetime="{{ item.date }}">#}
                                    <time class="comm_date" itemprop="commentTime" datetime="{{  format_date(item.date, '%Y-%m-%dT%H:%M:%S')}}">
                                        {{ item.date }}
                                    </time>
                                </div>
                                <div id_comm="{{item.id}}" itemprop="commentText" class="comm_comment ">{{ ct( item.descr )}}</div>
                                <div  class="comm_answer ui-corner-all " style="cursor: pointer; padding-bottom:10px;"> <a href='#'>{{ ct('reply') }}</a></div>
                                <div comm_cont="{{item.id}}">   </div>
                            {%  else %}
                                <div id_comm="{{item.id}}" class="comm_comment ">Коментарий удален.</div>
                            {%  endif %}
                        </div>
                        <ul class="sub_comments ui-corner-all">{{ loop(item.children) }}</ul>
					</li>
                    {% endif %}
				{%- endfor %}
			</ul>

			<div comm_cont="__" style="visibility: hidden; height:0px;">
                <div class="comm_editor" style="margin: 20px 10px; border: 1px solid #ddd; background: rgba(255,255,255,.4);">
                    <input class="hide_inp"/>
                    <div class="comm_title">{{ ct( 'name') }}: <b data='name'></b> </div>
                    <div class="easewig" ></div>
                    <div class=""style="text-align: right; padding: 5px 50px;"><div class="comm_create btn btn-primary" style="cursor: pointer; width:120px; font-size:14px; "> {{ ct( 'send') }}</div></div>
                    <input class="hide_inp"/>
                </div>
			</div>

		</li>
	</ul>
	{% if len(tree.children ) > 2 %} <div class="comment_button"></div> {% endif %}
{% endif %}
















