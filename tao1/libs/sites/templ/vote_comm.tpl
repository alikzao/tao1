<div class = "voting_comm" style="">

{#	{%  if perm.user_voted() %}#}
	{% set color = 'green' if comm.vote.score >= 0 else 'red' %}
{#	{% if user.full_id in item.vote.voted and not user.is_admin %}#}
{#		{%  if perm.user_voted() == 'up' %}#}
{#		если уже проголосовано#}
{#		{%  if item.vote.voted[user.full_id] == 'up' %}#}
{#			<div class="ui-icon-vote ui-icon-vote-up  "></div>#}
{#			<div class='{{color}} vote'>{{ item.vote.score }}</div>#}
{#			<div class="ui-icon-vote ui-icon-off-vote-down"></div>#}
{#		{% elif item.vote.voted[user.full_id] == 'down' %}#}
{#			<div class="ui-icon-vote ui-icon-off-vote-up"></div>#}
{#			<div class='{{color}} vote'>{{ item.vote.score }}</div>#}
{#			<div class="ui-icon-vote ui-icon-vote-down"></div>#}
{#		{% endif %}#}
{#	{% elif not user.is_admin and (user.full_id == doc.doc.user or not user.has_perm('des:obj', 'vote_com') ) %}#}
{#		вообще нельзя голосовать#}
{#		<div class="ui-icon-vote ui-icon-off-vote-up"></div>#}
{#		<div class='{{color}} vote'>{{ item.vote.score }}</div>#}
{#		<div class="ui-icon-vote ui-icon-off-vote-down"></div>#}
{#	{% else %}#}
{#		можно голосовать#}
		<div class="ui-icon-vote ui-icon-on-vote-up"></div>
		<div class='{{color}} vote'>{{ comm.vote.score }}</div>
		<div class="ui-icon-vote ui-icon-on-vote-down"></div>
{#	{%  endif %}#}

{#	{{  not user.is_admin and (user.full_id == doc.doc.user or not user.has_perm('des:obj', 'vote_com') ) }}#}
{#	 {{ user.is_admin}} {{user.full_id == doc.doc.user}} {{ not user.has_perm('des:obj', 'vote_com') }}#}

{#	{{ doc['doc']['user']}} {{ user.full_id  }}#}
{#	<div style=""class="ui-icon-vote ui-icon-vote-up "></div>#}
{#	<div style=""class="ui-icon-vote ui-icon-vote-down"></div>#}
{#	<div class="ui-icon-vote ui-icon-on-vote-up"></div>#}
{#	<div class="ui-icon-vote ui-icon-on-vote-down"></div>#}
{#	<div class="ui-icon-vote ui-icon-off-vote-up"></div>#}
{#	<div class="ui-icon-vote ui-icon-off-vote-down"></div>#}
</div>

{#	{%  if proc_id != 'des:PM' %} {%  endif %}#}

{#{% if user.is_admin or user.full_id != doc['doc']['user'] and user.has_perm('des:obj', 'vote_com')%}#}
<script type="text/javascript">

$(function() {
	$('[id_comm="{{comm.id}}"] .voting_comm:first').on('click', function(e){
		var target = $(e.target);
		if( target.is('.ui-icon-vote')){
			var comm = target.closest('[id_comm]');
			var user_id = comm.attr('user_id');
			var comm_id = comm.attr('id_comm');
			var vote = target.is('.ui-icon-on-vote-up,.ui-icon-vote-up, .ui-icon-off-vote-up') ? 'up':'down';
			$.ajax({
				url: '/tree/add_vote', type: 'POST', dataType: 'json',
				data: {
					doc_id: '{{doc_id}}',
					vote: vote, comm_id:comm_id
				},
				beforeSend: function(){ },
				success: function(data){
					if(data.result == 'ok'){
					    var color = data.score >= 0 ? 'green' : 'red';
						$('[id_comm="'+comm_id+'"] .vote:first').removeClass('red green').addClass(color).html(data.score);
						if (vote == 'up') {
							$('[id_comm="'+comm_id+'"]').find('.ui-icon-off-vote-up,.ui-icon-vote-up,.ui-icon-on-vote-up:first').removeClass('ui-icon-on-vote-up').addClass('ui-icon-vote-up');
							$('[id_comm="'+comm_id+'"]').find('.ui-icon-off-vote-down,.ui-icon-vote-down,.ui-icon-on-vote-down:first').removeClass('ui-icon-on-vote-down').addClass('ui-icon-off-vote-down');
						}
						if (vote == 'down') {
							$('[id_comm="'+comm_id+'"]').find('.ui-icon-off-vote-up,.ui-icon-vote-up,.ui-icon-on-vote-up:first').removeClass('ui-icon-on-vote-up').addClass('ui-icon-off-vote-up');
							$('[id_comm="'+comm_id+'"]').find('.ui-icon-off-vote-down,.ui-icon-vote-down,.ui-icon-on-vote-down:first').removeClass('ui-icon-on-vote-down').addClass('ui-icon-vote-down');
						}
					}else if(data.result == 'fail')  dao.user_mess( data.error, 'error' );
                    else                             dao.user_mess( data.error, 'error' );
                }
			});
			return false;
		}
	});
});
</script>
{#{% endif %}#}