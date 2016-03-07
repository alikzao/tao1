import json, re, cgi, os, sys
from urllib.parse import  *


from libs.contents.contents import *
# from libs.table.table import *

import core.union
# _ = core.union.get_trans('perm')


# ACL - access controll list
def user_has_permission(request, entity, permission, field=None):
	""" Проверяет в текущей сесии наличие пользователя из списка прав если да то возвращаем тру"""
	name = get_current_user(request, False)
	has = True
	if is_admin( request ): pass
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
	return {"result":"ok"}


# START WORK WITS GROUPS AND ROLES
def group_perm(request): #'/permission', 'GET'
	if get_const_value('is_admin') == "false" and not is_admin(): return page_404('/conf')
	if not user_has_permission('ss:work_rb', 'view'): return 'You have no permission.'#return '{"result": "fail", "error": "%s"}' % cgi.escape(ct("You have no permission."))
	t = ''
	u = urlparse(request.url)
	url = u.scheme + '://' + u.netloc + u.path
	for res in request.db.doc.find({'type':'group'}).sort('_id', 1):
		if t: t += ', '
		t += '"' +res['_id']+ '":{"id":"'+ res['_id'] + '", "title":"' + res['_id'] +'", "type":"checkbox", "is_editable":"true"}'
	t = '{' + t + '}'
	return templ('libs.perm:permission', request, dict(map_=t.decode('UTF-8'), url = url, proc_id='group_perm'))


def users_group(request): #@route('/users', method='GET')
	if get_const_value('is_admin') == "false" and not is_admin(): return page_404('/conf')
	if not user_has_permission('ss:work_rb', 'view'): return 'You have no permission.'
	db = request.db; t = ''
	u = urlparse(request.url)
	url = u.scheme + '://' + u.netloc + u.path
	for res in db.doc.find({'type':'group'}).sort('_id', 1):
		if t: t += ', '
		t += '"' +res['_id']+ '":{"id":"'+ res['_id'] + '", "title":"' + res['_id'] +'", "type":"checkbox", "is_editable":"true"}'
	t = '{' + t + '}'
	return templ('libs.perm:permission', request, dict(map_=t.decode('UTF-8'), url = url, proc_id='users_group'))

def users_group_post(request):
	""" Отображает список прав ролей для таблицы установки прав"""
	if not user_is_logged_in(): return {"result": "fail", "error": "Сеанс закончился зайдите в систему", "need_action":"login"}
	proc_id = get_post('proc_id')
	filter = json.loads(get_post('filter'))
	db = request.db; list_users = []; data=[]; #roles = get_roles();
	roles = get_perm()
	condition = {'doc_type':'des:users'}

	if 'title' in filter['column'] and filter['column']['title']:
		regex = re.compile( str(filter['column']['title']['val']), re.I | re.UNICODE)
		condition['head_field.name.'+cur_lang()] = regex

#	pages, req = get_pagination2(condition)

	count = 0
	for list_users in db.doc.find(condition):
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
		user_name = ct(list_users['head_field']['name']) if 'name' in list_users['head_field'] else 'no name'
		data.append( build_row_report_name(title=user_name, results=results, level=0, id=list_users['_id'], parent='_', child=[] ) )

	# cur_page = int(request.GET['page']) if 'page' in request.GET else 1
	cur_page = int(filter['page']['current']) if 'page' in filter else 1
	limit = int(get_const_value('doc_page_limit'))

	count = int(ceil(count/limit))

	data = data[(cur_page - 1) * limit : cur_page * limit]
	pages = {'count': count, 'current':cur_page, 'next': 0, 'prev':0}
	head = report_cons_head([('title', u'Пользователи')]+[(i, i) for i in roles], 'checkbox', 'true')

	return {"result":"ok", "head":head, "data":json.dumps( data ), "pages":json.dumps( pages)}

def get_pagination2(request, condition, collection='doc'):
	db = request.db
	filtered = json.loads(get_post('filter', '{}'))
	cur_page = int(request.GET['page']) if 'page' in request.GET else 1
	limit = int(get_const_value('doc_page_limit'))
	#	limit = 2
	if 'page' in filtered: page = filtered['page']
	else: page = {'current':1}

	skip = (page['current']-1)*limit
	count = float(db[collection].find(condition).count())
	count = int(ceil(count/limit))
	req = db[collection].find(condition).skip(skip).limit(limit)
	start_page = cur_page - 3
	if start_page<1: start_page = 1
	end_page = start_page + 7
	if end_page > count + 1: end_page = count + 1
	pages = {'count': count, 'current':page['current'], 'next': start_page, 'prev':end_page}
	return pages, req


def group_perm_post1(request,parent):
	""" Draw права справочника and fields """
	db = request.db;  data = []; roles = get_roles(); ctr = 15; child_ = []; child0 = [];
	rb_perm = ['view', 'edit', 'create', 'delete', 'move']
	if parent in ['des:obj', 'des:forum', 'des:wiki', 'des:news']: rb_perm += ['vote', 'vote_com', 'add_com','add_com_pre', 'del_comm', 'mod_accept', 'edit_tag']
	if parent in ['des:obj']: rb_perm += ['fb_import', 'edit_radio']
	doc = db.map.find_one({'_id':parent}, {'field_map':1 })
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

	for rs in doc['field_map']:    # находим выводим все поля справочников
		sub_id = parent+':'+rs['id']
		data.append( build_row_report(title='<b>%s</b>' % rs['id'], results=[rs['id']], level=1, id=sub_id, parent=parent, child=['2'] ) )
		child0.append(sub_id)


	return {"result":"ok", "head":report_cons_head([('title', u'Название')], 'checkbox', 'true'), "data": json.dumps( data ), "page":1,"pagectr":1,"pages":""}


def group_perm_post2(parent):
	""" Рисуем права на поля"""
	data = []; roles = get_roles();
	field_perm = ['view', 'edit']
	for perm in field_perm: # назначаем права на поля
		sub_sub_id = parent+'/' + perm; results = []
		for role in roles:
			val = parent in roles[role] and perm in roles[role][parent]
			results.append((role, ins_img(val), val))
		data.append( build_row_report_name(title=perm, results=results, level=2, id=sub_sub_id, parent=parent, child=[] ) )
	return '{"result":"ok", "head": %s, "data": %s, "page":1,"pagectr":1,"pages":"", "debug":""}' % (
	report_cons_head([('title', u'Название')]+[(i, i) for i in roles], 'checkbox', 'true'), json.dumps( data ))

def group_perm_post0(request): #@route('/permission', method='POST')
	""" Просто рисуем список всех справочников """
	if not user_is_logged_in():
		return '{"result": "fail", "error": "Сеанс закончился зайдите в систему", "need_action":"login"}'
	db = request.db; a = {};  data = []; roles = get_roles(); rb_perm = ['view', 'edit', 'create', 'delete', 'move']
	condition = {'doc_type':{'$ne':'templ_comm'}}

	pages, req = get_pagination2(condition, 'map')

	for res in req:  #находим все справочники
		data.append( build_row_report(title='<b>%s</b>' % res['_id'], results=[res['_id']], level=0, id=res['_id'], parent='_', child=rb_perm ) )

	return {"result":"ok", "head":report_cons_head([('title', u'Всего')]+[(i, i) for i in roles], 'checkbox', 'true'),
	        "data": json.dumps( data ), "pages":json.dumps( pages) }



def group_perm_post():
	parent = get_post('parent', '_')
	if parent == '_': return group_perm_post0()
	if not '/' in parent and parent.count(':') == 1 :       return group_perm_post1(parent)
	if parent.count(':') == 2 : return group_perm_post2(parent)


def get_roles(request):
	db = request.db; roles={}
	for res in db.doc.find({'type':'group'}).sort('_id', 1):
		roles[res['_id']] = res['permissions']
	return roles


def get_perm(request):
	db = request.db; roles={}
	for res in db.doc.find({'type':'group'}).sort('_id', 1):
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
	row = []; c = 0
	row.append({"id":"title", "formatted":title, "edit_value":''})
	for c, res, val in results:
		row.append({"id": c, "formatted":res, "edit_value":('true' if val else 'false')})
	return {"id":id, "doc":row, "parent":parent, 'level':level, 'child':child}


def ins_img(checked):
	""" Рисует картинки"""
	#return '<img src="/static/core/img/'+('check' if checked else 'cancel')+'.png" height="16"/>'
	return '<i class='+('icon-ok' if checked else 'icon-remove')+'   style="color:'+('LimeGreen' if checked else 'red')+'"></i>'


def report_cons_head(columns = [('title', u'Всего')], type="string", is_editable="false"):
	t = ''
	t += u'"title":{"id":"title", "title":"Название", "type":"string", "is_editable":"false"},'
	c = 0; cols = []
	for item in columns:
		(id, title) = item
		c += 1
		cols.append('"' + id + '":{"id":"' + id + '", "title":"' + title + '", "type":"'+type+'", "is_editable":"'+is_editable+'"}')
	t = '{' + ', '.join(cols) + '}'
	return t

def group_perm_uc_post(request):
	""" Установка прав для ролей """
	db = request.db
	permission = get_post('id') 
	role = get_post('field')
	entity = get_post('branch_id')
	value = get_post('value')
	doc = get_doc( role)
	if not entity in doc['permissions']: doc['permissions'][entity] = {}
	doc['permissions'][entity][permission] = value 
	db.doc.save(doc)
	return {"result":"ok", "updated":{role:{"formatted":ins_img(value == 'true').replace('"', '\\"'), "value":value}}}


def users_group_uc_post(request):
	""" Установка членства пользователей """
	db = request.db
	user = get_post('id')
	role = get_post('field')
	value = get_post('value')
	doc = get_doc(role)
	if value == 'true': 
		if not user in doc['users']: doc['users'][user] = 'true'
	else: 
		if user in doc['users']: del doc['users'][user]
	db.doc.save(doc)
	return {"result":"ok", "updated":{role:{"formatted":ins_img(value == 'true').replace('"', '\\"'), "value":value}}}









