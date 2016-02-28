<style type="text/css">
    .bottom_slot i{
        color:#704b40;
    }
</style>
<div class="bottom_slot">
	<i class="icon-comments"></i> {{doc.count_branch or 0}}
	<span class="bord"> <i class="icon-eye-open"></i> {{(0 if not doc.doc.visit else env.int(doc.doc.visit)) if 'visit' in doc.doc else '0'}}</span>
    {% set score = doc.vote.score if 'vote' in doc else 0 %}
	<span><i class="icon-long-arrow-down"></i><i class="icon-long-arrow-up"></i></span> <span class="{{ 'green' if score >= 0 else 'red' }}">{{ score if score != 0 else '0' }}</span> &nbsp;&nbsp;
	<i class="icon-tags"></i>
    {% for res in doc.tags %}
		<a href="/show/des:obj/tags/{{ res }}">{{ res }}</a><span style="color:grey;">,</span>
    {% endfor %}
</div>
