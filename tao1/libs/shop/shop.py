import json, cgi, os, sys,  hashlib, time
from urllib.parse import  *

from pymongo import *

from urllib import * 
# from app.report.report import *
from datetime import datetime, timedelta
from libs.perm.perm import *
from libs.table.table import create_empty_row_
from libs.contents.contents import get_doc, get_mt
from core.core import *

def add_basket_post(): 
	add_basket(get_post('ware_id'), int(get_post('quantity')))
	return {"result": "ok", "quantity":basket_count(), "basket": basket_show()}

def add_basket(ware, quantity):
	"""получает id товара и количество берет подробности о нем и заносит в сесии"""
	s = session()
	doc = get_doc(ware)
	basket_check()
	if not ware in s['basket']:
		s['basket'][ware] = {'title': ct(doc['doc']['title']), 'price': doc['doc']['price'],
		                     "amount": 0, 'quantity': 0, 'descr': doc['doc']['descr'],
		                     "_id":doc['_id']
		}
	s['basket'][ware]['quantity'] += quantity
	# die(doc['doc']['count_opt'])
	if 'count_opt' in doc['doc'] and doc['doc']['count_opt'] and int(quantity) >= int(ct(doc['doc']['count_opt'])):
		amount = float(quantity * doc['doc']['price_opt'])
		s['basket'][ware]['amount'] = amount
		s.save()
		# die( s['basket'][ware]['amount'] )
	else:
		amount = float(quantity * doc['doc']['price'])
		s['basket'][ware]['amount'] += amount
		s.save()

def list_basket(request):
	quantity = basket_count()
	basket = basket_show()
	amount = 0
	# basket = {'1':'1'}
	for i in basket:
		# amount += float(basket[i]['quantity']) * float(basket[i]['price'])
		amount += float(basket[i]['amount'])
	# return templ('app.shop:list_basket', quantity = quantity, basket = basket, amount = amount )
	return templ('libs.shop:list_basket', request, dict(quantity = quantity, basket = basket, amount = amount) )


def basket_context(request):
	basket = get_const_value("is_basket")
	u = urlparse(request.url)
	basket_url = u.scheme + '://' + u.netloc + '/basket'
	meta_doc = get_mt('des:client_order'); basket_map=None
	if meta_doc:
		meta_table = check_map_perm('des:order', meta_doc['field_map'])
		basket_map = rec_data_t(meta_table)
	return {'basket_url':basket_url, 'basket_map':basket_map, }


def clean_basket_post(): 
	basket_clean(get_post('ware_id'))
	return json.dumps({"result": "ok", "quantity":basket_count(), "basket": basket_show()})


def show_basket_post(): 
	return json.dumps({"result": "ok", "quantity":basket_count(), "basket": basket_show()})


def make_order_post():
	callback(get_post('phone'), get_settings('domain'), get_settings('basket', ''))
	add_order(json.loads(get_post('data')))
	return {"result":"ok"}


def add_order(request, data):
	db = request.db
	proc_id = 'des:order'; table_id = 'ware'
	sub_data = basket_show()
	doc_id = create_empty_row_(proc_id, data)
	doc = get_doc(doc_id)
	for i in sub_data:
		new_id = doc['seq_id']
		doc["seq_id"] = new_id+1
		new_id = str(new_id)
		doc['tables'][table_id][new_id] = sub_data[i]
	db.doc.save(doc)
	return {"result":"ok"}


def add_order_web_post():
	""" web заказы -> на создание -> init_web_order(new_row)
		web заказы -> на создание подтаблицы -> update_sum( owner, new_row)
		web заказы -> на обновление подтаблицы -> update_sum( owner, new_row)

		web заказы товары -> на создание -> update_price_column({}, new_row, doc['owner'])
											price_changed( doc['owner'], {}, new_row, False)

		web заказы товары -> на обновление -> update_price_column(old_row, new_row, doc['owner'])
											  price_changed(doc['owner'], old_row, new_row, False)
	"""
	phone = get_post('phone')
	basket = get_post('basket', '')
	callback(phone, get_settings('domain'), basket)
	s = session()
	basket_check()
	if len(s['basket']):
		owner = get_post('owner')
		owner = create_row('des:web_order', None, defaults={'phone':phone})
		amount = 0
		for _id in s['basket']:
			ware = s['basket'][_id]
			doc_id = create_row('des:web_order_ware', owner, defaults={"title":ware['_id'], "quantity":ware['quantity'],
			                                                           "price":ware['price']})
			amount += ware['quantity'] * float(ware['price'])
			if not doc_id: return '{"result":"fail", "error":"%s"}' %cgi.escape('updated', True)
		update_row_( 'des:web_order', owner, {'amount':amount}, '_', no_synh=True)
		wares_clean()
	return {"result":"ok"}


def get_shop_filter(request):
	db = request.db
	aaa = []
	for res in db.doc.find({"doc_type":"des:producer"}):
		aaa.append({"id":res['_id'], "title":ct( res['doc']["title"]) })
	return {'produced':aaa}


def basket_clean(ware):
	basket_check()
	s = session()
	if ware in s['basket']:
		del s['basket'][ware]
	s.save()

def wares_clean():
	basket_check()
	s = session()
	del s['basket']
	s.save()
	return {"result":"ok"}
	
def basket_show():
	basket_check()
	s = session()
	return s['basket']

def basket_count():
	"""щитает кол-во товаров в корзине"""
	basket_check()
	s = session(); summ = 0
	for i in s['basket']:
		summ += s['basket'][i]['quantity']
	return summ

def basket_amount():
	basket_check()
	s = session(); summ = 0
	for i in s['basket']:
		summ += s['basket'][i]['quantity']*s['basket'][i]['price']
	return summ

def basket_check():
	s = session()
	if not 'basket' in s:
		s['basket'] = {}
		s.save()
		

# =====================================================================================================================================
# ====================================== ADVANCED FILTER ===========================================================================
# =====================================================================================================================================

def ware_filter(filter):
	# отфильтровует сами товары указаному списку атрибутов
	if not isinstance(filter, list): filter = [filter]
	categ = {}
	for i in filter:
		cat = i[:32]
		attr = i[33:]
		if not cat in categ: categ[cat] = []
		categ[cat].append(attr)
	cond = dict([('attr.'+i, {'$in': v}) for i, v in categ.items()])
	#текущий вариант
	# aaa = {'attr':{'diagonal':'17', 'korpus': 'metall'}}
	# cond = {'attr.diagonal: {$in: [15, 17]}}
	# cond = {'docs: {$in: [15, 17]}}
	#текущий для агрегации
	#db.test.aggregate({$unwind: "$likes"})
	# {'docs':[{'id':1, 'cat': 'diagonal', 'attr':'17'}, {id:2, 'cat':'korpus', 'attr': 'metall'}] }
	return cond

def get_ware_cls(request, cls):
	""" получаем список для фильтра который справа показывается """
	# получаем список категорий которые принадлежат например смартфон    на выходе диагональ и тд.
	# $cat =
	# select c.* from ware_cat as c inner join on c.id = cc.owner ware_class_cat as cc where cc.owner = $cls
#    {'doc_type':'ware_class_cat', 'owner':cls}{'doc_type':'ware_cat', '_id':{'$in':cat}}
	# select a.* from ware_attr as a where owner in $cat
	db = request.db; categ = []; list_cat = []
	# собираем нужные данные, собираем фильтры принадлежащии классу
	for res in db.doc.find({'doc_type':'des:ware_class_cat', 'owner':cls}):
		list_cat.append(res['doc']['cat'])
	# собираем фильтры атрибутов
	for res in db.doc.find({'doc_type':'des:ware_cat', '_id':{'$in':list_cat}}):
		cat = {'id':res['_id'], 'title':ct(res['doc']['title']), 'attr':[]}
		categ.append(cat)
		# идем по полученым фильтрам и собиарем атрибуты
		for rs in db.doc.find({'doc_type':'des:ware_attr', 'owner': cat['id']}):
			attr = {'id':rs['_id'], 'title':ct(rs['doc']['title'])}
			cat['attr'].append(attr)
	return categ


def list_ware(request, cls):
	""" вызывается для показа списка товаров """
	#ware_class_cat-справочник где хранятся категории которые относятся к классу ( класс-смартфон у него категория диагональ экрана )
	# cats = [res['_id'] for res in db.doc.find({'doc_type':'ware_class_cat'})]
	cond = {'doc_type':'des:ware', 'doc.class': cls, 'doc.pub':'true'}
	if request.method == 'POST':
		cond.update(ware_filter(get_post('cat', [])))   # cond = {'attr.diagonal: {$in: [15, 17]}}
	from libs.sites.sites import get_pagination, get_full_docs
	pages, req = get_pagination(cond)
	sort = ('doc.date', -1)
	if sort: req.sort(*sort)
	dv = get_full_docs(req)
	filter = get_ware_cls(cls)
	return templ('libs.shop:list_ware', request, dict(cls = cls, docs = dv, proc_id='des:ware', pages = pages, filter=filter) )

# ======================================================================================================================
# ======================================================================================================================
# ======================================================================================================================
def list_class_post(cls):
	pass

def list_ware_post(cls):
	pass


def ware_page(request, doc_id):
	u = urlparse(request.url)
	url = u.scheme + '://' + u.hostname + u.path
	data_tree = []
	from libs.sites.sites import get_pagination, get_full_doc, get_full_docs
	db = request.db
	doc = get_full_doc(doc_id, img_ctr=4)

	req_attr = db.doc.find({'doc_type':'des:ware_attr', 'owner':doc['_id']})
	ware_attr = get_full_docs( db.doc.find({'doc_type':'des:ware_attr', 'owner':doc['_id']}) )


	proc_id = doc['proc_id']
	title = ct(doc['doc']['title']) if 'title' in doc['doc'] else ''
	cls = doc['doc']['class']
	req = db.doc.find( {'doc_type':'des:ware', '_id':{'$ne':doc['_id']}, 'doc.class':cls} ).limit(6)
	similar = get_full_docs( req )
	url1 = url
	seo = db.doc.find_one({'doc.alias':'ware_page_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1})
	# if seo:
	# 	seo = seo
	# else: seo = ''
	return templ('ware_page', request, dict(doc = doc, url = url1, doc_id=doc_id, proc_id=proc_id, similar = similar, seo=seo,
		tree = data_tree, page_title=title, ware_attr=ware_attr)) #news_map=news_map, captcha=raw, hash=hash,


def count_ware_(request, cls):
	db = request.db
	ctr = db.doc.find({'doc_type':'des:ware', 'doc.class':cls}).count()
	childs = db.doc.find_one({'_id':cls})
	if not 'child' in childs: return ctr
	for res in childs['child']:
		ctr += count_ware(res)
	return ctr


def count_ware(request, cls):
	db = request.db
	ctr = db.doc.find({'doc_type': 'des:ware', 'doc.class': cls}).count()
	childs = db.doc.find_one({'_id': cls})
	ctr += sum(count_ware(res) for res in childs.get('child', []))
	return ctr


def get_navigate_(request, doc_id):
	db = request.db; path = []
	parent = db.doc.find_one({'child':{'$in':[doc_id]}}, {'parent':1, 'doc.alias':1})
	if not parent: return []
	else:
		path.append(parent['doc']['alias'])
		path = path + get_navigate_(parent['_id'])
	return path


def get_navigate(request, doc_id):
	db = request.db; path = []
	parent = db.doc.find_one({'_id': doc_id}, {'parent':1, 'doc.alias':1, 'doc.title':1})
	if not parent: return []
	else:
		path.append((parent['doc']['alias'], ct(parent['doc']['title'])))
		path = path + get_navigate(parent['parent'])
	return path

def get_filters(request, cls):
	db = request.db
	docs=[]
	cursor = db.doc.aggregate([
		# { '$match'   : { 'doc_type' : "des:ware_attr",  'doc.class': { '$exists': True } } },
		{ '$match'   : { 'doc_type' : "des:ware_attr",  'doc.class': cls } },
		{ '$project' : { 'title'    : "$doc.title.ru", 'value':"$doc.attr_val.ru", 'class':"$doc.class", '_id':0 } },
		{ '$group'   : {'_id': {'class' :"$class", 'title': "$title"} , 'filters': { '$addToSet': "$value" } } },
		{ '$group'   : {'_id' :"$_id.class", 'title':{ '$addToSet': { 'title': "$_id.title", 'filters': "$filters" } } } }
	])
	for res in cursor:
		docs.append(res)
	return docs

def list_class(request, cls):
	""" показывает список вложеных категорий и товаров для категорий
	"""
	from libs.sites.sites import get_pagination, get_full_docs, get_curr_img, get_full_doc
	from libs.files.files import get_nf
	db = request.db; clss = []
	parent_id = db.doc.find_one({'doc_type':'des:ware_class', 'doc.alias':cls})
	for doc in db.doc.find({'doc_type':'des:ware_class', 'parent':parent_id['_id']}).sort('doc.date', -1):
		proc_id = doc['doc_type']
		d_img = doc['default_img'] if 'default_img' in doc and doc['default_img'] else None
		attachment = get_nf(proc_id, doc['_id'], 1)
		data = doc['doc']
		try:
			count = count_ware(doc['_id'])
		except: count='1'
		full_doc = {"_id":doc['_id'], "id": doc['_id'],
		            'count':count,
		            "doc": data,
		            "att": attachment, "img":get_curr_img(doc, attachment), 'default_img':d_img, 'proc_id':proc_id}
		clss.append(full_doc)
	pages= ''
	docs = get_full_docs(db.doc.find({'doc_type':'des:ware', 'doc.class':parent_id['_id']}).sort('doc.date', -1))
	# docs = get_full_docs(req).sort('doc.date', -1)
	filter = get_filters(parent_id['_id'])
	# filter = get_ware_cls(cls)
	parent_doc = get_full_doc(parent_id['_id'])
	# seo = db.doc.find_one({'doc.alias':'class_seo'}, {'doc.title':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })
	seo = db.doc.find_one({'_id':parent_id['_id']}, {'doc.description':1, 'doc.tags':1, 'doc.footer':1 })
	# seo = seo if 'doc' in seo else ''
	return templ('list_class', request, dict(cls_docs = clss, cls=cls, docs = docs, proc_id='des:ware', pages = pages,
	                                         path=get_navigate(parent_id['_id']), parent_doc=parent_doc, filter=filter, seo=seo) )


def set_filters(request, cls, filters):
	db = request.db
	url = filters[1:]
	url = url.split(';')
	docs=[]; cond=[]; ds = {}; attr = []; data = []

	for res in url:
		res = res.replace('%20', ' ')
		aaa = res.split('=');

		key = aaa[0]; val = aaa[1]
		if key in ds:
			if type(ds[key]) == list: ds[key].append(val)
			else: ds[key] = [ds[key], val]
		else: ds.update({key:val})
	for res in ds:
		attr.append(res)
	for res in ds.items():
		if type(res[1]) == list:  pr = {'doc.title.ru':res[0], 'doc.attr_val.ru':{'$in':res[1]}}
		else: pr = {'doc.title.ru':res[0], 'doc.attr_val.ru':res[1]}
		docs.append(pr)
	cursor = db.doc.aggregate([
		{ '$match'  : { 'doc_type' : "des:ware_attr", 'doc.class':cls, '$or': docs} },
		{ '$group'  : { '_id': "$owner", "attr": { '$push': "$doc.title.ru" } } },
		{ '$match'  : { "attr": { '$all': attr } } },
		{ '$project': {"_id":1 } }
	])
	for res in cursor:
		cond.append(res)
	if not len(cond): return None
	from libs.sites.sites import get_full_docs
	docs = get_full_docs(db.doc.find({ '$or':cond }).sort('doc.date', -1))
	return docs


def list_filters(request, cls, filters):
	""" если чтото выбрали для фильтров
	"""
	from libs.sites.sites import get_pagination, get_full_docs, get_curr_img, get_full_doc
	from libs.files.files import get_nf
	db = request.db; clss = []
	parent_id = db.doc.find_one({'doc_type':'des:ware_class', 'doc.alias':cls})
	for doc in db.doc.find({'doc_type':'des:ware_class', 'parent':parent_id['_id']}).sort('doc.date', -1):
		proc_id = doc['doc_type']
		attachment = get_nf(proc_id, doc['_id'], 1)
		data = doc['doc']
		try:
			count = count_ware(doc['_id'])
		except: count='1'
		full_doc = {"_id":doc['_id'], "id": doc['_id'],
		            'count':count,
		            "doc": data,
		            "att": attachment, "img":get_curr_img(doc, attachment), 'proc_id':proc_id}
		clss.append(full_doc)

	pages= ''
	docs = set_filters( parent_id['_id'], filters )

	filter = get_filters(parent_id['_id'])

	seo = db.doc.find_one({'doc.alias':'class_seo'}, {'doc.description':1, 'doc.tags':1, 'doc.body':1, 'doc.footer':1, 'doc.add_title':1 })
	seo = seo if 'doc' in seo else ''
	return templ('list_class', request, {'result':'ok', 'cls_docs':clss, 'cls':cls, 'docs':docs, 'proc_id':'des:ware', 'pages':pages,
	                            'path':get_navigate(parent_id['_id']), 'parent_doc':get_full_doc(parent_id['_id']), 'filter':filter, 'seo':seo})

def get_list_filter(request, cls):
	""" формируемая структура [{'id_class':'123', "filter_name":"name", attr:{'id_class':'123', 'title':'title'}]
	"""
	db = request.db; filters = []
	for res in db.doc.find({ 'doc_type':'des:ware_filter', '$or':[{'doc.ware_class':cls}, {} ]}):
		filters.append({'id_class':res['doc']['ware_class'], 'title':ct(res['doc']['title'])})
	# users = [doc._id for doc in db.doc.find({"doc_type":'des:ware_filter', 'group': {'$all': ['administrator']}})]
	users = [doc._id for doc in db.doc.find({"doc_type":'des:ware_filter', 'group': {'$all': ['administrator']}})]
	articles = db.doc.find({"doc_type":'blogs', 'user': {'$in': users}})
	return filters


def first_cls(request):
	""" выводит корневые категории, в основном для главной страницы """
	from libs.sites.sites import get_full_docs, get_curr_img
	from libs.files.files import get_nf
	db = request.db; docs = []
	for doc in db.doc.find({'doc_type':'des:ware_class', 'parent':'_'}).sort('doc.date', -1):
		proc_id = doc['doc_type']
		attachment = get_nf(proc_id, doc['_id'], 1)
		data = doc['doc']
		try:
			count = count_ware(doc['_id'])
		except: count = '1'
		full_doc = {"_id":doc['_id'], "id": doc['_id'],
		            'count':count,
		            "doc": data,
		            "att": attachment, "img":get_curr_img(doc, attachment), 'proc_id':proc_id}
		docs.append(full_doc)

	return docs

def list_ware_cls(request, full=False):
	"""
	получение колва докуентов
	 Для каждого класса находим сколько в нем документов
	 Назначаем их кол-во всем его родителям приплюсовыванием
	 :param выводить с дополнительной информацией типа картинок или просто названия, с доп. информацией выводится олько для главной
	"""
	db = request.db
	docs = [res for res in db.doc.find({'doc_type':'des:ware_class'}, {'doc.title.ru':1, 'doc.alias':1, 'parent':1, 'child':1 }).sort('doc.date', -1) ]
	# docs = [res for res in db.doc.find({'doc_type':'des:ware_class'}).sort('doc.date', -1) ]
	if full:
		docs = [res for res in db.doc.find({'doc_type':'des:ware_class'}).sort('doc.date', -1) ]
		from libs.sites.sites import get_full_docs
		docs = get_full_docs(docs)
	return form_tree_( docs )
	# return docs

# def form_tree_(docs):
# 	tree = {doc['_id']: doc for doc in docs}
# 	for doc in docs:
# 		if "child" in doc and doc['child'] != '_':
# 			doc['child'] = [tree[id] for id in doc['child']]
# 	docss = {"_id": "_", "child": [doc for doc in docs if "parent" not in doc or doc['parent']=='_']}
# 	return docss


def form_tree_(docs):
	""" формирует из документов дерево
	"""
	tree = {doc['_id']: doc for doc in docs}
	for doc in docs:
		doc['child'] = []
	for doc in docs:
		parent = doc.get("parent", None)
		if parent and parent != '_':
			tree[parent]['child'].append(doc)
	docss = {"_id": "_", "child": [doc for doc in docs if "parent" not in doc or doc['parent'] == '_']}
	return docss
# ======================================================================================================================
# ======================================================================================================================
# ======================================================================================================================


def list_orders(request):
	from libs.sites.sites import get_full_docs
	db = request.db
	# web_order = db.doc.find({'doc_type':'web_order'})
	# web_order_ware = db.doc.find({'doc_type':'web_order_ware'})
	web_order = get_full_docs(db.doc.find({'doc_type':'des:web_order'}).limit(60).sort('doc.date', -1))
	web_order_ware = get_full_docs(db.doc.find({'doc_type':'des:web_order_ware'}).limit(60).sort('doc.date', -1))
	ware = get_full_docs(db.doc.find({'doc_type':'des:ware'}).limit(60).sort('doc.date', -1))
	return templ('libs.shop:list_orders', request, dict(web_order = web_order, web_order_ware = web_order_ware, ware=ware))


def callback_post():
	phone = get_post('phone')
	basket = get_post('basket', '')
	dom = get_settings('domain')
	return callback(phone, dom, basket)

def callback(phone, dom, basket):
	""" отправка sms с почты на телефон
	"""
	# phone = get_post('phone')
	# dom = get_settings('domain')
	# mail = 'nextnn.la@yandex.ru'
	# mail = 'nexusnnn@rambler.ru'
	# mail = 'nexusnn@mail.ru'
	# mail = get_const_value('callback_mail')
	mail = get_settings('callback_mail')
	create_row('des:phone', '_', defaults={'phone':phone})
	text = u""" {0} """.format( phone )
	if basket == 'true':
		route_mail(mail, u'Cайт корзина ', text)
	else:
		route_mail(mail, u'Запрос на сайте ', text)
	# text = u""" {0} -> {1}""".format( dom, phone )
	# route_mail(mail, u'Запрос на сайте '+dom, text)
	return {"result":"ok"}







