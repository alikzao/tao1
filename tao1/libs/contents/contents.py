import sys, json, cgi, os, sys, hashlib, time, traceback

from pymongo import *

from urllib.parse import *
from uuid import uuid4
from random import randint, choice
from datetime import datetime
from core.set import *
from core.core import *


from urllib.parse import  *
import builtins as __builtin__

from settings import *
from trigger import *

from libs.perm.perm import user_is_logged_in, is_admin
from core.union import response_json


#Если путь продать, то не по чему будет больше идти.
def get_mt(request, proc_id):
	return request.db.map.find_one({'_id':proc_id})


def get_mth(request, proc_id):
	return request.db.map.find_one({'_id':proc_id}, {'field_map':1})['field_map']


def get_doc(request, doc_id, proc_id = None):
	if proc_id and proc_id.startswith('col:'):
		col = proc_id[4:]
	else:
		col='doc'
	if col == 'doc':
		if len(doc_id) == 32 or ':' in doc_id: id = '_id'
		elif doc_id.startswith('/'):
			id = 'doc.old_id'
		elif len(doc_id) <= 5 or ':' in doc_id:
			doc_id = '/news/'+doc_id+'/'; id = 'doc.old_id'
		else: id = 'doc.rev'
	else: id = '_id'
	return request.db[col].find_one({id:doc_id})


def save_doc(request, doc, proc_id = None):
	if proc_id and proc_id.startswith('col:'): col = proc_id[4:]
	else: col='doc'
	return request.db[col].save(doc)


def get_doch(request, doc_id):
	if len(doc_id) == 32 or ':' in doc_id: id = '_id'
	else: id='doc.rev'
	return request.db.doc.find_one({id:doc_id}, {'doc':1})['doc']


def get_doc_tree_(request, doc_id):
	return request.db.tree.find_one({'_id':doc_id})


async def table_get_field_post(request):
	data = get_post(request)
	field = data['field_id']
	proc_id = data['proc_id']
	doc = request.db.map.find_one({"_id":proc_id}, {"doc":1})
	res = []
#	res = list( filter( lambda x: x['id'] == field, doc['field_map']))
	for i in doc['doc']:
		if field == i['id']: 
			res.append(i)
	if len(res):
		# aaa = json.dumps(res[0])
		return response_json(request,  {"result":"ok", "val_field":res[0]})
	else:
		return response_json(request,  {"result":"fail", "error":field+" not this field."})


async def get_list_conf_docs_post(request, field):
	all_rbs = []
	for res in request.db.map.find({'$or':[{"conf.owner":None}, {"conf.owner":'_'} ], }):
		all_rbs.append(res)
	return response_json(request,  {"result":"ok", "doc":json.dumps(all_rbs) })


async def get_list_cascad_doc_post(request):
	if not user_is_logged_in(request): return user_not_logged()
	# proc_id = get_post('proc_id')
	data = get_post(request)
	rel_field  = data['rel_field']
	doc_id     = data['doc_id']
	proc_id    = data['rb_id']
	docs = []

	doc = request.db.doc.find_one({'_id':doc_id})
	filter_name_id = ct(request, doc['doc'][rel_field])

	owner_id_ware_class = request.db.doc.find_one({'_id':filter_name_id})['owner']
	for res in request.db.doc.find({'doc_type':proc_id, 'owner':owner_id_ware_class, 'doc.title':filter_name_id}):
		title = get_doc_title(request, res, res['_id'])
		docs.append({ "id":res['_id'], "title":title })
	return response_json(request,  {"result":"ok", "list_doc":json.dumps(docs)})


async def get_list_doc_post(request):
	if not user_is_logged_in(request): return user_not_logged()
	data = get_post(request)
	rb_id = data['rb_id']
	doc = get_list_doc_( request, rb_id )
	return response_json(request,  {"result":"ok", "list_doc":json.dumps(doc)})


def get_list_doc_(request, proc_id):
	doc = []
	doc.append({"id":"", "title":"-"})
	for res in request.db.doc.find({"doc_type":proc_id}):
		title = get_doc_title(request, res, res['_id'])
		doc.append({"id":res['_id'], "title":title})
	return doc


async def get_list_rb_post(request):
	if not user_is_logged_in(request): return user_not_logged()
	all_view = []
	# type = get_post('type')
	for res in request.db.map.find({'type':'templ'}):
		title = ct(request, res['conf']['title'])
		if 'owner' in res['conf'] and res['conf']['owner'] != '_':
			mt = get_mt(request, res['conf']['owner'])
			if not mt: continue
			title = '%s: %s' % (ct(request, mt['conf']['title']), title)
		all_view.append({'_id':res['_id'], 'title':title })
	return response_json(request,  {"result":"ok", "list_rb":all_view})


def get_list_branch_post(request):
	pass

def get_list_branch_post1(request):
	if not user_is_logged_in(request): return user_not_logged()
	proc_id = request.match_info.get('proc_id')
	branch = []
	doc = request.db.tree.find_one({'_id':'tree:'+proc_id})
	tree = doc['tree']
	branch.append({"id":"", "title":"-"})
	for res in tree:
		branch.append({"id":res, "title":ct(request, tree[res]['title'])})
	return response_json(request, {"result":"ok", "list_branch":branch })


def is_str(doc_id):
	for res in range(0, 10):
		if doc_id.find(str(res)) != -1: return False
	return True


def get_doc_title_cascad(request, doc, value = None):
	""" проверяем что есть поле title или name или value и что оно не равно 32 и в нем нет цыфр
	    это для того чтоб не попадало _id в выпадающий список
	"""
	# die(doc)
	title = ''
	if 'title' in doc['doc']:
		titl = ct(request, doc['doc']['title'])
		if (len(titl) != 32 or len(titl) != 34 ) and not is_str( titl ):
			title = ct(request,  doc['doc']['title'])
	elif 'name' in doc['doc']:
		name = ct(request,  doc['doc']['name'])
		if (len(name)  != 32 or len(name)  != 34 ) and not is_str( name ):
			title = ct(request,  doc['doc']['name'])
	elif 'value' in doc['doc']:
		val = ct(request,  doc['doc']['value'])
		if (len(val) != 32 or len(val)  != 34 ) and not is_str( val ):
	# elif 'value' in doc['doc']:
			title = ct(request, doc['doc']['value'])
	else:
		meta = get_mt(request, doc['doc_type'])
		if 'conf' in meta and 'is_doc' in meta['conf'] and meta['conf']['is_doc']:
			title = ct(request, meta['conf']['title'])+u' № - от -'
		else: # мы совсем не понимаем как так произошло, но...
			title = value
	return title


def get_doc_title(request, doc, value = None):
	""" проверяем что есть поле title или name или value и что оно не равно 32 и в нем нет цыфр
	    это для того чтоб не попадало _id в выпадающий список
	"""
	title = ''
	if 'title' in doc['doc']:
		title = ct(request,  doc['doc']['title'])
	elif 'name' in doc['doc']:
		title = ct(request,  doc['doc']['name'])
	elif 'value' in doc['doc']:
		title = ct(request,  doc['doc']['value'])
	else:
		meta = get_mt(request, doc['doc_type'])
		if 'conf' in meta and 'is_doc' in meta['conf'] and meta['conf']['is_doc']:
			title = ct(request, meta['conf']['title'])+u' № - от -'
		else: # мы совсем не понимаем как так произошло, но...
			title = value
	return title


def switch_lang(request):
	s = session(request )
	data = get_post(request)
	lang_id = data['lang_id']
	if lang_id == 'en' or lang_id == 'ru' :
		s['lang'] = lang_id
		s.save()
		return {"result":"ok"}
	return {"result":"fail"}


async def get_doc_post(request):
	if is_admin(request):
		data = get_post(request)
		doc_id = data['doc_id']
		doc = request.db.doc.find_one({"_id":doc_id})['doc']
		return response_json(request,  {"result":"ok", "id":doc_id, "doc":doc})
	return response_json(request,  {"result":"fail", "doc":'bolt'})









class sb_except:
	def __init__(self, u, e):
		self.u = u
		self.e = e


def event(event, proc_id, *args, **kwargs):
	event_id = proc_id + '/' + event
	ev = events.get(event_id, None)
	if ev is not None:
		try: ev(*args, **kwargs)
		except Exception as e: return ('fail', e)
		# raise e
		return ('ok', '')
	else: return ('ok', '')


def event_1(event, proc_id, doc_id):
	if proc_id in events and events[proc_id]:
		ev = str(events[proc_id][event])
		# die(ev)
		try: eval(ev, glb, {"doc_id": doc_id})
		# try: exec ev
		except Exception as e:
			return e
		return ('ok', '')
	else: return ('ok', '')


def event2(event, proc_id, data):
	# from app.contents.contents import get_mt
	# from sites.daoerp.user_app.users_app.users_app import  *
	ev = events.__dict__[proc_id]
	# ev = str(ev[proc_id])
	# die(ev)
	if proc_id in ev and ev[proc_id]:
		try:
			ev = str(ev[proc_id][event])
			try:
				exec(ev)
			except Exception as e:
				pass
			return ('ok', '')
		except sb_except as s:
			u = s.u
			e = s.e
			return ('fail', "err %s, line %s, func %s, class %s" % (e, "\n".join(u), event, proc_id))
	else: return ('ok', '')


def event_db(event, proc_id, data):
	doc = get_mt(proc_id)
	if 'events' in doc and event in doc['events']:
		try:
			assert isinstance(data, dict)
			ev = str(doc['events'][event])
			sandboxed(ev, data)
			if data['error']: return ('fail', "Error validation %s" % data['error'])
			return ('ok', '')
		except sb_except as s:
			u = s.u
			e = s.e
			return ('fail', "err %s, line %s, func %s, class %s" % (e, "\n".join(u), event, proc_id))
	else: return ('ok', '')


import_backup = __builtin__.__import__
def importer(a, s, d, f=[], level=-1):
	aaa = ['app.accounting']
	if a in aaa:
		return import_backup(a, s, d, f, level)
	return None


def sandboxed(request, code, data):
	pass
# 	db = request.db
# 	ev = str(code)
# 	# from app.accounting.accounting import export
# 	# e = export()
# 	for i in e: data[i] = e[i]['func']
# 	data.update()
# #	data['vd'] = vd
# 	data['error'] = ''
# 	data['db_doc'] = db.doc
# 	__builtin__.__import__ = importer
# 	try:
# 		exec(ev, data)
# 	except Exception as e:
#
# 		__builtin__.__import__ = import_backup
# 		u = traceback.format_exception(*sys.exc_info())
# 		raise sb_except(u, e)
# 	__builtin__.__import__ = import_backup



def add_func(request):
	if is_admin(request):
		return templ('libs.admin:add_func', request, dict(proc_id='add_func'))


def sandbox(request):
	if is_admin(request):
		return templ('libs.admin:sandbox', request, dict(proc_id='sandbox'))


def test_test(request):
	if is_admin(request):
		return templ('libs.admin:test_test', request, dict(proc_id='test_test'))


async def add_func_post(request):
	data = get_post(request)
	data = json.loads(data['data'])
	doc = request.db.conf.find_one({"_id":"default"})
	doc['func'].update({ data['name']: {'func': data['func'], 'descr': ''} })
	request.db.conf.save(doc)
	return response_json(request,  {"result":"ok"})


async def sandbox_post(request):
	data = get_post(request)
	data = json.loads(data['data'])
#	proc_id = get_post(proc_id)
	meta = request.db.map.find_one({'_id':data['proc_id']})
	if not 'events' in meta: meta['events'] = {}
	meta['events'].update( { data['event'] : data['code'] })
	request.db.map.save(meta)
	return response_json(request,  {"result":"ok"})









