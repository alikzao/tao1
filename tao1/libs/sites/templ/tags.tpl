
<div class="tags">
{% for res in get_tags(tag_dict)%}
	{% set number = res[1]%}
	<span class="single_tag">
        <h{{res[2]}} style="height:20px !important; margin:0px !important;padding:0px !important;"><a href="/show/{{ tag_dict }}/tags/{{res[0]}}">{{res[0]}}</a></h{{res[2]}}> <span class="hh h{{res[2]}}">({{res[1]}})</span>
    </span>
{% endfor %}
</div>


