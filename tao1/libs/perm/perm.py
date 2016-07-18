import json, re, cgi, os, sys
from urllib.parse import  *
from math import ceil

from libs.contents.contents import *
from core.union import response_json
# from libs.table.table import *

import core.union
# _ = core.union.get_trans('perm')


# ACL - access controll list
def user_has_permission(request, entity, permission, field=None):
	""" Check in current session наличие пользователя из списка прав если да то return True"""
	name = get_current_user(request, False)
	has = True
	if is_admin( request ): has = True
	elif not request.db.doc.find_one({'doc_type':'des:role', 'users.user:'+name:'true', 'permissions.'+entity+'.'+permission:'true'}):
		has = False
	elif field and not request.db.doc.find_one({'doc_type':'des:role', 'users.user:'+name:'true', 'permissions.'+entity+'/'+field+'.'+permission:'true'}):
		has = False
	return has


def is_admin(request):
	return get_current_user(request, True) == get_admin(request)


def user_is_logged_in(request):
	user = get_current_user(request)
	return user != 'guest'


async def u_is_l(request):
	s = await get_session(request)
	if not 'user_id' in s or s['user_id'] == 0 or s['user_id'] == 'guest':
		s['user_id'] = 'guest'
		return False
	else:
		return True



def add_role(request, data):
	domain = get_domain()
	request.db.doc.save(  get_doc_role(data, domain) )
	return response_json(request, {"result":"ok"})


# START WORK WITS GROUPS AND ROLES
def group_perm(request): #'/permission', 'GET'
	url = request.scheme + '://' + request.host + request.path
	print('url->', url)
	if get_const_value(request, 'is_admin') == "false" and not is_admin(request): return web.HTTPFound('/conf')
	if not user_has_permission(request, 'ss:work_rb', 'view'): return 'You have no permission.'#return '{"result": "fail", "error": "%s"}' % cgi.escape(ct("You have no permission."))
	t = ''

	for res in request.db.doc.find({'type':'group'}).sort('_id', 1):
		if t: t += ', '
		t += '"' +res['_id']+ '":{"id":"'+ res['_id'] + '", "title":"' + res['_id'] +'", "type":"checkbox", "is_editable":"true"}'
	t = '{' + t + '}'
	# return templ('libs.perm:permission', request, dict(map_=t.decode('UTF-8'), url = url, proc_id='group_perm'))
	return templ('libs.perm:permission', request, dict(map_=json.loads(t), url = url, proc_id='group_perm'))


async def users_group(request): #@route('/users', method='GET')
	url = request.scheme + '://' + request.host + request.path
	print('url->', url)

	if get_const_value(request, 'is_admin') == "false" and not is_admin(request): return web.HTTPFound('/conf')
	if not user_has_permission(request, 'ss:work_rb', 'view'): return 'You have no permission.'
	t = ''
	for res in request.db.doc.find({'type':'group'}).sort('_id', 1):
		if t: t += ', '
		t += '"' +res['_id']+ '":{"id":"'+ res['_id'] + '", "title":"' + res['_id'] +'", "type":"checkbox", "is_editable":"true"}'
	t = '{' + t + '}'
	# return templ('libs.perm:permission', request, dict(map_=t.decode('UTF-8'), url = url, proc_id='users_group'))
	return templ('libs.perm:permission', request, dict(map_=t, url = url, proc_id='users_group'))


async def users_group_post(request):
	""" Отображает список прав ролей для таблицы установки прав"""
	if not user_is_logged_in(request): return {"result": "fail", "error": "The session ended Login", "need_action":"login"}
	data = await request.post()
	filter = json.loads(data['filter'])
	data=[]
	roles = get_perm(request)
	condition = {'doc_type':'des:users'}

	if 'title' in filter['column'] and filter['column']['title']:
		regex = re.compile( str(filter['column']['title']['val']), re.I | re.UNICODE)
		condition['doc.name.'+cur_lang(request)] = regex

#	pages, req = get_pagination2(condition)

	count = 0
	for list_users in request.db.doc.find(condition):
		results = []
		skip = False
		for role in roles:
			val = list_users['_id'] in roles[role]
			if role in filter['column'] and filter['column'][role]:
				if filter['column'][role]['val'] == 't' and not val or filter['column'][role]['val'] == 'f' and val:
					skip = True
					continue
			results.append((role, ins_img(val), val))
		if skip: continue
		count += 1
		user_name = ct(request, list_users['doc']['name']) if 'name' in list_users['doc'] else 'no name'
		data.append( build_row_report_name(title=user_name, results=results, level=0, id=list_users['_id'], parent='_', child=[] ) )

	# cur_page = int(request.GET['page']) if 'page' in request.GET else 1
	cur_page = int(filter['page']['current']) if 'page' in filter else 1
	limit = int(get_const_value(request, 'doc_page_limit'))

	count = int(ceil(count/limit))

	data = data[(cur_page - 1) * limit : cur_page * limit]
	pages = {'count': count, 'current':cur_page, 'next': 0, 'prev':0}
	head = report_cons_head([('title', 'Пользователи')]+[(i, i) for i in roles], 'checkbox', 'true')

	# print( {"result":"ok", "head":head, "data":json.dumps( data ), "pages":json.dumps( pages)} )
	# print('data->', data)
	# return response_json(request, {"result":"ok", "head":head, "data":json.dumps( data ), "pages":json.dumps( pages)})
	print('heqd->', head)
	return response_json(request, {"result":"ok", "head":head, "data":data, "pages":pages })
	# return response_json(request, {"result":"ok", "head":head, "data":data, "pages":pages })


async def get_pagination2(request, condition, collection='doc'):
	data = await request.post()
	filtered = json.loads(data.get('filter', '{}'))
	cur_page = int(request.GET['page']) if 'page' in request.GET else 1
	limit = int(get_const_value(request, 'doc_page_limit'))
	#	limit = 2
	if 'page' in filtered: page = filtered['page']
	else: page = {'current':1}

	skip = (page['current']-1)*limit
	count = float(request.db[collection].find(condition).count())
	count = int(ceil(count/limit))
	req = request.db[collection].find(condition).skip(skip).limit(limit)
	start_page = cur_page - 3
	if start_page<1: start_page = 1
	end_page = start_page + 7
	if end_page > count + 1: end_page = count + 1
	pages = {'count': count, 'current':page['current'], 'next': start_page, 'prev':end_page}
	return pages, req


def group_perm_post1(request, parent):
	""" Draw права справочника and fields """
	data = []
	roles = get_roles(request)
	child0 = []
	rb_perm = ['view', 'edit', 'create', 'delete', 'move']
	if parent in ['des:obj', 'des:forum', 'des:wiki', 'des:news']: rb_perm += ['vote', 'vote_com', 'add_com','add_com_pre', 'del_comm', 'mod_accept', 'edit_tag']
	if parent in ['des:obj']: rb_perm += ['fb_import', 'edit_radio']
	# doc = request.db.map.find_one({'_id':parent}, {'field_map':1 })
	doc = request.db.map.find_one({'_id':parent}, {'doc':1 })
	for i in rb_perm:  # назначаем права на справочники    выводим права на справочники
		sub_id = parent+'/'+i; results = []
		for role in roles: #{u'role:simple_users': {u'des:users/phone': {u'edit': u'true', u'view': u'true'}, u'des:PM/title': {u'edit': u'true', u'view': u'true'}, u'des:PM/date': {u'edit': u'true', u'view': u'true'}}}
			val = parent in roles[role] and i in roles[role][parent] and roles[role][parent][i] == 'true'
			# role = simple_users
			# parent = des:obj
			# roles = список [role:admin, role:blogger и тд]
			results.append((role, ins_img(val), val))
		data.append( build_row_report_name(title=i, results=results, level=1, id=sub_id, parent=parent, child=[] ) )
		child0.append(sub_id)

	for rs in doc['doc']:    # находим выводим все поля справочников
		sub_id = parent+':'+rs['id']
		data.append( build_row_report(title='<b>%s</b>' % rs['id'], results=[rs['id']], level=1, id=sub_id, parent=parent, child=['2'] ) )
		child0.append(sub_id)


	# return response_json(request, {"result":"ok", "head":report_cons_head([('title', 'Название')], 'checkbox', 'true'), "data": json.dumps( data ), "page":1,"pagectr":1,"pages":""})
	return response_json(request, {"result":"ok", "head":report_cons_head([('title', 'Название')], 'checkbox', 'true'), "data": data, "page":1,"pagectr":1,"pages":""})


def group_perm_post2(request, parent):
	""" Рисуем права на поля"""
	data = []; roles = get_roles(request);
	field_perm = ['view', 'edit']
	for perm in field_perm: # назначаем права на поля
		sub_sub_id = parent+'/' + perm; results = []
		for role in roles:
			val = parent in roles[role] and perm in roles[role][parent]
			results.append((role, ins_img(val), val))
		data.append( build_row_report_name(title=perm, results=results, level=2, id=sub_sub_id, parent=parent, child=[] ) )
		return response_json(request, {"result":"ok", "head": report_cons_head([('title', 'Название')]+[(i, i) for i in roles], 'checkbox', 'true'), "data":data, "page":1,"pagectr":1,"pages":"", "debug":""})


async def group_perm_post0(request): #@route('/permission', method='POST')
	""" Просто рисуем список всех справочников """
	if not user_is_logged_in(request):
		return response_json(request, {"result": "fail", "error": "Сеанс закончился зайдите в систему", "need_action":"login"})
	data = []
	roles = get_roles(request)
	rb_perm = ['view', 'edit', 'create', 'delete', 'move']
	condition = {'doc_type':{'$ne':'templ_comm'}}

	pages, req = await get_pagination2(request, condition, 'map')

	for res in req:  #находим все справочники
		data.append( build_row_report(title='<b>{}</b>'.format(res['_id']), results=[res['_id']], level=0, id=res['_id'], parent='_', child=rb_perm ) )

	return response_json(request, {"result":"ok", "head":report_cons_head([('title', 'Всего')]+[(i, i) for i in roles], 'checkbox', 'true'),
	        "data": data, "pages":pages })



async def group_perm_post(request):
	data = await request.post()
	parent = data.get('parent', '_')
	if parent == '_': return await group_perm_post0(request)
	# if parent == '_': await group_perm_post0(request)
	if not '/' in parent and parent.count(':') == 1 :       return group_perm_post1(request, parent)
	if parent.count(':') == 2 : return group_perm_post2(request, parent)


def get_roles(request):
	db = request.db; roles={}
	for res in db.doc.find({'type':'group'}).sort('_id', 1):
		roles[res['_id']] = res['permissions']
	return roles


def get_perm(request):
	roles={}
	for res in request.db.doc.find({'type':'group'}).sort('_id', 1):
		roles[res['_id']] = res['users']
	return roles


def build_row_report(title='', results=[], level=0, id='', parent='', child=[]):
	row = []; c = 0
	row.append({"id":"title", "formatted":title, "edit_value":''})
	for res in results:
		c += 1
		row.append({"id":"column" + str(c), "formatted":res, "edit_value":''})
	return {"id":id, "doc":row, "parent":parent, 'level':level, 'child':child}


def build_row_report_name(title='', results=[], level=0, id='', parent='', child=[]):
	row = [{"id":"title", "formatted":title, "edit_value":''}]
	for c, res, val in results:
		row.append({"id": c, "formatted":res, "edit_value":('true' if val else 'false')})
	return {"id":id, "doc":row, "parent":parent, 'level':level, 'child':child}


def ins_img(checked):
	#return '<img src="/static/core/img/'+('check' if checked else 'cancel')+'.png" height="16"/>'
	return '<i class="'+('fa fa-check' if checked else 'fa fa-remove')+'"   style="color:'+('LimeGreen' if checked else 'red')+'"></i>'


def report_cons_head(columns = [('title', 'Всего')], type="string", is_editable="false"):
	t = ''
	t += '"title":{"id":"title", "title":"Название", "type":"string", "is_editable":"false"},'
	c = 0; cols = []
	for item in columns:
		(id, title) = item
		c += 1
		cols.append('"' + id + '":{"id":"' + id + '", "title":"' + title + '", "type":"'+type+'", "is_editable":"'+is_editable+'"}')
	t = '{' + ', '.join(cols) + '}'
	# return t
	return json.loads(t)


async def group_perm_uc_post(request):
	""" Установка прав для ролей """
	data = await request.post()
	permission = data.get('id')
	role = data.get('field')
	entity = data.get('branch_id')
	value = data.get('value')
	doc = request.db.doc.find_one({"_id":role}) #get_doc(request, role)
	if not entity in doc['permissions']: doc['permissions'][entity] = {}
	doc['permissions'][entity][permission] = value
	request.db.doc.save(doc)
	# return response_json(request, {"result":"ok", "updated":{role:{"formatted":ins_img(value == 'true').replace('"', '\\"'), "value":value}}} )
	return response_json(request, {"result":"ok", "updated":{"value":value, "formatted":ins_img(value == 'true'), 'field_name': role }} )


async def users_group_uc_post(request):
	""" Установка членства пользователей """
	data = await request.post()
	user = data.get('id')
	role = data.get('field')
	value = data.get('value')
	doc = request.db.doc.find_one({"_id": role})
	if value == 'true': 
		if not user in doc['users']: doc['users'][user] = 'true'
	else: 
		if user in doc['users']: del doc['users'][user]
	request.db.doc.save(doc)
	exm = {'value': "true", 'formatted': "<span style='color:green; font-size:16px'><i class='fa fa-check'></i></span>", 'field_name': "last_art"}

	return response_json(request, {"result":"ok", "updated":{"value":value, "formatted":ins_img(value == 'true'), 'field_name': role }} )









