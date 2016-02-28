import json
import cgi
from datetime import datetime, timedelta
from uuid import uuid4

from libs.contents.contents import *
from libs.table.table import del_row, update_cell
from libs.perm.perm import is_admin, user_has_permission
from core.core import *
from core.union import response_json
# from libs.captcha.captcha import *





def form_tree_comm(request, docs):
	""" forms of documents tree
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


def add_comm_post(request):
#	return json.dumps(current_id, title, link, proc_id)
	"""current_id это id ветки"""
	db = request.db
	ip = request.environ.get('REMOTE_ADDR')
	user = get_current_user(True)
	if check_ban(ip, user): return {"result":"fail", "error":u"Ваш ip или аккаунт забанен на этом сайте, свяжитесь с администрацией"}
	# else: title = get_post('title').decode('utf-8')
	else: title = get_post('title')
	# if get_const_value('all_comm') == "false":
	if not user_has_permission('des:obj', 'add_com') and  not user_has_permission('des:obj', 'add_com_pre'): return {"result":"fail", "error":"no comment"}
	if not check_user_rate( user ): return {"result":"fail", "error": u"Вы не можете оставлять сообщения слишком часто, из-за отрицательной кармы"}

	doc_id = get_post('doc_id')
	if user_is_logged_in(): title = get_current_user()
	title_ = ct( get_doc( doc_id )['doc']['title'] )
	title = no_script( title ) if title else u'Аноним'
	parent = get_post('parent', "_")
	descr = get_post('descr')
	descr = no_script( descr )
	descr = descr.replace('\n', '<br/>')

	pre = 'true' if not user_has_permission('des:obj', 'add_com') else 'false'   # ретурн если нет и того и другого    а если нет только одного то как раз проверим
	date = str(str_date_j())
	user_ = get_current_user_name( title ) or title
	our = "true" if user_is_logged_in() else "false"
	body = re.sub(r'(http?://([a-z0-9-]+([.][a-z0-9-]+)+)+(/([0-9a-z._%?#]+)+)*/?)', r'<a href="\1">\1</a>', descr)

	# добавление родителю ребенка
	db.doc.update({ "_id": parent }, { "$addToSet": { "child": doc_id } } )

	# занесение коментов в справочник коментов
	doc_id_comm, updated = create_empty_row_('des:comments', parent, '', { "user":'user:'+title })
	data = { "title":title_, "date":date, "body":body, "parent":parent, "owner":doc_id, 'ip':ip, 'name':user_, "our":our, 'pre':pre }
	update_row_('des:comments', doc_id_comm, data, parent)

	#отсылка сообщение на почту
	from core.union import make_link
	link = make_link('show_object', {'doc_id':doc_id }, True)+'#comm_'+ str( id )
	subject = u'Пользователь {} создал коментарий'.format( title )
	if settings.notify_user:
		sub('user:'+title, link, subject)

	from libs.sites.sites import reset_cache
	rev = get_doc(doc_id)['doc']['rev']
	reset_cache(type="doc", doc_id=rev)
	# добавление подсчета коментариев в отдельном документе
	db.doc.update({ "_id": doc_id }, { "$inc": { "count_branch":1 } } )
	# return json.dumps({"result":"ok", "content":data.update({"title":title}), "hash":""})
	return {"result":"ok", "content":data, "hash":""}


def edit_comm_post(request):
	if not user_has_permission('des:obj', 'add_com'): return {"result":"fail", "error":"no comment"}
	if not user_is_logged_in(): return {"result":"fail", "error":"no comment"}
	comm_id =   get_post('comm_id')
	body =      get_post('body')
	user =      get_post('user')
	db = request.db

	if user == get_current_user() or is_admin():
		if 'child' in get_doc(comm_id) and not is_admin(): return {"result":"fail", "error":"comment already answered"}
		from core.union import invalidate_cache
		invalidate_cache('single_page')
		return {"result":"ok", "id":comm_id}
	else:
		return {"result":"fail", "error":"access denied"}


def del_comm_post(request):
	""" doc_id - id самого коментария """
	comm_id = get_post('comm_id')
	doc = get_doc(comm_id)
	db = request.db

	if is_admin() or user_has_permission('des:obj', 'del_comm'):
		# добавление подсчета коментариев в отдельном документе
		db.doc.update({ "_id": doc['doc']['owner'] }, { "$inc": { "count_branch":-1 } } )
		if 'child' in doc:
			if len(doc['child']):
				db.doc.update({"_id":comm_id}, {"$set":{'doc.is_del':'true'}})
				return {"result":"ok", "action":"del_dom", "id":comm_id}
		else:
			del_row('des:comments', { comm_id:comm_id })
			return {"result":"ok", "id":comm_id}

	else: return {"result":"fail", "error":"error sequrity"}


def add_vote_comm_post(request):
	"""Вычисляем данные в посте сколько проголосовало и тд."""
	db = request.db
	vote    = get_post('vote')
	comm_id = get_post('comm_id')
	comm = get_doc(comm_id)

	# doc =  db.tree.find_one({'owner':doc_id})
	user = get_current_user(True)
	from libs.sites.sites import check_time
	# comm = doc['tree'][comm_id]


	if check_time( comm['doc']['date'], 'days', int( get_const_value('vote_timeout') ) ):
		return {"result":"fail", "error":u"Голосование уже закончилось"}
	if not 'vote' in comm : comm['vote'] = {"score":0,"votes_count":0, "votes_count_plus":0,"votes_count_minus":0, "voted":{}}
	if not user_has_permission('des:obj', 'vote_com'): return {"result":"fail","error":u"Не имеете права голоса"}
	if not is_admin() and user in comm['vote']['voted'] : return {"result":"fail","error":u"Повторное голосование запрещено"}
	if not is_admin() and user == 'user:'+ct(comm['title']): return {"result":"fail","error":u"Голосовать за себя запрещено"}

	dt = datetime.today().strftime('%Y-%m-%d')
	user_f = get_doc(user)
	if not 'vote' in user_f : user_f['vote'] = {}
	if not dt in user_f['vote'] : user_f['vote'][dt] = {'up': 0, 'down': 0}

	if not is_admin() and int(user_f['vote'][dt]['up']) + int(user_f['vote'][dt]['down']) >= int(float(user_f['doc']['rate'])+1.25):
		return {"result":"fail","error":u"Лимит голосов за сегодня исчерпан"}

	user_f['vote'][dt][vote] += 1
	db.doc.save(user_f)

	comm['vote']['voted'][user] = vote
	if vote == 'up':
		comm['vote']['score'] += 1
		comm['vote']['votes_count_plus'] += 1
	else:
		comm['vote']['score'] -= 1
		comm['vote']['votes_count_minus'] += 1
	comm['vote']['votes_count'] += 1
	db.doc.save(comm)
	comm_vote = comm['vote']

	# начисление балов пользователю
	# u_id = 'user:'+ct(comm['title'])
	u_id = ct( comm['doc']['user'] )
	u = get_doc(u_id)
	if u:
		if not 'rate' in u['doc']:
			u['doc']['rate'] = '0'
			db.doc.save(u)
		if float(u['doc']['rate']) >= 17:
			rate = float(u['doc']['rate']) + (0.02 if vote == 'up' else -0.1)
		else: rate = float(u['doc']['rate']) + (0.2 if vote == 'up' else -0.1)
		#	rate =+ 1 if vote == 'up' else -1
		update_cell(str(u_id), 'des:users', 'rate', str(rate) )

	return {"result":"ok", "score":comm_vote["score"],"votes_count":comm_vote["score"],"charge_string":"","sign":"positive",
	        "votes_count_plus":comm_vote["votes_count_plus"],"votes_count_minus":comm_vote["votes_count_minus"],"is_positive":True}


def ban_comm_post(request):
	if not is_admin(): return {"result":"fail", "error":"no ban"}
	if not user_is_logged_in(): return {"result":"fail", "error":"no comment"}
	proc_id = get_post('proc_id')
	id_comm = get_post('branch_id')
	db = request.db
	doc = db.doc.find_one({'_id':id_comm})

	doc = doc['doc']
	ip = doc['ip'] if 'ip' in doc else ''
	# try:
	lst = [x.strip() for x in get_const_value('ban_comm', '').split(',')]
	# die([lst, ip, branch])
	if not ip in lst:
		lst.append(ip)
	set_const_value('ban_comm', ','.join(lst))

	user_name = ct(doc['user'])
	user = get_doc('user:'+user_name)
	if user:
		user['doc']['ban'] = 'true'
		db.doc.save(user)
	return {"result":"ok", "user":user_name}


#===========================================================================================================


def conf_menu_get(request, action):
	sss = '/tree/data/'+action
	return templ('libs.admin:conf_menu',  request, dict(proc_id=action, url='/tree/data/'+action))


def count_branch(doc):
#	return 1
	ctr = 0
	tree = doc['tree']
	for res in tree.keys():
		ctr +=1
	return ctr-1

def get_doc_tree(request, owner, tree_id):
	db = request.db
	def make_doc_tree():
		doc = {"_id": uuid4().hex, "type": "tree", "tree": { "_": { "children": [ ], "parent": "", "title": { "ru": u"корень", "en": "root" } }}, "seq_id_tree": 1, "owner": owner, "sub_type": tree_id}
		db.tree.save(doc)
		return doc
	if not owner:
		doc = db.tree.find_one({'_id':tree_id})
		if not doc: doc = make_doc_tree()
		return doc
	doc = db.tree.find_one({'owner':owner})
	if doc: return doc
	return make_doc_tree()


def tree_post(request, proc_id):
	if proc_id.startswith('tree:'):
		if not user_has_permission(proc_id[5:], 'view'): return '{"result": "fail", "error": "%s"}' % cgi.escape(ct("You have no permission."))
		return tree_data(proc_id, False)
	else:
		owner = get_post('owner', False)
		proc_id2 = get_post('proc_id', False)
		return tree_data(proc_id, owner) if owner else tree_data(proc_id2, False)


def tree_data(request, proc_id, owner):
	""" Берет из базы данные формирует из них json и возвращает в нужный шаблон"""
	# proc_id = первый раз сom:des:obj
	db = request.db
	lang = cur_lang()
	doc = get_doc_tree(owner, proc_id)
	proc_id = doc['_id']
	def translate_(branch):
		new_children = []
		branch['title'] = ct( branch['title'])
		branch['descr'] = ct( branch['descr'] )if 'descr' in branch else ''
		for child in branch['children']:
			new_children.append(translate_(child))
		branch['children'] = new_children
		return branch

	docs = [res for res in db.doc.find({'doc_type':'des:comments', 'doc.owner':owner}).sort('doc.date', -1) ]
	from libs.sites.sites import get_full_docs
	docs = get_full_docs(docs)
	value = form_tree_comm( docs )
	# value = []

	# value = translate_(form_tree(db.tree.find_one({'_id':proc_id})))
	return json.dumps({"result":"ok", "content":value, "proc_id":proc_id})

	
def check_ban(ip, user):
	lst = [x.strip() for x in get_const_value('ban_comm', '').split(',')]
	user = get_doc(user)
	return (user and 'ban' in user['doc'] and user['doc']['ban'] == 'true') or ip in lst


def accept_comm_post(request):
	if not is_admin(request) and not user_has_permission(request, 'des:comments', 'edit'): return {"result":"fail", "error":"no has permission"}
	data = get_post(request)
	doc_id = data['doc_id']
	doc = request.db.doc.find_one({'_id':doc_id})
	doc['doc']['pre'] = 'false'
	request.db.doc.save(doc)
	owner = doc['doc']['doc_id']
	comm_id = str(doc['doc']['comm_id'])
	tree = request.db.tree.find_one({'_id': owner})
	# die(tree['tree'].keys())
	tree['tree'][comm_id]['pre'] = 'false'
	request.db.tree.save(tree)
	return {"result":"ok"}


def check_user_rate(request, user):
	user_rate = request.db.doc.find_one({'_id':user}, {'doc.rate':1})
	if not user_rate or not 'rate' in user_rate['doc']: return True
	user_rate = float(user_rate['doc']['rate'])
	if user_rate > -5: return True

	for res in request.db.doc.find({'doc_type':'des:comments', 'doc.user':user}, {'doc.date':1}).sort('doc.date', -1).limit(1):
		last_time = res['doc']['date']
		today = datetime.today()
		if user_rate < -5: delta = (today + timedelta(hours=-8)).strftime("%Y-%m-%d %H:%M:%S")
		elif user_rate < -10: delta = (today + timedelta(hours=-12)).strftime("%Y-%m-%d %H:%M:%S")
		elif user_rate < -15: delta = (today + timedelta(hours=-24)).strftime("%Y-%m-%d %H:%M:%S")
		if last_time < delta: return True
		return False
	return True


def form_tree(request, doc, is_comm=False):
	tree = doc['tree']
	revers = get_const_value(request, 'comm_reversed') == "true"

	def get_children(parent_id):
		new_tree = []
		children = tree[parent_id]['children']
		if revers and is_comm: children.reverse()
		for branch_id in children:
			branch = tree[branch_id]
			new_tree.append( get_children(branch_id))
		title = ct(request, tree[parent_id]['title'])
		name = get_current_user_name(request, title)
		ip = None
		if 'ip' in tree[parent_id] and get_settings('is_comm_ip', False):
			ip = tree[parent_id]['ip'][-6:]

		new_branch = {
			'id': parent_id,
			'title': name if is_comm and parent_id != '_' and title.startswith('user:') else title ,
			'descr': ct(request, tree[parent_id]['descr']) if 'descr' in tree[parent_id] else None,
			'date': tree[parent_id]['date'] if 'date' in tree[parent_id] else None,
			'name': name,
			'ip': ip,
			'our': tree[parent_id]['our'] if 'our' in tree[parent_id] else None,
			'is_del': tree[parent_id]['is_del'] if 'is_del' in tree[parent_id] else None,
			'link': tree[parent_id]['link'] if 'link' in tree[parent_id] else None,
			'link2': tree[parent_id]['link2'] if 'link2' in tree[parent_id] else None,
			'for_owner': tree[parent_id]['for_owner'] if 'for_owner' in tree[parent_id] else None,
			'children': new_tree,
			'pre': tree[parent_id]['pre'] if 'pre' in tree[parent_id] else None,
		    'vote': tree[parent_id]['vote'] if 'vote' in tree[parent_id] else {"score":0,"votes_count":0, "votes_count_plus":0,"votes_count_minus":0, "voted":{}}
		}
		return new_branch
	return get_children('_')

def get_current_user_name(request, user_id=None):
	if not user_id:
		user_id = get_current_user(request)
	if user_id:
		doc = request.db.doc.find_one({"_id":'user:'+user_id}, {"head_field.name":1})
		if doc: return doc['head_field']['name']
	else: return 'Гость'