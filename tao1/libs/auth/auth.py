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


def user_ban(request): #@route('/logout')
	if not is_admin(request): return {"result":"fail", "error":"no ban"}
	user_id = get_post('user_id')
	doc = request.db.doc.find_one({'_id':user_id})
	if doc:
		doc['doc']['ban'] = 'true'
		request.db.doc.save(doc)
	return response_json(request, {"result":"ok", "user": doc['_id'] })



def root_signup_get(request): #'/signup', 'GET'
	""" Просто показуем окно регистрации """
	hash, raw = get_captcha(False)
	return templ('libs.auth:signup', request, dict(captcha=raw, hash=hash))



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
	request.db.on.remove({"_id": s['user_id']})
	request.db.doc.update({"_id": "user:" + s['user_id']}, {"$set": {"status": "off"}})
	print('logout', request.db.doc.find_one({"_id": "user:" + s['user_id']})  )

	s['user_id'] = 'guest'
	if 'access_token' in s.__dict__:
		s['access_token'] = None
	return web.HTTPSeeOther('/')


async def login_post(request):
	"""If the user exists, then save in database session"""
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
	data = get_post( request )
	mail = data.POST['mail']
	name = data.POST['name']
	captcha = data.POST['captcha']
	hash = data.POST['hash']
	password = data.POST['password']
	address = data.POST['addres']
	phone = data.POST['phone']
#	date = time.strftime("%H:%M:%S %d.%m.%Y")
#	date=time.time()
	passw = getmd5(password)
	if not check_captcha(hash, captcha):
		hash, raw = get_captcha(hash)
		mess="Неправильно введен проверочный код"
		return templ('app.auth:signup', request, dict(name=name, mail=mail, address=address, phone=phone, hash = hash, mess = mess.decode('UTF-8')) )
	#проверяем есть ли такие пользователи в базе если нет то регистрируем
	if not request.db.doc.find_one({'_id':'user:'+name}):
		doc = {'_id': 'user:'+name, 'name': name, 'password': passw, 'mail': mail, "type": "table_row", "rate":0,
				"doc_type": "des:users", "doc": {"user":"user:"+name, "name": {'ru':name, 'en':name}, "old": "33", "phone":phone, "address": address,
					'date': create_date(), "home": "false" } }
		request.db.doc.save(doc)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.user:'+name:'true'}} )
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
	url = "https://api.odnoklassniki.ru/oauth/token.do?code="+code+"&client_id="+ok['id']+"&client_secret="+ok['key']+"&redirect_uri=http://"+settings.domain+"/oauth_ok&grant_type=authorization_code"
	aaa  = requests.post(url)
	resp = json.loads(aaa.content)
	access_token = resp['access_token']
	refresh_token = resp['refresh_token']

	import hashlib
	sign=hashlib.md5('application_key='+ok['pub_key']+'method=users.getCurrentUser'+hashlib.md5(access_token+ok['key']).hexdigest() ).hexdigest()
	url = 'http://api.odnoklassniki.ru/token.do?method=users.getCurrentUser&access_token='+access_token+'&application_key='+ok['pub_key']+'&sig='+sign+'&format=json'
	url = 'http://api.odnoklassniki.ru/fb.do?method=users.getCurrentUser&access_token='+access_token+'&application_key='+ok['pub_key']+'&sig='+sign

	aaa  = requests.get(url)

	res = json.loads(aaa.content)
	s = session(request)
	if 'error' in request.GET: return 'ошибка авторизации' + request.GET['error_description']

	user_id = str(res['uid'])
	user_id = 'user:ok:'+user_id
	user = request.db.doc.find_one({'_id':user_id })
	if user and 'ban' in user['doc'] and user['doc']['ban'] == 'true':
		session_add_mess(u'Ошибка входа на сайт')
		redirect('/')
		return ''
	s['user_id'] = user_id[5:]
	s.save()


	name = res['first_name']+' '+res['last_name']
	old = res['age'] if 'age' in res else ''
	is_mail = False
	if 'mail' in user['doc'] and user['doc']['mail']:  is_mail = True
	if not user:
		is_mail = False
		user = {'_id': user_id, "alien":"vk", 'name': name, 'password': "passw", "type": "table_row", "doc_type":"des:users",
		        "doc":{"user":user_id, "old":old, "phone":"", "address":"", "mail":"", 'rate':0,
		        'date': create_date(), "home": "false", 'name': {'ru':name} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['doc']['name'] = {cur_lang(): name}
	from libs.files.files import link_upload_post_
	link_upload_post_( res['pic_2'], 'des:users', user_id, True)
	request.db.doc.save(user)
	session_add_mess('Вы успешно вошли на сайт')
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

	access_token = resp['access_token']
	user_id = resp['user_id']
	url = 'https://api.vk.com/method/getProfiles?uid='+str(user_id)+'&access_token='+access_token+'&fields=screen_name,email,useroffline,photo'
	aaa  = requests.get(url)
	res = json.loads(aaa.content)['response'][0]
	user_data = { 'id': 'vk:'+str(res['uid']), "link":'http://vk.com/'+res['screen_name'] }
	if 'error' in request.GET: return 'ошибка авторизации' + request.GET['error_description']

	user_id = str(user_id)
	user_id = 'user:vk:'+user_id
	user = request.db.doc.find_one({'_id':user_id })
	if user and 'ban' in user['doc'] and user['doc']['ban'] == 'true':
		session_add_mess(u'Ошибка входа на сайт')
		redirect('/')
		return ''
	s['user_id'] = user_id[5:]
	s.save()
	name = res['first_name']+' '+res['last_name']
	if not user:
		user = {'_id': user_id, "alien":"vk", 'name': name, 'password': "passw", "type": "table_row",
		        "doc_type":"des:users", "doc":{"user":user_id, "old": "", "phone":"", "address":"", "mail":"", 'rate':0,
		                                              'date': create_date(), "home": "false", 'name': {'ru':name} } }
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['doc']['name'] = {cur_lang(): name}
	from libs.files.files import link_upload_post_
	link_upload_post_( res['photo'], 'des:users', user_id, True)
	request.db.doc.save(user)
	session_add_mess(u'Вы успешно вошли на сайт')
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

	if 'error' in request.GET: return 'Authorisation Error' + request.GET['error_description']

	user_id = 'user:tw:'+fs['user_id']
	user = request.db.doc.find_one({'_id':user_id })
	if user and 'ban' in user['doc'] and user['doc']['ban'] == 'true':
		session_add_mess('Error logging in')
		redirect('/')
		return ''

	s['user_id'] = 'tw:'+fs['user_id']
	s.save()
	if not user:
		user = {'_id': user_id, "alien":"tw", 'name': fs['screen_name'], 'password': "passw", "type": "table_row",
		       "doc_type":"des:users", "doc":{"user":user_id, "old": "", "phone":"", "address":"", "mail":"", 'rate':0,
		                'date': create_date(), "home": "false", 'name': {'ru':fs['screen_name']} } }
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['doc']['name'] = {cur_lang(): fs['screen_name']}
	from libs.files.files import link_upload_post_
	request.db.doc.save(user)
	session_add_mess(u'You have successfully logged in')
	redirect('/')



def oauth_ya_login(request):
	ya = settings.oauth_ya
	key = ya['id']
	sec = ya['key']
	url = 'https://oauth.yandex.ru/authorize?response_type=code&client_id='+key
	redirect(url, 302)


def oauth_ya(request):
	ve = request.GET
#	raise Exception (str(ve))
	code = ve['code']
	ya = settings.oauth_ya
	url = 'https://oauth.yandex.ru/token'
	data = {
		'grant_type': 'authorization_code',
		'code': code,
		'client_id': ya['id'],
		'client_secret': ya['key']
	}
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
	user = request.db.doc.find_one({'_id':user_id })
	if not user:
		user = {'_id': user_id, "alien":"ya", 'name': name, 'password': "passw", "type": "table_row",
		        "doc_type":"des:users", "doc":{"user":user_id, "old": "", "phone":"", "address":"", "mail":mail, 'rate':0,
		                                              'date': create_date(), "home": "false", 'name': {'ru':name} }, "hierarchy": { "tree:des:users": "_" }}
		request.db.doc.save(user)
		request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
		user = request.db.doc.find_one({'_id':user_id })
	user['doc']['name'] = {cur_lang(): name}
	request.db.doc.save(user)
	session_add_mess(u'You have successfully logged in')
	redirect('/')


def oauth_gl_login(request):
	gl = get_settings('oauth_gl')
	from oauth2client.client import OAuth2WebServerFlow
	flow = OAuth2WebServerFlow(
		client_id =     gl['id'],
		client_secret = gl['key'],
		scope=          'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
		redirect_uri=   gl["redirect_uri"],
	)
	try:
		url = flow.step1_get_authorize_url()
	except :
		raise Exception('Google Auth 404')
	redirect(request, url, 302)


def oauth_gl(request):
	import httplib2
	code = request.GET['code']

	gl = settings.oauth_gl

	from oauth2client.client import OAuth2WebServerFlow
	flow = OAuth2WebServerFlow(
		client_id =     gl['id'],
		client_secret = gl['key'],
		scope=          'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
		redirect_uri=   gl["redirect_uri"],
		state=          'profile'
	)

	credentials = flow.step2_exchange( code )

	http = httplib2.Http()
	http = credentials.authorize(http)
	resp, content = http.request('https://www.googleapis.com/userinfo/v2/me', method="GET")


	if 'error' in request.GET: return 'error autorize' + request.GET['error_description']
	me = json.loads(content.decode("utf-8"))

	print( 'gl_user', me)

	s = session(request)
	s['user_id'] = me['id']

	user_id = 'user:gl:'+me['id']

	user_db = request.db.doc.find_one({'_id':user_id })
	# if user_db: redirect(request, '/')
	sex = "true" if "gender" in me and me["gender"] == "male" else "false"
	doc = {'_id': user_id, "alien":"fb", 'name': me['name'], 'password': "passw", "doc_type":"des:users",
            "doc":{
	            "nik":me['id'],
	            "user":user_id, "old":'', "phone":"", "mail":me.get('email', ''), "sex":sex,
	            "d_birth":'', 'date': create_date(),
	            "edu": {"en":me.get("bio", '') }, "about":{"en":me.get("about", '')},
	            'name': {'en':me.get('given_name', '')}, "last_name":{"en":me.get('family_name', '') }
            }
       }
	print( 'doc', doc)

	request.db.doc.save(doc)
	# request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )
	# user = request.db.doc.find_one({'_id':user_id })
	# user['doc']['name'] = {cur_lang(request): me['name']}
	# if 'picture' in me:
	# 	from libs.files.files import link_upload_post_
		# link_upload_post_( me['picture'], 'des:users', user_id, True)
	# request.db.doc.save(user)
	# session_add_mess('You have successfully logged in')
	return web.HTTPSeeOther('/')



def count_old(d_birth):
	if d_birth == '-': return d_birth
	from datetime import datetime
	d1 = d_birth
	d2 = datetime.now()
	try:
		d1 = datetime.strptime(d1, "%Y-%m-%d")
	except:
		d1 = datetime.strptime(d1, "%d-%m-%Y")
	d3 = d1 - d2
	d3 = int(abs(d3.days)/365.24)
	return d3


def oauth_fb(request):
	if 'error' in request.GET: return 'Authorisation Error' + request.GET['error_description']
	code = request.GET['code']

	app_id = settings.oauth_fb['id']
	app_secret = settings.oauth_fb['key']
	redirect_uri = settings.oauth_fb['redirect_uri']

	url = "https://graph.facebook.com/oauth/access_token?client_id="+app_id+"&redirect_uri="+redirect_uri +"&client_secret="+app_secret+"&code="+code
	req  = requests.get(url)
	access_token = req.content[13:-16]
	url = 'https://graph.facebook.com/me?fields=id,name,picture,email,birthday,about,first_name,bio,last_name,gender&access_token='+str(access_token.decode("utf-8") )
	me  = requests.get(url)
	me = json.loads(me.content.decode("utf-8"))

	user_id = "user:fb:"+me['id']
	user_db = request.db.doc.find_one({'_id':user_id })
	# if user_db: redirect(request, '/')

	sex = "true" if "gender" in me and me["gender"] == "male" else "false"
	d_birth = me.get('birthday', '/').replace('/', '-')
	old = count_old(d_birth)

	s = session(request)
	s['user_id'] = me['id']

	print( 'user_id ', user_id )
	doc = {'_id': user_id, "alien":"fb", 'name': me['name'], 'password': "passw", "doc_type":"des:users",
	            "doc":{
		            "nik":me['id'],
		            "user":user_id, "old":old, "phone":"", "mail":me.get('email', ''), "sex":sex,
		            "d_birth":d_birth, 'date': create_date(),
		            "edu": {"en":me.get("bio", '') }, "about":{"en":me.get("about", '')},
		            'name': {'en':me.get('first_name', '')}, "last_name":{"en":me.get('last_name', '') }
	            }
	       }
	request.db.doc.save(doc)
	# request.db.doc.update({'_id':'role:simple_users'}, {'$set':{'users.'+user_id:'true'}} )

	return web.HTTPSeeOther('/')


def	get_old_post(request, id, mail):
	cond = {'doc_type':'des:users', 'doc.mail':str(mail), 'doc.user_left':1}
	user = request.db.doc.find_one(cond)
	if not user: return 0
	for res in request.db.doc.find({'doc_type':'des:obj', 'doc.user':user['_id']}):
		res['doc']['user'] = id
		request.db.doc.save(res)
	request.db.doc.remove({'_id':user['_id']})
	return user['doc']['rate'] if 'rate' in user['doc'] else 0


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
		app_id = oauth_fb['id']; app_secret = oauth_fb['key']; site = 'https://www.facebook.com/'
	elif name == 'vkontakte':
#		app_id = '2734012'; app_secret = 'O1676ZSdHEqPmmrBmJFs'; site = 'http://vkontakte.ru/apps.php?act=add'  
		app_id = oauth_vk['id']; app_secret = oauth_vk['key']; site = 'https://vk.com/apps.php?act=add'
	import oauth2 as oauth
	
	consumer = oauth.Consumer(app_id, app_secret)
	consumer = oauth.Consumer(app_id, app_secret)
	client = oauth.Client(consumer)
	resp, content = client.request(site, "GET")
	return json.loads(json.dumps(content, ensure_ascii=False))




