
<div class="save_templ">Save</div>

<div class="list_templ ui-corner-all" style="background-color: #333333;  line-height:110%; color:white; overflow:auto; position: absolute; top: 50px; left: 20px; bottom: 0; width: 200px;">
{% for res in list_templ %}
	<div c_type="{{res[2]}}"class="templ" path="{{ res[1] }}" style="margin:5px; cursor: pointer; color:{{'white' if res[2] == 'html' else 'yellow'}}">{{ res[0] }}</div>
{% endfor %}
</div>

<div class="" style="position: absolute; top: 50px; left: 220px; right: 0px; bottom: 0; ">
	<textarea name="" id="" class="t_area" cols="30" rows="10"></textarea>
</div>

<script type="text/javascript">

$(function(){

	var textarea1 = $('.t_area');
	var myCodeMirror = CodeMirror.fromTextArea(textarea1.get(0), {
		lineNumbers: true,
		matchBrackets: true,
		mode:  "htmlmixed",
		theme: "rubyblue",
		indentUnit: 4,
		tabSize: 4,
		indentWithTabs: true,
		lineWrapping: true,
		gutter: true,
		fixedGutter: true,
		onChange: function(){
			textarea1.val(myCodeMirror.getValue());
		}
	});

	$('.save_templ').button();
	var path = '';
	$('.templ').click(function(){
	    path = $(this).attr('path');
		$.ajax({
			type:"POST", dataType:"json", url:'/get_templ',
			data:{ path:path},
			success:function (data) {
				if (data.result == 'ok') {
					myCodeMirror.setValue(data.tpl);
				}
			}
		});
	});

	$('.save_templ').click(function(){
		var templ = myCodeMirror.getValue();
		$.ajax({
			type:"POST", dataType:"json", url:'/save_templ',
			data:{ path:path, templ:templ},
			success:function (data) {
				if (data.result == 'ok') {
					alert('Saved');
				}
			}
		});
	});

});

</script>







