<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
	<channel>
		<title></title>
		<language>ru</language>
		<link></link>
		<description></description>
{#		<lastBuildDate>2012-12-04</lastBuildDate>#}
		<lastBuildDate>{{dtime}}</lastBuildDate>
		<webMaster>@</webMaster>
		{% for res in data %}
		<item>
			<title>{{res.summary}}</title>
			<link>/news/{{res.id}}</link>
			<description>{{res.content}} </description>
			<pubDate>{{res.dtime}}</pubDate>
		</item>
		{% endfor %}
	</channel>
</rss>