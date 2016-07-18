import sys, re
from urllib.parse import *

from libs.perm.perm import *
from libs.perm.perm import user_has_permission
from libs.table.table import check_map_perm, rec_data_t, create_empty_row_

from libs.files.files import *
# from libs.captcha.captcha import *
from libs.tree.tree import *
from core.core import *
from core.union import cache, response_json

from datetime import datetime

from math import ceil
import aiohttp_jinja2
#test()
# _ = core.union.get_trans('user_site')
#vd(_('ccc'))

def page_404(request, page):
	us = 'us'
	return templ('libs.sites:page_404', request, dict(page=page, mess=us))

def show_middle_img(request):
	return templ('middle_img', request, {})

def show_inner(request, menu, content):
	u = urlparse(request.url)
	set_url = u.scheme + '://' + u.netloc + '/settings'
	return templ('libs.admin:base', request, dict( menu = menu, content = content, set_url=set_url))

def get_file_print_doc(request, proc_id, doc_id, file_name):
	db = request.db; fs = GridFS(db)

	fn = get_file_meta(proc_id, file_name, doc_id, '')
	f = fs.get(fn['_id']); # метод гридфс
	att = f.read();
	response.headers['Content-Type'] = fn['mime']
	# response.headers['Content-Disposition'] = 'attachment; filename="%s"' % fn['file_name']
	return att

def env_context():
	soc = {'friend':count_friend(), 'pm': count_pm()}
	return {'soc_h':soc}


def select_templ(template):
	if get_const_value("select_templ") == 'false':
		return 'domain/'+template
	else:
		return get_domain()+'/'+template


def show_top_site_menu(request):
	tp = form_tree(request.db.tree.find_one({'_id':'menu:site:top'}))
	return {'top_menu':tp}


def show_left_site_menu(request):
	lm = form_tree(request.tree.find_one({'_id':'menu:site:left'}))
	return { 'left_menu': lm}


uncut = re.compile (r'<cut[^>]+(title="([^">]*)")[^>]*>(.*)</cut>', flags=re.S)
#uncut_s = re.compile (r'<cut[^>]+(title="([^">]*)")[^>]*>(.*)</cut>', flags=re.S)

def short_text(text, limit, link=False, clean_newline=False, keep_link = False, readnext = ''):
	"""Выводит короткий текст, вызывается в шаблоне и передается через контекст """
	text = re.sub('<img[^>]+>', '', text)
	if keep_link:
		text = re.sub('<(/?)a([^>]*)>', '############\\1a\\2############', text)
		text = re.sub('<[^<>]+?>', ' ', text)
		text = re.sub('############(/?)a(.*?)############', '<\\1a\\2>', text)
	else:
		text = re.sub('<[^<>]+?>', ' ', text)
	if clean_newline:
		text = re.sub('\n', ' ', text)
	text = re.sub('&nbsp;', ' ', text)
	text = re.sub(' +', ' ', text)
	text = str(text)[:limit]
	if link:
		link = """<div class="readnext"><a style="color:#4F4F4F; padding:3px 4px; margin:4px 0;"
		class="btn btn-sm btn-default" href="{0}">Читать далее <i class="icon-long-arrow-right"></i> </a></div>""".format(link)
		text = text+' '+link
	elif readnext and len(text) >= limit:
		text = text+' '+readnext
	return text


class Full_doc(dict):
	_att = None
	_img = None
	def __init__(self, proc_id, doc_id, fields = {}):
		self['id'] = doc_id
		self['proc_id'] = proc_id
		for k, v in fields.items(): self[k] = v

	def get_att(self):
		if not self._att:
			self._att = get_nf(self['proc_id'], self['id'], 1)
		return self._att

	att = property(get_att)

	def get_img(self):
		if not self._img:
			self._img = get_curr_img(self, self.att)
		return self._img

	img = property(get_img)


# @cache("get_full_docs", expire=get_settings('cache_get_full_docs', 7))
def get_full_docs(request, docs, img_ctr=1):
	full_docs = []

	for doc in docs:
		doc_id = doc['_id']
		proc_id = doc['doc_type']
		cb = doc['count_branch'] if 'count_branch' in doc else '-'
		last_comm = doc['last'] if 'last' in doc else {}
		owner = doc['owner'] if 'owner' in doc else '-'

		# d_img = doc['default_img'] if 'default_img' in doc and doc['default_img'] else None
		d_img = doc.get('default_img', None)
		att = get_nf(request, proc_id, doc_id, img_ctr, False, d_img)
		img = get_curr_img(doc, att, img_ctr=1 )

		data = doc['doc']

		tags = doc['tags'][cur_lang( request )] if 'tags' in doc and doc['tags'] is not None and cur_lang( request ) in doc['tags'] and doc['tags'][cur_lang( request )] else ''
		parent = doc['parent'] if 'parent' in doc and doc['parent'] else ''
		child =  doc['child']  if 'child'  in doc and doc['child']  else '_'

		poll=[]
		full_doc = {"_id":doc['_id'], "id": doc_id, "doc": data, "att": att, "img":img,
		            'proc_id':proc_id, 'count_branch':cb, 'last_comm':last_comm, 'vote':get_vote(doc), 'tags':tags, 'poll':poll,
		            'parent':parent, 'child':child, 'owner':owner}
		full_docs.append(full_doc)
	return full_docs


def get_curr_img(doc, attachment, def_name = '', img_ctr=1):
	if 'default_img' in doc: return doc['default_img']
	if len(attachment):
		if img_ctr==1:
			return list(attachment.keys())[0]
		return list(attachment.keys())
	return def_name


def get_full_doc(request, doc_id, avatar=False, img_ctr=1):
	""" Находим одиночный обьект и если в нем стоит аватар True то показуем только првую маленькую картинку """
	doc = get_doc(request, doc_id); poll = None; units = ''
	if not doc: return None
	cb = doc['count_branch'] if 'count_branch' in doc else '-'
	proc_id = doc['doc_type']
	if proc_id == 'des:ware' and 'units' in doc['doc'] and doc['doc']['units']:
		try:
			units = request.db.doc.find_one({'_id':doc['doc']['units']})
			units = ct(units['doc']['title'])
		except: units = ''

	d_img = doc.get('default_img', None)
	attachment = get_nf(request, proc_id, doc['_id'], img_ctr)
	data = doc['doc']
	meta_table = get_mt(request, proc_id)['doc']
	for f in meta_table:
		if f['id'] in data and 'is_translate' in f and (f['is_translate'] == 'true' or f['is_translate'] == True):
			data[f['id']] = ct(request, data[f['id']])
	tags = doc['tags'][cur_lang(request)] if 'tags' in doc and cur_lang(request) in doc['tags'] and doc['tags'][cur_lang(request)] else ''
	fn = doc.get('final_name', '')
	return {"id": doc_id, "_id": doc['_id'], 'units':units, 'final_name':fn, 'count_branch':cb, "doc": data,
	        "att": attachment, 'default_img':d_img, 'proc_id':proc_id, 'vote':get_vote(doc), 'tags':tags, 'poll':poll}



def get_full_user(request, doc_id, avatar=False):
	""" Находим одиночный обьект и если в нем стоит аватар True то показуем только првую маленькую картинку """
	if not doc_id.startswith('user'): doc_id = 'user:'+doc_id
	doc = get_doc(request, doc_id)
	if not doc:
		return {"id": '', "doc": {'name':''}, "att": {} }

	attachment = get_nf(request, 'des:users', doc_id, 1)
	# img = get_curr_img(doc, attachment, 'avatar')
	# img = get_nf('des:users', doc_id, 1)
	# attachment = get_nf('des:users',, doc['_id'], 1)
	img = get_curr_img(doc, attachment, '')

	return {"id": doc_id, "doc":doc['doc'], "att": [img] }


ac = ["des: ware", "des: vat", "des: report_pe_ticket", "des: report_pe", "des: price_column", "des: price", "des: outcome_cash_order", 
	"des: jobs_ware_out", "des: jobs_ware_in", "des: jobs", "des: job_order_ware_out", "des: job_order_ware_in",
	"des: job_order_jobs", "des: job_order", "des: income_cash_order", "des: enterprise", "des: debit_invoice_ware",
	"des: debit_invoice", "des: credit_invoice_ware", "des: credit_invoice", "des: counteragent", "des: consist_of" ]

def rss_parse():
	pass


def show_arhiv(request):
	return templ('arhiv', request, {})


def list_mod(request, kind):
	db = request.db
	if not is_admin(request) and not user_has_permission(request, 'des:news', 'mod_accept'): return http_err(404, '')
	if kind == 'blog':
		docs = get_full_docs(request, db.doc.find({'doc_type':'des:obj', 'doc.accept': {'$ne': 'true'}, 'doc.pub': 'true'}).limit(50).sort('doc.date', -1))
		return templ('list_m_blog', docs=docs)
	elif kind == 'news':
		docs = get_full_docs(request, db.doc.find({'doc_type':'des:news', 'doc.accept': {'$ne': 'true'}, 'doc.pub': 'true'}).limit(60).sort('doc.date', -1))
		return templ('list_m_news', docs=docs)
	else: return http_err(404, '')


def list_mod_post(request):
	db = request.db
	obj = get_full_docs(request, db.doc.find({'doc_type':'des:obj', 'doc.accept': {'$ne': 'true'}, 'doc.pub': 'true'}).sort('doc.date', 1) )
	news = get_full_docs(request, db.doc.find({'doc_type':'des:news', 'doc.accept': {'$ne': 'true'}, 'doc.pub': 'true'}).sort('doc.date', 1) )
	return { "result":"ok", "news":json.dumps(news), "obj":json.dumps(obj) }


def show_comm_answ(request, user_id):
	docs = get_doc(user_id)
	pages, req = get_pagination(request, {'doc_type':'des:comments', 'doc.parent_comm':user_id, 'doc.hidden':{'$ne':'true'}})
	req.sort('date', -1)

	dv = get_full_docs(req)

	return templ('comm_list', request, dict(docs = dv, proc_id='des:comments', pages = pages))


def hide_comm_answ(request):
	db = request.db
	doc_id = get_post(request)
	doc = get_doc(request, doc_id)
	doc['hiden'] = 'false'
	db.doc.save(doc)
	return {"result":"ok"}


def read_abuse(doc_id):
	set_val_field(doc_id, field={'read':'true'})
	return {"result":"ok"}


def show_abuse_list(request):
	if not is_admin(request): return page_404('')
	condition = {'doc_type':'des:spam', 'doc.read':{'$ne':'true'}}
	pages, req = get_pagination(request, condition)
	req.sort('doc.date', -1)
	dv = get_full_docs(request, req)
	return templ('list_abuse', request, dict( docs = dv, proc_id='des:spam', pages = pages) )


def search_google(request, filter=''):
	return templ('list_google', request, {})


def search_yandex(request, filter=''):
	text = urlparse.parse_qsl(request.url)[1][1]
	return templ('list_yandex', request, dict(text=text.decode('utf-8')))


def search_full_text(request, filter=''):
	req = request.db.doc.find( {'doc_type':{'$in':['des:ware', 'des:radio', 'des:wiki', 'des:obj']},  '$text': { '$search': filter } } ).limit(40)
	dv = get_full_docs(request, req)
	return templ('search_list', docs = dv , proc_id='des:obj')


@cache('list_cached', expire=10 )
async def list_tags(request):
	proc_id    = request.match_info.get('proc_id', "des:obj")
	tags       = request.match_info.get('tags')
	simple_url = request.scheme + '://' + request.host

	tags = [tags.strip().lower()]
	condition = {'doc_type':proc_id, "$and":[{'tags.'+cur_lang(request):{'$in': tags}}], 'doc.accept':'true', 'doc.pub':'true'}
	pages, req = get_pagination( request, condition )
	docs = get_full_docs(request, req.sort('doc.date', -1))

	seo = request.db.doc.find_one({'doc.alias':'publics_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })
	seo = seo if seo and 'doc' in seo else ''

	return templ('list_tags', request,{"docs":docs, "proc_id":proc_id, "url":simple_url, "pages":pages, "title":tags[0], "seo":seo})


def list_arhiv(request, date_range):
	proc_id = "des:obj"
	url = urlparse(request.url)
	simple_url = request.scheme + '://' + request.host

	start=None; end=None
	if date_range:
		if isinstance(date_range, str):
			if len(date_range) == 10:
				start = date_range
				end= date_range + ' 99999'
			if len(date_range) == 7:
				if date_range.endswith('-00'):
					date_range = date_range[:4]
				else:
					start = date_range + '-00'
					end= date_range + '-99'
			if len(date_range) == 6:
				date_range = date_range[:5] + '0' + date_range[-1:]
				start = date_range + '-00'
				end= date_range + '-99'
			if len(date_range) == 4:
				start = date_range + '-00-00'
				end= date_range + '-99-99'
		else: (start, end) = date_range

	condition = {'doc_type':proc_id, 'doc.date': {'$gte': start, '$lte': end}, 'doc.accept':'true', 'doc.pub':'true'}
	pages, req = get_pagination(condition)
	dv = get_full_docs(req.sort('doc.date', -1))

	seo = request.db.doc.find_one({'doc.alias':'publics_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })
	seo = seo if seo and 'doc' in seo else ''

	title=date_range if isinstance(date_range, str) else date_range[0]

	return templ('single_list', docs = dv, proc_id=proc_id, url = simple_url, pages = pages, title=title, seo=seo )


def show_list(request, proc_id=None, action='obj', tags = None, filter='', u='', branch=None, order='date', date_range=None, templ_m=False, a=False, template=None):
	# url = urlparse(request.url)
	simple_url = request.scheme + '://' + request.host
	title = 'LIST'
	sort = None
	condition = {'doc_type':proc_id}
	if proc_id in ['des:obj', 'des:news']:
		condition['doc.accept']= 'true'
	if proc_id == 'des:comments' and not is_admin(request) and not user_has_permission(request, 'des:comments', 'edit'):
		condition['doc.pre']= {'$ne': 'true'}

	user = get_current_user(request, True)

	if is_admin(request): pass
	elif proc_id in ['des:obj', 'des:news', 'des:poll', 'des:radio', 'des:wiki', 'des:banner']:
		if user_is_logged_in(request):
			condition.update({'$or': [{'doc.pub':'true'}, {'doc.user':user}]})
		else:
			condition.update({'doc.pub':'true'})

	if action == 'visit':     sort = ('doc.visit', -1)
	elif action == 'rated':   sort = ('doc.rate_total', -1)
	elif action == 'popular': sort = ('doc.rate_votes', -1)
	elif action == 'ware':
		prod = request.POST.getall('producer')
		if len(prod):
			condition.update( {"doc.producer":{'$in':prod}} )
	elif action == 'users':
		condition.update({"doc_type":"des:users"})
	elif action == 'friend':
		req = request.db.doc.find_one({"_id":get_current_user(request, True)}, {"friends":1}); friends = []
		if 'friends' in req: friends = req['friends']
		condition.update({"_id":{'$in':friends}})
		sort = ('doc.date', -1) #req = db.doc.find({"_id":{'$in':friends}}).sort('doc.date', -1)
	elif action == 'user':
		if not filter.startswith('user:'): filter = 'user:'+filter
		condition.update({"doc_type":"des:obj", "doc.user":filter})
		t = {'date': 'doc.date', 'rating': 'vote.score'}
		if not order in t: order = 'date'
		sort_order = t[order]
		sort = (sort_order, -1) #req = db.doc.find({"doc_type":"des:obj", 'doc.published':'true', "doc.user":u}).sort('doc.date', -1)
	elif action == 'comments':
		if not filter.startswith('user:'): filter = 'user:'+filter
		title = filter
		condition.update({"doc_type":"des:comments", "doc.user":filter})
		sort = ('doc.date', -1)

	elif action == 'search':
		regex = re.compile(u'%s' % filter.decode('utf-8'), re.I | re.UNICODE)
		condition['doc.body.'+cur_lang(request)] = regex
		title = filter.decode('utf-8')
		sort = ('doc.date', -1)
	else:
		sort = ('doc.date', -1)
	if not condition['doc_type']: condition['doc_type'] = 'des:obj'

	pages, req = get_pagination(request, condition)
	if sort:
		req.sort(*sort)
	dv = get_full_docs(request, req)

	news_map = get_news_map(request, 'des:obj')
	info_map = get_news_map(request, 'des:users')
	if date_range:
		date_range=date_range if isinstance(date_range, str) else date_range[0]

	seo = request.db.doc.find_one({'doc.alias':'publics_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })
	seo = seo if seo and 'doc' in seo else ''

	if proc_id == 'des:comments' or action == 'comments':
		return templ('comm_list', request, dict(docs = dv, proc_id=proc_id, url = simple_url, pages = pages, news_map=news_map, date_range=date_range) )

	if proc_id == 'des:users':
		return templ('list_u', request, dict(docs = dv, proc_id=proc_id, pages = pages,pm_map="", news_map=news_map, info_map = info_map) )

	if proc_id == 'des:maps':
		return templ(('app.maps:maps_list_a' if a else 'app.maps:list_maps'), request, dict(docs = dv, proc_id=proc_id, pages = pages,pm_map="", news_map=news_map, info_map = info_map) )

	elif action == 'friend' or action == 'users':
		user = get_full_doc(request, get_current_user(request, True))
		return templ('list_u', request, dict(docs = dv, doc=user, proc_id=proc_id, url = simple_url,
			pages = pages,pm_map="", news_map=news_map, user_name=get_current_user(request), info_map = info_map, date_range=date_range) )

	elif date_range: title = date_range
	return templ('single_list', request, dict(docs = dv, proc_id=proc_id, url = simple_url, pages = pages, news_map=news_map, date_range=date_range, title=title, seo=seo) )


def list_obj1(request ):
	# url = urlparse(request.url)
	print(datetime.now())
	proc_id = request.match_info.get('doc_id', 'des:obj')
	simple_url = request.scheme + '://' + request.host
	title = 'LIST'
	condition = {'doc_type':proc_id, 'doc.accept':'true'}

	user = get_current_user(request, True)

	if is_admin(request): pass
	elif proc_id in ['des:obj', 'des:news', 'des:poll', 'des:radio', 'des:wiki', 'des:banner']:
		if user_is_logged_in(request):
			condition.update({'$or': [{'doc.pub':'true'}, {'doc.user':user}]})
		else:
			condition.update({'doc.pub':'true'})

	pages, req = get_pagination(request, condition)

	req.sort('doc.date', -1)
	dv = get_full_docs(request, req)

	news_map = get_news_map(request, 'des:obj')

	seo = request.db.doc.find_one({'doc.alias':'publics_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })
	seo = seo if seo and 'doc' in seo else ''

	print( datetime.now())
	return templ('single_list', request, dict(docs = dv, proc_id=proc_id, url = simple_url, pages = pages, news_map=news_map, title=title, seo=seo) )

def list_obj(request ):
	# url = urlparse(request.url)
	start = datetime.now()
	proc_id = request.match_info.get('doc_id', 'des:obj')
	simple_url = request.scheme + '://' + request.host
	title = 'LIST'
	condition = {'doc_type':proc_id, 'doc.accept':'true', 'doc.pub':'true'}
	pages, req = get_pagination(request, condition)

	req.sort('doc.date', -1)
	dv = get_full_docs(request, req)
	end = datetime.now()
	print('list_obj->', end - start)
	return templ('single_list', request, {'docs':dv, 'proc_id':proc_id, 'url':simple_url, 'pages':pages, 'title':title, } )


def google_post(request):
	return templ('google_post', request, {})


def get_pagination(request, condition, paginate = True):
	db = request.db
	cur_page = int(request.GET['page']) if 'page' in request.GET else 1
	limit = int(get_const_value(request, 'doc_page_limit'))
	#	limit = 2
	skip = (cur_page-1)*limit
	req = db.doc.find(condition)
	count = float(req.count())
	count = int(ceil(count/limit))
	if paginate: req = req.skip(skip).limit(limit)
	start_page = cur_page - 3
	if start_page<1: start_page = 1
	end_page = start_page + 7
	if end_page > count + 1: end_page = count + 1
	pages = {'count_page': count, 'cur_page': cur_page, 'start_page': start_page, 'end_page':end_page, 'skip': skip, 'limit': limit}
	return pages, req


def get_pagination_p(request, pipe):
	db = request.db; count = 0
	cur_page = int(request.GET['page']) if 'page' in request.GET else 1
	limit = int(get_const_value('doc_page_limit'))
	#	limit = 2
	skip = (cur_page-1)*limit
	pipec = list(pipe)
	pipec.append({'$group': {'_id': '1', 'count': {'$sum': 1}}})
	for res in db.doc.aggregate(pipec):
		count = res['count'] if 'count' in res and res['count'] else 0
		# count = res
	# req = db.doc.aggregate(pipec)
	# count = float(req.count())
	count = int(ceil(count/limit))
	pipe.append({'$skip': skip})
	pipe.append({'$limit': limit})
	result = db.doc.aggregate(pipe)
	# req = req.skip(skip).limit(limit)
	start_page = cur_page - 3
	if start_page<1: start_page = 1
	end_page = start_page + 7
	if end_page > count + 1: end_page = count + 1
	pages = {'count_page': count, 'cur_page': cur_page, 'start_page': start_page, 'end_page':end_page}
	return pages, result




async def user_status_post(request):
	from libs.tree.tree import check_user_rate
	user_is_logged = False
	s = await get_session(request)
	if not 'user_id' in s or s['user_id'] == 0 or s['user_id'] == 'guest':
		s['user_id'] = 'guest'
	else:
		# request.db.on.update({"_id":s['user_id']}, {"$currentDate": {"date": {"$type":"timestamp"}}}, True )
		request.db.on.update({"_id":s['user_id']}, {"$set":{"date": time.time() } }, True )
		request.db.doc.update({"_id": "user:" + s['user_id']}, {"$set": {"status": "on"}})

		user_is_logged = True
	# print( 's', s, cur_lang(request) )
	print( 'user_is_logged', user_is_logged )

	if user_is_logged:
		user_id = 'user:'+s['user_id']
		user = request.db.doc.find_one({'$or': [{"_id": user_id}, {'doc.mail': s['user_id']}]})
		# print('user', user, 'uid', user_id)
		ac = request.db.doc.find({'doc_type':'des:comments', 'doc.parent_comm':user_id, 'doc.hidden':{'$ne':'true'} }).count()
		try:
			rate = float( user['doc'].get('rate', 0) )
		except: rate = 0.0
		is_adm = is_admin(request)
		abuse = request.db.doc.find({'doc_type':'des:spam', 'doc.read':{'$ne':'true'}}).count() if is_adm else 0
		try:
			name = ct(request, user['doc'].get('name', '') )
		except:name = ''
		return response_json(request, {'result': 'ok', 'panel':templ_str('soc_h2',  request, dict(
				rate=rate, news_map = get_news_map(request, 'des:obj'), answer_comm=ac, abuse=abuse, is_logged=user_is_logged,
				user_id= user['_id'], is_admin=is_adm
		    )),
		    'user':{
				'name': name,
				'id': user['_id'],
				'is_admin': is_adm,
				'is_logged_in':user_is_logged,
				'alien': s['user_id'][:3],
				'water_mark': get_const_value(request, 'img_sign'),
				'answer_comm': ac,
				'abuse': abuse,
				'can_write': user_has_permission(request, 'des:obj', 'create'),
				'can_comment':( user_has_permission(request, 'des:obj', 'add_com') or user_has_permission(request, 'des:obj', 'add_com_pre') ) and check_user_rate(request, user['_id']),
				'user_rate': check_user_rate(request, user_id ),
				'del_comm': user_has_permission(request, 'des:obj', 'del_comm'),
				'moderator_comm': user_has_permission(request, 'des:comments', 'edit'),
				'edit_tags': user_has_permission(request, 'des:obj', 'edit_tag')
			}
		})
	else:
		return response_json(request, {'result': 'ok', 'panel':templ_str('soc_h2',  request, dict(news_map ="", answer_comm=0, abuse=0, is_logged=user_is_logged)),
		    'user':{
				'name':'Gзщuest', 'fb_id':'', 'water_mark': "", 'id':"user:guest",
				'is_admin': False, 'moderator_comm': False, 'is_logged_in':user_is_logged,
				'alien':None, 'answer_comm':0, 'abuse': 0, 'is_logged':user_is_logged,
				'can_write':False, 'user_rate':True, 'del_comm': False, 'edit_tags':False,
				'can_comment':True
			}
		})


def get_news_map(request, proc_id):
	meta_doc = request.db.map.find_one({'_id':str(proc_id)})
	meta_table = check_map_perm(request, proc_id, meta_doc['doc'])
	return rec_data_t(request, meta_table)



def set_prio(request):
	doc_id = get_post('doc_id')
	prio = get_post('prio')
	if not user_has_permission('des:news', 'create'):
		return templ('libs.sites:error', request, dict(title= 'У вас недостаточно прав', mess='У вас недостаточно прав'))
	set_val_field(doc_id, field={'prio':prio})
	return {"result":"ok"}


def add_news(request):
	proc_id = request.match_info.get('proc_id')
	title   = request.match_info.get('title', '')
	print('proc_id', proc_id)
	if not user_has_permission(request, proc_id, 'create'):
		mess = 'You do not have permission for this action'
		return templ('libs.sites:error', request, {"title":mess, "mess":mess} )
	news_map = get_news_map(request, proc_id)
	doc_id, updated = create_empty_row_(request, proc_id, '_', False)
	doc = get_doc(request, doc_id)
	if title: doc['doc']['title'] = {cur_lang(request) : title}
	return templ('add_news',  request, {"news_map":news_map, 'doc_id':doc_id, "doc":{'proc_id':proc_id, 'doc':doc['doc']} } )


def news_accept_post(request):  #@route('/', method = "GET")
	db = request.db
	doc = get_doc(get_post('doc_id'))
	proc_id = doc['doc_type']
	if not is_admin() and not user_has_permission(request, proc_id, 'mod_accept'):
		return {"result":"fail", "error":ct(cur_lang(request), 'У вас недостаточно прав для управления статусом статей') }
	if not doc:
		return {"result":"fail", "error":ct(cur_lang(request), 'Article not found') }
	doc['doc']['accept'] = 'true'
	db.doc.save(doc)
	if proc_id != 'des:obj': return {"result":"ok"}
	author = get_doc(request, doc['doc']['user'])
	if not author: return {"result":"fail", "error":"Author not found"}
	author['doc']['accept'] = 'true'
	db.doc.save(author)
	db.doc.update({'_id':'role:blogger'}, {'$set':{'users.'+author['_id']:'true'}} )
	reset_cache(doc)
	reset_main_cache()
	return {"result":"ok"}


def news_edit(request):  #@route('/', method = "GET")
	doc_id = request.match_info.get('doc_id')
	news_map = get_news_map(request, 'des:obj')
	doc = get_full_doc(request, doc_id)
	if not is_admin and doc['doc']['user'] != get_current_user(True):
		session_add_mess('У вас не прав на редактирование чужого материала', 'error')
		redirect('/', 302)
	return templ('news_add',  request, dict(news_map=news_map, doc_id=doc['id'], doc = doc))


# def show_main_page1(request):
# 	if 'templ' in request.GET:
#
# 		return show_main_page_()
# 	return show_main_page_cached()

#@cache('show_main_page', expire=settings.cache_main_page) 3600

# @cache('show_main_page_cached', expire=get_settings('cache_main_page', 7) )
# def show_main_page_cached():
# 	return show_main_page_()
#
# @cache('blogs_cached', expire=get_settings('cache_main_page', 7) )
# def blogs():
# 	return show_main_page_(template='blogs')
#
# @cache('wiki_cached', expire=get_settings('cache_main_page', 7) )
# def wiki_():
# 	return show_main_page_(template='wiki')


@cache('main_page', expire=10 )
async def show_main_page( request ):
	sp = get_const_value(request, 'is_shop')
	docs = []; clss = []

	if sp:
		from libs.shop.shop import list_ware_cls, first_cls
		clss = first_cls()
		docs = get_full_docs(request.db.doc.find({"doc_type":"des:ware", "doc.is_main":"true"}).limit(18))
	params={'var':'321'}
	trigger_hook('main_page', params)
	seo = request.db.doc.find_one({'doc.alias':'main_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })

	return templ("main_page",  request, dict(param=params['var'], docs = docs, clss=clss, docs_news=[], seo=seo ))


def test():
	return templ('test.tpl', data='data123')


def show_obj( request ):
	# print('1231340-95824-892234892985-2394850234985-20394850-329845394852039845-23982509238450938')
	# print('1231340-95824-892234892985-2394850234985-20394850-329845394852039845-23982509238450938w')
	print('123---322wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww55')
	doc_id = request.match_info.get('doc_id')
	url = request.scheme + '://' + request.host + request.path
	data_tree = []; comm=None
	doc = get_full_doc(request, doc_id)
	proc_id = doc['proc_id']
	if proc_id  == 'des:comments': return web.HTTPNotFound('/redirect')
	d_com = get_mt(request, proc_id)
	is_comments = False
	if d_com['conf']['comments'] == 'on':
		is_comments = True
		# comm = get_doc_tree(request, doc['_id'], proc_id)
		# comm = comm['_id']

		docs = [res for res in request.db.doc.find({'doc_type':'des:comments', 'doc.owner':doc['_id']}).sort('doc.date', 1) ]
		docs = get_full_docs(request, docs)
		data_tree = form_tree_comm(request, docs )

	rating, votes = get_rating(request, proc_id, doc_id)
	title = ct(request, doc['doc']['title']) if 'title' in doc['doc'] else ''
	templl = 'single_page'
	tags = list(set(doc['tags']) - set([ s.strip().lower() for s in get_const_value(request, 'minus_tags', '').split(',') ]))

	date_sim = (datetime.today() - timedelta(days=5)).strftime('%Y-%m-%d %H:%M:%S')[:19]

	req = request.db.doc.find({'doc_type':proc_id, '_id':{'$ne':doc['_id']}, 'tags.ru':{'$in':tags}, 'doc.date':{'$lt':date_sim } }).sort('doc.date', -1).limit(6)
	similar = get_full_docs( request, req )
	seo = request.db.doc.find_one({'doc.alias':'publics_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1,
	                                                            'doc.add_title':1 })
	seo = seo if seo and 'doc' in seo else ''

	return templ(templl,  request, dict(doc = doc, url = url, doc_id=doc_id, proc_id=proc_id, comm_id = comm, similar = similar, seo=seo,
		is_comments = is_comments, rating = rating, votes = votes, tree = data_tree, page_title=title, id=doc['_id']))


def show_object(request, doc_id, templ_m=False, no_redirect=False):
	doc = get_full_doc(doc_id)
	if not doc: return http_err(404)
	if not no_redirect:
		if doc_id.startswith('/'):
			redirect('/news/'+doc['doc']['rev'], 301)
			return
		if len(doc_id) ==32 and 'rev' in doc['doc']:
			redirect('/news/'+doc['doc']['rev'], 301)
			return
	proc_id = doc['proc_id']
	if proc_id in ['des:obj']:
		if (not is_admin(request) and not is_user_owner(doc)) and (not 'pub' in doc['doc'] or doc['doc']['pub'] != 'true' or not 'accept' in doc['doc'] or doc['doc']['accept'] != 'true') :
			return http_err(404)

	if not 'templ' in request.GET: o = show_object_cached(doc_id, templ_m)
	else: o = show_object_(doc_id, templ_m)
	return o


@cache('show_object_cached', expire=get_settings('cache_single_page', 7))
def show_object_cached(doc_id, templ_m=False):
	return show_object_(doc_id, templ_m)


def show_object_(request, doc_id, templ_m=False):
	u = urlparse(request.url)
	url = u.scheme + '://' + u.hostname + u.path
	data_tree = []; comm=None
	doc = get_full_doc(doc_id)
	proc_id = doc['proc_id']
	if proc_id  == 'des:comments':
		return http_err(404)
	d_com = get_mt(proc_id)
	is_comments = False
	db = request.db
	if d_com['conf']['comments'] == 'on': # db.doc.createIndex( { 'doc_type':1, 'doc.owner':1 } )
		is_comments = True
		comm = get_doc_tree( doc['_id'], proc_id)
		# data_tree = form_tree(comm, True)
		comm = comm['_id']

		docs = [res for res in db.doc.find({'doc_type':'des:comments', 'doc.owner':doc['_id']}).sort('doc.date', 1) ]
		# die( [ doc['_id'], doc_id  ])
		docs = get_full_docs(docs)
		data_tree = form_tree_comm( docs )

	# hash, raw = get_captcha(False)
	rating, votes = get_rating(proc_id, doc_id)
	title = ct(doc['doc']['title']) if 'title' in doc['doc'] else ''
	templl = 'single_page'
	if templ_m: templl = 'single_page_m'
	tags = list(set(doc['tags']) - set([ s.strip().lower() for s in get_const_value('minus_tags', '').split(',') ]))

	from datetime import datetime
	date_sim = (datetime.today() - timedelta(days=5)).strftime('%Y-%m-%d %H:%M:%S')[:19]

	req = db.doc.find({'doc_type':proc_id, '_id':{'$ne':doc['_id']}, 'tags.ru':{'$in':tags}, 'doc.date':{'$lt':date_sim } }).sort('doc.date', -1).limit(6)
	similar = get_full_docs( req )
	url1=url
	seo = db.doc.find_one({'doc.alias':'publics_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })
	seo = seo if seo and 'doc' in seo else ''

	return templ(templl,  request, dict(doc = doc, url = url1, doc_id=doc_id, proc_id=proc_id, comm_id = comm, similar = similar, seo=seo,
		is_comments = is_comments, rating = rating, votes = votes, tree = data_tree, page_title=title))



@cache('show_object1', expire=get_settings('cache_single_page', 7))
def show_wiki(request, title):
	#title = title.encode('utf-8').lower()
	title = title.decode('utf-8').lower()
	#die(title)
	doc = request.db.doc.find_one({'doc_type':'des:wiki', 'doc.title.'+cur_lang():title}, {'_id':1})
	if not doc:
		tag = request.db.doc.find_one({'doc_type':'des:wiki', 'tags.'+cur_lang():{'$in':[title]}}, {'_id':1})
		if tag:
			return show_obj(request, tag['_id'], no_redirect=True)
		else:
			return news_add('des:wiki', title)
	return show_obj(request, doc['_id'], no_redirect=True)


def fpp(request):
	return templ('libs.sites:fpp', request, {})



def add_rating_post(request):
	""" Собираем для звездочек """
	proc_id = request.POST['proc_id']
	doc_id = request.POST['doc_id']
	rating = request.POST['rating']
	db = request.db
	user = get_current_user()
	if not user:
		return '{"result":"fail", "error":"%s"}' % translate(cur_lang(), 'Гости не могут голосовать, зарегистрируйтесь.' )
	db.doc.update({'_id':doc_id, 'rating.'+user: {'$exists': False}}, {'$set':{'rating.'+user: int(rating)}})
	rate, votes =get_rating(proc_id, doc_id)
	db.doc.update({'_id':doc_id}, {'$set':{'doc.rate_total':rate, 'doc.rate_votes':votes}})
	rating, votes = get_rating(proc_id, doc_id)
	return {"result":"ok", "rating":rating, "votes":votes}


def get_rating(request, proc_id, doc_id):
	rating = request.db.doc.find_one({'_id':doc_id}, {'rating':1})
	rate, votes = 0.0, 0
	if rating and 'rating' in rating and type(rating['rating']) == dict:
		r = rating['rating'].values()
		votes = len(r)
		s = sum(r, 0.0)
		rate = s/votes
		rate = round(rate, 1)
	return rate, votes


def get_rss(request):
	dtime = time.strftime("%a, %d %b %Y %H:%M:%S +0200", time.gmtime()).decode('UTF-8')
	db = request.db; data = []
	for res in db.doc.find({"doc_type":"des:obj"}, {'doc.body':1, 'doc.title':1, 'doc.date':1, 'doc.rev':1 }).sort('doc.date', -1).limit(21):
		if not 'body' in res['doc']: continue
		if not 'title' in res['doc']: continue
		text = ct(res['doc']['body'])
		text = re.sub('<[^<>]+?>', ' ', text)
		text = re.sub(' +', ' ', text)
		res['doc']['body'][cur_lang()] = str(text)[:200]
#		data.append( {'id':str(res['_id']),'summary':cgi.escape(ct( res['doc']['title'])),'content':cgi.escape(text),
#					'dtime':datetime.strptime(str(res['doc']['date']), '%Y-%m-%d').strftime('%a, %d %b %Y %H:%M:%S +0200' ) } )
		data.append( {'id':str(res['doc']['rev']),'summary':cgi.escape(ct( res['doc']['title'])),'content':cgi.escape(text[:400]) })
	response.headers['Content-Type'] = 'text/xml; charset=UTF-8'
	return templ('libs.sites:rss',  request, dict(dtime=dtime, data=data))


def print_web_doc(request, doc_id):
	doc = get_full_doc(doc_id)
	if not doc:
		redirect('/', 302)
		return
	if doc_id.startswith('/'):
		redirect('/news/'+doc['doc']['rev']+'/print', 301)
		return
	if len(doc_id) <=5:
		redirect('/news/'+doc['doc']['rev']+'/print', 301)
		return
	if len(doc_id) ==32 and 'rev' in doc['doc']:
		redirect('/news/'+doc['doc']['rev']+'/print', 301)
		return
	return templ('libs.sites:print',  request, dict(doc=doc))


@cache('get_sitemap', expire=1800)
def get_sitemap(request):
	dtime = time.strftime("%Y-%m-%d", time.gmtime())
	db = request.db
	urls = list()
	domain = get_settings('domain')
	urls.append("""
				   <url>
				      <loc>http://%s/</loc>
				      <lastmod>%s</lastmod>
				      <changefreq>hourly</changefreq>
				      <priority>1</priority>
				   </url>
				   <url>
				      <loc>http://%s/slot/mp_2_0</loc>
				      <lastmod>%s</lastmod>
				      <changefreq>hourly</changefreq>
				      <priority>1</priority>
				   </url>
		""" % (domain, dtime, domain, dtime))
	# for res in db.doc.find({'doc_type': {'$in': ['des:obj', 'des:radio', 'des:news']}}):
	for res in db.doc.find({'$or': [{'doc_type': {'$in': ['des:obj', 'des:news']}, 'doc.accept':'true', 'doc.pub':'true'}, {'doc_type': {'$in': ['des:radio', 'des:wiki']} }] }):
		# if res['doc_type'] in ['des:obj', 'des:news'] and (not 'accept' in res['doc'] or res['doc']['accept'] != 'true'): continue
		if res['doc_type'] != 'des:wiki':
			link = 'http://'+domain+'/news/'+res['doc']['rev']
		else:
			link = 'http://'+domain+'/wiki/'+ct(res['doc']['title']).encode('utf-8')
		try:
			ddate = str(res['doc']['date'] ) [:10]
		except:
			ddate = '2015-12-13'
		urls.append("""
				   <url>
				      <loc>{0}</loc>
				      <lastmod>{1}</lastmod>
				      <changefreq>weekly</changefreq>
				      <priority>0.8</priority>
				   </url>
			""" .format( link, ddate )
		)

	templ = """<?xml version="1.0" encoding="UTF-8"?>
				<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
					%s
				</urlset> """ % '\n'.join(urls)

	response.headers['Content-Type'] = 'text/xml; charset=UTF-8'
	return templ


def empty_list(request):
	return templ('libs.admin:empty', request, {})

def user_posts(request, proc_id, user_id):
	u = user_id
	action = 'posts' if proc_id == 'des:obj' else 'comments'
	action1 = 'user' if proc_id == 'des:obj' else 'comments'
	if u.startswith('user:'):
		u = get_doc(u)
		if not u: return redirect('/')
		uu = ct(u['doc']['name']).replace(' ', '.')
		return redirect('/'+action+'/'+quote(uu.encode('UTF-8')))
	else:
		db = request.db
		uu = u.replace('.', ' ')
		u = db.doc.find_one({'doc_type':'des:users', 'doc.name.ru':uu})
		if not u: return redirect('/')

	return show_list(proc_id=proc_id, action=action1, tags = None, filter=u['_id'])

def user_profile(request, u):
	if u.startswith('user:'):
		u = get_doc(u)
		if not u: return redirect('/')
		uu = u['doc']['name']['ru'].replace(' ', '.')
		return redirect('/posts/'+quote(uu.encode('UTF-8')))
	else:
		db = request.db
		uu = u.replace('.', ' ')
		u = db.doc.find_one({'doc_type':'des:users', 'doc.name.ru':uu})
		# die(u)
		if not u: return redirect('/')

	dv = get_full_doc(u['_id'])

	return templ('user_page',  request, dict(doc = dv, doc_id=u['_id'], user_name=ct(u['doc']['name']),proc_id='des:users'))


def count_pm(request):
	db = request.db
	pm = db.doc.find({"doc.visit":{"$exists":False},"doc_type":"des:PM", "doc.user":get_current_user(True)}).count()
	if pm is not None or pm != 0:
		return pm
	else: return 0
	
def count_friend(request):
	db = request.db; ctr=0
	pm = db.doc.find_one({"_id":get_current_user(True)})
	if pm and 'friends' in pm:
		ctr = len(pm['friends'])
	return ctr


def action_add_friend_post(request):
	db = request.db
	doc_id = request.POST['doc_id']
	friend_id = request.POST['friend_id']
	doc = db.doc.find_one({'_id':doc_id})
	if not 'friends' in doc:
		doc['friends'] = []
	doc['friends'].append(friend_id)	
	db.doc.save(doc)
	return {"result":"ok"}


def robots_txt(request):
	# response.headers['Content-Type'] = 'text/plain'
	return templ('robots', request, {})


def get_slot(request, slotname, exclude=None, tags = None, img_ctr=1):
	""" получает конфигурацию слотов из базы и передает в шаблон, далее через контекст передается в шаблон,
	вызывается из шаблона а в слоте вызывается фукция которая короткий текст должна выдавать. """
	# conf_name = request.GET['templ'] if 'templ' in request.GET else get_settings('template', 'default')
	conf_name = 'default'

	conf = get_templ_conf(request, conf_name)

	if slotname in conf:
		slot = conf[slotname]
		tmpl = slot['templ'] if 'templ' in slot else 'slot1'
		if tags: slot['tag'] = tags

		docs, pages=get_obj(request, slot, exclude=[] if exclude is None else exclude, img_ctr=img_ctr)
		# print('get_slot', len(docs), 'slot: ', slot, 'slot_name: ', slotname)
		print('get_slot', len(docs), 'slot_name: ', slotname)
#		ress = timeit.timeit(lambda: get_obj(slot, exclude=[] if exclude is None else exclude), number=10)
		if exclude is not None:
			for res in docs:
				exclude.append(res['id'])
		return templ_str(tmpl, request, { "docs": docs, "slot": slot, "slot_name": slotname })
		# return aiohttp_jinja2.render_string(tmpl, request, { "docs": docs, "slot": slot, "slot_name": slotname })
		# t = templ(tmpl, request, { "docs": docs, "slot": slot, "slot_name": slotname })
		# print('t : ', t, tmpl, type(t))
		# return t.__dict__
	else: return ''


def get_slot_json(request, slotname):
	""" получает конфигурацию слотов из базы и передает в шаблон, далее через контекст передается в шаблон,
	вызывается из шаблона а в слоте вызывается фукция которая короткий текст должна выдавать. """
	conf_name = request.GET['templ'] if 'templ' in request.GET else get_settings('template', 'default')
	conf = get_templ_conf(request, conf_name)
	if slotname in conf:
		slot = conf[slotname]
		t, pages = get_obj(request, slot)
		for res in t:
			res['vote']['voted'] = None
		return t
	else: return []
	# 	return json.dumps(t)
	# else: return '[]'


def get_slot_list(request, slotname):
	conf = get_templ_conf(request)
	if slotname in conf:
		slot = conf[slotname]
		dv, pages = get_obj(slot, True)
		if slot['kind'] == 'users':
			return templ('list_u',  request, dict(docs = dv,  url = '/', pages = pages))
		return templ('single_list',  request, dict(docs = dv,  url = '/', pages = pages))
	else: return '[]'


#		role = [(lambda x: x.strip())(x) for x in role] #
#		condition['doc.tags.'+cur_lang()] = regex
def get_obj(request, slot, page=False, skip=0, exclude=[], img_ctr=1):
	if not slot: return '', 0
	try:
		tags = slot['tag']; branch=slot['by_group']; role=slot['role']; user=slot['user']; limit=int(slot['limit']); vote=int(slot['vote']);
		kind=slot['kind']; last_art=slot['last_art']; order=slot['sort'] if 'sort' in slot else 'none'
		term=slot['term'] if 'term' in slot else '' #срок годности
	except Exception: return '', 0
	if limit < 0: return '', 0
	proc_id = 'des:'+kind; count = 0
#	condition = {'doc_type':proc_id, 'doc.title':{'$exists':True} }
	condition = {'doc_type':proc_id}

	if term and  re.match('^[1-9][0-9]*$', term):
		term = int(term)
		dt = (datetime.today() + timedelta(days=-term)).strftime("%Y-%m-%d %H:%M:%S")
		condition['doc.date'] = {'$gt':dt}


	# if last_art == 'true':
	# 	condition['doc.last_art'] = 'true'
	if vote: condition['vote.score'] = {'$gte':int(vote)}
	user_filter = []
	if role: user_filter += role_users(role)
	if user:
		user = [(lambda x: x.strip())(x) for x in user]
		if len(user): user_filter = user_filter + user
	if len(user_filter):
		condition['doc.user'] = {'$in': user_filter}
	condition['$and'] = []
#	if proc_id != 'des:users' and proc_id != 'des:poll':
#		condition['$and'].append({'$or': [{'doc.pub': 'true'}, {'doc.user': get_current_user(True)} ]} )
	if proc_id in ['des:obj', 'des:news', 'des:poll', 'des:radio', 'des:wiki', 'des:banner', 'des:ware', 'des:clips']:
		condition['$and'].append({'doc.pub': 'true'})
	if proc_id in ['des:obj', 'des:news']:
		condition['doc.accept'] = 'true'
#		if proc_id == 'des:obj':
#			condition['$and'].append({'$or': [{'doc.accept': 'true'}, {'doc.user': get_current_user(True)} ]} )
	if len(tags): #
		tags = tags.split(',')
		tags = [(lambda x: x.strip().lower())(x) for x in tags ] # получили все что разделено через запятую, отрезали пробелы
		tags_minus = [x[1:] for x in tags if x.startswith('-') ] # в тагс_минусзанесли только те что начинаются на минус и минус из млова убрали
		tags = [x for x in tags if not x.startswith('-') ] # оставили только те которые без минуса

		if len(tags):
			condition['$and'].append({'tags.'+cur_lang(request):{'$in': tags}})
		if len(tags_minus): condition['$and'].append({'tags.'+cur_lang(request):{'$nin': tags_minus}})
	if len(exclude): condition['$and'].append({'_id':{'$nin': exclude}})
	pages = ''
	if not len(condition['$and']): del condition['$and']
	if order == 'date': order = 'doc.date'
	if order == 'rate':
		if kind=='users': order = 'doc.rate'
		else: order = 'vote.score'
	if order == 'views':
		order = 'doc.visit'
		condition['doc.visit'] = {'$ne':''}
	if order == 'comm': order = 'count_branch'
	pipe = [
		{'$match': condition},
		# {'$sort': {'doc.primary': -1}},
		# {'$sort': {'doc.primary': -1, order: -1}} if proc_id == 'des:news' else {'$sort': {order: -1}},
	    {'$sort': {'doc.primary': -1, order: -1}} if proc_id == 'des:news' else {'$sort': {order: -1}},
	]
	if last_art == 'true':
		pipe.append({'$group': {'_id':'$doc.user',
		                        'id':{'$first':'$_id'},
		                        'doc':{'$first':'$doc'},
		                        'doc_type':{'$first':'$doc_type'},
		                        'count_branch':{'$first':'$count_branch'},
		                        'last_comm':{'$first':'$last_comm'},
		                        'vote':{'$first':'$vote'},
		                        'tags':{'$first':'$tags'}
					}})
		if order != 'none':
			pipe.append({ '$sort':{order:-1} })
		pipe.append({'$project':{
			             '_id':'$id',
			             'doc':1,
			             'doc_type':1,
			             'count_branch':1,
			             'last_com':1,
			             'tags':1,
			             'vote':1
			        }})
	# pipe.append({'allowDiskUse':True})
	if page:
		pages, result = get_pagination_p(pipe)
	elif skip:
		pipe.append({'$skip': int(skip)})
		pipe.append({'$limit': limit})
		result = request.db.doc.aggregate(pipe,  allowDiskUse=True)
	else:
		pipe.append({'$limit': limit})
		result = request.db.doc.aggregate(pipe,  allowDiskUse=True)

	# print('results',result)
	# print('result.__dict__', result.__dict__)
	docs=[]
	for res in result:
		# print('res1', type(res))
		docs.append(res)
	dv = get_full_docs(request, docs, img_ctr)
	# print('dv', len(dv))
	return dv, pages


def get_templ_conf(request, templ='default'):
	from libs.admin.admin import get_slot_name
	# doc = request.db.conf.find_one({"_id":"conf_templ"}, {templ:1})
	doc = request.db.conf.find_one({"_id":"conf_templ"})
	if doc and templ in doc:
		conf = doc[templ]
		for slotname, slot in conf.items():
			conf[slotname] = get_slot_name(request, slot)

	else: conf = {}
	return conf


def role_users(request, role):
	""" Users receive a certain role """
	db = request.db
	if type(role) == str:
		doc = db.doc.find_one({'_id': role}, {'users':1})
	else:
		doc = db.doc.find_one({'_id':{'$in': role }}, {'users':1})
	return doc['users'].keys()


def save_templ_conf(request):
	data = json.loads(get_post('data'))
	db = request.db
	doc = db.conf.find_one({"_id":"conf_templ"})
	if not doc: doc = {"_id":"conf_templ"}
	doc['default'] = data
	db.conf.save(doc)
	return {"result":"ok"}


def vote_topic_post():
	return True


def get_vote(doc):
	if not 'vote' in doc or doc['vote'] is None:
		doc['vote'] = {"score":0,"votes_count":0, "votes_count_plus":0,"votes_count_minus":0, "voted":{}}
	return doc['vote']


def check_time(last_date, unit, check_t):
	dt = (datetime.today() + timedelta(**{unit:-check_t})).strftime("%Y-%m-%d %H:%M:%S")
	return last_date < dt


def add_vote_post(request):
	""" Calculate how many vote and etc."""
	db = request.db

	doc_id = get_post('doc_id')
	vote = get_post('vote')
	vote_type = get_post('vote_type')
	doc = get_doc(doc_id)
	if check_time(doc['doc']['date'], 'days', int(get_const_value('vote_timeout'))):
		return {"result":"fail", "error":u"Голосование уже закончилось"}
	user = get_current_user(True)

	if not 'vote' in doc: doc['vote'] = {"score":0,"votes_count":0, "votes_count_plus":0,"votes_count_minus":0, "voted":{}}
	if not user_has_permission(request, 'des:obj', 'vote'): return '{"result":"fail","error":"Не имеете права голоса"}'
	if not is_admin(request) and user in doc['vote']['voted']: return '{"result":"fail","error":"Повторное голосование запрещено"}'
	if not is_admin(request) and user == doc['doc']['user']: return '{"result":"fail","error":"Голосовать за себя запрещено"}'

	dt = datetime.today().strftime('%Y-%m-%d')
	user_f = get_doc(request, user)
	if not 'vote' in user_f : user_f['vote'] = {}
	if not dt in user_f['vote'] : user_f['vote'][dt] = {'up': 0, 'down': 0}
	if not is_admin(request) and int(user_f['vote'][dt]['up']) + int(user_f['vote'][dt]['down']) >= int(float(user_f['doc']['rate'])+1.25):
		return {"result":"fail","error":"Лимит голосов за сегодня исчерпан"}
	user_f['vote'][dt][vote] += 1
	db.doc.save(user_f)

	doc['vote']['voted'][user] = vote
	if vote == 'up':
		doc['vote']['score'] += 1
		doc['vote']['votes_count_plus'] += 1
	else:
		doc['vote']['score'] -= 1
		doc['vote']['votes_count_minus'] += 1
	doc['vote']['votes_count'] += 1
	db.doc.save(doc)

	# начисление балов пользователю
	u_id = doc['doc']['user']
	u = get_doc(u_id)
	if not 'rate' in u['doc']:
		u['doc']['rate'] = '0'
		request.db.doc.save(u)
	rate = float(u['doc']['rate']) + (0.5 if vote == 'up' else -0.5)
#	rate =+ 1 if vote == 'up' else -1
	update_cell(str(u_id), 'des:users', 'rate', str(rate) )

	doc = doc['vote']
	return {"result":"ok", "score":doc["score"],"votes_count":doc["score"],"charge_string":"","sign":"positive", "vote_type":vote_type,
	        "votes_count_plus":doc["votes_count_plus"],"votes_count_minus":doc["votes_count_minus"],"is_positive":True}

def vote_comm_post():
	"""Вычисляем данные в коментариях сколько проголосовало и тд."""
#	doc = get_doc('tree:'+doc_id)
	return {"result":"ok", "score":"+4","votes_count":6,"charge_string":"","sign":"positive","votes_count_plus":5,"votes_count_minus":1,"is_positive":true}


def chat(request, doc_id):
	ip = request.db.conf.find_one({'_id':'chat_ban_ip'})
	links = request.db.test.find({'doc_type':'link_chat'})
	return templ('libs.sites:chat', request, dict(key = doc_id, ip=ip['ip'], links = links))


def get_tags(request, tag_dict='des:obj'):
	"""# х0 - сам тег, х1 - число,
		# получили самое большое число
		# считаем алгоритм в какую степень нужно возвести максимальное число чтоб получить текущее
		# на выходе число от 0 до 1, мы умножаем на 4 и вычитаем из 6(рвзмер заголовка целое число)    math.log - вычисляет логариф
		# логарифм  это функция которая вычисляет степень в которую нужно возвести основу   чтоб получить заданое число (например если основа 2 число 8 то соответствующая степень это 3)
		#  round( math.log( x[1] - low, mx - low ) * 4)    умножаем на 4 потому что у нас 5 градаций     от 0 до 4
	"""
	doc = request.db.conf.find_one({"_id":"tags_"+tag_dict[4:]})
	if not doc: return []
	import math
	low = int(get_const_value(request, 'count_tags'))
	minus = get_const_value(request, 'minus_tags')

	minus = [res.strip() for res in minus.split(',')]
#	tags = [((x[0], x[1], x[1]) for x in doc['tags'][cur_lang()] if not x[0] in minus]
	lang = cur_lang(request)
	try:
		tags = [x for x in doc['tags'][lang] if not x[0] in minus and x[1] > low]
	except:
		tags = [x for x in doc['tags']['ru'] if not x[0] in minus and x[1] > low]
	if not tags: return []
	mx = max(tags, key=lambda x: x[1])[1]
	if mx-low <= 1: return []
	tags = [(x[0], x[1], 6 - int( round( math.log( x[1] - low, mx - low ) * 4) ) ) for x in tags]
	tags = sorted(tags, key=lambda x: x[0] )
	return tags


def get_linked_title(doc_id, title='title'):
	doc = get_doc(doc_id)
	return ct(doc['doc'][title]) if 'title' in doc['doc'] else ''


def spam_post():
	data = json.loads(get_post('data'))
	doc_id, updated = create_empty_row_('des:spam', '_', None, {}, clear_id=True)
	update_row_('des:spam', doc_id, data, '_', noscript=True, no_synh=True, accept_def=False)
	return {"result":"ok"}


def set_main_news(request):
	""" устанавливает выделеным новости на главной странице
	"""
	db = request.db
	old = str(datetime.now() - timedelta(hours=36))

	for res in db.doc.find({'doc_type':'des:news', 'doc.date': {'$gt': old}}):
		visit = 0.0
		if 'visit' in res['doc'] and res['doc']['visit']:
			visit = float(res['doc']['visit'])
		try:
			if visit > 400:
				res['doc']['primary'] = 'true'
				db.doc.save(res)
		except:pass
	for res in db.doc.find({ 'doc_type':'des:news', 'doc.primary':'false' }):
		del res['doc']['primary']
		db.doc.save(res)

	for res in db.doc.find({ 'doc_type':'des:news', 'doc.primary':'true', 'doc.date': {'$lt': old} }):

		del res['doc']['primary']
		db.doc.save(res)

	for res in db.doc.find({ 'doc_type':'des:news', 'doc.primary':'true' }):
		visit = 0.0
		if 'visit' in res['doc'] and res['doc']['visit']:
			visit = float(res['doc']['visit'])

		if visit < 400:
			del res['doc']['primary']
			db.doc.save(res)


def loader_slot(request):
	""" подгружает слоты внизу страницы
	"""
	skip = get_post('skip')
	slotname = get_post('slot')
	conf = get_templ_conf(get_tpl())
	if slotname in conf:
		slot = conf[slotname]
		dv, pages = get_obj(slot, False, skip)
		return {"result":"ok", "content":templ(slot['templ'],  request, dict(docs=dv, slot=slot)), "len_dv":len(dv)}
	else: return '[]'


def transfer_article():
	""" меняем слот у материала
	"""
	doc_id = get_post('doc_id')
	target = get_post('target')
	doc = get_doc(doc_id)
	if target in ['top', 'view', 'out']:
		update_row_(doc['doc_type'], doc_id, {'tags':ct(doc['doc']['tags'])+', *'+target}, '_')
	return {"result":"ok"}


def test_main(request):
	st = get_const_value('stretch_tv')
	if st:
		db = request.db
		if st == '1':
			doc = db.templ.find_one({'_id':'tv_frame_middle.tpl'})
			if 'doc' in doc and 'big_bit' in doc['doc']: video = doc['doc']['small_bit']
		else:
			doc = db.templ.find_one({'_id':'tv_frame_small.tpl'})
			if 'doc' in doc and 'small_bit' in doc['doc']: video = doc['doc']['small_bit']
		doc = get_doc('tv_frame_main.tpl', 'col:templ')
		# die(doc)
		if 'doc' in doc:
			di = doc['default_img'] if doc and 'default_img' in doc else ''
			att = get_nf('col:templ', doc['_id'], 1)
	params={'var':'321'}
	trigger_hook('main_page', params)
	return templ('test_main', request, dict(param=params['var'], docs = [], docs_news=[]))


def test_main2(request):
	st = get_const_value(request, 'stretch_tv')
	if st:
		db = request.db
		if st == '1':
			doc = db.templ.find_one({'_id':'tv_frame_middle.tpl'})
			if 'doc' in doc and 'big_bit' in doc['doc']: video = doc['doc']['small_bit']
		else:
			doc = db.templ.find_one({'_id':'tv_frame_small.tpl'})
			if 'doc' in doc and 'small_bit' in doc['doc']: video = doc['doc']['small_bit']
		doc = get_doc('tv_frame_main.tpl', 'col:templ')
		# die(doc)
		if 'doc' in doc:
			di = doc['default_img'] if doc and 'default_img' in doc else ''
			att = get_nf('col:templ', doc['_id'], 1)
	params={'var':'321'}
	trigger_hook('main_page', params)
	return templ('test_main2', request, dict(param=params['var'], docs = [], docs_news=[]))


def news(request):
	return templ('news', request, dict(docs=[]))

def contacts(request):
	return templ('contacts', request, dict(docs=[]))

def trigger_hook(name, params, __hooks={}):
	if name in __hooks:
		for hook in __hooks[name]:
			if get_settings('debug', False):
				hook(params)
			else:
				try: hook(params)
				except: pass


def wiki(request, text, user=None, title=None):
	"""получает смешаное слово"""
	if not text: return ''
	params={'text':text, 'user':user}
	trigger_hook('wrap', params)
	text = params['text']
	toc = []
	def wiki_toc(x):
		toc.append(x.group(1))
		return '<h2><a name="'+x.group(1)+'"></a>'+x.group(1)+'</h2>'
#	text = re.compile(r'\[\[([^\]]+)\]\]', re.DOTALL).sub(lambda x: '<a href="http://'+s+'/'+x.group(1)+'">'+x.group(1)+'</a>', text)
	text = re.compile(r'\[\[([^\]]+)\]\]', re.DOTALL).sub(lambda x: '<a href="' + request.shema+'://'+request.host+'/wiki/' + x.group(1)+'">'+x.group(1)+'</a>', text)
	text = re.compile(r'== (.+?) ==', re.DOTALL).sub(wiki_toc, text)
	text = re.sub(r'<img([^>]+)height="[^>"]*"([^>]*)/?>', r'<img \1 \2>', text)

	title = str(title)
	text = text.replace(str(title), '<strong>' + str(title) +'</strong>' )
	text = text.replace(str(title.swapcase()), '<strong>' + str(title.swapcase())+'</strong>' )
	text = text.replace(str(title.title()), '<strong>' + str(title.title())+'</strong>' )

	t = ''
	if len(toc):
		t += '<ul>'
		for i in toc:
			t +='<li><a href="#'+i+'">'+i+'</a></li>'
		t += '</ul>'
	return t+text



