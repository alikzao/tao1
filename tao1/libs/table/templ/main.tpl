
<div class="inner" proc_id="{{proc_id}}"></div>

<script type="text/javascript">



$(function() {

	var is_admin = '{{ is_admin }}';

	var t = $('[proc_id="{{proc_id}}"]');

	dao.tableprocessor(t, {
		url:'{{url}}',
		id: '{{proc_id}}',
		columns:{{map_}},
		parts:{{parts}},
		user_name:'{{user_id}}',
		select_id :'{{select_id}}',
		has_tree: false,
		check_tree: true,
		view_mode: 'table',
		is_editable: true,
		id_tree: null,
		hidden_id: true,
		has_img: true,
		max_width: 300,
		file_manager: { img:true, other:false },
		dumb:''
	});
});
</script>
	













