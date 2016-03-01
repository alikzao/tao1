

<li id_comm="_" class="ui-corner-all " style="border: 1px solid #eee;">

    {%- for comm in tree.child recursive %}

        <li user_id="{{ comm._id }}" id_comm="{{comm.id}}" class="item item_open">
            <a style="vertical-align:bottom; cursor: pointer;" id_comm="{{comm.id}}" target="_blank" {% if comm.doc.link != '-'  %} class="cm-menu-item" d_id="{{ comm.doc.d_id }}" ng-href="/{{ comm.doc.link }}" {% endif %}>
                <i class="fa {{ comm.doc.icon }}"></i> &nbsp;
                {{ ct(comm.doc.title) }}
                <span style="position:absolute; right:20px; width:100%; text-align:right; vertical-align:top;">
                    <i class="fa fa-angle-right" style="vertical-align:top;"></i> &nbsp;
                </span>
            </a>
            <ul class="sub_comments item_close" att="111" style="display:none; background-color: #1c2128;">{{ loop(comm.child) }}</ul>
        </li>
    {%- endfor %}
</li>
<script type="text/javascript">
$(function(){
    $('.cm-menu-item').each(function(){
        var href = $(this).attr('ng-href');
        var loc = window.location;
        href = loc.protocol +'//'+ loc.host + href.substring(1);
        $(this).attr('ng-href', href);
    });
    $('.sidebar').on('click', '.item a', function() {
        $(this).closest('li').find('.sub_comments').toggle();
    });

});
</script>

<style type="text/css">

.sub_comments, .sub_comments li, .sub_comments li > a{
    background-color: #1c2128;
 }

.left_menu li > a:hover {
    background-color: #1c2128;
    color:white;
}
.left_menu li.active > a {
    background-color: #455264;
}
.left_menu li > a, .sidebar li  i {
    -webkit-font-smoothing: antialiased;
    line-height: 20px;
    color: rgb(139, 146, 154);
    cursor: auto;
{#    font-family: 'Quattrocento Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif;#}
    font-size: 14px;
    font-weight: 300;
}
.left_menu{
    background-color: #303946 !important;
}
.left_menu ul{
    background-color: #303946;
}
</style>




