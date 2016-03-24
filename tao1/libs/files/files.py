import sys
from urllib import *
import  urllib
from urllib.parse import *

import io

from aiohttp import MultiDict, web

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

	prefix = prefix + '_' if prefix else ''
	file_name = prefix + img
	fn = request.db.fs.files.find_one({'file_name':file_name, 'doc_id':doc_id})

	if not fn: return None, None, None
	f = fs.get(fn['_id'])
	return fn, f, prefix


def img(request):
	""" return file and information about it, for static """
	proc_id = request.match_info.get('proc_id', "des:obj")
	doc_id =  request.match_info.get('doc_id', "")
	img =     request.match_info.get('img', "")
	action =  request.match_info.get('action', "img")
	att = None
	headers = {}
	try:
		fn, att, prefix = img_m(request, proc_id, doc_id, img, action)
		if not fn: return web.HTTPNotFound()
		headers['Content-Length'] = fn['length']
		lm = locale_date("%a, %d %b %Y %H:%M:%S GMT", fn['uploadDate'].timetuple(), 'en_US.UTF-8')
		headers['Last-Modified'] = lm

		ims = request.if_modified_since

		if ims and ims.strftime('%Y-%m-%d %H:%M:%S') >= fn['uploadDate'].strftime('%Y-%m-%d %H:%M:%S'):
			headers['Date'] = locale_date("%a, %d %b %Y %H:%M:%S GMT", time.gmtime(), 'en_US.UTF-8')
			return web.HTTPNotModified( headers=MultiDict( headers ) )

		headers['Content-Type'] = fn['mime']
		headers['Cache-Control'] = 'max-age=604800'
		content  = att.read()
	finally:
		if att: att.close()
	return web.Response(body=content, headers=MultiDict( headers ))


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
	# 	condition = {'doc_id':doc_id, 'file_name': 'orig_' + default_img }
		condition = {'doc_id':doc_id, 'file_name': re.compile('^orig_', re.I | re.U) }
	else:
		condition = {'doc_id':doc_id, 'file_name': 'orig_avatar' if avatar else re.compile('^thumb_', re.I | re.U)}
		# print('condition ', {'doc_id':doc_id, 'file_name': 'orig_avatar' if avatar else re.compile('^thumb_', re.I | re.U)} )
	req = request.db.fs.files.find(condition)
	if is_limit:
		req = req.limit(is_limit)
	for res in req:
		# if doc_id == "user:uk": print('att=========', res)
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
def get_teg_img(request, proc_id, doc_id):
	att = get_nf(request, proc_id, doc_id, is_limit=0, avatar=False)
	if not att.keys(): return ''
	return '<img src="http://{0}{1}" />'.format(get_settings('domain'), htmlspecialchars(att[att.keys()[0]]['orig']))


async def get_file_names_post(request):
	data = await request.post()
	is_limit=None
	doc_id = data.get('doc_id', '')
	proc_id = data.get('proc_id', '')
	t = get_nf_(request, proc_id, doc_id, is_limit)
	doc = get_doc(request, doc_id, proc_id)
	di = doc['default_img'] if doc and 'default_img' in doc else ''
	t.update(get_alien_names(request, doc_id))
	if not t: t = 'false'
	else: t = json.dumps(t)
	return response_json(request, {"result":"ok", "content":t, "default_img":di})

def get_alien_names(request, doc_id):
	doc = get_doc(request, doc_id)
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


async def del_files_post(request):
	data = await request.post()
	proc_id = data.get('proc_id', 'des:obj')
	# if not user_has_permission(proc_id, 'delete'):
	# 	return {"result": "fail", "error": "You have no permission."}
	doc_id = data.get('doc_id')
	type = data.get('type')
	file_name = data.get('file_name')
	if file_name is None: return response_json(request, {"result":"fail", "error":"not file name"})
	if type == 'video':
		del_files_video(request, doc_id, file_name, proc_id)
	else:
		del_files(request, doc_id, file_name, proc_id)
	return response_json(request, {"result":"ok"})


def del_files_video(request, doc_id, file_name, proc_id):
	doc = get_doc(doc_id)
	# fl = doc
	doc['files'].remove(file_name)
	request.db.doc.save(doc)
	path = os.path.join(os.getcwd(), 'static', 'video', doc_id)
	os.remove( path +'/'+ file_name )


def del_files(request, doc_id, file_name, proc_id):
	fs = GridFS(request.db)
	doc = get_doc(request, doc_id, proc_id)
	if doc and 'default_img' in doc:
		del doc['default_img']
		request.db.doc.save(doc)
	try:
		fn = get_file_meta(request, proc_id, file_name, doc_id, 'thumb')
		fs.delete(fn['_id'])
	except:pass
	try:
		fn = get_file_meta(request, proc_id, file_name, doc_id, 'orig')
		fs.delete(fn['_id'])
	except:pass
	try:
		fn = get_file_meta(request, proc_id, file_name, doc_id, 'middle')
		fs.delete(fn['_id'])
	except:pass
	return response_json(request, {"result":"ok"})


def del_all_files(request, doc_id, proc_id):
	for file_name in get_nf_(request, proc_id, doc_id):
		del_files(request, doc_id, file_name, proc_id)


async def add_files_post(request):
	data = await request.post()
	proc_id = data.get('proc_id', 'des:obj')
	# if not user_has_permission(proc_id, 'create'):
	# 	return 	response_json(request, {"result": "fail", "proc_id":proc_id, "error":"You have no permission."})
	res = True
	img = data.get('image', '')
	file_st = data.get('file_st', '')
	water_mark = data.get('water_mark', '')
	img = img if isinstance(img, list) else [img]

	admin = get_settings('admin', '')
	if not admin.startswith('user:'): admin = 'user:'+admin
	doc_id = data.get('doc_id', '')

	doc = get_doc(request, doc_id, proc_id)
	if not doc:
		doc = get_doc(request, doc_id)
	if 'doc' in doc and 'user' in doc['doc'] and doc['doc']['user'] == admin and proc_id == 'des:obj':
		pref = 'admin_img'
	elif 'doc' in doc and 'user' in doc['doc'] and doc['doc']['user'] == admin and proc_id == 'des:banners':
		pref = 'admin_img_b'
	elif proc_id == 'des:news': pref = 'news_img'
	elif proc_id == 'des:users': pref = 'user_icon'
	else: pref = 'user_img'
	for file in img:
		res = res and add_file(request, proc_id, doc_id, file, water_mark, pref=pref )
	if res: return response_json(request, {"result":"ok"})
	else: return response_json(request, {"result":"fail", "error":"file not received"})


def add_file(request, proc_id, doc_id, file, water_mark = None, pref='def' ):
	""" get the image from the stream and changing it the size   (image/jpeg   video/mp4)
	file.file  -  This is dangerous for big files
	"""
	print('file=>', file)
	mime = file.content_type
	raw = file.file
	print('raw=>', raw)
	file_name = file.filename
	if mime == 'video/mp4':
		upload_video(request, proc_id, doc_id, raw, mime, file_name, water_mark, pref=pref)
	else:
		return add_file_raw(request, proc_id, doc_id, raw, mime, file_name, water_mark, pref=pref )
	# return '{"result":"fail", "error": "File not uploaded"}'


def upload_video(request, proc_id, doc_id, raw, mime, file_name, water_mark, pref='def'):
	fname = os.path.join(os.getcwd(), 'static', 'video', doc_id) #base_path
	if not os.path.exists(fname):
		os.makedirs(fname)
	fname = os.path.join(fname, str(file_name))
	open(fname, 'w')
	# open(fname, 'wb').write(raw)
	open(fname, 'w').write(raw)

	doc = get_doc(request, doc_id)
	if not 'files' in doc:
		doc['files'] = []
	doc['files'].append( file_name )
	request.db.doc.save(doc)
	return True


# watch the download files for the video editor
def add_file_raw(request, proc_id, doc_id, raw, mime, file_name, water_mark = None, only_small=False, pref = 'def' ):
	""" save the file in a database from variable (raw file) """
	from core.core import get_const_value
	# img = Image.open( io.BytesIO(raw) )
	img = Image.open( raw )
	# img = raw
	# img = Image.open( io.StringIO(raw) )

	if pref == 'def':
		mid_size = 500
		sml_size = 250
	else:
		fl = get_settings('files')
		sml_size, mid_size = fl[pref]

	ttext = get_const_value(request, 'img_sign')
	if ttext and water_mark:
		watermark = Image.new("RGBA", img.size)
		waterdraw = ImageDraw.ImageDraw(watermark, "RGBA")
		waterdraw.text((10, img.size[1]-20), get_const_value('img_sign') )
		watermask = watermark.convert("L").point(lambda x: min(x, 200))
		watermark.putalpha(watermask)
		img.paste(watermark, None, watermark)

	# original image
	s = io.BytesIO()
	if mime == 'image/jpeg':
		img.save(s, 'JPEG', quality=90)
	elif mime == 'image/png':
		img.save(s, 'PNG', quality=90)
	elif mime == 'image/gif':
		img.save(s, 'GIF', quality=90)

	big_raw = s.getvalue()
	s.close()

	# reduced copy
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

	# 	middle copy, if provided
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

	fs.put(small_raw, file_name ='thumb_'+file_name, doc_id = doc_id, proc_id=proc_id, mime = mime)
	return True


def link_upload_post(request):
	url = get_post('link')
	doc_id = get_post('doc_id')
	proc_id = get_post('proc_id')
	link_upload_post_(url, proc_id, doc_id)
	return response_json(request, {"result":"ok", "doc_id":doc_id})


def link_upload_post_(url, proc_id, doc_id, avatar=False, pref="def"):
	fl = requests.get(url)
	file_name = 'avatar' if avatar else url.split('/')[-1]
	add_file_raw(proc_id, doc_id, fl.content, fl.headers['content-type'], file_name, pref=pref)


async def set_def_img(request):
	data = await request.post()
	img  = data.get('id_img', '')
	doc_id  = data.get('doc_id')
	proc_id  = data.get('proc_id')
	doc = request.db.doc.find_one({"_id": doc_id})
	doc['default_img'] = img
	request.db.doc.save(doc)
	return response_json(request, {"result":"ok", "doc_id":doc_id, "img":img})


def check_video_dir_(doc_id):
	pass
def get_clip_(doc_id):
	return ''


bp = os.path.join(os.getcwd(), 'clip') #base_path
def upload_clip(request, doc_id):
	""" downloads files from a computer to the server
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
			if ext in images: return {"result":"fail", "error": "Image can\'t be on audio track"}
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
		return response_json(request,  {"result":"fail", "error": "File not uploaded"})


def parse_date(ims):
	""" Parse rfc1123, rfc850 and asctime timestamps and return UTC epoch. """
	try:
		ts = email.utils.parsedate_tz(ims)
		return time.mktime(ts[:8] + (0,)) - (ts[9] or 0) - time.timezone
	except (TypeError, ValueError, IndexError, OverflowError):
		return  None



