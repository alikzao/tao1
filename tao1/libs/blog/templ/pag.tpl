


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

