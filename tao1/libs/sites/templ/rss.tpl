<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
	<channel>
		<title>ariru</title>
		<language>ru</language>
		<link>http://www.ari.ru</link>
		<description>Агентство Русской Информации</description>
{#		<lastBuildDate>2012-12-04</lastBuildDate>#}
		<lastBuildDate>{{dtime}}</lastBuildDate>
		<webMaster>ari@ariru.info</webMaster>
		{% for res in data %}
		<item>
			<title>{{res.summary}}</title>
			<link>http://www.ari.ru/news/{{res.id}}</link>
			<description>{{res.content}} </description>
			<pubDate>{{res.dtime}}</pubDate>
		</item>
		{% endfor %}
	</channel>
</rss>