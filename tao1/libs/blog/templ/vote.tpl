<div class = "voting" >

	{% set color = 'green' if doc.vote.score >= 0 else 'red' %}
		<div class="ui-icon-vote ui-icon-on-vote-up"></div>
		<div class='{{color}} vote'>{{ doc.vote.score }}</div>
		<div class="ui-icon-vote ui-icon-on-vote-down"></div>
</div>

<script type="text/javascript">
$(function() {
	var vv = $('.voting');
	$('.voting').click(function(e){
		var target = $(e.target);
		var comm_type = 'doc';
		if( target.is('.ui-icon-vote')){
			var vote = target.is('.ui-icon-on-vote-up,.ui-icon-vote-up, .ui-icon-off-vote-up') ? 'up':'down';
			$.ajax({
				url: '/vote/add', type: 'POST', dataType: 'json',
				data: {
					doc_id: '{{doc_id}}',
					vote: vote, vote_type:comm_type
				},
				beforeSend: function(){ },
				success: function(data){
					if(data.result == 'ok'){
						var color = data.score >= 0 ? 'green' : 'red'
						vv.find('.vote').removeClass('red green').addClass(color).html(data.score);
						if (vote == 'up') {
							vv.find('.ui-icon-off-vote-up,.ui-icon-vote-up,.ui-icon-on-vote-up').first().removeClass('ui-icon-on-vote-up').addClass('ui-icon-vote-up');
							vv.find('.ui-icon-off-vote-down,.ui-icon-vote-down,.ui-icon-on-vote-down').first().removeClass('ui-icon-on-vote-down').addClass('ui-icon-off-vote-down');
						}
						if (vote == 'down') {
							vv.find('.ui-icon-off-vote-up,.ui-icon-vote-up,.ui-icon-on-vote-up').first().removeClass('ui-icon-on-vote-up').addClass('ui-icon-off-vote-up');
							vv.find('.ui-icon-off-vote-down,.ui-icon-vote-down,.ui-icon-on-vote-down').first().removeClass('ui-icon-on-vote-down').addClass('ui-icon-vote-down');
						}
					}else{ dao.user_mess(data.error, 'error'); }
                }
			});
			return false;
		}
	});
});
</script>
{#{% endif %}#}