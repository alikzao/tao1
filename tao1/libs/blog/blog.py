
import sys, json

from urllib.parse import *



from core.core import *

from libs.table.table import update_row_, create_empty_row_
from libs.contents.contents import get_doc
from libs.sites.sites import get_full_doc, get_full_docs


import core.union
# _ = core.union.get_trans('user_site')


def user(request, u):
	db = request.db
	uu = u
	u_id    = db.doc.find_one({'doc_type':'des:users', '_id':'user:'+uu})
	u_alias = db.doc.find_one({'doc_type':'des:users', 'doc.nickname':uu})
	u_name  = db.doc.find_one({'doc_type':'des:users', 'doc.name.ru':uu})

	if u_id:      u = u_id
	elif u_alias: u = u_alias
	elif u_name:  u = u_name
	dv = get_full_doc( u['_id'] )

	req = db.doc.find({'doc_type':'des:obj', 'doc.user':u['_id']})
	docs = get_full_docs(req)

	friends = json.loads(json.dumps(u['friends'])) if 'friends' in u else []
	followers = json.loads(json.dumps(u['followers'])) if 'followers' in u else []

	js_friends = json.dumps(u['friends']) if 'friends' in u else []
	js_followers = json.dumps(u['followers']) if 'followers' in u else []


	return templ('user_page', request, dict( doc = dv, docs=docs, doc_id=u['_id'], user_name=ct( u['doc']['name'] ), proc_id='des:users',
	             friends=friends, followers=followers, js_friends=js_friends, js_followers=js_followers) )


def list_users(request):
	req = request.db.doc.find({'doc_type':'des:users'})
	docs = get_full_docs(req)
	return templ('list_users', request, dict(docs=docs))


def add_email(request):
	user = get_full_doc( get_current_user(True) )
	return templ('add_email', request, dict(user=user))


def add_email_post(request):
	email = get_post('email')
	user_id = get_post('user_id')
	db = request.db

	code_sub_in = uuid4().hex
	code_sub_out = uuid4().hex

	db.doc.update({'_id':user_id}, {'$set':{'mail':email, 'doc.mail':email, 'code_sub_in':code_sub_in, 'code_sub_out':code_sub_out}})

	dom = get_settings('domain')
	link_confirm = 'http://'+dom+'/signup/in/'+email+'/'+code_sub_in
	text = """<html><head></head><body>
	       <p>Для подтверждения регистрации на сайте {0} перейдите по следующей <a href="{1}">ссылке</a>.</p>
	       </body></html>""".format( dom, link_confirm )

	route_mail(email, u'Подтверждение регистрации '+dom, text)

	mess = "Для подтверждения регистрации вам на почту выслано письмо."
	return {"result":"ok", 'mess':mess}


def add_mess(request):
	#TODO тут проверка что нужный пользователь залогинен
	db = request.db
	mess = get_post('mess')
	user = get_post('user')
	limit = get_const_value('limit_char', '200')
	mess = mess.decode('UTF-8')
	mess = mess[:int(limit)]

	doc_id, updated = create_empty_row_('des:obj', '_', True, {"user":user, 'date':time.strftime("%Y-%m-%d %H:%M:%S")})
	update_row_('des:obj', doc_id, {'body':mess, 'title':'', 'pub':'true', 'accept':'true'}, '_', no_synh=True,  accept_def = True)

	user = db.doc.find_one({'_id':user})
	user_name = user['doc']['name'][cur_lang()]

	text = u"""<html><head></head><body>
	       <p>Пользователь {0} написал новое <a href="{1}"><b>соощение</b></a>.</p>
	       <p>Прокоментировать и оценить его вы можете <a href="{1}"><b>тут</b></a>.</p>
	       <p>Отписатся от рассылки вы можете перейдя по адресу ...</p></body></html>""".format( user_name, 'http://site.dev/news/'+doc_id )

	if 'friends' in user:
		for res in user['friends']:
			mail = db.doc.find_one({'_id':res}, {'doc.mail':1} )
			route_mail( mail['doc']['mail'], u'Пользователь '+user_name+u' написал новое сообщение, вы на него подписаны.', text)
	if 'followers' in user:
		for res in user['followers']:
			mail = db.doc.find_one({'_id':res}, {'doc.mail':1} )
			route_mail( mail['doc']['mail'], u'Пользователь '+user_name+u' написал новое сообщение, он у вас в друзьях.', text)
	return {"result":"ok", 'mess':mess, 'doc_id':doc_id}


def add_fr(request):
	user_master = get_post('user_m')
	user_slave = get_post('user_s')
	request.db.doc.update({'_id':user_master}, {'$push':{'friends':user_slave}})
	return {"result":"ok"}


def add_sub(request):
	db = request.db
	user_master = get_post('user_m')
	user_slave = get_post('user_s')
	db.doc.update({'_id':user_master}, {'$push':{'followers':user_slave}})
	db.doc.update({'_id':user_slave},  {'$push':{'subscriber':user_master}})

	return {"result":"ok"}



def main_page_signup(request):
	db = request.db
	name =   get_post('name')
	passwd = get_post('passwd')
	email =  get_post('email')
	passwd = getmd5(passwd)

	code_sub_in = uuid4().hex
	code_sub_out = uuid4().hex

	if db.doc.find_one({'doc_type':'des:users', 'doc.name':name}):
		mess = "Такой логин уже есть выберите другой"
		return {"result":"warn", "mess":mess.decode('UTF-8')}

	if db.doc.find_one({'doc_type':'des:users', 'doc.mail':email}):
		mess = "Email {} уже есть выберите другой".format(email)
		return {"result":"warn", "mess":mess.decode('UTF-8')}

	doc = {'_id': 'user:'+email, 'name': name, 'password': passwd, 'mail': email, "type": "table_row", "rate":0, "doc_type": "des:users",
           "doc": {"user":"user:"+name, "name": {'ru':name, 'en':name}, 'date': create_date(), "home": "false", "mail": email },
           'code_sub_in':code_sub_in, 'code_sub_out':code_sub_out}
	db.doc.save(doc)
	db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.user:'+name:'true'}} )
	mess = "Для подтверждения регистрации вам на почту выслано письмо."

	dom = get_settings('domain')
	link_confirm = 'http://'+dom+'/signup/in/'+email+'/'+code_sub_in
	text = u"""<html><head></head><body>
	       <p>Для подтверждения регистрации на сайте {0} перейдите по следующей <a href="{1}">ссылке</a>.</p>
	       </body></html>""".format( dom, link_confirm )

	route_mail(email, 'Подтверждение регистрации '+dom, text)

	return {"result":"warn", "mess":mess.decode('UTF-8')}


def signup_in(request):
	mail = request.match_info.get('mail', '')
	code = request.match_info.get('code', '')
	doc = request.db.doc.find_one({'doc_type':'des:users', 'mail':mail})
	if not doc:
		return templ('error_page', request, {'mess':'Unknown E-mail'} )
	if 'confirmed' in doc['doc'] and doc['doc']['confirmed'] == 'true':
		return templ('error_page', request, {'mess':'Registration has already been confirmed'})
	if 'code_sub_in' in doc['doc'] and doc['doc']['code_sub_in'] != code:
		return templ('error_page', request, {'mess':'Registration code is incorrect'})
	doc['doc']['confirmed'] = 'true'
	doc['doc']['accept'] = 'true'
	request.db.doc.save(doc)
	return templ('error_page', request, {'mess':'Registration successfully verified'})


def main_page_login(request):
	db = request.db
	s = session()
	mail = get_post('mail')
	passwd = get_post('passwd')
	passw = getmd5(passwd)
	for res in db.doc.find({'doc_type':'des:users', 'mail':mail}):
		if not 'confirmed' in res['doc']:
			mess = 'Вы зарегистрированы только через социальные сети, либо не подтвердили свой электронный адрес'
			return {"result":"warn", "mess":mess}
		if passw == res['password']:
			s['user_id'] = mail
			s.save()
			return {"result":"ok", "mess":"Вы успешно вошли на сайт."}



def subscribe_new(request):
	db = request.db
	mail = get_post('mail')
	if db.doc.find_one({'doc_type':'des:subscr', 'doc.mail':mail}):
		return '{"result":"ok", "mess":"Уже подписан"}'
	ip = request.environ.get('REMOTE_ADDR')
	user_agent = request.environ.get('HTTP_USER_AGENT')
	code_sub_in = uuid4().hex
	code_sub_out = uuid4().hex
	doc_id, updated= create_empty_row_('des:subscr', None, False, {})
	update_row_('des:subscr', doc_id, {"mail":mail, "ip":ip, 'user_agent':str(user_agent), 'confirmed': 'false', 'code_sub_in':code_sub_in, 'code_sub_out':code_sub_out}, '_')
	dom = get_settings('domain')
	link_confirm = 'http://'+dom+'/subscribe/in/'+mail+'/'+code_sub_in
	route_mail(mail, 'Подтверждение подписки '+dom, link_confirm)
	return {"result":"ok"}


def subscribe_in(request, mail, code):
	db = request.db
	doc = db.doc.find_one({'doc_type':'des:subscr', 'doc.mail':mail})
	if not doc:
		return templ('sub_anonim_yes', request, dict(mess= 'Неизвестный E-mail'))
	if doc['doc']['confirmed'] == 'true':
		return templ('sub_anonim_yes', request, dict(mess= 'Подписка уже подтверждена'))
	if doc['doc']['code_sub_in'] != code:
		return templ('sub_anonim_yes', request, dict(mess= 'Код подтверждения не верный'))
	doc['doc']['confirmed'] = 'true'
	db.doc.save(doc)
	return templ('sub_anonim_yes', request, dict(mess = 'Подписка успешно подтверждена'))


def subscribe_out(request, mail, code):
	db = request.db
	doc = db.doc.find_one({'doc_type':'des:subscr', 'doc.mail':mail})
	if not doc:
		return templ('sub_anonim_yes',request, dict(mess=u'Такого E-mail нет в базе'))
	if doc['doc']['confirmed'] == 'false':
		return templ('sub_anonim_yes', request, dict( mess=u'Подписка уже отменена'))
	if doc['doc']['code_sub_out'] != code:
		return templ('sub_anonim_yes', request, dict(mess=u'Код подтверждения не верный'))
	doc['doc']['confirmed'] = 'false'
	db.doc.save(doc)
	return templ('sub_anonim_yes', request, dict(mess = u'Подписка успешно отменена'))


def subscribe(request):
	user = get_doc(request, get_current_user(request, True))
	if not 'subscription' in user: user['subscription'] = {}
	return templ('subscribe', request, dict(subscribe = user['subscription']))


def subscribe_post(request):
	user = get_doc(request, get_current_user(request, True))
	if not 'subscription' in user: user['subscription'] = {}
	channel = get_post('channel')
	status = get_post('status')
	user['subscription'][channel] = status
	request.db.doc.save(user)
	return {"result":"ok"}



