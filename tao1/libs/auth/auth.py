# coding: utf-8

import json, time, tempfile, requests
import base64
import aiohttp
from datetime import datetime

from core.set import *
from settings import *
from libs.contents.contents import *
from libs.sites.sites import *
from core.core import *
from datetime import datetime
from libs.perm.perm import user_has_permission


def show_site():
	redirect('/')

def root_login_get(request):
	""" Просто показуем окно валидации """
	return templ('libs.auth:login', request, {})

def root_login_post(request):  #@route('/login', method='POST')
	"""Проверяем есть ли такой пользователь в базе если етсь 
	то заходим и сохраняем сесию или куки то есть заходим по oAuth """
	s = session()
	login_error = "Incorrect username or password."
	name = request.POST['name']
	password = request.POST['pasw']
	passw = getmd5(password)
	db = users_connect()
	if db.users.find_one({"name":name, 'password':passw}):
		if name == 'admin':
			s['user_id'] = name
			s.save()
			redirect('/admin_conf')
		elif is_admin():
			s['user_id'] = name
			s.save()
			redirect('/conf')
		else:
			s['user_id'] = name
			s.save()
			redirect('http://'+name+'.'+const_domain+'/conf')
	else: 
		return templ('app.auth:login', request,  dict(mess = login_error, env = get_env(), context=env_context()))
	return templ('app.auth:login', request, dict(mess = login_error, env = get_env(), context=env_context()))

def user_ban(request): #@route('/logout')
	if not is_admin(request): return {"result":"fail", "error":"no ban"}
	user_id = get_post('user_id')
	doc = request.db.doc.find_one({'_id':user_id})
	if doc:
		doc['head_field']['ban'] = 'true'
		request.db.doc.save(doc)
	return {"result":"ok", "user": doc['_id'] }



def root_signup_get(request): #'/signup', 'GET'
	""" Просто показуем окно регистрации """
	hash, raw = get_captcha(False)
	return templ('libs.auth:signup', request, dict(captcha=raw, hash=hash))

def root_signup_post(): #@route('/signup', method='POST')
	"""Получаем данные пользователя с формы и заносим их в базу проверяя,
	затем реплицируем базу данных, если проверка удалась то предоставляем вход в базу
	потомn посылку извещения на почту если нужно или капчу ну чтото типа этого"""
	mess = "login please"
	mail = request.POST['mail']
	name = request.POST['name']
	hash = request.POST['hash']
	captcha = request.POST['captcha']
	password = request.POST['password']
	address = request.POST['addres']
	phone = request.POST['phone']
#	date = time.strftime("%H:%M:%S %d.%m.%Y")
	date=time.time()
	passw = getmd5(password)
	db_users = users_connect()
	server = server_connect()
	
	if not check_captcha(hash, captcha): # Если не False
		mess="вы ввели неправильно проверочный код"
		hash, raw = get_captcha(hash)
		return templ('app.auth:signup', name=name, mail=mail, address=address, phone=phone, hash = hash, captcha = raw, mess = mess.decode('UTF-8'))
	#проверяем есть ли такие пользователи в базе если нет то регистрируем
	if not db_users.users.find_one({'name':name}):
		doc_users = {"_id": name, "name": name, "password": passw, "mail": mail, "type": "table_row",
				"doc_type": "users", "head_field": { "user":"user:"+name, "name": name, "old": "33", "phone":phone, "address": address,
					"date": date, "home": "false" }, "hierarchy": { "tree": "3" }}
		db_users.users.save(doc_users) 
#		db_server.create(name)
		server.copy_database('py', name, 'localhost')
		db = server[name]
		doc = {'_id': 'user:'+name, 'name': name, 'password': passw, 'mail': mail, "type": "table_row",
				"doc_type": "users", "head_field": { "user":"user:"+name, "name": name, "old": "33", "phone":phone, "address": address,
					"date": date, "home": "false" }, "hierarchy": { "tree": "3" }}
		db.doc.save(doc)
		doc_role = db.doc.find_one({'_id':'role:admin'})
		doc_role['users'].update({'users.user:'+name:'true'})	
		db.doc.save(doc_role)
		mess = "Поздравляем, можете войти."
		return templ('app.auth:login', mess = mess.decode('UTF-8'), env = get_env())
	else:
		mess = "Такой логин уже есть выберите другой"
		hash, raw = get_captcha(hash)
		return templ('libs.auth:signup', name=name, mail=mail, address=address, phone=phone, hash = hash, captcha = raw,mess = mess.decode('UTF-8'))


def check_login_try(request, ip, success):
	doc = request.db.stat.conf.find_one({"_id":"login_ip"})
	if not doc:
		doc = {"_id":"login_ip", "ip":[]}
#		doc = {"_id":"login_ip", "ip":[("155.22.33.55",["2012:06:05 22:22"]), ("155.22.333.555",["2012:06:05 252:22"]) ]}
		request.db.stat.conf.save(doc)
	dt = (datetime.today() + timedelta(hours=0)).strftime("%Y-%m-%d %H:%M:%S")
	lst = []
	for res in doc['ip']:
		if res[0] == ip:
			lst = res
	if not len( lst):
		lst = [ip, []]
		doc['ip'].append(lst)
	actual = []
	for res in lst[1]:
		dt_d = (datetime.today() + timedelta(hours=-1)).strftime("%Y-%m-%d %H:%M:%S")
		if res > dt_d:
			actual.append(res)
	if len(actual) > 3:
		return False
	if not success:
		actual.append(dt)
	lst[1] = actual
	request.db.stat.conf.save(doc)
	return True


async def login(request):
	""" Просто показуем окно валидации """
	return templ('libs.auth:login', request, {})


async def logout_get(request): #'/logout'
	""" User exit from the site /logout """
	s = await get_session(request)
	s['user_id'] = 'guest'
	if 'access_token' in s.__dict__:
		s['access_token'] = None
	return web.HTTPSeeOther('/')


async def login_post(request):
	"""Если етсь такой пользователь в базе то заходим и сохраняем сесию или куки это oAuth """
	# ip = request.environ.get('REMOTE_ADDR')
	data = get_post( request )
	# s = session(request)
	s = await get_session(request)
	login_error = "access error "
	name = data['name']
	name = name.lower()
	password = data['pasw']
	passw = getmd5(password)

	for res in request.db.doc.find({'_id':'user:'+name}, {"password":1}):
		if passw == res['password']:
			print( 'passwd Ok s1', s )
			s['user_id'] = name
			print( 'passwd Ok s2', s )

			if get_const_value(request, 'redirect_user') != 'external' or is_admin(request):
				return web.HTTPSeeOther('/')
			else:
				return web.HTTPSeeOther('/')
		else:
			# if not check_login_try(ip, False):
			# 	return templ('app.auth:login', mess =u'Вы не прошли авторизацию с нескольких попыток попробуйте еще раз через час')
			return templ('libs.auth:login', request, {"mess": login_error} )
	return templ('libs.auth:login', request, {"mess": login_error})


def signup(request):
	hash, raw = get_captcha(False)
	return templ('libs.auth:signup', request, dict(captcha=raw, hash=hash))


def signup_post(request):
	"""Получаем данные пользователя с формы и заносим их в базу проверяя,
	если удачно то предоставляем вход в базу потом дополнительные идентификац"""
	mess = "login please"
	mail = request.POST['mail']
	name = request.POST['name']
	captcha = request.POST['captcha']
	hash = request.POST['hash']
	password = request.POST['password']
	address = request.POST['addres']
	phone = request.POST['phone']
#	date = time.strftime("%H:%M:%S %d.%m.%Y")
#	date=time.time()
	passw = getmd5(password)
	db = connect()
	if not check_captcha(hash, captcha): # Если не False
		hash, raw = get_captcha(hash)
#	if hash != c[1] or captcha!=c[0]TT:
		mess="Неправильно введен проверочный код"
		return templ('app.auth:signup', request, dict(name=name, mail=mail, address=address, phone=phone, hash = hash, mess = mess.decode('UTF-8')) )
#	str_mail = re.sub(r"[@\.]", "$", mail)
	#проверяем есть ли такие пользователи в базе если нет то регистрируем
	if not db.doc.find_one({'_id':'user:'+name}):
		doc = {'_id': 'user:'+name, 'name': name, 'password': passw, 'mail': mail, "type": "table_row", "rate":0,
				"doc_type": "des:users", "head_field": {"user":"user:"+name, "name": {'ru':name, 'en':name}, "old": "33", "phone":phone, "address": address,
					'date': create_date(), "home": "false" }, "hierarchy": { "tree": "3" }}
		db.doc.save(doc) 
		db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.user:'+name:'true'}} )
		mess = "Поздравляем, можете войти."
	else:
		mess = "Такой логин уже есть выберите другой"
	return templ('libs.auth:login', request, dict(mess = mess.decode('UTF-8')) )


def oauth_ok_post():
	pass


def oauth_ok(request):
	import requests
	if 'error' in request.GET:
		return 'ошибка авторизации' + request.GET['error_description']
	code = request.GET['code']
	ok = settings.oauth_ok
	# url = "https://api.vk.com/oauth/access_token?client_id="+ ok['id']+"&client_secret="+ ok['key']+"&code=" + code + "&redirect_uri=http://"+settings.domain+"/oauth_vk"
	# http://edu.daoerp.com/static/static/img/clean.jpg
	url = "https://api.odnoklassniki.ru/oauth/token.do?code="+code+"&client_id="+ok['id']+"&client_secret="+ok['key']+"&redirect_uri=http://"+settings.domain+"/oauth_ok&grant_type=authorization_code"
	# url = "https://api.odnoklassniki.ru/oauth/token.do?code="+code+"&client_id="+ok['id']+"&client_secret="+ok['key']+"&redirect_uri=http://"+settings.domain+"/oauth_ok&grant_type={grant_type}"
	aaa  = requests.post(url)
	# {"access_token":"dwipa.7912dvrsxji0049e565qh4a3k3d","refresh_token":"971547395341_382ca2a1321d0c24cfd1ef1964e2f4ea0d_573991092e",
	# "token_type":"session","expires_in":"1800"}

	resp = json.loads(aaa.content)
	# resp = aaa.content

	access_token = resp['access_token']
	refresh_token = resp['refresh_token']

	# http://edu.daoerp.com/oauth_ok?code=1gN0BfuIGEi3k3dyPtAtaTXMhJJEqRMvXAUFzQu…BeSQPexu3FtTeGWqB0jG7lsMVMVaW2ltM0m3cqJII6lNv574vcqfO54MG4PfyVqHxkWpXZNCvJ

	import hashlib
	sign=hashlib.md5('application_key='+ok['pub_key']+'method=users.getCurrentUser'+hashlib.md5(access_token+ok['key']).hexdigest() ).hexdigest()
	# sign=hashlib.md5('application_key='+'pub_key'+'method=users.getCurrentUser'+hashlib.md5('access_token'+'ok').hexdigest()).hexdigest()
	url = 'http://api.odnoklassniki.ru/token.do?method=users.getCurrentUser&access_token='+access_token+'&application_key='+ok['pub_key']+'&sig='+sign+'&format=json'
	url = 'http://api.odnoklassniki.ru/fb.do?method=users.getCurrentUser&access_token='+access_token+'&application_key='+ok['pub_key']+'&sig='+sign

	# aaa  = requests.post(url)
	aaa  = requests.get(url)
	# die(aaa.content)

	# res = json.loads(aaa.content)['response'][0]
	res = json.loads(aaa.content)
	s = session(request)
	if 'error' in request.GET: return 'ошибка авторизации' + request.GET['error_description']

	user_id = str(res['uid'])
	user_id = 'user:ok:'+user_id
	user = request.db.doc.find_one({'_id':user_id })
	if user and 'ban' in user['head_field'] and user['head_field']['ban'] == 'true':
		session_add_mess(u'Ошибка входа на сайт')
		redirect('/')
		return ''
	s['user_id'] = user_id[5:]
	s.save()


	name = res['first_name']+' '+res['last_name']
	old = res['age'] if 'age' in res else ''
	is_mail = False
	if 'mail' in user['head_field'] and user['head_field']['mail']:  is_mail = True
	if not user:
		is_mail = False
		user = {'_id': user_id, "alien":"vk", 'name': name, 'password': "passw", "type": "table_row", "doc_type":"des:users",
		        "head_field":{"user":user_id, "old":old, "phone":"", "address":"", "mail":"", 'rate':0,
		        'date': create_date(), "home": "false", 'name': {'ru':name} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['head_field']['name'] = {cur_lang(): name}
	from libs.files.files import link_upload_post_
	link_upload_post_( res['pic_2'], 'des:users', user_id, True)
	request.db.doc.save(user)
	session_add_mess(u'Вы успешно вошли на сайт')
	if is_mail: redirect('/')
	else: redirect('/add_email')

def oauth_vk(request):
	import requests
	s = session(request)
	if 'error' in request.GET:
		return 'ошибка авторизации' + request.GET['error_description']
	code = request.GET['code']
	vk = settings.oauth_vk
	site = 'http://vk.com/'
	url = "https://api.vk.com/oauth/access_token?client_id="+ vk['id']+"&client_secret="+ vk['key']+"&code=" + code + "&redirect_uri=http://"+settings.domain+"/oauth_vk"
	aaa  = requests.get(url)
	resp = json.loads(aaa.content)
#	die("http://"+settings.domain+"/oauth_vk")
#	die(aaa.content)

	access_token = resp['access_token']
	# vd_log('vk', access_token)
	user_id = resp['user_id']
	url = 'https://api.vk.com/method/getProfiles?uid='+str(user_id)+'&access_token='+access_token+'&fields=screen_name,email,useroffline,photo'
	aaa  = requests.get(url)
	res = json.loads(aaa.content)['response'][0]
#	raise Exception(str(res))
	user_data = { 'id': 'vk:'+str(res['uid']), "link":'http://vk.com/'+res['screen_name'] }
#	s['user_id'] = user_data['id']
#	s.save()
	if 'error' in request.GET: return 'ошибка авторизации' + request.GET['error_description']

	user_id = str(user_id)
	user_id = 'user:vk:'+user_id
	user = request.db.doc.find_one({'_id':user_id })
	if user and 'ban' in user['head_field'] and user['head_field']['ban'] == 'true':
		session_add_mess(u'Ошибка входа на сайт')
		redirect('/')
		return ''
	s['user_id'] = user_id[5:]
	s.save()
	name = res['first_name']+' '+res['last_name']
	if not user:
		user = {'_id': user_id, "alien":"vk", 'name': name, 'password': "passw", "type": "table_row",
		        "doc_type":"des:users", "head_field":{"user":user_id, "old": "", "phone":"", "address":"", "mail":"", 'rate':0,
		                                              'date': create_date(), "home": "false", 'name': {'ru':name} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['head_field']['name'] = {cur_lang(): name}
	from libs.files.files import link_upload_post_
	link_upload_post_( res['photo'], 'des:users', user_id, True)
	request.db.doc.save(user)
	session_add_mess(u'Вы успешно вошли на сайт')
	# log_event('User logged via vkpntacte')
	redirect('/')


def oauth_tw_login(request):
	from twython import Twython
	tw = settings.oauth_tw

	twitter = Twython(tw['id'], tw['key'] )

	auth = twitter.get_authentication_tokens()
	url = auth['auth_url']
	at1 = auth['oauth_token']
	at2 = auth['oauth_token_secret']

	s = session(request)
	s['twitter/auth'] = {'key': at1, 'secret': at2}
	s.save()
	redirect(url, 302)


def oauth_tw(request):
	from twython import Twython

	s = session(request)
	if not 'twitter/auth' in s: raise Exception('Twitter Auth Redirect Error')
	tok = s['twitter/auth']

	oauth_verifier = request.GET['oauth_verifier']
	tw = settings.oauth_tw


	twitter = Twython(tw['id'], tw['key'], tok['key'], tok['secret'])
	fs = twitter.get_authorized_tokens(oauth_verifier)

	ERROR = "{u'oauth_token_secret': u'iVzCRqZnaLZmdx0Ln298cyREefi6PIMNzo0BbWthzJ81v', u'user_id': u'1062335046', u'x_auth_expires': u'0', " \
	        "u'oauth_token': u'1062335046-KVHAMVwD8D1rvE99qby4wH5JGUtnxlHOa0xNoQW', u'screen_name': u'pauluskpsite'}"

	if 'error' in request.GET: return 'ошибка авторизации' + request.GET['error_description']

	user_id = 'user:tw:'+fs['user_id']
	user = request.db.doc.find_one({'_id':user_id })
	if user and 'ban' in user['head_field'] and user['head_field']['ban'] == 'true':
		session_add_mess(u'Ошибка входа на сайт')
		redirect('/')
		return ''

	s['user_id'] = 'tw:'+fs['user_id']
	s.save()
	if not user:
		user = {'_id': user_id, "alien":"tw", 'name': fs['screen_name'], 'password': "passw", "type": "table_row",
		       "doc_type":"des:users", "head_field":{"user":user_id, "old": "", "phone":"", "address":"", "mail":"", 'rate':0,
		                'date': create_date(), "home": "false", 'name': {'ru':fs['screen_name']} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['head_field']['name'] = {cur_lang(): fs['screen_name']}
	from libs.files.files import link_upload_post_
	# link_upload_post_( tw_user.profile_image_url, 'des:users', user_id, True)
	request.db.doc.save(user)
	session_add_mess(u'Вы успешно вошли на сайт')
	redirect('/')



def oauth_ya_login(request):
	ya = settings.oauth_ya
	key = ya['id']
	sec = ya['key']
#	url = 'https://oauth.yandex.ru/authorize?response_type=<token|code>&client_id='+key+'[&display=popup][&state=<state>]'
	url = 'https://oauth.yandex.ru/authorize?response_type=code&client_id='+key
#	token = urllib.open(url)
#	s = session()
	redirect(url, 302)


def oauth_ya(request):
	ve = request.GET
#	raise Exception (str(ve))
	code = ve['code']
	ya = settings.oauth_ya
#	url = 'http://pauluskp.py.mongo/oauth_ya#access_token='+code+'&token_type=bearer&state='
	url = 'https://oauth.yandex.ru/token'
	data = {
		'grant_type': 'authorization_code',
		'code': code,
		'client_id': ya['id'],
		'client_secret': ya['key']
	}
#	data = '&'.join(i for i, v in )
#	raise Exception(str(urlencode(data)))
	import urllib2
	try:
		rq = urllib2.Request(url, urlencode(data))
		f = urllib2.urlopen(rq)
		text = f.read().decode('utf8')
	except urllib2.URLError as e:
		raise Exception(e.fp.read())

	data = json.loads(text)
	s = session(request)
	s['oauth/yandex'] = data['access_token']

	url = 'https://api-yaru.yandex.ru/me/'
	try:
		f = urllib2.urlopen(urllib2.Request(url, headers={'Authorization': 'OAuth %s' % data['access_token']})).read()
	except urllib2.URLError as e:
		raise Exception(e.fp.read())

	import lxml.etree, lxml.html
	doc = lxml.html.document_fromstring(f)
	id = doc.cssselect('[rel=www]')[0].get('href')
	mail = doc.cssselect('email')[0].text
	name = doc.cssselect('name')[0].text

	user_id = 'user:ya:'+id[7:-6]
	s['user_id'] = 'ya:'+id[7:-6]
	s.save()
	#	user_id = 'user:tw:'+tw_user['id_str']
	user = request.db.doc.find_one({'_id':user_id })
	if not user:
		user = {'_id': user_id, "alien":"ya", 'name': name, 'password': "passw", "type": "table_row",
		        "doc_type":"des:users", "head_field":{"user":user_id, "old": "", "phone":"", "address":"", "mail":mail, 'rate':0,
		                                              'date': create_date(), "home": "false", 'name': {'ru':name} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['head_field']['name'] = {cur_lang(): name}
	request.db.doc.save(user)
	session_add_mess(u'Вы успешно вошли на сайт')
	redirect('/')


def oauth_gl_login(request):
	gl = get_settings('oauth_gl')
	from oauth2client.client import OAuth2WebServerFlow
	flow = OAuth2WebServerFlow(
		client_id = gl['id'],
		client_secret = gl['key'],
		scope='https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
		redirect_uri='http://'+settings.domain+'/oauth_gl'
	)
	try:
		url = flow.step1_get_authorize_url()
	except :
		raise Exception('Google Auth 404')
#	raise Exception(str(flow.__dict__))
#	s['google/auth'] = {'key': flow.request_token.key, 'secret': flow.request_token.secret}
#	s.save()
	redirect(url, 302)


def oauth_gl(request):
	import httplib2
	ve = request.GET

	gl = settings.oauth_gl

#	{"web":{"auth_uri":"https://accounts.google.com/o/oauth2/auth","client_secret":"UXErK0otyK82IlaWIGOgLY9k","token_uri":"https://accounts.google.com/o/oauth2/token","client_email":"154285046201@developer.gserviceaccount.com","redirect_uris":["http://localhost/oauth_gl"],"client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/154285046201@developer.gserviceaccount.com","client_id":"154285046201.apps.googleusercontent.com","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","javascript_origins":["http://localhost"]}}
	from oauth2client.client import OAuth2WebServerFlow
	flow = OAuth2WebServerFlow(
		client_id = gl['id'],
		client_secret = gl['key'],
		scope='https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
		redirect_uri='http://'+settings.domain+'/oauth_gl',
		state='profile'
	)

	credentials = flow.step2_exchange(ve['code'])

	http = httplib2.Http()
	http = credentials.authorize(http)
	resp, content = http.request('https://www.googleapis.com/userinfo/v2/me', method="GET")
#	raise Exception(str(content))

#	if not 'google/auth' in s: raise Exception('Google Auth Redirect Error')
#	tok = s['google/auth']

	s = session(request)
	if 'error' in request.GET: return 'ошибка авторизации' + request.GET['error_description']
	gl_user = content
	gl_user = json.loads(content)
	s['user_id'] = 'gl:'+gl_user['id']
	s.save()
	user_id = 'user:gl:'+gl_user['id']
	#	user_id = 'user:tw:'+tw_user['id_str']
	user = request.db.doc.find_one({'_id':user_id })
	if not user:
		user = {'_id': user_id, "alien":"gl", 'name': gl_user['name'], 'password': "passw", "type": "table_row",
		        "doc_type":"des:users", "head_field":{"user":user_id, "old": "", "phone":"", "address":"", "mail":gl_user['email'], 'rate':0,
		                                              'date': create_date(), "home": "false", 'name': {'ru':gl_user['name']} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['head_field']['name'] = {cur_lang(): gl_user['name']}
	if 'picture' in gl_user:
		from libs.files.files import link_upload_post_
		link_upload_post_( gl_user['picture'], 'des:users', user_id, True)
	request.db.doc.save(user)
	session_add_mess(u'Вы успешно вошли на сайт')
	redirect('/')



def oauth_fb_(request):
	import facepy
	from urlparse import parse_qs
	from facepy import GraphAPI
	from facepy.utils import get_extended_access_token
	oauth_fb = settings.oauth_fb
	id = oauth_fb['id']
	key = oauth_fb['key']
	access_token = facepy.utils.get_application_access_token( id, key)
	token_app=     facepy.utils.get_application_access_token('APP_ID','APP_SECRET_ID')
	graph = GraphAPI(access_token)
	post = graph.get('/me')
	# die( post )


def oauth_fb(request):
	s = session(request)

	if 'error' in request.GET: return 'ошибка авторизации' + request.GET['error_description']
	code = request.GET['code']
	wwww = request.GET['wwww']
	www = wwww.replace('_', '=')
	app_id = settings.oauth_fb['id']; app_secret = settings.oauth_fb['key']
	rr = request.environ['wsgi.url_scheme']+'://'+request.environ['HTTP_HOST']+'/oauth_fb?wwww='+wwww
	ee = base64.b64decode(www)
	# die(rr)
	url = "https://graph.facebook.com/oauth/access_token?client_id="+app_id+"&redirect_uri="+rr+"&client_secret="+app_secret+"&code="+code

	aaa  = requests.get(url)
	if aaa.content[12] == '|': access_token = aaa.content[13:]
	else: access_token = aaa.content[13:-16]

	s['access_token'] = access_token
	url = 'https://graph.facebook.com/me?access_token='+access_token
	aaa  = requests.get(url)
	if 'error' in aaa.content: pass
	res = json.loads(aaa.content)
	if not 'id' in res:
		mess = u'Вы не смогли залогинится. Есть несколько причин.<br/>' \
		       u'1) Фейсбук не вернул ваш ID. Перезагрузите страницу и попробуйте зайти еще раз.<br/>'\
		       u'2) Возможно что то пошло не так просьба связатся с администрацией ".<br/>' + aaa.content
		return templ('app.auth:error', request, dict(mess=mess))
	fb_id = str(res['id'])
	user_data = { 'id': 'fb:'+fb_id, "link":res['link'] }
	user_id = 'user:fb:'+fb_id

	rrr = request.db.doc.find_one({'_id':user_id })
	if rrr and 'ban' in rrr['head_field'] and rrr['head_field']['ban'] == 'true':
		session_add_mess(u'Ошибка входа на сайт')
		redirect('/')
		return ''

	s['user_id'] = user_data['id']
	s.save()
	if not rrr:
#		rate = float(get_old_post(user_id, res['email']))
		doc = {'_id': user_id, "alien":"fb", 'name': res['name'], 'password': "passw", "type": "table_row",
				"doc_type":"des:users", "head_field":{"user":user_id, "old": "", "phone":"", "address":"", "mail":res['email'], 'rate':0,
				'date': create_date(), "home": "false", 'name': {'ru':res['name']} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(doc)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
	elif not 'mail' in rrr['head_field']:
		rate = get_old_post(user_id, res['email'])
		rrr['head_field']['mail'] = res['email']
		rrr['head_field']['rate'] = rate
		rrr['head_field']['name'] = {cur_lang(): res['name']}
#		rrr['head_field']['name'][cur_lang()] = res['name']
		request.db.doc.save(rrr)
	else:
		rrr['head_field']['name'] = {cur_lang(): res['name']}
		request.db.doc.save(rrr)

	#if check_fb_friend(fb_id):
	#	db.doc.update({'_id':'role:forum'}, {'$set':{'users.'+user_id:'true'}} )
	#else:
	#	db.doc.update({'_id':'role:forum'}, {'$unset':{'users.'+user_id:1}} )

	session_add_mess(u'Вы успешно вошли на сайт')
	trigger_hook('auth', {'fb_id':fb_id, 'user_id':user_id})

	# занесение картинки пользователя в базу
	# запрос на получение картинки с первым запросом не выдает
	url = 'https://graph.facebook.com/me/picture?access_token='+access_token
	aaa  = requests.get(url)
	from libs.files.files import add_file_raw
	import hashlib
	try:
		res = json.loads(aaa.content)
		if 'data' in res and 'url' in res['data']:
			aaa = requests.get(res['data']['url'])
	except Exception:
		pass
	if str(hashlib.md5( aaa.content).hexdigest()) == 'af10cdc4144e0a16b097a293b0d95422':
		del_files(user_id, 'avatar', 'des:users')
	else:
		add_file_raw('des:users', user_id, aaa.content, aaa.headers['content-type'], 'avatar', pref='user_icon')
	redirect(ee)


def	get_old_post(request, id, mail):
	cond = {'doc_type':'des:users', 'head_field.mail':str(mail), 'head_field.user_left':1}
	user = request.db.doc.find_one(cond)
	if not user: return 0
	for res in request.db.doc.find({'doc_type':'des:obj', 'head_field.user':user['_id']}):
		res['head_field']['user'] = id
#		res['head_field']['rate'] = id
		request.db.doc.save(res)
	request.db.doc.remove({'_id':user['_id']})
	return user['head_field']['rate'] if 'rate' in user['head_field'] else 0


def req_fb(req, is_json = False):
	s = session()
	if not 'access_token' in s: return
	url = 'https://graph.facebook.com/'+req+'?access_token='+s['access_token']
	aaa  = requests.get(url)
	if is_json: return json.loads(aaa.content)
	return aaa.content


def check_fb_friend(fb_id):
	friends = json.loads(req_fb(fb_id+'/friends'))
	for res in friends['data']:
		if res['id'] == settings.oauth_fb['vip']:
			return True
	return False


def oauth_action_post(request):
	name = request.POST['name']
	site = None; app_id=None; app_secret=None
	if name == 'facebook':
#		app_id = '312290002124713'; app_secret = 'edcac76ddb0ff8d9bd6663901c03d835'; site = 'http://www.facebook.com/' 
		app_id = oauth_fb['id']; app_secret = oauth_fb['key']; site = 'http://www.facebook.com/'  
	elif name == 'vkontakte':
#		app_id = '2734012'; app_secret = 'O1676ZSdHEqPmmrBmJFs'; site = 'http://vkontakte.ru/apps.php?act=add'  
		app_id = oauth_vk['id']; app_secret = oauth_vk['key']; site = 'http://vk.com/apps.php?act=add'
	import oauth2 as oauth
	
	
	consumer = oauth.Consumer(app_id, app_secret)
#	token = oauth.Token('access-key-here','access-key-secret-here')
#	client = oauth.Client(consumer, token)
#	response = client.request(site)
	
#	consumer = oauth.Consumer(key=settings.OATH_CONSUMER_KEY, secret=settings.OATH_SECRET)
#	token = oauth.Token(token.token, token.secret)
#	client = oauth.Client(consumer, token)
	consumer = oauth.Consumer(app_id, app_secret)
	client = oauth.Client(consumer)
	resp, content = client.request(site, "GET")
	return json.loads(json.dumps(content, ensure_ascii=False))


def repost_fb_post(request):
	user = get_current_user(True)
	if not user.startswith('user:fb:'): return
	content = req_fb('me/feed', True)
	ctr = 1
	for res in content['data']:
		if not ctr: break
		ctr -=1
		if 'privacy' in res and res['privacy']['value'] and res['privacy']['value'] != 'EVERYONE': continue
		if request.db.doc.find_one({'head_field.fb_id':res['id']}): continue
		body = ""; title=""
		doc_id, updated = create_empty_row_('des:obj', '_', {})
		if 'picture' in res:
			fb_img_id = False
			b = res['link'].find('fbid=')
			if b:
				b += 5
				e = res['link'].find('&', b)
				fb_img_id = res['link'][b:e]
			if fb_img_id:
				img = req_fb(fb_img_id, True)
				if 'source' in img:
					img_url = img['source']
					from libs.files.files import add_file_raw
					try:
						bbb  = requests.get(img_url)
						add_file_raw('des:obj', doc_id, bbb.content, bbb.headers['content-type'], fb_img_id)
						body += '<img src="/img/des:obj/%s/%s/img" />' % (doc_id, fb_img_id)
					except Exception:
						pass
#		if 'type' in res and res['type']
		if 'message' in res:
			title = res['message'][:50]
			body += '<div>'+res['message']+'</div>'
		if 'story' in res:
			title = res['story'][:50]
			body += '<div>'+res['story']+'</div>'
		if 'link' in res and 'name' in res:
			body += '<div><a href="%s">%s</a></div>'%(res['link'], res['name'])
			if 'caption' in res: body += '<div>'+res['caption']+'</div>'
			title = res['name'][:50]

		date = res['created_time']
		date = date[:10] + ' '+date[11:19]
		update_row_('des:obj', doc_id, {"body":body, 'date':date, 'pub':'true', 'title':title, 'fb_id':res['id'], 'tags': u'facebook, импорт', 'user':user}, '_', no_synh=True, accept_def=True)
	return {"result":"ok"}


def synh_doc_fb(request, doc_id, user):
	user = get_current_user(True)
	if user.startswith('user:fb:'): user = user[8:]
	else: return
	#	id_page = '350206461728430' #test страница
	id_page = settings.oauth_fb['public_page'] #test страница
	#	id_page = '477596152258286' #test группа
	#	id_page = 'alex.zao.9' #
	s = session(request)
	import requests
	doc = get_doc(doc_id)
	doc_mess = ct(doc['head_field']['body'])
	doc_mess = re.sub('<[^<]+?>', '', doc_mess)
	url = 'https://graph.facebook.com/'+id_page+'/feed' #?message='+doc_mess+'&target_id='+id_page +'&uid='+user+'&access_token='+s['access_token'] #GROUP_ID/feed
	#	url = 'https://api.facebook.com/method/stream.publish?message='+doc_mess+'&attachment='.$attachment.'&target_id=’.PAGE_ID.’&uid=’.UID.’&access_token='.$facebook->getAccessToken();
	#	url = 'https://graph.facebook.com/me?access_token='+access_token
	doc_mess = doc_mess.replace('&nbsp;', ' ')
	aaa  = requests.post(url, {'message':doc_mess, 'access_token':s['access_token'], 'published':True })
#	die(aaa.content)
	c = json.loads(aaa.content)
	if 'id' in c:
		fb_id = c['id']
		doc['head_field']['fb_id'] = fb_id
		request.db.doc.save(doc)
#	aaa  = requests.post(url, {'message':doc_mess, 'target_id':id_page, 'uid':user, 'access_token':s['access_token'] })

def synh_comm_fb(request, doc_id, user, comm_id):
	user = get_current_user(True)
	if user.startswith('user:fb:'): user = user[8:]
	else: return
	id_page = settings.oauth_fb['public_page'] #test страница
	s = session(request)
	import requests
	tree = get_doc_tree_(doc_id)
	doc = get_doc(tree['owner'])
	doc_mess = tree['tree'][str(comm_id)]
	if not 'fb_id' in doc['head_field'] or not doc['head_field']['fb_id']: return
	fb_id = doc['head_field']['fb_id']
	url = 'https://graph.facebook.com/'+fb_id+'/comments' #?
	aaa  = requests.post(url, {'message':ct(doc_mess['descr']), 'access_token':s['access_token'] })
	c = json.loads(aaa.content)
	fb_id = c['id']
	doc_mess['fb_id'] = fb_id
	request.db.tree.save(tree)



# db.doc.update({'_id':'user:daoerp'}, {$set:{'password':'3efe60e786fe94437c3c8dc1d6d83b6b'}})
