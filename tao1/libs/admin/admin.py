import json, cgi, os, sys

import requests

from urllib.parse import  *
from random import choice
from core.set import *
from core.core import *
from settings import *
from libs.contents.contents import *
from libs.sites.sites import *
from libs.perm.perm import user_has_permission

def get_ss( request ):
	return [
			{'id':"ss:add_rb",     "_id":"add_rb",      "class":"d_rb",   "title":ct( request, 'create_rb'), 'link': ''},
			{'id':"ss:del_rb",     "_id":"del_rb",      "class":"d_rb",   "title":ct( request, 'del_rb'), 'link': ''},
			{'id':"ss:conf_adm",   "_id":"conf_adm",    "class":"d_rb",   "title":ct( request, 'Конфигурация админки'), 'link': ''},
			{'id':"ss:add_func",   "_id":"add_func",    "class":"d_rb",   "title":ct( request, 'Создать функцию'), 'link': ''},
			{'id':"ss:change_pass","_id":"change_pass", "class":"d_rb",   "title":ct( request, 'Сменить пароль'), 'link': ''},
			{'id':"ss:in_sandbox", "_id":"in_sandbox",  "class":"d_rb",   "title":ct( request, 'Sandbox'), 'link': ''},
			{'id':"ss:create_user","_id":"create_user", "class":"add_rb", "title":ct( request, 'create_user'), 'link': '/table/in/des:users'},
			{'id':"ss:add_role",   "_id":"add_role",    "class":"add_rb", "title":ct( request, 'create_group'), 'link': ''},
			{'id':"ss:users_group","_id":"users_group", "class":"add_rb", "title":ct( request, 'group_users'), 'link': '/settings/users_group'},
			{'id':"ss:group_perm", "_id":"group_perm",  "class":"add_rb", "title":ct( request, 'right_group'), 'link': '/settings/group_perm'}
	]

def show_conf(request): #route('/conf', 'GET')
	"""Показывает список дизайнерских документов"""
	if get_const_value(request, 'is_admin') == "false" and not is_admin(request): return web.HTTPSeeOther('/')
	if not user_is_logged_in(request): return web.HTTPSeeOther('/login')
	all_docs = []; all_rbs = []; ss = []; all_menu = []
	special = ['des:users', 'des:report_pe', 'des:conf', 'des:role']
	# выводим справочники и документы из документа прослойки.
	for res in request.db.map.find({"conf.turn":"true", '$or':[{"conf.owner":None}, {"conf.owner":'_'}], "conf.is_doc":True} ):
		if user_has_permission(request, res['_id'], 'view'): all_docs.append(res)
	for res in request.db.map.find({"conf.turn":"true", '$or':[{"conf.owner":None}, {"conf.owner":'_'}], "conf.is_doc":False}):
		if not res['_id'] in special and user_has_permission(request, res['_id'], 'view'):	all_rbs.append(res)
	# выводим настроечные кнопки которые справа.
	for res in get_ss(request):
		if user_has_permission(request, res['id'], 'view'):
			res['id'] = res['id'][:2]+'_'+res['id'][3:]
			ss.append(res)

	# выводим кнопки работы с меню.
	for res in request.db.tree.find({'sub_type':'menu'}):
		if user_has_permission(request, res['_id'], 'view'): all_menu.append(res)
	url = request.scheme + '://' + request.host
	# return templ('libs.admin:conf', request, dict(url = url, all_docs = all_docs, all_rbs = all_rbs, all_menu = all_menu, ss = ss) )
	tree = []
	for res in request.db.doc.find({"doc_type":"des:left_menu"}):
		tree.append(res)
	val_tree = form_tree_comm(request, tree)
	# print( request.__dict__)
	return templ('libs.admin:admin', request, dict(url = url, all_docs = all_docs, all_rbs = all_rbs, all_menu = all_menu,
	                                               ss = ss, tree=val_tree) )

def left_menu_post(request):
	# value = left_menu_post_(request)
	docs = []
	for res in request.db.doc.find({"doc_type":"des:left_menu"}):
		docs.append(res)
	value = form_tree_comm(request, docs)
	return response_json(request, {"result":"ok", "content":value})


def conf_post(request):
	"""show list design docs"""
	data = get_post(request)
	data = json.loads(data['data'])

	if not user_is_logged_in(request):
		return user_not_logged(request)
	if 'action' in request.POST:
		action = request.POST['action']
	if action == 'create_rb':
		if not user_has_permission(request, 'ss:work_rb', 'view'): return 'You have no permission.'
		owner = data['rb_id']
		return add_ref(data, owner)
	if action == 'del_rb':
		if not user_has_permission(request, 'ss:work_rb', 'view'): return 'You have no permission.'
		rb_id = data['rb_id']
		is_del_doc = 'is_del_doc' in request.POST
		return del_ref(rb_id, is_del_doc)
	if action == 'create_role':
		if not user_has_permission(request, 'ss:work_rb', 'view'): return 'You have no permission.'
		return add_role(data)
	return 'action 404'


def get_slot_name(request, slot):
	if not slot: slot = {}
	if not 'sort' in slot: slot['sort'] = 'date'
	if not 'templ' in slot: slot['templ'] = 'slot1'
	if 'kind' in slot:
		doc = request.db.map.find_one({'_id':'des:'+slot['kind']})
		title = ct(request, doc['conf']['title'])
		slot['kind_title'] = title if doc else '-'
	else: slot['kind_title'] = '-'
	if 'user' in slot and slot['user']:
		users = []
		for rs in slot['user']:
	#		slot['user'] = get_doc(rs)
			doc = request.db.doc.find_one({'_id': rs})
			if not doc: continue
			if 'name' in doc['doc']: name = ct(request, doc['doc']['name'])
			else: name = rs
			users.append(name)

		slot['user_title'] = ', '.join(users)
	else: slot['user_title'] = '-'
	sorts = {'date': u'Дата','rate': u'Рейтинг','views': u'Просмотры','comm': u'Комментарии',}

	slot['sort_title'] = sorts[slot['sort']] if slot['sort'] in sorts else '-'
	slot['last_art_title'] = u'Да' if 'last_art' in slot and slot['last_art'] == 'true' else u'Нет'
	tpl = {'slot1':u'slot1-Стандартный','poll': u'poll-Голосование','slot_n':u'slot_n-Стандартный новостной','slot_m':u'slot_m-Стандартный мини','slot_m2':u'slot_m2-Улучшеный мини','slot_mm':u'slot_mm-Стандартный мини мини','slot_mm2':u'slot_mm2-Стандартный мини мини2','slot_car':u'slot_car-Прокрутка','slot_r':u'slot_r-Радио','slot_r_mm':u'slot_r_mm-Радио мини','slot_b':u'slot_b-Банеры','slot_t':u'slot_t-Кругозор','slot_l':u'slot_l-Списком','slot_tab1':u'slot_tab1-Закладки','slot_tab2':u'slot_tab2-Закладки2','slot_u':u'slot_u-Пользователи'}
	slot['tpl_title'] = tpl[slot['templ']] if slot['templ'] in tpl else '-'
	return slot


def get_data_slot(request):
	data = get_post(request)
	slotname = data['slot_name']
	confname = data['conf_name']
	conf = get_templ_conf(request, confname)
	slot = None
	if slotname in conf:
		slot = conf[slotname]
#	slot = get_slot_name(slot)
	return slot


def save_slot(request):
	data = get_post(request)
	slotname = data['slot_name']
	confname = data['conf_name']
	data = json.loads( data['data'] )
	conf = request.db.conf.find_one({'_id':'conf_templ'})
	conf[confname][slotname] = data
	request.db.conf.save(conf)
	slot = get_slot_name(request, conf[confname][slotname])
	return {"result":"ok", "slot": json.dumps(slot) }


def change_pass_admin(request):
	if is_admin(request):
		return templ('app.auth:conf_', request,  dict(proc_id='change_pass_admin'))


def change_pass_admin_post(request):
	data = get_post(request)
	new_pass = data['pass']
	if is_admin(request):
		user_id = get_current_user(request, True)
		request.db.doc.update({"_id":user_id}, {"$set":{'password': getmd5(new_pass) } } )
	return {"result":"ok"}


def recover(request):
	return templ('libs.auth:recover', request, {})


def recover_post(request):
	data = get_post(request)
	name = data['name']
	email = data['email']
	doc = '123'; error = ''
	if name and email:
		doc = request.db.doc.find_one({'_id':'user:'+name, 'doc.mail':email, 'doc_type':'des:users'})
		if not doc: error = 'user not found'
	else: error = 'You must specify a user name and email'
	if not error:
		word = ''.join( [choice('QWERTYUPLKJHGFDSAZXCVNMabcdefjhigklmnopqrstuvwxyz2345679') for i in xrange(8)] )

		link = name + ' Your new password:' + word
		subject = 'Password recovery by:' + get_host(request)
		mail(request, email, subject, link)
		doc['password'] = getmd5(word)
		request.db.doc.save(doc)

		error = 'New password sent to your email'
	return templ('libs.admin:recover', request, {"mess": error} )


def edit_conf(request):
	if is_admin(request):
		all_rbs = []
		for res in request.db.map.find({'$or':[{"conf.owner":None}, {"conf.owner":'_'} ], }):
			all_rbs.append(res)
		return templ('libs.admin:conf_conf', request, dict(proc_id='conf_rb_doc', data = all_rbs) )

def edit_conf_post(request):
	""" Заносим видимость или невидимость кнопки тоесть модуля	"""
	data = get_post(request)
	data = json.loads(data['data'])
	for res in request.db.map.find({'$or':[{"conf.owner":None}, {"conf.owner":'_'}]} ):
		if user_has_permission(request, res['_id'], 'view'):

			res['conf']['turn'] = 'true' if data[res['_id']] else 'false'
		request.db.map.save(res)
	return {"result":"ok"}

def del_ref_post(request):
	""" Вначале удаляем из ролей справочник потом удаляем его самого,
	дерево, затем удаляем или переносим все документы что были в нем"""
	from libs.table.table import del_row
	data = get_post(request)
	rb_id = data['rb_id']
	is_del_doc = data['is_del_doc']
	doc = get_doc(request, 'role:admin')
	field = doc['permissions']
	if rb_id in field:
		del field[rb_id]
	request.db.doc.save(doc)
	request.db.map.remove(rb_id)
	for ids in request.db.doc.find({'doc_type':rb_id}):
		del_row(request, rb_id, ids) if is_del_doc=='off' or is_del_doc=='' else transfer_doc(request, rb_id, ids, 'des:obj')
	return response_json(request, {"result":"ok", "rb":rb_id})


def add_rb(request):
	if is_admin(request):
		return templ('libs.admin:add_rb', request, {'proc_id':'add_rb'})


def del_rb(request):
	if is_admin(request):
		return templ('libs.admin:dell_rb', request, {'proc_id':'del_rb'})


def add_ref_post(request):
	data = get_post(request)
	data =json.loads( data['data'])
	id = data['id']
	owner = data['owner'] if 'owner' in data else None
	name_ru = data['name_ru']
	name_en = data['name_en']
	is_doc = data['is_doc']
	if owner is None:
		add_main_ref(request, id, name_ru, name_en, '_', is_doc, data['is_comm'])
	else:
		add_sub_ref(request, id, name_ru, name_en, owner, is_doc)
	return response_json(request, {"result":"ok"})


def add_main_ref(request, id, name_ru, name_en, owner, is_doc, comm):
	if owner is None: owner='_'
	if is_doc == 'forum': doc = get_doc_forum()
	elif is_doc == 'obj': doc = get_doc_obj()
	else: doc = get_doc_des(id, name_ru, name_en, owner, is_doc)
	if comm == 'on' or is_doc == 'obj' or is_doc == 'forum':
		doc.update({'is_comm':True})
	request.db.map.save( doc )
	# request.db.doc.update({'_id':'role:admin'}, {"$set":{'permissions':{"des:"+id: {"edit":"true", "delete":"true", "create":"true", "move":"true", "view":"true" } } } } )
	doc_perm = get_doc(request, 'role:admin')
	doc_perm['permissions'].update({"des:"+id: {"edit":"true", "delete":"true", "create":"true", "move":"true", "view":"true" }})
	request.db.doc.save(doc_perm)
	return response_json(request, {"result":"ok"})


def add_sub_ref(request, id, name_ru, name_en, owner, is_doc):
	if owner is None: owner='_'
	doc = get_doc_des(id, name_ru, name_en, owner, is_doc)
	request.db.map.save( doc )
	return {"result":"ok"}


def conf_templ():
	lst = [name for name in os.listdir(os.path.join(os.getcwd(), 'templ'))]
	sw = ''
	if lst:
		sw = '<div class="switch_template">{}</div>'.format(''.join(['<div style="margin:5px;" class="btn btn-info">{title}</div>'.format(title=name) for name in lst]))
	else:
		lst = ['default']
	tpl = '<div class="templates">{}</div>'.format(''.join(['<div t_name="{name}"><div>{name}</div>{templ}</div>'.format(
		    name = name, templ = templ_str(name+'#conf_templ', conf_name=name, conf=get_templ_conf(templ=name) ) ) for name in lst]))
	return sw + tpl


def get_list_templ(request):
	list_templ = []
	templs = os.path.join(os.getcwd(), 'templ')
	for fname in os.listdir(templs):
		if fname.endswith( '.tpl'):
			list_templ.append( (fname, os.path.join( templs, fname ), 'html' ) )
	templs = os.path.join(os.getcwd(), 'static')
	for fname in os.listdir(templs):
		if fname.endswith( '.css'):
			list_templ.append( (fname, os.path.join( templs, fname ), 'css' ) )
	return templ('libs.admin:edit_templ', request, dict(list_templ = list_templ))


def save_templ_post(request):
	data = get_post(request)
	path = data['path']
	tpl = data['templ']
	w_file(path, tpl)
	return {"result":"ok"}

def get_templ_post(request):
	data = get_post(request)
	path = data['path']
#	templ = get_post('templ')
#	if templ.endswith('.css'): path = os.path.join(os.getcwd(), 'static', templ)
#	else: path = os.path.join(os.getcwd(), 'templ', templ)
	tpl = r_file(path)
	return {"result":"ok", "tpl":tpl}
#	return templ('app.admin:edit_templ', tpl = tpl)



def get_arhiv_templ():
	""" Получение архива с шаблоном или модулем и установка и раскидывание его по деректориям """
	from zipfile import ZipFile
	import os
	# путь для распаковки файлов
	path = os.path.join(settings.lib_path, 'media/upload/products')
	f = ZipFile('filename', 'r')
	for name in f.namelist():
		try:
			unicode_name = name.decode('UTF-8').encode('UTF-8')
		except:
			unicode_name = name.decode('cp866').encode('UTF-8')
		# some analyzing of unicode_name and execute some actions
		# ...
		file_name = os.path.join(path, unicode_name)
		f2 = open(file_name, 'w')
		#f.extract(name, path) # works only for python 2.6+
		f2.write(f.read(name))
		f2.close()
	f.close()



