
<div class="inner" proc_id="{{proc_id}}"></div>

<script type="text/javascript">
$(function() {
    var act = [];

    var aaa =
    {
	    "title": '',
	    "hint": 'Обновить',
	    "id": "refresh",
	    "visible": true,
	    "action": "this.updatelist",
	    "type": "button",
	    "class": { "inrow": false, "toolbar": true, "context": true },
	    "icon": "icon-refresh"
    };
    act.push(aaa);


  var t = $('[proc_id="{{proc_id}}"]');
    dao.tableprocessor(t, {
      url:'{{url}}',
      id: '{{ proc_id }}',
      columns:{{map_}},
	  ajax_url: '/settings/',
      actions:act,
      parts:{},
      has_tree: false,
	  hidden_id: true,

	  pre_sub:false,
	  expanded: false,

	  check_tree: false,
      view_mode: 'table',
      is_editable: true,
      id_tree: null,
      file_manager: { img:true, other:false },
	  dumb:''
    });
});
</script>
















