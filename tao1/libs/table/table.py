import json, cgi, sys

from settings import *
from datetime import datetime, timedelta

from core.core import *
from urllib import *
from math import *
from copy import deepcopy
from uuid import uuid4

from libs.contents.contents import *
from libs.perm.perm import is_admin, user_has_permission
# from libs.perm.perm import *
from core.union import response_json, response_string
import html



def table_data(request):
	"""
	при отрисовке вкладки при нажатии кнопки рефреш, в admin.js там в update_tab
	берем из модели которая в свою очередь берет из закладки  какойто id номер вкладки
	и по роуту вызывается эта функция.
	"""
	proc_id = request.match_info.get('proc_id')
	data = table_data_(request, proc_id)
	return templ('libs.table:main', request, dict(parts = data['parts'], hdata = data['hdata'], map_ = data['map_'], url = data['url'], proc_id = data['proc_id'], select_id =data['select_id']) )


def table_data_(request, proc_id):
	if get_const_value( request, 'is_admin') == "false" and not is_admin(request): return redirect('/')
	data = get_post( request )
	select_id = data['select_id'] if 'select_id' in data else None

	url = ''
	meta_doc = get_mt(request, proc_id)

	meta_table = check_map_perm(request, proc_id, meta_doc['doc'])
	#это для интернационализации
	parts = []
	# строим иерархию по шапкам
	for res in request.db.map.find({"conf.owner": proc_id}):
		parts.append(res)
	_parts = ""
	for tbl in parts:
		if _parts: _parts+=", "
		tp = 'table'; conf = {}
		if 'com:' == tbl['_id'][0:4]: tp = 'comments'
		if tp == 'table':
			conf['columns'] = rec_data_t(request, tbl['doc'])
		conf_ = ""
		for k in conf:
			if conf_: conf_ += ", "
			conf_ +='"' + k + '": '+ conf[k]
		conf_ = "{"+conf_+"}"
		_parts += '{"id": "' + tbl['_id'] + '", "title": "' + \
		          ct(request, tbl['conf']['title']) + '", "conf": ' + conf_ + ', "type": "' + tp + '" }'
	_parts = "["+_parts+"]"
	map_ = rec_data_t(request, meta_table)
	return  {'parts':_parts, 'hdata':meta_doc, 'map_':map_, 'url':url, 'proc_id':proc_id, 'select_id':select_id}


def rec_data_t(request, meta_table):
	# """подсчет полей таблицы чтоли"""
	for res in range(0, len(meta_table)):
		meta_table[res]['title'] = ct(request, meta_table[res]['title'])
		meta_table[res]['hint'] = ct(request, meta_table[res]['hint'])
	map_ = ""
	for key in meta_table:
		if map_:
			map_+=", "
		map_ +='"'+key['id']+'": '+ json.dumps(key)
	map_ = "{"+map_+"}"
	return map_


def sort_body(request, proc_id, meta_table, docs_table):
	"""
	проодит по всем документам, если документ переводной то переводит
	И в зависимости от типа документа рисует соотвествующее значение в ячейке
	:param proc_id:
	:param meta_table:
	:param docs_table:
	:return:
	"""
	from libs.files.files import get_nf
	out_docs = []
	for res in docs_table: #проходим по всем документам
		doc = res['doc']
		for field in meta_table:
			if field['id'] in doc and 'is_translate' in field and field['is_translate']:
				lang = cur_lang(request)
				doc[field['id']] = ct(request, doc[field['id']], lang )
		doc_id = res['_id']; sorted_doc = []; parent = '_'; child= []
		if 'parent' in res and res['parent']: parent = res['parent']
		if 'child' in res and res['child']: child = res['child']
		for key in meta_table:
			if key['id'] in doc:
				select_id = doc[key['id']]
				if 'type' in key and key['type'] == 'checkbox':
					edit_value = doc[key['id']]
					icon = 'fa-check' if doc[key['id']] == 'true' else 'fa-close'
					color = 'green' if doc[key['id']] == 'true' else 'red'
					formatted = "<i style='color:"+color+"; font-size:16px' class='fa "+icon+"'></i>"
				elif 'type' in key and key['type'] == 'passw':
					edit_value = '*****'; formatted = '*****'
				elif 'type' in key and key['type'] == 'html':
					edit_value = ''; formatted = doc[key['id']][:100]
				elif 'type' in key and key['type'] == 'rich_edit':
					edit_value = ''
					formatted = cgi.escape(doc[key['id']][:100], True)
				elif 'type' in key and key['type'] == 'select':
					sel = request.db.doc.find_one({'_id':select_id})
					if sel:
						edit_value = doc[key['id']]
						formatted = cgi.escape(get_doc_title(request, sel, '[%s]' % edit_value))
						edit_value = cgi.escape(edit_value, True)
					else:
						edit_value = ''; formatted = '-'
				else:
					edit_value = html.escape(str(doc[key['id']]), True)
					formatted = html.escape(str(doc[key['id']]))
			else:
				edit_value = ''; formatted = ''
			sorted_doc.append({"id":key['id'], "edit_value":edit_value, "formatted":formatted})

		out_docs.append({"id":doc_id, "doc":sorted_doc, "parent":parent, "child":child, "imgs": get_nf(request, proc_id, doc_id, 2)})
	return out_docs


async def table_data_post(request):
	""" #page=текущая страница page ctr=кол-во pages=отрисованые ссылки на страницу навигация """
	data = get_post(request)
	proc_id = data['proc_id']
	if not user_has_permission(request, proc_id, 'view'):  return {"result": "fail", "error": "You have no permission." }
	filtered = json.loads(data['filter'])
	doc_id = data['doc_id'] if 'doc_id' in data else '_'
	parent = data['parent'] if 'parent' in data else '_'
	id_next = None; id_prev = None
	if 'page' in filtered: page = filtered['page']
	else: page = {'current':1}
	limit = int(get_const_value(request, 'doc_page_limit'))
	bdata, docs_table_count = table_data_post_(request, proc_id, filtered, doc_id, parent)
	otvet = {"result":"ok", "data":bdata,
	         "pages":{"count":int(ceil(float(docs_table_count)/limit)),
			 "current":page['current'], "next": id_next, "prev":id_prev} }
	return response_json(request, otvet)


def table_data_post_(request, proc_id, filter, doc_id, parent, no_limit=False):
	""" Получает id таблицы и значения для фильтрации Берет из базы данные 
	формирует из них json и возвращает в нужный шаблон"""
	t = time.time()
	user_name = get_current_user(request)
	meta_doc = request.db.map.find_one({'_id':proc_id})
	meta_table = check_map_perm(request, proc_id, meta_doc['doc'])
	start_date = ''; end_date = '9999999999999999999999999'
	if 'date' in filter: 
		if 'start' in filter['date']: start_date = filter['date']['start'] 
		if 'end' in filter['date']: end_date = filter['date']['end'] + ' 99999999'
	if 'branch_id' in filter: branch_id = filter['branch_id']
	else: branch_id = None
	if 'page' in filter: page = filter['page']
	else: page = {}
	if not 'current' in page:
		page['current'] = 1
	limit = int(get_const_value(request, 'doc_page_limit'))
	skip = (page['current']-1)*limit
	#получаем данные из фильтров и присваиваем их нужной переменой
	condition = {'$and': [{'doc_type':proc_id}]}
#	condition = {'doc_type':proc_id, 'parent':{'$or':(parent)}
	if parent == '_':
		condition['$and'].append({'$or': ({'parent': '_'}, {'parent': {'$exists': 0}} )})
	else:
		condition['$and'].append({'parent': parent })
		no_limit = True
	_meta_table = {}
	#это для получение полного метатейбла с полем user чтоб по нему фильтровать.
	for meta in meta_doc['doc']:
		_meta_table[meta['id']] = meta
	user_in_meta = 'user' in _meta_table
	# это получение уже обрезаного мета тейбла.
	_meta_table = {}
	for meta in meta_table:
		_meta_table[meta['id']] = meta
	
	if doc_id != '_':	
		condition['$and'].append({'owner': doc_id})
	if 'date' in meta_table:
		condition['$and'].append({'doc.date': {'$gte': start_date, '$lte': end_date}})
	if user_in_meta and not is_admin(request) and get_const_value(request, 'user_self') == 'yes' :
		condition['$and'].append({'doc.user': "user:"+user_name})

	if not 'main' in filter or any(filter['main']) == False and any(filter['column'])==False and (branch_id is None):
		pass
	elif 'main' in filter and any(filter['main']):
		regex = re.compile(u'%s' % filter['main'], re.I | re.UNICODE )
		ors = []
		for field in _meta_table:
			suffix = ''
			if 'is_translate' in _meta_table[field] and _meta_table[field]['is_translate']:
				suffix = '.' + cur_lang(request)
			ors.append({'doc.' + field + suffix: regex})
		condition['$and'].append({'$or': ors})
	elif 'column' in filter and any(filter['column']): #фильтр по колонкам
		for field in filter['column']:
			f = filter['column'][field]
			if not 'val' in f and not 'range' in f: continue
			if _meta_table[field]['type'] == 'date':
				condition['$and'].append({'doc.' + field: {'$gte':f['range']['from'], '$lt':f['range']['to'] }})
				continue
			regex = re.compile(u'%s' % str(f['val']), re.I | re.UNICODE)
			suffix = ''
			if 'is_translate' in _meta_table[field] and (_meta_table[field]['is_translate'] == "true" or
					                                             _meta_table[field]['is_translate'] == True):
				suffix = '.' + cur_lang(request)
			if _meta_table[field]['type'] == 'select':
				suffix = '.' + cur_lang(request)
				ids= []
				rel = _meta_table[field]['relation']
				for res in request.db.doc.find({"doc_type":rel, 'doc.'+('name' if rel == 'des:users' else 'title') + suffix: regex }):
					ids.append(res['_id'])
				condition['$and'].append({'doc.' + field:  {'$in':ids}})
			else:
				if 'str_option' in f and f['str_option'] == 'eq':
					condition['$and'].append({'doc.' + field + suffix: f['val']})
				else:
					regex = re.compile('%s%s%s' % ( ('^' if 'str_option' in f and f['str_option'] == 'start' else ''), f['val'],
					                                (('$' if 'str_option' in f and  f['str_option'] == 'end'  else ''))), re.I | re.UNICODE)
					condition['$and'].append({'doc.' + field + suffix: regex})

	#is_ajax = request.header.get('X-Requested-With') == 'XMLHttpRequest'
	docs_table_count = request.db.doc.find(condition).count()
	docs_table = None
	if no_limit:
		docs_table = request.db.doc.find(condition).sort('doc.date', -1)
	else:
		docs_table = request.db.doc.find(condition).sort('doc.date', -1).skip(skip).limit(limit)
	return list( sort_body(request, proc_id, meta_table, docs_table) ),   docs_table_count


def create_date():
	return time.strftime("%Y-%m-%d %H:%M:%S")

p = print

def table_add_row_post(request):
	data      = get_post(request)
	proc_id   = data['proc_id']
	owner     = data.get('owner', None)
	# defaults  = json.loads(data['defaults'] if 'defaults' in data else {})

	auto_fill = data.get('auto_fill', False)

	if not user_has_permission(request, proc_id, 'create'):
		return response_json(request, {"result": "fail", "error": "You have no permission."})
	try:
		doc_id, updated = create_empty_row_(request, proc_id, owner, auto_fill)   # update_row_(proc_id, doc_id, {})
		if doc_id:
			return response_json(request, {"result":"ok", "id":doc_id, "updated": updated})
		else:
			return response_json(request, {"result":"fail", "descr":"not doc_id", "error":json.dumps(updated)})
	except Exception as e:
		return response_json(request, {"result":"fail", "descr":"exception", "error": e})


checkout_error = 'You can not modify the posted document'
def create_empty_row_(request, proc_id, owner, auto_fill, defaults={}, clear_id=True, id=None):
	if not id: id = uuid4().hex
	user = defaults['user'] if 'user' in defaults else get_current_user(request, True)
	date = defaults['date'] if 'date' in defaults else create_date()
	doc_type =  ': ' if clear_id else proc_id, # if you create a document that has been canceled then set :
	doc_s = {"_id":id, "doc": {'date':date, 'rev':uuid4().hex[-9:], "last_art":"true", 'user':user},
	         "type": "table_row", "seq_id":0, 'tags':{}, "doc_type":doc_type,  "owner":owner if owner else '_'}

	doc_s['doc'].update(defaults)

	res = 'ok'; err=''

	if res != 'ok': return {"result":"fail", "error":json.dumps(err) }

	doc_id= request.db.doc.save(doc_s)
	updated = make_updated(request, {}, doc_s['doc'], proc_id)
	if res == 'ok' and doc_s['owner'] != '_':
		print('doc_s', doc_s)
		res, err = on_create_subtable(request, doc_s)
		if res != 'ok': return None, err
	return doc_id, updated


def create_row(request, proc_id, owner, defaults={}):
	doc_id, updated = create_empty_row_(request, proc_id, owner, '', {})
	import time
	time.sleep(0.1)

	update_row_(request, proc_id, doc_id, defaults, '_', no_synh=True)
	return doc_id


def set_val_field(request, doc_id, field={}):
	doc = get_doc(request, doc_id)
	proc_id = doc['doc_type']
	mt = get_mt(request, proc_id)
	k = field.keys()[0]
	v = field[k]
	if not k in [f['id'] for f in mt['doc']]:
		data = {'hint_ru':'', 'hint_en':'','title_ru':k, 'title_en':k, "visible":'true', "oncreate":'edit',
				"type": 'string', 'is_editable':'true', "id":k, 'is_translate':'false'}
		add_field(request, proc_id, data, field_id=None)
	doc['doc'][k] = v
	request.db.doc.save(doc)


def table_get_row_post(request):
	data = get_post(request)
	row_id = data['row_id']
	proc_id = data['proc_id']
	doc = get_doc(request, row_id)
	if not proc_id: proc_id = doc['doc_type']
	doc_id, updated = create_empty_row_(request, proc_id, False, False, defaults={}, clear_id=True)

	updated = make_updated(request, {}, doc['doc'], doc['doc_type'])
	return response_json(request, {"result":"ok", "updated":updated, "row_id": doc_id })


def table_preedit_row_post(request):
	data = get_post(request)
	doc = get_doc(request, data['doc_id'])
	return response_json(request, {"result":"ok", "doc":{
		'title': ct(request, doc['doc']['title']), 'body': ct(request, doc['doc']['body']), 'date': doc['doc']['date']}} )




def save_auto_tags(request, doc, tags):
	"""
		автоопределение тегов  получаем текст и сравниваем его с с теми тегами которые уже есть и вычленяем их из него
		работает только для новостей
		1) разбиваем строчку с тегами через запятую и создаем словарь из всего этого
		2) находим документ с облаком тегов
		3) получаем текст и название новости плюсуем
		4) и выводим отсюда тег нужный
	"""
	try:
		if not doc['doc_type'] in ['des:news']: return 'not des:news'
		if 'tags' in doc['doc'] and doc['doc']['tags']:
			text_tags = dict([(i.strip().lower(), 1) for i in doc['doc']['tags'][cur_lang(request)].split(',') if i.strip()])
		else: text_tags = {}
		tags = request.db.conf.find_one({"_id":tags })
	#	doc_doc = defaultdict(doc['doc'])
		title = doc['doc']['title'][cur_lang(request)] if 'title' in doc['doc'] else ''
		descr = doc['doc']['descr'][cur_lang(request)] if 'descr' in doc['doc'] else ''
		body = doc['doc']['body'][cur_lang(request)] if 'body' in doc['doc'] else ''
		try: text = ' '.join([title, descr, body.decode('UTF-8')])
		except: text = ' '.join([title, descr, body])
		text = text.lower()
		for res in tags['tags'][cur_lang(request)]:
			if ' ' in res[0]: checked = res[0] in text
			else: checked = res[0].encode('UTF-8') in text.split(' \n\t\r.,:;!?%"\'')
			if checked: text_tags[res[0]] = 1

		doc['doc']['tags'][cur_lang(request)] = ', '.join(text_tags.keys())
	except: pass


def count_tags(request, t, t_old, tag_dict):
	""" при сохранении документа пересчитать кол-во тегов в облаке t-скорее всего тег
		вызывается в save_tags
		1) получает документ где хранится облако тегов
		2) идем по тегам и если есть
	"""
	tags = request.db.conf.find_one({"_id":'tags_'+tag_dict[4:]})  # получает документ где хранится облако тегов
	tags = tags['tags'][cur_lang(request)] if tags and 'tags' in tags and cur_lang(request) in tags['tags'] else []
	tags_d = dict(tags)
	for res in t:
		if not res in tags_d: tags_d[res] = 1 #если нету полученого в тегах документа    то прописуем там
		else: tags_d[res] += 1
	for res in t_old:
		if res in tags_d:
			tags_d[res] -= 1
			if tags_d[res] == 0: del tags_d[res]
	tags = [ (res, tags_d[res]) for res in tags_d]
	request.db.conf.save( {"_id":'tags_'+tag_dict[4:],"tags":{cur_lang(request):tags}} )

def save_tags(request, doc, tag_dict):
	"""
	разбиваем строчку тегов в масив и заносим в документ правильно разбитые теги
	call the function that fills in the tag cloud
	tag_dict - справочник из которого теги сохраняются   вроде как удалено из текста
	1) check that the document contains tags
	2) разбиваем строку тегов на слова через запятую и запихиваем в словарь tags = {'tag1':1,'tag2':1}
	"""
	# TODO если теги пустые то мы их не стираем
	lang = cur_lang(request)
	if 'doc' in doc and doc['doc'] and 'tags' in doc['doc'] and doc['doc']['tags']:
		if lang in doc['doc']['tags']:
			if not doc['doc']['tags'][lang]: doc['doc']['tags'][lang] = ''
			t_old = doc['tags'][lang] if 'tags' in doc and lang in doc['tags'] else []
			# разбиваем строку тегов на слова через и запихиваем в словарь tags = {'123':1, '456':1}
			tags = dict([(i.strip().lower(), 1) for i in doc['doc']['tags'][lang].split(',') if i.strip()])
			if not 'tags' in doc: doc['tags'] = {}
			if not is_admin(request) and not user_has_permission(request, doc['doc_type'], 'edit_tag'):
				# наполняем в ифе tags теми перемеными которые не содержат звездочки.
				tags2 = tags; tags = {}
				for res in tags2:
					if not '*' in res:
						tags[res] = tags2[res]
			doc['tags'][lang] = tags
			if doc['doc_type'] in ['des:news', 'des:obj', 'des:banners', 'des:wiki']:
				if 'pub' in doc['doc'] and doc['doc']['pub'] == 'true':
					if 'accept' in doc['doc'] and doc['doc']['accept'] == 'true' or doc['doc_type'] in ['des:banners', 'des:wiki', 'des:news']:
						count_tags(request, tags, t_old, doc['doc_type'])
			elif doc['doc_type'] in ['des:ware']:
				count_tags(request, tags, t_old, doc['doc_type'])
			doc['doc']['tags'][lang] = ', '.join(tags)
			request.db.doc.save(doc)


async def table_update_row_post(request):
	proc_id = request.match_info.get('proc_id')
	force = request.match_info.get('force', False)
	if not force and not user_has_permission(request, proc_id, 'create'):
		return {"result": "fail", "error": "You have no permission."}
	data = get_post(request)
	row_id = data['row_id']
	# print('parent', data['parent'])


	parent = data['parent'] if  'parent' in data else '_'
	data = json.loads(data['data'])
	print( 'data', data )
	if 'rev' in data:
		del data['rev']

	return response_json(request, update_row_(request, proc_id, row_id, data, parent = parent) )


def update_row_(request, proc_id, doc_id, data, parent, noscript=True, no_synh=False, accept_def=False, no_notify=False):
	"""
	:param nouscript:  удаляет теги и стили из текста вроде
	:param no_synh:    не синхронизирует с фейсбуком
	:param accept_def: не публикует документ автоматически, нужно для всяких парсеров
	:param no_notify:
	:return: json format doc[id] proc_id   doc_ = {'body':wiki(body), 'date':date, 'title':title }
	"""

	print('parent', parent)

	doc_meta = get_mt(request, proc_id)
	meta_table = doc_meta['doc']
	doc = get_doc(request, doc_id)
	doc_parent = get_doc(request, parent) if parent != '_' else None
	user = request.db.doc.find_one({'_id':doc['doc']['user']})
	old_row = dict(doc['doc']) # doc из документа который создан create_empty_row_
	#=============================================================================================================================
	for field in meta_table:  # инициализируем поля и устраняем всякие глюки если чегото нет
		if 'is_translate' in field and (field['is_translate'] == True or field['is_translate'] == "true"):
			if not field['id'] in doc["doc"] or type(doc['doc'][field['id']]) != dict: # если в старой записи нет поля или оно не словарь
				doc["doc"][field['id']] = {}
			if not field['id'] in data:  # этот иф можно закоментировать     проверить     если поля нет в новой записи
				data[field['id']] = old_row[field['id']][cur_lang(request)] if field['id'] in old_row and old_row[field['id']] and cur_lang(request) in old_row[field['id']] else ''
			doc["doc"][field['id']][cur_lang(request)] = data[field['id']]
		else:
			if field['oncreate'] == 'edit':
				if not field['id'] in data:
					data[field['id']] = ''
				else:
					doc["doc"][field['id']] = data[field['id']]

	#===================================================================================================================
	if 'body' in doc['doc']:    # очищаем  боди от всякой ерунды
		text = doc['doc']['body'][cur_lang(request)] if  type(doc['doc']['body']) == dict else doc['doc']['body']
		text = re.sub(r'<!--(.|\n)*?-->', '', text)
#		if noscript or True: #==========================================================================================
		if noscript and not is_admin(request):
			text = no_script(text, True)
		if type(doc['doc']['body'] ) == dict:
			doc['doc']['body'][cur_lang(request)] = text
		else: doc['doc']['body'] = text

	#===================================================================================================================
	# if res == 'ok':  # если поле
	doc['doc_type'] = proc_id
#		if not is_admin:


	#сохранение единственого материала для отображения единственого автора в колонке
	if 'last_art' in doc['doc'] and  doc['doc']['last_art'] == 'true':
		for res in request.db.doc.find({'doc_type':proc_id, 'doc.user':doc['doc']['user'], 'doc.last_art':'true'}):
#			for res in db.doc.find({'doc_type':{'$ne':':'}, 'doc.user':doc['doc']['user'], 'doc.last_art':'true'}):
			res['doc']['last_art'] = 'false'
			request.db.doc.save(res)
	#сохранение для разрешенного пользователя
	if is_admin(request) or accept_def or proc_id == 'des:obj' and 'accept' in user['doc'] and user['doc']['accept'] == 'true':
		doc['doc']['accept'] = 'true'
	else: doc['doc']['accept'] = 'false'

	save_auto_tags(request, doc,'tags_'+proc_id[4:]) # автоопределение тегов  получаем текст и сравниваем его с с теми тегами которые уже есть и вычленяем их из него
	save_tags(request, doc, 'tags_'+proc_id[4:])

	#сохранение для разрешенного пользователя
	if accept_def or proc_id == 'des:obj' and 'primary' in user['doc'] and user['doc']['primary'] == 'true':
		doc['doc']['primary'] = 'true'
	else: doc['doc']['primary'] = 'false'

	if 'parent_id' in data and data['parent_id']:
		parent_id = data['parent_id']
		# Удаляем из старого родителя
		request.db.doc.update({'child':{'$in':[doc_id]}}, {'$pull':{'child':doc_id}})
		# Добавляем в нового родителя
		# if parent_id !='_': db.doc.update({'_id':parent_id}, {'$push':{'child':doc_id}})
		request.db.doc.update({'_id':parent_id}, {'$push':{'child':doc_id}})
		# Добавляем себе нового родителя
		doc['parent'] = parent_id
	else:
		doc['parent'] = parent
		if doc_parent: # тут мы получили родительский документ и смотрим если в нем нет себя ребенка то мы себя заносим
			if not 'child' in doc_parent: doc_parent['child'] = []
			doc_parent['child'].append(doc_id)
			request.db.doc.save(doc_parent)

	request.db.doc.update({'_id':doc_id}, doc)

	# =======================================================================
	res, err = event('on_update_row', proc_id, doc_id)
	if res != 'ok': return {"result":"fail", "error":json.dumps(err)}
	# =======================================================================

	doc['final'] = 1

	from core.core import get_settings

	if get_settings('notify_user', False) and check_pub_doc(doc) and proc_id in ['des:obj', 'des:radio', 'des:comments']: subscribe(doc)
	if not no_notify and get_settings('notify_admin', False) and proc_id in ['des:obj', 'des:radio', 'des:comments']: notify_admin(doc)


	if res == 'ok' and 'owner' in doc and doc['owner'] != '_':
		on_update_subtable(request, doc)

	from core.union import clean_cache
	from libs.sites.sites import wiki
	clean_cache(doc)

	doc_ = {'body':wiki(request, ct(request, doc['doc']['body'])), 'date':doc['doc']['date'], 'title':ct(request, doc['doc']['title']) }
	return {"result":"ok", "doc_id":doc['_id'], "proc_id":proc_id, "updated":"", "doc":doc_}


def check_pub_doc(doc, need_accept = True):
	if doc['doc_type'] != 'des:comments':
		return 'pub' in doc['doc'] and doc['doc']['pub'] == 'true' and (not need_accept or 'accept' in doc['doc'] and doc['doc']['accept'] == 'true')
	return True


def check_type_subscribe(doc):
	if doc['doc_type'] == 'des:comments': return 'sub_answ_comm'
	return 'sub_alien'


def subscribe(request, doc):
	if 'mail_sent' in doc:
		return
	doc['mail_sent'] = 1
	request.db.doc.save(doc)
	t = check_type_subscribe(doc)
	cond = {'doc_type':'des:users', 'subscription.'+t:'true'}
	try:
		if t == 'sub_answ_comm': cond['_id'] = doc['doc']['parent_comm']
	except: cond['_id'] = '_'
	author = get_doc(doc['doc']['user'])
	title = ''
	if 'title' in doc['doc']: title = ct(request, doc['doc']['title'])
	for res in request.db.doc.find(cond):
		if not 'mail' in res['doc']: continue
		to = res['doc']['mail']
		dom = get_settings('domain')
		if t == 'sub_answ_comm':
			link = 'http://'+dom+'/news/'+doc['doc']['owner']+'#comm_'+str(doc['doc']['comm_id'])
			text = u"""<html><head></head><body>
			<p>Пользователь {0} оставил ответ на ваш комментарий. Можете просмотреть по адресу {1}
			</p></body></html>""".format( ct(request, author['doc']['name']), link)
		else:
			link = 'http://'+dom+'/news/'+doc['doc']['rev']
			text = u"""<html><head></head><body>
			<p>Пользователь {0} разместил новый материал. <a href="{0}"><b>{2}</b></a></p>
			<p>Можете просмотреть по адресу {1} </p></body></html>""".format( ct(request, author['doc']['name']), link, title)
		from core.core import route_mail
		route_mail(request, to, u'Новые материалы на сайте '+dom, text)


def notify_admin(request, doc):
	if 'mail_admin_sent' in doc: return
	doc['mail_admin_sent'] = 1
	request.db.doc.save(doc)
	author = get_doc(request, doc['doc']['user'])
	author_name = ct(request, author['doc']['name']) if author else u'Аноним'
	from core.core import get_admin
	try:
		to = get_admin(request, True)['doc']['mail']
		text = ''
		domain = get_settings('domain')
		if get_const_value(request, 'only_closed_news', 'false') == 'true':
			if doc['doc_type'] == 'des:obj' and (not 'accept' in author['doc'] or author['doc']['accept'] == 'false'):
				link = 'http://'+domain+'/news/'+doc['doc']['rev']
				text = 'Не удостовереный Пользователь {0} разместил новый материал. Можете просмотреть по адресу {1}'.format( ct(request, author['doc']['name']), link)
		else:
			if doc['doc_type'] == 'des:comments':
				link = 'http://'+domain+'/news/'+doc['doc']['owner']+'#comm_'+str(doc['doc']['comm_id'])
				text = u'Пользователь {0} оставил комментарий. Можете просмотреть по адресу {1}'.format(request, author_name, link)
			else:
				link = 'http://'+domain+'/news/'+doc['doc']['rev']
				text = u'Пользователь {0} разместил новый материал. Можете просмотреть по адресу {1}'.format( ct(request, author['doc']['name']), link)
		from core.core import route_mail
		if text:
			route_mail(request, to, u'Новые материалы на сайте '+domain, text)
	except:
		pass


def check_map_perm(request, proc_id, meta_table, permission = 'view'):
	meta = []
	for i in meta_table:
		if user_has_permission(request, proc_id, permission, i['id']):
			meta.append(i)
	return meta


def find_field(idd, meta_table):
	for field in meta_table:
		if field['id'] == idd:
			return field
	return None


def table_update_cell_post(request):
	proc_id = request.match_info.get('proc_id')
	if not user_has_permission(request, proc_id, 'edit'):
		return {"result": "fail", "error": "You have no permission."}
	data = get_post(request)
	idd = data['id']
	field = data['field']
	value = unquote( data['value'] )
	return response_json(request, update_cell(request, idd, proc_id, field, value) )


def update_cell(request, idd, proc_id, field, value):
	meta_doc = get_mt(request, proc_id)

	meta_table = meta_doc['doc']
	doc = get_doc(request, idd)

	meta = find_field(field, meta_table)
	if meta is None: return {"result":"fail", "error":"there is not such field " + field }

	if 'is_translate' in meta and (meta['is_translate'] == "true" or meta['is_translate'] == True):
		if not field in doc["doc"] or type(doc["doc"][field]) != dict:
			doc["doc"][field] = {}
		doc["doc"][field][cur_lang(request)] = value
	else:
		doc["doc"][field] = value

	request.db.doc.save(doc)
	if proc_id == 'des:news':
		save_auto_tags(request, doc,'tags_'+proc_id[4:])
	save_tags(request, doc, 'tags_'+proc_id[4:])

	updated = updated_edit_cell(request, field, value, proc_id)

	res, err = event('on_update_row', proc_id, idd)

	if res != 'ok': return {"result":"fail", "error":json.dumps(err) }
	otvet = {"result":"ok", "updated": updated }
	if 'owner' in doc and doc['owner'] != '_':
		on_update_subtable(request, doc)
	return otvet


def updated_edit_cell(request, field, value, proc_id):
	"""compares the old and the new value and returns the fields that are changed """
	meta_table = get_mt(request, proc_id)['doc']; updated = ''; meta = {}
	for res in meta_table:
		if field in res.get('id'): meta = res
	if 'type' in meta:
		if meta['type'] == 'passw':
			v = '*****'; formatted = '*****'
		elif meta['type'] == 'checkbox':
			v = str(value)
			if v == 'true':
				color = 'green'; icon = 'fa-check'
			else:
				color = 'red'; icon = 'fa-close'
			formatted = "<span style='color:"+color+"; font-size:16px'><i class='fa "+icon+"'></i></span>"
		elif meta['type'] == 'select':
			v = str(value)
			aaa = get_doc(request, v)
			if aaa: formatted = html.escape(get_doc_title(request, aaa, '[{}]'.format(v) ))
			else: formatted = '-'
		elif meta['type'] == 'cascad_select':
			v = str(value)
			aaa = get_doc(request, v)
			if aaa: formatted = html.escape(get_doc_title_cascad(request, aaa, '[{}]'.format(v) ))
			else: formatted = '-'
		else:
			formatted = value
			v = value
		t = type(v)
		if t == int or t == float or meta['type'] == 'checkbox':
			updated  = { "formatted":formatted, "value":v, 'field_name':field }
		else:
			updated =  { "formatted":formatted, "value": v, 'field_name':field  }
	return updated


def on_update_subtable(request, doc):
	owner = get_doc(request, doc['owner']) # parent doc
	res = 'ok'; err=''
	if res != 'ok': return {"result":"fail", "error":json.dumps(err)}
	request.db.doc.save(owner)
	return 'ok', None


def on_create_subtable(request, doc):
	owner = get_doc(request, doc['owner'])
	print('owner ', owner )
	request.db.doc.save(owner)
	return 'ok', None


def make_updated(request, old_row, new_row, proc_id):
	"""сравнивает старое и новое значеие и возвращает те поля которое изменились  это для изменения всей строки"""
	updated = ''
	meta_table = get_mt(request, proc_id)['doc']
	for k, v in new_row.items():
		if not k in old_row or old_row[k] != v:
			meta = find_field(k, meta_table)
			# преобразовуем название если в поле есть селект 
			if meta and 'type' in meta and meta['type'] == 'passw': 
				v = '*****'; formatted = '*****'
			elif meta and 'type' in meta and meta['type'] == 'checkbox': 
				v = str(v)
				if v == 'true':
					color = 'green'; icon = 'fa-check'
				else:
					color = 'red'; icon = 'fa-close'
				formatted = json.dumps("<span style='color:"+color+"; font-size:16px'><i class='fa "+icon+"'></i></span>")[1:-1]
			elif meta and 'type' in meta and meta['type'] == 'select':
				v = str(v)
				doc = get_doc(request, v)
				if doc: formatted = cgi.escape(get_doc_title(request, doc, '[{}]'.format(v) ))
				else: formatted = '-'
			elif meta and 'type' in meta and meta['type'] == 'cascad_select':
				v = str(v)
				doc = get_doc(request, v)
				if doc: formatted = cgi.escape(get_doc_title_cascad(request, doc, '[{}]'.format(v) ))
				else: formatted = '-'
			else: formatted = ct(request, v)
			if updated: updated += ', '
			# поле int нужно преобразовывать шif type(aaa) == 'int'
			t = type(v)
			if t == int or t == float or meta and 'type' in meta and meta['type'] == 'checkbox':
				updated += '"'+k+'": {"formatted": "%s", "value":"%s"}' % (formatted, v)
			else:
				updated += '"'+k+'":{"formatted": %s, "value": %s}' % (json.dumps(formatted), json.dumps(ct(request, v)))
	updated = '{'+updated+'}'

	return updated


async def table_del_row_post(request):
	data = await request.post()
	# proc_id = data['proc_id'] if 'proc_id' in data else None
	proc_id = data.get('proc_id')
	force = data.get('force', False)
	ids =   data.get('ids')
	ids =   json.loads( ids )
	idsn =  data.get('idsn')
	idsn =  json.loads(idsn)

	print( "4444", data['idsn'])

	for doc in request.db.doc.find({'_id': {'$in': idsn}}):
		final = False
		if not 'final' in doc: final = True
		# запрещаем не админу удалять документы созданые админом
		if not force and final and not user_has_permission(request, proc_id, 'delete') or not is_admin(request):
			return {"result": "fail", "error": "You have no permission."}
	return del_row(request, proc_id, ids)


def del_row(request, proc_id, ids):
	""" Удаление документа
		1) Идем по всем полученым для удаления ids
		2) Делаем какието операции с бугалтерией
		3) Удаляем картинки приатаченый к этому документу
		4) Удаляем сам документ
		5) Выполняем тригер в песочнице связаный с удалением этого документа
		============================================================================
		6) Удаляем себя у всех потомков
		7) Удаляем себя у всех родителей
		8) Очищаем если у документа есть родитель родителя
		9) удаляем теги которые есть в документе из облака тегов
	"""
	ctr = 0; errors = ''
	for current_id in ids:
		doc = get_doc(request, current_id)
		if not doc: return {"result": "fail", "error": 'doc not found'}
		proc_id = doc['doc_type']

		parent = doc['parent'] if 'parent' in doc else '_'
		children = doc['child'] if 'child' in doc else '_'
		old_row = doc['doc']
		from libs.files.files import del_all_files
		del_all_files(request, doc['_id'], proc_id)
		request.db.doc.remove({'_id': doc['_id']})
		try:
			res, err = event('on_del_row', proc_id, {'old_row':old_row, "doc": doc}) # TODO обработать err
			if res != 'ok': errors+=err
		except:pass
		ctr += 1
		request.db.doc.remove({"owner":doc['_id']})
		# request.db.tree.remove({"owner":doc['_id']})
		if children != '_':
			request.db.doc.update_many({'parent':doc['_id']}, {'$set':{'parent':'_'} })
		if parent != '_':
			request.db.doc.update({'child':{'$in':[doc['_id']]}}, {'$pull':{'child':doc['_id']}})
		if not ': ' in proc_id:
			del_doc_tags(request, proc_id, doc)
	if errors:  return {"result": "fail", "error":errors}
	return response_json(request, {"result":"ok", "counter":ctr})


def del_doc_tags(request, proc_id, doc):
	""" при удалении документа пересчитать кол-во тегов в облаке t-скорее всего тег
		идем по всем вложеным спискам в облаке и смотрим что списки у каждого первый елемент не совпадает с одним из удаляемых тегов если совпал
		то удаляем вложеный список или вычитаем единицу из второго элемента
	"""
	cloud_tags = request.db.conf.find_one({"_id":'tags_'+proc_id[4:]})  # get doc where storage cloud tags
	if not cloud_tags: return 'not cloud_tags'
	tags = cloud_tags['tags'][cur_lang(request)] if cloud_tags and 'tags' in cloud_tags and cur_lang(request) in cloud_tags['tags'] else []# берет с нужным языком
	del_tags = doc['tags'][cur_lang(request)] if 'tags' in doc and cur_lang(request) in doc['tags'] else []
	if not del_tags: return 'not del_tags'
	for res in tags:
		if res[0] in del_tags:
			if res[1] == 1: tags.remove(res)
			else: res[1] -= 1
	request.db.conf.save( cloud_tags )
	return 'ok'


def delete_sub_row(request, proc_id, current_id):
	doc = get_doc(request, current_id)
	if doc['owner'] and doc['owner']!='_': 
#		for tree in db.view("_design/main/_view/sub_docs", key=current_id, include_docs=True):
		for res in request.db.doc.find({'_id':current_id}):
			request.db.doc.remove(res)
	return {"result":"ok"}


def get_des_field_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	doc = get_mt(request, proc_id)
	field = doc['doc']
	for l_field in field:
		return {"id":l_field['id'], "title":translate( cur_lang(request), l_field['title'])}


def get_field_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	doc = get_mt(request, proc_id)
	field = doc['doc']
	list_field = []
	for l_field in field:
		list_field.append({"id":l_field['id'], "title":ct(request, l_field['title'])})
	return response_json(request,{"result":"ok", "list_field":list_field })


def table_transfer_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	if not user_has_permission(request, proc_id, 'create'):
		return {"result": "fail", "error": "You have no permission."}
	return transfer_doc(request, proc_id, json.loads(get_post('ids')), get_post('to'))


def transfer_doc(request, proc_id, ids, to):
	proc_id = get_post('proc_id')
	if not user_has_permission(request, proc_id, 'create'):
		return {"result": "fail", "error":"You have no permission."}
	ctr = 0
	dat = get_post(request)
	data = json.loads(dat['ids'])
	for current_id in data:
		doc = get_doc(request, current_id)
		if doc is not None:
			doc['doc_type'] = dat['to']
			request.db.doc.save(doc);	ctr += 1
	return response_json(request, {"result":"ok", "counter":ctr})


def table_del_field_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	field_id = data['field_id']
	doc = get_mt(request, proc_id)
	field = doc['doc']
	for i in field:
		if field_id in i['id']:
			field.remove(i) 
			request.db.map.save(doc)
			return response_json(request, {"result":"ok"})
	return response_json(request, {"result":"fail"})


def table_edit_field_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	field_id = data['field_id']
	data = json.loads(data['data'])
	return add_field(request, proc_id, data, field_id)


def table_add_field_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	print('1) data===================================================================================================')
	data = json.loads(data['data'])
	print('data', data)
	return add_field(request, proc_id, data)


def add_field(request, proc_id, data, field_id=None): #field_id=None индекс поля которое нужно поменять при редактировании
	if not user_has_permission(request, proc_id, 'create'):
		return response_json(request, {"result": "fail", "error": "You have no permission."})
	print('data===================================================================================================')
	print('data', data)
	if 'relation' in data: relation = data['relation']
	else: relation = ''
	if 'relation_field' in data: relation_field = data['relation_field']
	else: relation_field = ''
	for i in data:
		tp = data['type'] if 'type' in data else 'string'
		field = { "hint": {"ru":data['hint_ru'], "en":data['hint_en']}, 
				"title": {"ru":data['title_ru'],"en":data['title_en']}, "visible": data['visible'], "oncreate": data['oncreate'],
				"type": tp, "relation":relation, "relation_field":relation_field,
				"is_editable": data['is_editable'], "id": data['id'], "is_translate":data['is_translate']}
	doc = get_mt(request, proc_id)
	if not field_id:
		doc['doc'].append(field)
	else:
		for res in doc['doc']:
			if field_id == res['id']:
				cur = doc['doc'].index(res)
				doc['doc'].remove(res)
				doc['doc'].insert(cur, field)
	request.db.map.save(doc)
	return response_json(request, {"result":"ok"} )


def move_field_post(request, proc_id, field_id, left):
	data = get_post(request)
	left = data['one_field']
	proc_id = data['proc_id']
	doc = get_mt(proc_id)
	for res in doc['doc']:
		if left in res.values():
			left = doc['doc'].index(res)
	for res in doc['doc']:
		if get_post('field_id') in res.values():
			doc['doc'].remove(res)
			doc['doc'].insert(left, res)
			request.db.map.save(doc)
	return {"result":"ok"}


def duplicate_doc_post(request):
	data = get_post(request)
	doc_id = data['row_id']
	doc = dict(get_doc(request, doc_id))
	doc['_id'] = uuid4().hex
	request.db.doc.save(doc)
	for res in request.db.doc.find({'owner':doc_id}):
		sub_doc = dict(res)
		sub_doc['_id'] = uuid4().hex
		sub_doc['owner'] = doc['_id']
		request.db.doc.save(sub_doc)
	updated = make_updated(request, {}, doc['doc'], doc['doc_type'])
	return response_json(request, {"result":"ok", "row_id":doc['_id'], "updated":updated })


def get_event_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	name_func = data['name_func']

	doc = request.db.map.find_one({'_id':proc_id}, {'events':1})
	e = doc['events'][name_func] if 'events' in doc else ''
	return response_json(request, {"result":"ok", "func_text":json.dumps(e)})


def add_func(request):
	if is_admin(request):
		return templ('libs.auth:conf_', request, {"proc_id":'add_func'})


def table_sort_columns_post(request):
	data = get_post(request)
	proc_id = data['proc_id']
	order = json.loads(data['order'])
	doc = request.db.map.find_one({'_id':proc_id})
	fields = {}
	for res in doc['doc']:
		fields[res['id']] = res

	doc['doc'] = []
	for res in order:
		doc['doc'].append(fields[res])
	request.db.map.save(doc)
	return response_json(request, {"result":"ok"})


def table_copy_doc(request):
	"""
	1) Создаем пустой документа
	"""
	data = get_post(request)
	old_id = data['doc_id']

	from libs.files.files import get_nf, get_file_meta, add_file_raw
	# 1) копируем просто документ
	new_id_owner = simply_copy_doc(request, old_id)
	# 2) Дублирование картинки

	from gridfs import GridFS
	fs = GridFS(request.db)
	for fn in request.db.fs.files.find({'doc_id':old_id, 'file_name':re.compile('^orig_', re.I | re.U)}):
		# TODO таки уменьшать картинку при занесении, сейчас просто название меняется
		if not fn: return None, None, None
		f = fs.get(fn['_id']).read()
		fs.put(f, file_name ='thumb_1'+fn['file_name'], doc_id = new_id_owner, proc_id=fn['proc_id'],  mime = fn['mime'])
		fs.put(f, file_name ='orig_1'+fn['file_name'],  doc_id = new_id_owner, proc_id=fn['proc_id'],  mime = fn['mime'])
		# add_file_raw(fn['proc_id'], old_id, f, fn['mime'], '1'+fn['file_name'] )

	# 3) Дублирование тех документов что он owner
	for res in request.db.doc.find({'owner':old_id}):
		doc_id = simply_copy_doc(request, res['_id'])
		request.db.doc.update({'_id':doc_id}, {'$set':{'owner':new_id_owner}})
	return {"result":"ok"}


def simply_copy_doc(request, old_id):
	new_id = uuid4().hex
	old_doc = request.db.doc.find_one({'_id':old_id})
	old_doc['_id'] = new_id
	old_doc['doc']['rev'] = uuid4().hex[-9:]
	request.db.doc.insert(old_doc)
	return new_id


def table_sort_post(request):
	"""
	1) получаем нужный документ
	2) получаем его предыдущий документ
	3) берем дату предыдущего документа увеличиваем её на 1 секунду и сохраняем
	// снизу - некст, сверху - прев.  !!!!!!!!!
	"""
	data = get_post(request)
	doc_id = data['doc_id']
	prev = data['prev'] if 'prev' in data else ''
	next = data['next'] if 'next' in data else ''
	if next:
		old_date_id  = next
		delta = 1
	else:
		old_date_id  = prev
		delta = -1
	doc = request.db.doc.find_one({'_id':doc_id})
	old_date = request.db.doc.find_one({'_id':old_date_id})

	ddd = datetime.datetime.strptime(old_date['doc']['date'], "%Y-%m-%d %H:%M:%S")
	dd =  ddd + timedelta(seconds=delta)
	datef = datetime.datetime.strftime(dd, "%Y-%m-%d %H:%M:%S")
	datee =  datef
	doc['doc']['date'] = str(datef)
	request.db.doc.save(doc)
	return response_json(request, {"result":"ok", 'datee':datee})


