<div class="navbar navbar-fixed-top navbar-inverse" >
    <div class="navbar-inner" >
        <div class="container" style="">
            <ul class="nav navbar-nav pull-right">
	            <li><a class="pull-left brand" target="_blank" href="/" title=""><h1 id="" style="font-size: 20px">{{site_name}}</h1></a></li>

                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">{{ lang }} <b class="caret"></b>{{lang }}</a>
                    <ul class="dropdown-menu">
                        <li lang_id="ru"><a href="#">рус</a></li>
        			    <li lang_id="en"><a href="#">en</a></li>
                   </ul>
               </li>
                <li><a href="/news/" ><i class="fa fa-question-sign"></i></a></li>
                <li><a href="/mongodb" target=_blank>{{ ct( 'Base') }}</a></li>
                <li><a class="close_all_tabs" title="Очистить все закладки" onclick="page_view.close_all_tabs();return false;"href="#">{{ ct( 'Clean') }}</a></li>
                <li><a href="/logout">{{ ct( 'logaut') }}</a></li>
                {% if is_logged   %}
                <li class="profile menu" >
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown"> <i class="fa fa-user"></i> <b class="caret"></b></a>
                        <ul class="dropdown-menu">
                        {% if is_logged and is_admin%}
                        {% endif  %}
                        <li><a  href="/logout">{{ ct('logaut') }}</a></li>
                       </ul>
                   </li>
                </li>
                {% else %}
                <li><div class="title">Enter</div>
                    <ul> <li><a href="/account/signup">Registration</a></li> </ul>
                </li>
                {% endif %}
            </ul>
            <ul  class="nav navbar-nav pull-right">
	            <li class="divider-vertical"></li>
                <li class="placeholder"></li>
            </ul>
        </div>
    </div>
</div>

