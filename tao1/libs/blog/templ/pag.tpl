


<div style="margin-bottom: 20px;">
	<div class="sss pagination" style="display: inline-table;">
		<ul class="pagination">
			{%  if pages['cur_page'] > 1 %}
				<li><a href="?page={{pages['cur_page']-1}}">←</a></li>
			{% endif %}
			{%  if pages['start_page'] > 1 %}
				<li><a href="?page=1">1</a></li>
			{% endif %}
			{%  if pages['start_page'] > 2 %}
				<li><span>...</span></li>
			{% endif %}

			{%  for res in range(pages['start_page'], pages['end_page']) %}
				{%  if res == pages['cur_page'] %}
					<li style="font-weight: bold;"><span>{{res}}</span></li>
				{%  else %}
					<li><a href="?page={{res}}">{{res}}</a></li>
				{% endif %}
			{%  endfor %}

			{%  if pages['end_page'] < pages['count_page'] - 1 %}
				<li><span>...</span></li>
			{% endif %}
			{%  if pages['end_page'] < pages['count_page'] %}
				<li><a href="?page={{pages['count_page']}}">{{pages['count_page']}}</a></li>
			{% endif %}
			{%  if pages['cur_page'] < pages['count_page'] %}
				<li><a href="?page={{pages['cur_page']+1}}">→</a></li>
			{% endif %}
		</ul>
	</div>
</div>

<script>

	{#$('.sss span').button().addClass('ui-state-hover');  #}
	{#$('.sss a').button();#}
</script>

{#,37.144.94.145,37.29.88.233,178.162.85.38,217.118.81.29,82.208.71.171,70.232.166.178,89.239.148.187,128.75.161.242,95.24.69.154,178.65.90.79,95.46.69.231,37.57.33.203#}
{#<div style="margin-bottom: 20px;">#}
{#		<div class="sss" style="display: inline-table;"> #}
{#	{%  if pages['cur_page'] > 1 %}#}
{#		<a href="?page={{pages['cur_page']-1}}">←</a> #}
{#	{% endif %}#}
{#	{%  if pages['start_page'] > 1 %}#}
{#		<a href="?page=1">1</a>  #}
{#	{% endif %}#}
{#	{%  if pages['start_page'] > 2 %}#}
{#		... #}
{#	{% endif %}#}
{##}
{#	{%  for res in range(pages['start_page'], pages['end_page']) %}#}
{#			{%  if res == pages['cur_page'] %}#}
{#				<span>{{res}}</span>#}
{#			{%  else %}#}
{#				<a href="?page={{res}}">{{res}}</a> #}
{#			{% endif %}#}
{#	{%  endfor %}#}
{##}
{#	{%  if pages['end_page'] < pages['count_page'] - 1 %}#}
{#		...  #}
{#	{% endif %}#}
{#	{%  if pages['end_page'] < pages['count_page'] %}#}
{#		<a href="?page={{pages['count_page']}}">{{pages['count_page']}}</a> #}
{#	{% endif %}#}
{#	{%  if pages['cur_page'] < pages['count_page'] %}#}
{#		<a href="?page={{pages['cur_page']+1}}">→</a> #}
{#	{% endif %}#}
{#		</div>#}
{#</div>#}
{#<script> #}
{#$('.sss span').button().addClass('ui-state-hover');  #}
{#$('.sss a').button();#}
{#</script>#}
