

<div class="processor_id" proc_id="{{proc_id}}"> </div>

<script type="text/javascript">
    $(function() {
		var t = $('[proc_id="{{proc_id}}"]');
		var tree = dao.tree_processor(t, null, {
			url: '{{url}}',
			id: '{{options_id}}',
			check_tree: true,
			is_add_link: true,
			id_tree: null
		});
		tree.update({   });
	});
</script>
	














