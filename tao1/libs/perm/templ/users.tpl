<div class = "users" >
		<div id="all_view"> 
		
		{%  for i in all_view %}
			<h1><a href = "">{{i.value}}</a></h1>
		{% endfor %} 
		
		</div>
		
<script type="text/javascript">
$(function() {
  var t = $('.users:last');
    dao.tableprocessor(t, {
      url:'{{url}}',   //орппопопо
      id: 'users_group',
      columns:{{map_}},  //сюда можно навесить кучу всего разного
	  ajax_url: '/settings/',
      actions:{},
      parts:{},
	  check_tree: false,
      has_tree: false,
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














