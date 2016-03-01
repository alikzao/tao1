import json, cgi, os, sys, requests,  hashlib, time, tempfile, time

import timeit
from pymongo import *

from urllib import *
import urllib
from datetime import datetime, timedelta
from libs.contents.contents import *
from core.core import *
from libs.clip.py2ffmpeg import *


cv = '.vob'
cv = '.avi'
pre_v = '.mp4'
pre_v = '.avi'
final_v = '.mp4'
final_v = '.avi'

flag_download = 1
flag_video = 1
flag_audio = 1
flag_conv = 1



def clip_page(request, doc_id):
	""" просто показывает страничку редактирования клипа
	"""
	if not user_has_permission('des:clips', 'edit') and not 'daoerp' in get_host():
		return 'ERROR 404'
	doc = get_clip(doc_id)
	if not doc:
		return 'ERROR 404: clip does not exists'
	return templ('libs.clip:cloud_tv.tpl', request, {"doc":doc})


def list_clips(request):
	""" show list clips
	"""
	if not user_has_permission('des:clips', 'edit') and not 'daoerp' in get_host():
		return 'ERROR 404'
	db = request.db
	req = db.doc.find({'doc_type':'des:clips', 'head_field.user': get_current_user(True)})
	from libs.sites.sites import get_full_docs
	dv = get_full_docs(req)
	return templ('libs.clip:list_clips.tpl', request, dict(docs=dv))


def add_rolik():
	doc_id = create_row('des:clips', None)
	return {"result":"ok", "doc_id":doc_id}


def add_clip(doc_id):
	update_status(doc_id, 'wait')
	return {"result":"ok"}


def down_clip(doc_id):
	update_status(doc_id, 'download')
	return {"result":"ok"}


def get_clip(request, doc_id):
	doc = get_doc(doc_id)
	if not 'data_v' in doc: doc['data_v'] = []
	if not 'data_a' in doc: doc['data_a'] = []
	if not 'label' in doc: doc['label'] = ''
	if not 'status' in doc: doc['status'] = ''
	request.db.doc.save(doc)
	return doc

def update_status(request, doc_id, status, kind = 's'):
	doc = get_clip(doc_id)
	if not 'status' in doc or type(doc['status']) != dict: doc['status'] = {}
	doc['status'][kind] = str(status)
	request.db.doc.save(doc)


def get_status(doc_id):
	kind = get_post('kind', 's')
	return {'status':read_status(doc_id, kind)}


def read_status(doc_id, kind = 's'):
	doc = get_clip(doc_id)
	if not 'status' in doc or type(doc['status']) != dict: doc['status'] = {}
	return doc['status'][kind] if kind in doc['status'] else ''
# apt-get install libsox-fmt-mp3
#apt-get install libavformat-extra-53

def drag_fragment(request, doc_id):
	if not user_has_permission('des:clips', 'edit'): return {"result": "fail", "error": "You have no permission."}
	db = request.db
	frag = int(get_post('frag'))
	track = 'data_'+get_post('track')
	place = int(get_post('place'))
	doc = get_clip(doc_id)
	rs = None
	for res in range(len(doc[track])):
		if doc[track][res]['frag'] == frag:
			rs = res
			break
	if rs is not None:
		item = doc[track][rs]
		del doc[track][rs]
		doc[track].insert(place, item)
		db.doc.save(doc)
		return {"result":"ok"}
	else:
		return {"result":"fail", "error": "fragment not found"}


def del_fragment(request, doc_id):
	if not user_has_permission('des:clips', 'edit'):
		return {"result": "fail", "error": "You have no permission."}
	db = request.db
	frag = int(get_post('frag'))
	track = 'data_'+get_post('track')
	doc = get_clip(doc_id)
	rs = None
	# die(doc[track])
	for res in range(len(doc[track])):
		if doc[track][res]['frag'] == frag:
			rs = res
			break
	if rs is not None:
		del doc[track][rs]
		db.doc.save(doc)
		return {"result":"ok"}
	else:
		return {"result":"fail", "error": "fragment not found"}


def edit_fragment(request, doc_id):
	if not user_has_permission('des:clips', 'edit'):
		return {"result": "fail", "error": "You have no permission."}
	db = request.db; r = ''
	link = get_post('link')
	label = get_post('label')
	if not link:
		r = "No link"
	start = check_time(get_post('start', '0'))
	len_ = check_time(get_post('len', '0'))
	end = check_time(get_post('end', '0'))
	if not start or not len_:
		#TODO у картинок нет старт
		r = "Incorrect time"
	track = 'data_'+get_post('track')
	del_audio = get_post('del_audio', '0')
	frag = int(get_post('frag'))
	doc = get_clip(doc_id)
	rs = None
	for res in doc[track]:
		if res['frag'] == frag:
			rs = res
			break
	if rs:
		if rs['link'] != link:
			rs['title'] = get_title(link)
			rs['filename'] = get_filename(link)
			rs['thumb'] = get_thumb(link)
		rs['link'] = link
		rs['label'] = label
		rs['start'] = start
		rs['end'] = end
		rs['len'] = len_
		rs['del_audio'] = del_audio
	rs['r'] = r
	db.doc.save(doc)
	return rs


def add_fragment(request, doc_id):
	r = ''
	if not user_has_permission('des:clips', 'edit'):
		return '{"result": "fail", "error": "You have no permission."}'
	db = request.db
	link = get_post('link')
	label = get_post('label')
	if not link:
		r = "No link"
	start = check_time(get_post('start', '0'))
	end = check_time(get_post('end', '0'))
	len_ = check_time(get_post('len', '0'))
	del_audio = get_post('del_audio', '')
	if not start or not len_:
		r = "Incorrect time"
	track = 'data_'+get_post('track')
	doc = get_clip(doc_id)
	frag = (doc['frag']+1) if 'frag' in doc else 1
	doc['frag'] = frag
	res = {'frag':frag, 'link':link, 'start':start, 'end':end, 'len':len_, 'title':get_title(link), 'thumb':get_thumb(link),
	       'label':label,'r':r, 'del_audio':del_audio}
	doc[track].append(res)
	db.doc.save(doc)
	return res


def add_descr(request, doc_id):
	doc = get_clip(doc_id)
	if not doc['head_field']['title']: doc['head_field']['title'] = {}
	if not doc['head_field']['descr']: doc['head_field']['descr'] = {}
	doc['head_field']['title']['ru'] = get_post('title', '')
	doc['head_field']['descr']['ru'] = get_post('descr', '')
	request.db.doc.save(doc)
	return {"result":"ok"}


def clip_upload(request, doc_id):
	frag = get_post('frag')
	track = get_post('track')

	if frag:
		db = request.db
		doc = get_clip(doc_id)
		clip = None
		t = 'data_'+track
		if not t in doc: return {"result": "fail", "error": "Unknown track"}
		for res in doc[t]:
			if res['frag'] == int(frag): clip = res
		if not clip: return {"result": "fail", "error": "Fragment doesn't contain file"}
		fn = clip['filename']
		ext = fn.split('.')[-1]
		if not ext in ['avi', 'flv', 'mp4']:
			return {"result": "fail", "error": "Incompatible file format"}
		doc['upload'] = {'frag': frag, 'track': track}
		db.doc.save(doc)
	update_status(doc_id, 'upload_vk')
	return


def upload_clip(request, doc_id):
	""" загружает файлы с компа на сервер
	"""
	check_video_dir(doc_id)
	doc = get_clip(doc_id)
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

		request.db.doc.save(doc)
		return json.dumps(rs)
	else:
		return {"result":"fail", "error": "File not uploaded"}


def rolik_pub(request, doc_id):
	doc = get_doc(doc_id)
	a, b =screen_clip(doc_id, doc['final_name'])
	doc['head_field']['pub'] = 'true'
	request.db.doc.save(doc)
	return {"result":"ok", "b":b, "a":a}

def clip_pub(request, doc_id):
	db = request.db
	track = get_post('track')
	frag = int(get_post('frag'))
	doc = get_clip(doc_id)
	for res in doc['data_'+track]:
		if res['frag'] == frag:
			rs = res
			break
	ext = rs['filename'].split('.')[-1]
	c = 'cp {f_in} {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'in_'+track, str(frag)+'.'+ext),
		f_out = os.path.join(bp, doc_id, 'final.'+ext)
	)
	r = cmd(c)
	doc['final_name'] = 'final.'+ext
	doc['head_field']['pub'] = 'true'
	db.doc.save(doc)
	c, rr = screen_clip(doc_id, doc['final_name'])
	return {"result":"ok", "r": r, "c": c, "rr": rr}


def del_rolik(doc_id):
	pass


def check_time(tm):
	try: res = int(tm)
	except: res = None
	if res is None:
		tm = re.sub(r'(\.|,|/|-| )', ':', tm)
		if not re.match(r'^[0-2]\d:[0-5]\d:[0-5]\d$', tm):
			return None
		return tm
	else:
		return str(res/3600 % 60).zfill(2)+':'+str(res/60 % 60).zfill(2)+':'+str(res % 60).zfill(2)


def update_fragment(doc_id):
	doc = get_clip(doc_id)
	return doc['status'] if 'status' else ''


def add_dir(path):
	os.mkdir(path)
	# mod = 0o777 if py3k else 0777
	mod = 0o777
	os.chmod(path,mod)


def check_video_dir(doc_id, clean=False):
	# die(bp)
	if not os.path.exists(bp):
		add_dir(bp)
	p = os.path.join(bp, doc_id)
	if os.path.exists(p):
		import shutil
		if os.path.exists(p+'/out_v'): shutil.rmtree(p+'/out_v')
		if os.path.exists(p+'/out_a'): shutil.rmtree(p+'/out_a')
	if os.path.exists(p+'/out_v'+pre_v): os.remove(p+'/out_v'+pre_v)
	if os.path.exists(p+'/out_a'+pre_v): os.remove(p+'/out_a'+pre_v)
	if clean and os.path.exists(p+'/final'+final_v): os.remove(p+'/final'+final_v)

	if not os.path.exists(p):
		add_dir(p)
		add_dir(p+'/in_v')
		add_dir(p+'/in_a')
	add_dir(p+'/out_v')
	add_dir(p+'/out_a')


def proc_rolik(request):
	""" ♍
	get gocs from db
	идет по списку клипов    закачивает их     вырезает нужный фрагмент
	потом опять идем по списку и всех их сливаем
	"""
	db = request.db
	doc = db.doc.find_one({'doc_type': 'des:clips', 'status.s': 'download'})
	print ('\n' * 5, doc)
	if doc:
		# AVI, MP4, 3GP, MPEG, MOV, MP3, FLV или WMV.
		# aaa = """
		doc_id = doc['_id']
		update_status(doc_id, 'downloading')
		check_video_dir(doc_id)
		doc = get_clip(doc_id)
		if flag_download:
			for res in doc['data_v']:
				if True or not 'loaded' in res or not res['loaded']:
					print( res['filename'])
					ext = res['filename'].split('.')[-1]
					down_rolik(res['link'], os.path.join(bp, doc_id, 'in_v', str(res['frag'])+'.'+ext))
					res['loaded'] = True
			for res in doc['data_a']:
				if not 'filename' in res: continue
				ext = res['filename'].split('.')[-1]
				down_rolik(res['link'], os.path.join(bp, doc_id, 'in_a', str(res['frag'])+'.'+ext))
		db.doc.save(doc)
		update_status(doc_id, 'ready')

	doc = db.doc.find_one({'doc_type': 'des:clips', 'status.s': 'wait'})
	# if True:
	if doc:
		doc_id = doc['_id']
		update_status(doc_id, 'prepare');
		doc = get_clip(doc_id)
		if not doc: return
		check_video_dir(doc_id, True)

		update_status(doc_id, 'fragments')
		for res in doc['data_v']:
			ext = res['filename'].split('.')[-1]
			# if res['title'].endswith('.jpg') or res['title'].endswith('.png') or res['title'].endswith('.jpeg') or res['title'].endswith('.gif'):
			if ext in ['jpg','png', 'jpeg', 'gif']:
				if flag_video:
					clone_img(doc_id, res['frag'], ext, res['len'])
				if flag_audio:
					clone_mp3(doc_id, res['frag'], res['len'], track='v')
			else:
				if flag_video:
					cut_frag_v(doc_id, res['frag'], res['start'], res['len'], ext=ext)
				if flag_audio:
					if res['del_audio'] == '1': clone_mp3(doc_id, res['frag'], res['len'], 'v')
					else: cut_frag_a(doc_id, res['frag'], res['start'], res['len'], track='v', vol = 256, ext=ext)

		if flag_audio:
			if not doc['data_a']:
				# Если аудиодорожка отсутствует
				clone_mp3(doc_id, 0, '00:00:01', 'a')
			else:
				for res in doc['data_a']:
					if res['del_audio'] == '1': clone_mp3(doc_id, res['frag'], res['len'], 'a')
					else:
						if not 'filename' in res: continue
						ext = res['filename'].split('.')[-1]
						cut_frag_a(doc_id, res['frag'], res['start'], res['len'], track='a', vol = 512, ext=ext)

		update_status(doc_id, 'start glue')
		# соединяем цепочку видеофрагментов
		if flag_video:
			if doc['data_v']: join_frag_v(doc_id, [i['frag'] for i in doc['data_v']])
		# соединяем цепочку аудиодорожек из видео
		if flag_audio:
			if doc['data_v']: join_frag_a(doc_id, track = 'v', lst=[i['frag'] for i in doc['data_v']])
		# соединяем цепочку аудиодорожек из аудио
		if flag_audio:
			join_frag_a(doc_id, track = 'a', lst=[i['frag'] for i in doc['data_a']] or [0])
		# exit()

		# Микшируем аудиодорожки в одну
		if flag_audio and flag_video:
			join_av_track(doc_id)

		update_status(doc_id, 'final glue')
		if flag_conv:
			doc['final_name'] = conv_video(doc_id)

		if not 'descr' in doc: doc['descr'] = ''
		if not 'title' in doc: doc['title'] = ''
		db.doc.save(doc)
		update_status(doc_id, 'ready')


def get_filename(link):
	if 'youtube' in link:
		if 'feature=player_embedded&' in link:
			link = re.sub(r'feature=player_embedded&', r'', link)
		return cmd ('youtube-dl --get-filename {0}'.format(link))
	return ''


def get_thumb(link):
	if 'youtube' in link:
		if 'feature=player_embedded&' in link:
			link = re.sub(r'feature=player_embedded&', r'', link)
		return cmd('youtube-dl --get-thumbnail {0}'.format(link))
	if 'podfm' in link:
		return 'http://files.podfm.ru/images/podfm_logo.png'
	return ''


def get_title(link):
	if 'youtube' in link:
		if 'feature=player_embedded&' in link:
			link = re.sub(r'feature=player_embedded&', r'', link)
		return cmd('youtube-dl --get-title {0}'.format(link))
	return ''


def down_rolik(link, file_name):
	if not link: return
	# if 'youtube' in link:
	if os.path.exists(file_name):
		os.remove(file_name)
	if 'youtube' in link:
		if 'feature=player_embedded&' in link:
			link = re.sub(r'feature=player_embedded&', r'', link)
		cmd ('youtube-dl -o {0} {1}'.format(file_name, link))
	return


def draw_img(request, doc_id):
	check_video_dir()
	text = get_post('text').decode('utf-8')
	text = text.split('\n')
	frag = int(get_post('frag'))
	from PIL import Image, ImageDraw
	# import Image, ImageDraw, ImageFont
	fontPath = get_settings('font_path_ubuntu')
	font = ImageFont.truetype(fontPath, 72)
	im = Image.new( "RGB", (1200,720), "#000" )
	draw = ImageDraw.Draw( im )
	for i in range(len(text)):
		txt = text[i]
		size  = font.getsize(txt)
		left = (1200 - size[0])/2
		top = (720 - size[1] * len(text) )/2 + size[1] * i
		draw.text((left, top), txt, font=font, fill="white" )
	im.save(os.path.join(bp, doc_id, 'in_v', str(frag)+'.jpg'))
	del draw
	rs = None
	doc = get_clip(doc_id)
	for res in doc['data_v']:
		if res['frag'] == frag:
			rs = res
			break
	# die(doc)
	rs['title'] = str(frag)+'.jpg'
	rs['filename'] = str(frag)+'.jpg'
	rs['thumb'] = ''
	request.db.doc.save(doc)
	return json.dumps(rs)


