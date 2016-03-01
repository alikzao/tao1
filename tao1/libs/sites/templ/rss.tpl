<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
	<channel>
		<title>{{ title }}</title>
		<language>ru</language>
		<description>Агентство Русской Информации</description>
		<lastBuildDate>{{dtime}}</lastBuildDate>
		<webMaster>{{mail}}</webMaster>
		{% for res in data %}
		<item>
			<title>{{res.summary}}</title>
			<link>{{domen}}{{res.id}}</link>
			<description>{{res.content}} </description>
			<pubDate>{{res.dtime}}</pubDate>
		</item>
		{% endfor %}
	</channel>
</rss>