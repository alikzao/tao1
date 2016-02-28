

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

{#<script type="text/javascript">#}
{#	var t = $('[proc_id="{{proc_id}}"]');#}
{#	if('{{proc_id}}' == 'change_pass_admin') change_pass_(t);#}
{#	if('{{proc_id}}' == 'sandbox') sandbox(t);#}
{#	if('{{proc_id}}' == 'add_func') add_func(t);#}
{#	if('{{proc_id}}' == 'add_rb') {#}
{#//		alert('aaaaa');#}
{#		add_rb(false, true, t);#}
{#	}#}
{#	if('{{proc_id}}' == 'del_rb') del_rb(t);#}
{#	if('{{proc_id}}' == 'conf_rb_doc') edit_conf(t);#}
{#</script>#}
	












