<div class = "voting" >

{#	{%  if perm.user_voted() %}#}
	{% set color = 'green' if doc.vote.score >= 0 else 'red' %}
{#	{% if user.full_id in doc.vote.voted and not user.is_admin %}#}
{#		{%  if perm.user_voted() == 'up' %}#}
{#		если уже проголосовано#}
{#		{%  if doc.vote.voted[user.full_id] == 'up' %}#}
{#			<div class="ui-icon-vote ui-icon-vote-up "></div>#}
{#			<div class='{{color}} vote'>{{ doc.vote.score }}</div>#}
{#			<div class="ui-icon-vote ui-icon-off-vote-down"></div>#}
{#		{% elif doc.vote.voted[user.full_id] == 'down' %}#}
{#			<div class="ui-icon-vote ui-icon-off-vote-up"></div>#}
{#			<div class='{{color}} vote'>{{ doc.vote.score }}</div>#}
{#			<div class="ui-icon-vote ui-icon-vote-down"></div>#}
{#		{% endif %}#}
{#	{% elif not user.is_admin and (user.full_id == doc['doc']['user'] or not user.has_perm('des:obj', 'vote') ) %}#}
{#		вообще нельзя голосовать#}
{#		<div class="ui-icon-vote ui-icon-off-vote-up"></div>#}
{#		<div class='{{color}} vote'>{{ doc.vote.score }}</div>#}
{#		<div class="ui-icon-vote ui-icon-off-vote-down"></div>#}
{#	{% else %}#}
{#		можно голосовать#}
		<div class="ui-icon-vote ui-icon-on-vote-up"></div>
		<div class='{{color}} vote'>{{ doc.vote.score }}</div>
		<div class="ui-icon-vote ui-icon-on-vote-down"></div>
{#	{%  endif %}#}

{#	{{ doc['doc']['user']}} {{ user.full_id  }}#}
{#	<div style=""class="ui-icon-vote ui-icon-vote-up "></div>#}
{#	<div style=""class="ui-icon-vote ui-icon-vote-down"></div>#}
{#	<div class="ui-icon-vote ui-icon-on-vote-up"></div>#}
{#	<div class="ui-icon-vote ui-icon-on-vote-down"></div>#}
{#	<div class="ui-icon-vote ui-icon-off-vote-up"></div>#}
{#	<div class="ui-icon-vote ui-icon-off-vote-down"></div>#}
</div>

{#	{%  if proc_id != 'des:PM' %} {%  endif %}#}

{#{% if user.is_admin or (user.full_id != doc['doc']['user'] and user.has_perm('des:obj', 'vote')) or (user.full_id != doc['doc']['user'] and user.has_perm('des:obj', 'vote_comm'))%}#}
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