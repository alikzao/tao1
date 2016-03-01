
<div class="template">
    <div class="">Templates</div>
    <div class="install_tpl">Install</div>
    {% for res in list_templ %}
        <input class="switch" type="radio" name="{{ res.id }}" value="{{ res.name }}"/>
    {% endfor %}
</div>

<div class="module">
    <div class="">Modules</div>
	<div class="install_mod">Install</div>
</div>


<style type="text/css">
	.template{
		position:absolute; top:0; left:10px; bottom:0; width: 50%;
	}
	.module{
		position:absolute; top:0; right:0px; bottom:0; left:50%;
	}
</style>

<script type="text/javascript">

$(function(){
    $('.install_tpl, .install_mod').button();


	$('.switch').change(function(){
	    var current_tpl = $(this).attr('name');
		$.ajax({
			type:"POST", dataType:"json", url:'/save_curr_tpl',
			data:{ current_tpl:current_tpl },
			success:function (data) {
				if (data.result == 'ok') {
					alert('saved');
				}
			}
		});
	});

	var textarea = $('t_area');
	var myCodeMirror = CodeMirror.fromTextArea(textarea.get(0), {
		lineNumbers: true,
		matchBrackets: true,
		mode:  "htmlmixed",
		theme: "rubyblue",
		//mode: 'application/x-httpd-php',
		indentUnit: 4,
		tabSize: 4,
		indentWithTabs: true,
		lineWrapping: true,
		gutter: true,
		fixedGutter: true,
		onChange: function(){
			textarea.val(myCodeMirror.getValue());
		}
	});


	$('.save_templ').button();

	var t = "<div>" +
			"<div>Limit:</div>" +
			"</div>" +
			"<style> .sett input, .sett select{margin-bottom:5px;}</style>";

	$('.templ').click(function(){
	    var path = $(this).attr('path');
		$.ajax({
			type:"POST", dataType:"json", url:'/get_templ',
			data:{ path:path},
			success:function (data) {
				if (data.result == 'ok') {
					textarea.val(data.templ);
				}
			}
		});
	});

	$('.save_templ').click(function(){
	    var path = $(this).attr('path');
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







