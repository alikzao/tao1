

<div class="conf_conf">
    <form role="form" style="margin-left:15px;">
        <div class="form-group">
            {% for res in data  %}
                <div class="checkbox">
                    <label>
                        <input type="checkbox" {% if res.conf.turn=='true' %}checked='true'{% endif %} name="{{res._id}}"/> {{ res.conf.title.ru }}
                    </label>
                </div>
            {% endfor %}
            <div class="btn btn-default" style="margin-bottom:20px;"><i class="icon-ok"> Сохранить</i></div>
        </div>
    </form>
</div>

<script type="text/javascript">
    $(function(){
        $('.conf_conf').on('click', '.btn', function(){
            console.log('click btn');
            console.log('click btn');
            var inputs = $('.conf_conf').find('input:checkbox');
            var data = {};
            inputs.each(function(i, v){
                data[$(v).attr('name')] = $(v).is(':checked') ? 1 : 0;
            });
            console.log('dataaaa', data);
            $.ajax({
                type: "POST", dataType: "json", url: '/conf_rb_doc',
                data: { data: JSON.stringify(data) },
                success: function(data){
                    if (data.result == 'ok') { alert('Конфигурация сохранена'); }
                }
            });
        });
    });
</script>














