import sys, io
from urllib import *
import  urllib
from urllib.parse import *

import io


import email.utils
from PIL import Image, ImageDraw

import time, json, shutil, requests
from gridfs import GridFS
from libs.contents.contents import *

from settings import *



#@cache.cache('img', type='memory', expire=settings.cache_img)
def img_m(request, proc_id, doc_id, img, action='img'):
	fs = GridFS(request.db)
	prefix=''
	if action == 'img': prefix='orig'
	elif action == 'thumb_img': prefix='thumb'
	elif action == 'middle_img': prefix='middle'

	fn = get_file_meta(proc_id, img, doc_id, prefix)
	if not fn: return None, None, None
	f = fs.get(fn['_id']) # метод гридфс
	return fn, f, prefix

def img(proc_id, doc_id, img, action='img'):
	""" возвращает файл и информацию о нем, для статики
	"""
	att = None
	try:
		fn, att, prefix = img_m(proc_id, doc_id, img, action)
		if not fn:
			return http_err(404, '')
		response.headers['Content-Length'] = fn['length']   #возвращает информацию О файле    st_size-размер файла в байтах, st_mtime-время последней моификации содержания файла
		lm = locale_date("%a, %d %b %Y %H:%M:%S GMT", fn['uploadDate'].timetuple(), 'en_US.UTF-8')
		response.headers['Last-Modified'] = lm

		ims = request.environ.get('HTTP_IF_MODIFIED_SINCE')
		if ims: #если файл не менялся то достаточно передать 304 заголовок
			ims_ = parse_date(ims.split(";")[0].strip())

		if ims and ims_ and ims > fn['uploadDate'].strftime('%Y-%m-%d %H:%M:%S'):
			response.headers['Date'] = locale_date("%a, %d %b %Y %H:%M:%S GMT", time.gmtime(), 'en_US.UTF-8')
			response.status = 304
			return ''

		response.headers['Content-Type'] = fn['mime']
		l = (len (prefix) + 1) if prefix else 0
		response.headers['Cache-Control'] = 'max-age=604800'
		aaa  = att.read()
	finally:
		if att: att.close()
	# att.close()
	return aaa

def get_nf(request, proc_id, doc_id, is_limit=0, avatar=False, default_img=None):
	""" Получение списка имен файла в документе  """
	return get_nf_(request, proc_id, doc_id, is_limit, avatar, default_img)


def get_nf_(request, proc_id, doc_id, is_limit=0, avatar=False, default_img=None):
	""" Получение списка имен файла в документе  """
	attachments = {}
	attachments_n = {}; ctr = 0
	# /des:ware/7ce9/2/
	# condition = {'doc_id':doc_id, 'proc_id': proc_id, 'file_name': 'orig_avatar' if avatar else re.compile('^thumb_', re.I | re.U)}
	if get_settings('is_disk', False):
		doc = get_doc(doc_id)
		if 'files' in doc:
			for k, v in doc['files'].items():
				ctr += 1
				fne = v.encode('utf-8') if type(v) == str else v

				attachments[v] = {
					'filename': fne,
					# 'filename': '/files/'+quote(fne),
					'orig':  '/files/'+quote(fne),
					'thumb': '/files/'+quote(fne)
					# 'thumb': '/files/thumb_'+quote(fne)
				}
				if is_limit == ctr: break
			# die(  attachments  )
			return attachments

	if default_img:
		# condition = {'doc_id':doc_id}
	# 	condition = {'doc_id':doc_id, 'file_name': 'orig_' + default_img }
		condition = {'doc_id':doc_id, 'file_name': re.compile('^orig_', re.I | re.U) }
	else:
		condition = {'doc_id':doc_id, 'file_name': 'orig_avatar' if avatar else re.compile('^thumb_', re.I | re.U)}
	req = request.db.fs.files.find(condition)
	if is_limit:
		req = req.limit(is_limit)
	for res in req:
#		if is_limit != None and ctr==is_limit: break
		fn = res['file_name']
		if fn[4] == '_': fn = fn[5:]
		elif fn[5] == '_': fn = fn[6:]
		if type(fn) == str:
			fne = fn.encode('utf-8')
		else: fne = fn
		attachments[fn] = {
			'filename': fn,
			'orig': '/img/'+proc_id+'/'+doc_id+'/'+quote(fne)+'/img',
			'thumb': '/img/'+proc_id+'/'+doc_id+'/'+quote(fne)+'/thumb_img'
			#'orig': '/img/'+proc_id+'/'+doc_id+'/'+fn+'/img',
			#'thumb': '/img/'+proc_id+'/'+doc_id+'/'+fn+'/thumb_img'
		}
		# attachments['filename'] = fn
		# attachments['orig'] = '/img/'+proc_id+'/'+doc_id+'/'+quote(fne)+'/img'
		# attachments['thumb']= '/img/'+proc_id+'/'+doc_id+'/'+quote(fne)+'/thumb_img'

	try:
		video = get_doc(doc_id)
		if 'files' in video and video['files']:
			for res in video['files']:
				attachments[res] = {'filename':res}
	except:pass
	return attachments

#@cache.cache('get_nf', type='memory', expire=120)
def get_teg_img(proc_id, doc_id):
	att = get_nf(proc_id, doc_id, is_limit=0, avatar=False)
	if not att.keys(): return ''
	return '<img src="http://{0}{1}" />'.format(get_settings('domain'), htmlspecialchars(att[att.keys()[0]]['orig']))


def get_file_names_post():
	is_limit=None
	doc_id = get_post('doc_id')
	proc_id = get_post('proc_id')
	t = get_nf_(proc_id, doc_id, is_limit)
	doc = get_doc(doc_id, proc_id)
	di = doc['default_img'] if doc and 'default_img' in doc else ''
	t.update(get_alien_names(doc_id))
	if not t: t = 'false'
	else: t = json.dumps(t)
	return {"result":"ok", "content":t, "default_img":di}

def get_alien_names(doc_id):
	doc = get_doc(doc_id)
	if not doc or not 'alien_img' in doc: return {}
	var = {}
	for res in doc['alien_img']:
		var[res['id']] = {
			'orig': res['orig']['href'],
			'thumb': res['thumb']['href']
		}
	return var

#@cache.cache('get_file_meta', type='memory', expire=120)
def get_file_meta(request, proc_id, file_name, doc_id, prefix=''):
	if prefix: prefix = prefix + '_'
	# print ('get_file_meta',prefix,  file_name)
	file_name = prefix + file_name
	# file_ = db.fs.files.find_one({'proc_id':proc_id, 'file_name':file_name, 'doc_id':doc_id})
	file_ = request.db.fs.files.find_one({'file_name':file_name, 'doc_id':doc_id})
	return file_

#ghtREmp5

def del_files_post():
	proc_id = get_post('proc_id')
	# if not user_has_permission(proc_id, 'delete'):
	# 	return '{"result": "fail", "error": "%s"}' % cgi.escape(ct("You have no permission."))
	doc_id = get_post('doc_id') 
	type = get_post('type')
	file_name = get_post('file_name')
	if file_name is None: return '{"result":"fail", "error":"not file name"}'
	if type == 'video':
		del_files_video(doc_id, file_name, proc_id)
	else:
		del_files(doc_id, file_name, proc_id)
#	db = connect(); fs = GridFS(db)
#	fn = get_file_meta(proc_id, file_name, doc_id, 'thumb')
#	fs.delete(fn['_id'])
#	fn = get_file_meta(proc_id, file_name, doc_id, 'orig')
#	fs.delete(fn['_id'])
	return '{"result":"ok"}'

def del_files_video(request, doc_id, file_name, proc_id):
	doc = get_doc(doc_id)
	# fl = doc
	doc['files'].remove(file_name)
	request.db.doc.save(doc)
	path = os.path.join(os.getcwd(), 'static', 'video', doc_id)
	os.remove( path +'/'+ file_name )

def del_files(request, doc_id, file_name, proc_id):
	fs = GridFS(request.db)
	doc = get_doc(doc_id, proc_id)
	if doc and 'default_img' in doc:
		del doc['default_img']
		request.db.doc.save(doc)
	try:
		fn = get_file_meta(proc_id, file_name, doc_id, 'thumb')
		fs.delete(fn['_id'])
	except:pass
	try:
		fn = get_file_meta(proc_id, file_name, doc_id, 'orig')
		fs.delete(fn['_id'])
	except:pass
	try:
		fn = get_file_meta(proc_id, file_name, doc_id, 'middle')
		fs.delete(fn['_id'])
	except:pass
	return {"result":"ok"}

def del_all_files(request, doc_id, proc_id):
	for file_name in get_nf_(request, proc_id, doc_id):
		del_files(request, doc_id, file_name, proc_id)


def add_files_post():
	proc_id = get_post('proc_id')
	# if not user_has_permission(proc_id, 'create') or proc_id == 'col:templ':
	# 	return '{"result": "fail", "proc_id":"%s","error": "%s"}' % (proc_id, cgi.escape(ct("You have no permission.")) )
	res = True
	img = get_post('image'); file_st = get_post('file_st'); water_mark = get_post('water_mark')
	img = img if isinstance(img, list) else [img]

	admin = get_settings('admin', '')
	if not admin.startswith('user:'): admin = 'user:'+admin
	doc_id = get_post('doc_id')
	doc = get_doc(doc_id, proc_id)
	if not doc:
		doc = get_doc(doc_id)
	if 'head_field' in doc and 'user' in doc['head_field'] and doc['head_field']['user'] == admin and proc_id == 'des:obj': pref = 'admin_img'
	elif 'head_field' in doc and 'user' in doc['head_field'] and doc['head_field']['user'] == admin and proc_id == 'des:banners': pref = 'admin_img_b'
	elif proc_id == 'des:news': pref = 'news_img'
	elif proc_id == 'des:users': pref = 'user_icon'
	elif proc_id == 'des:radio': pref = 'radio_img'
	elif proc_id == 'col:templ' and doc_id == 'tv_frame_main.tpl': pref = 'tv_img'
	else: pref = 'user_img'
	for file in img:
		res = res and add_file(proc_id, doc_id, file, water_mark, pref=pref )
	if res: return {"result":"ok"}
	else: return {"result":"fail", "error":"фаил не получен"}

def add_file(proc_id, doc_id, file, water_mark = None, pref='def' ):
	""" получаем картинку с потока меняем размер сохраняем """
	if 'file' in file.__dict__ :
		mime = file.type
		raw = file.value # This is dangerous for big files
		file_name = file.filename
		#  image/jpeg   video/mp4
		if mime == 'video/mp4':
			upload_video(proc_id, doc_id, raw, mime, file_name, water_mark, pref=pref)
		else:
			return add_file_raw(proc_id, doc_id, raw, mime, file_name, water_mark, pref=pref )
	return False
	# return '{"result":"fail", "error": "File not uploaded"}'

def upload_video(request, proc_id, doc_id, raw, mime, file_name, water_mark, pref='def'):
	fname = os.path.join(os.getcwd(), 'static', 'video', doc_id) #base_path
	if not os.path.exists(fname):
		os.makedirs(fname)
	fname = os.path.join(fname, str(file_name))
	open(fname, 'w')
	# open(fname, 'wb').write(raw)
	open(fname, 'w').write(raw)


	doc = get_doc(doc_id)
	if not 'files' in doc:
		doc['files'] = []
	doc['files'].append( file_name )
	request.db.doc.save(doc)
	return True

# смотреть загрузку файлов для видео  редактора

def add_file_raw(request, proc_id, doc_id, raw, mime, file_name, water_mark = None, only_small=False, pref = 'def' ):
	"""сохранение в базу файла из переменой(сырого файла)"""
	del_files(doc_id, file_name, proc_id)
	del_files(doc_id, file_name, proc_id)
	from core.dao_core import get_const_value
#	size = 128, 128
	img = ''
	img = Image.open(io(raw))

	if pref == 'def':
		mid_size = 500
		sml_size = 250
	else:
		fl = get_settings('files')
		sml_size, mid_size = fl[pref]

	ttext = get_const_value('img_sign')
	if ttext and water_mark:
		watermark = Image.new("RGBA", img.size)
		waterdraw = ImageDraw.ImageDraw(watermark, "RGBA")
		waterdraw.text((10, img.size[1]-20), get_const_value('img_sign') )
		watermask = watermark.convert("L").point(lambda x: min(x, 200))
		watermark.putalpha(watermask)
		img.paste(watermark, None, watermark)

	# try:
	# Оригинальное изображение
	s = io.BytesIO()
	if mime == 'image/jpeg':
		img.save(s, 'JPEG', quality=90)
	elif mime == 'image/png':
		img.save(s, 'PNG', quality=90)
	elif mime == 'image/gif':
		img.save(s, 'GIF', quality=90)

	big_raw = s.getvalue()
	s.close()

	# Уменьшенная копия
	wpercent = (sml_size/float(img.size[0]))
	hsize = int((float(img.size[1])*float(wpercent)))
	size = (sml_size, hsize)

	small_img = img.resize(size, Image.ANTIALIAS)
	s = io.BytesIO()
	# small_img.convert('RGB')
	if mime == 'image/jpeg':
		small_img.save(s, 'JPEG', quality=65)
	elif mime == 'image/png':
		small_img.save(s, 'PNG', quality=65)
	elif mime == 'image/gif':
		small_img.save(s, 'GIF', quality=65)

	small_raw = s.getvalue()
	s.close()

	# Средний вариант, если предусмотрен
	if mid_size:
		wpercent = (mid_size/float(img.size[0]))
		hsize = int((float(img.size[1])*float(wpercent)))
		size = (mid_size, hsize)
		mid_img = img.resize(size, Image.ANTIALIAS)
		s = io.BytesIO()
		if mime == 'image/jpeg':
			mid_img.save(s, 'JPEG', quality=65)
		elif mime == 'image/png':
			mid_img.save(s, 'PNG', quality=65)
		elif mime == 'image/gif':
			mid_img.save(s, 'GIF', quality=65)
		mid_raw = s.getvalue()
		s.close()

	db = request.db
	fs = GridFS(db)

	fs.put(big_raw, file_name ='orig_'+file_name, doc_id = doc_id, proc_id=proc_id,  mime = mime)
	if mid_size:
		fs.put(mid_raw, file_name ='middle_'+file_name, doc_id = doc_id, proc_id=proc_id,  mime = mime)

	# open('/home/user/workspace/py.mongo/sites/ariru/1.png', 'w').write(small_raw)
	fs.put(small_raw, file_name ='thumb_'+file_name, doc_id = doc_id, proc_id=proc_id, mime = mime)
	return True

def simply_add_file_raw(request, proc_id, doc_id, raw, mime, file_name, water_mark = None, only_small=False, pref = 'def' ):
	"""сохранение в базу файла из переменой(сырого файла)"""
	from core.core import get_const_value
	img = ''
	img = Image.open(io.BytesIO(raw))
	if pref == 'def':
		mid_size = 500
		sml_size = 250
	else:
		fl = get_settings('files')
		sml_size, mid_size = fl[pref]

	# Оригинальное изображение
	s = io.BytesIO()

	if mime == 'image/jpeg':
		img.save(s, 'JPEG', quality=90)
	elif mime == 'image/png':
		img.save(s, 'PNG', quality=90)
	elif mime == 'image/gif':
		img.save(s, 'GIF', quality=90)

	big_raw = s.getvalue()
	s.close()

	# Уменьшенная копия
	wpercent = (sml_size/float(img.size[0]))
	hsize = int((float(img.size[1])*float(wpercent)))
	size = (sml_size, hsize)

	small_img = img.resize(size, Image.ANTIALIAS)
	s = io.BytesIO()

	if mime == 'image/jpeg':
		small_img.save(s, 'JPEG', quality=65)
	elif mime == 'image/png':
		small_img.save(s, 'PNG', quality=65)
	elif mime == 'image/gif':
		small_img.save(s, 'GIF', quality=65)

	small_raw = s.getvalue()
	s.close()

	# Средний вариант, если предусмотрен
	if mid_size:
		wpercent = (mid_size/float(img.size[0]))
		hsize = int((float(img.size[1])*float(wpercent)))
		size = (mid_size, hsize)
		mid_img = img.resize(size, Image.ANTIALIAS)
		s = io.BytesIO()
		if mime == 'image/jpeg':
			mid_img.save(s, 'JPEG', quality=65)
		elif mime == 'image/png':
			mid_img.save(s, 'PNG', quality=65)
		elif mime == 'image/gif':
			mid_img.save(s, 'GIF', quality=65)
		mid_raw = s.getvalue()
		s.close()

	db = request.db
	fs = GridFS(db)

	fs.put(big_raw, file_name ='orig_'+file_name, doc_id = doc_id, proc_id=proc_id,  mime = mime)
	if mid_size:
		fs.put(mid_raw, file_name ='middle_'+file_name, doc_id = doc_id, proc_id=proc_id,  mime = mid_mime)

	fs.put(small_raw, file_name ='thumb_'+file_name, doc_id = doc_id, proc_id=proc_id, mime = sml_mime)
	return True

def link_upload_post():
	url = get_post('link')
	doc_id = get_post('doc_id')
	proc_id = get_post('proc_id')
	link_upload_post_(url, proc_id, doc_id)
	return{"result":"ok", "doc_id":doc_id}

def link_upload_post_(url, proc_id, doc_id, avatar=False, pref="def"):
	fl = requests.get(url)
	file_name = 'avatar' if avatar else url.split('/')[-1]
	add_file_raw(proc_id, doc_id, fl.content, fl.headers['content-type'], file_name, pref=pref)


def set_def_img():
	db = request.db
	img  = get_post('id_img')
	doc_id  = get_post('doc_id')
	proc_id  = get_post('proc_id')
	doc = get_doc(doc_id, proc_id)
	doc['default_img'] = img
	save_doc(doc, proc_id)
	return{"result":"ok", "doc_id":doc_id, "img":img}


def check_video_dir_(doc_id):
	pass
def get_clip_(doc_id):
	return ''




bp = os.path.join(os.getcwd(), 'clip') #base_path
def upload_clip(request, doc_id):
	""" загружает файлы с компа на сервер
	"""
	check_video_dir_(doc_id)
	doc = get_clip_(doc_id)
	# doc['title'] = get_post('title', '')
	track = 'data_'+get_post('track', '')
	frag = int(get_post('frag'))
	fl = get_post('file')
	# fl = img[0] if isinstance(img, list) and img else img
	if 'file' in fl.__dict__ :
		file_name = fl.filename

		images = ['jpg', 'png', 'jpeg', 'gif']
		ext = file_name.split('.')[-1]
		if track == 'data_v':
			fname = os.path.join(bp, doc_id, 'in_v', str(frag)+'.'+ext)
			open(fname, 'wb').write(fl.value)
		if track == 'data_a':
			if ext in images: return '{"result":"fail", "error": "Image can\'t be on audio track"}'
			open(os.path.join(bp, doc_id, 'in_a', str(frag)+'.'+ext), 'wb').write(fl.value)
		rs = None
		for res in doc[track]:
			if res['frag'] == frag:
				rs = res
				break
		rs['title'] = file_name
		rs['filename'] = file_name
		rs['thumb'] = ''
		db = request.db
		db.doc.save(doc)
		return json.dumps(rs)
	else:
		return {"result":"fail", "error": "File not uploaded"}


def parse_date(ims):
	""" Parse rfc1123, rfc850 and asctime timestamps and return UTC epoch. """
	try:
		ts = email.utils.parsedate_tz(ims)
		return time.mktime(ts[:8] + (0,)) - (ts[9] or 0) - time.timezone
	except (TypeError, ValueError, IndexError, OverflowError):
		return  None


