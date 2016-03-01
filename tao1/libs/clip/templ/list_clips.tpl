{% extends "layout.tpl" %}




{% block content %}


<div  style="margin:20px 20px 0 20px;" class="btn btn-success cr_clip"><i class="icon-ok"></i> Create new clip</div>
<div class="colls" >
    <table style="margin:20px; width:95%;" class="table table-hover table-condensed table-bordered">
        <thead>
            <tr> <th>ID</th><th>Title</th> <th>Описание</th> <th>Date</th> <th>Author</th> </tr>
        </thead>
        <tbody>
            {% for res in docs %}
                <tr>
                    <td><a href="/edit/clip/{{ res.id }}">{{ ct(res.doc.rev)}}</a></td>
                    <td><a href="/edit/clip/{{ res.id }}">{{ ct(res.doc.title )}}</a></td>
                    <td><a href="/edit/clip/{{ res.id }}">{{ ct(res.doc.descr)}}</a></td>
                    <td><a href="/edit/clip/{{ res.id }}">{{ res.doc.date }}</a></td>
                    <td></td>
                </tr>
            {% endfor%}
        </tbody>
    </table>
</div>


<script type="text/javascript">

$(function(){
    $('.cr_clip').click(function(){
        $.ajax({
            type: "POST", dataType: "json", url:'/rolik/add', data: { },
            success: function (data) {
                if (data.result == 'ok') {
                    window.location = '/edit/clip/'+data.doc_id
                }
            }
        });
    })
});

</script>



{% endblock %}
