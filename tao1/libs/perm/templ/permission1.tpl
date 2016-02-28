<div id = "permission" >
		<div id="all_view"> 
		
		{%  for i in all_view %}
			<h1><a href = "">{{i.value}}</a></h1>
		{% endfor %} 
		
		</div>
		
<script type="text/javascript">
$(function() {
  var t = $('#permission');
    dao.tableprocessor(t, {
      url:'{{url}}',   //орппопопо
      id: 'permission',
//	  id: '{{processor_id}}',
      columns:{{map_}},  //сюда можно навесить кучу всего разного
      actions:{},
      parts:{},
      has_tree: true,
	  check_tree: false,
      view_mode: 'table',
      is_editable: true,
      id_tree: null,
      file_manager: {
          img:true,
          other:false
      },
        dumb:''
    });
});
</script>

</div>














