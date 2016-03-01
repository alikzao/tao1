<div class = "voting_comm" style="">

	{% set color = 'green' if item.vote.score >= 0 else 'red' %}
		<div class="ui-icon-vote ui-icon-on-vote-up"></div>
		<div class='{{color}} vote'>{{ item.vote.score }}</div>
		<div class="ui-icon-vote ui-icon-on-vote-down"></div>
</div>

<script type="text/javascript">
$(function() {
	$('[id_comm="{{item.id}}"] .voting_comm:first').click(function(e){
		var target = $(e.target);
		if( target.is('.ui-icon-vote')){
			var comm = target.closest('[id_comm]');
			var user_id = comm.attr('user_id');
			if(user_id == current_user.id) {
				dao.user_mess(dao.ct('Нельзя голосовать за свои сообщения'), 'error');
			}
			var id_comm = comm.attr('id_comm');
			var vote = target.is('.ui-icon-on-vote-up,.ui-icon-vote-up, .ui-icon-off-vote-up') ? 'up':'down';
			$.ajax({
				url: '/tree/add_vote', type: 'POST', dataType: 'json',
				data: {
					doc_id: '{{doc_id}}',
					vote: vote, id_comm:id_comm
				},
				beforeSend: function(){ },
				success: function(data){
					if(data.result == 'ok'){
					    var color = data.score >= 0 ? 'green' : 'red';
						$('[id_comm="'+id_comm+'"] .vote:first').removeClass('red green').addClass(color).html(data.score);
						if (vote == 'up') {
							$('[id_comm="'+id_comm+'"]').find('.ui-icon-off-vote-up,.ui-icon-vote-up,.ui-icon-on-vote-up:first')
                                    .removeClass('ui-icon-on-vote-up').addClass('ui-icon-vote-up');
							$('[id_comm="'+id_comm+'"]').find('.ui-icon-off-vote-down,.ui-icon-vote-down,.ui-icon-on-vote-down:first')
                                    .removeClass('ui-icon-on-vote-down').addClass('ui-icon-off-vote-down');
						}
						if (vote == 'down') {
							$('[id_comm="'+id_comm+'"]').find('.ui-icon-off-vote-up,.ui-icon-vote-up,.ui-icon-on-vote-up:first')
                                    .removeClass('ui-icon-on-vote-up').addClass('ui-icon-off-vote-up');
							$('[id_comm="'+id_comm+'"]').find('.ui-icon-off-vote-down,.ui-icon-vote-down,.ui-icon-on-vote-down:first')
                                    .removeClass('ui-icon-on-vote-down').addClass('ui-icon-vote-down');
						}
					}else{ dao.user_mess(data.error, 'error'); }
                }
			});
			return false;
		}
	});
});
</script>
