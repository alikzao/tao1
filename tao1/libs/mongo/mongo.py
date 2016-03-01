import json, cgi, os, sys, requests, hashlib, time, tempfile,  getopt
from urllib.parse import  *

from pymongo import *
from gridfs import GridFS

from libs.contents.contents import *
from core.core import *

from urllib import *
from datetime import datetime
from copy import deepcopy
from uuid import uuid4
from shutil import *

from settings import *

def connect(host, db_name, login, passw):
#	vd ( host, db_name, login, passw)
	# host = settings.domain
	db = get_settings('database', {} )
	# db_conn['conn'] = MongoClient(db['host'], **kw)
	kw = {'slave_okay': True}
	# cn = MongoClient(db['host'], **kw)
	cn = MongoClient(db['host'])
	db = cn[db['name']]
	# db = cn[db_name]
	if not login or not passw:
		try:
			t = db.collection_names()
		except:
			redirect('/mongodb/login/'+db_name)
	elif not db.authenticate(login, passw):
		redirect('/mongodb/login/'+db_name)
	return db, cn


def mongodb_():
	redirect( '/mongodb/'+get_domain())

def mongodb(db_id):
	if not is_admin(): return ''

	s = session()

	if not is_main and db_id != get_domain():
		redirect( '/mongodb/'+get_domain())

	if 'mongo' in s:
		if is_main:
			s['mongo']['db_name'] = db_id
			s.save()
			db, cn = connect(s['mongo']['host'], get_settings('database')['login'], get_settings('database')['login'],
			                 get_settings('database')['pass'] )
			db_list = cn.database_names()
		else: db_list = [db_id]

		db, cn = connect(**s['mongo'])
		info = {
			'status':db.last_status(),
			'name':db.name,
			'dbstat':db.command("dbstats"),
			'buildinfo':db.command("buildinfo")
		}
		return templ('app.mongo_tree:db_list', env=env, coll = db.collection_names(), info=info, db_list = db_list, db_id = db_id )
	else: redirect('/mongodb/login/'+db_id)


def db_login(request, db_id):
#	raise Exception (db_id+' '+get_domain()+' '+get_host())
	if not is_admin(): return ''
	if not is_main and db_id!=get_domain():
		redirect( '/mongodb/'+get_domain())
	return templ('app.mongo_tree:db_login', request, dict(db_id=db_id))


def db_login_post():
	db_id = get_post('db_id', get_domain())
	if not is_main and db_id != get_domain():
		redirect( '/mongodb/'+get_domain())
	cred = {'host': 'localhost', 'db_name': db_id, 'login': get_post('name'), 'passw': get_post('passw')}
	s = session()
	db, cn = connect(**cred)
	if db:
		s['mongo'] = cred
		s.save()
	redirect( '/mongodb/'+db_id)


def del_db(db_id):
	s = session()
	coll = get_post('coll')
	if not 'mongo' in s: redirect( '/mongodb/'+db_id)
	db, cn = connect(**s['mongo'])
	cn.drop_database()
	return {"result":"ok"}


def get_docs():
	s = session()
	coll = get_post('coll')
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		docs = []
		for res in db[coll].find().limit(100):
#			"data": "<Mongo Binary Data>",  fs.chunks (82)
			res['__coll_id'] = coll
			docs.append( check_val(res) )
	return {"result":"ok", "docs":docs, "coll":coll}


def get_doc_mongo():
	s = session()
	doc_id = get_post('doc_id')
	coll = get_post('coll')
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		docs = []
		doc = db[coll].find_one({'_id':doc_id})
		doc = check_val(doc)
		doc['__coll_id'] = coll
#		docs.append(res)
	return {"result":"ok", "doc":doc, 'coll':coll}


def check_val(val):
	if type(val) == dict:
		for res in val:
			val[res] = check_val(val[res])
	elif type(val) == list:
		ls = []
		for res in val:
			ls.append( check_val(res) )
		val = ls
	else: val = str( val)
	return val

def del_doc_post():
	coll = get_post('coll')
	doc_id = get_post('doc_id')
	s = session()
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		db[coll].remove(doc_id)
		return {"result":"ok", "id":doc_id, "coll":coll}


def search_docs():
	field = get_post('field')
	import re
	condition = get_post('condition')
	coll = get_post('coll')
	s = session()
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		docs = []
		regex = re.compile(condition, re.I | re.U)
		for res in db.collection_names():
			for rs in db[res].find({ field:regex }):
				rs['__coll_id'] = res
				docs.append(rs)
		return {"result":"ok", "docs":docs, "coll":coll}


def edit_key_post():
	s = session()
	coll = get_post('coll')
	doc_id = get_post('doc_id')
	new_val = reversed(json.loads( get_post('new_val')))
	old_val = reversed(json.loads( get_post('old_val')))
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		doc = db[coll].find_one({'_id':doc_id})
		old_target = doc; parent = doc; old_key = None
		for res in old_val:
			old_target = parent # doc
			if res in parent: # 'user' in doc
				parent = parent[res] # doc['user']
			old_key = res # 'user'

		new_target = doc; parent = doc; new_key = None
		for res in new_val:
			new_target = parent
			if res in parent:
				parent = parent[res]
			new_key = res

		val = old_target[old_key]
		del old_target[old_key]
		new_target[new_key] = val
		db[coll].save(doc)
		return { "result":"ok" }


def edit_val_post():
	s = session()
	coll = get_post('coll')
	doc_id = get_post('doc_id')
	val =  get_post('new_val')
	path = '.'.join(reversed(json.loads( get_post('old_val'))))
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		db[coll].update({'_id':doc_id}, {'$set':{path:val}})
		return { "result":"ok" }


def edit_val_post1():
	"""
		coll:map
		new_val:icon-custom custom-coins
		old_val:["icon","1","actions"]
		doc_id:des:job_order
	"""
	s = session()
	coll = get_post('coll')
	doc_id = get_post('doc_id')
	new_val =  get_post('new_val')
	old_val = reversed(json.loads( get_post('old_val')))
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		doc = db[coll].find_one({'_id':doc_id})
		old_target = doc
		parent = doc
		old_key = None
		for res in old_val:
			old_target = parent # doc
			if res in parent: # 'user' in doc
				parent = parent[res] # doc['user']
			old_key = res # 'user'
			old_target[old_key] = new_val
		# old_target[old_key] = new_val
		db[coll].save(doc)
		return { "result":"ok" }


def import_db_post(request):
	# request.POST
	for file in request.files.getall('file'):
		if not file.filename: continue
		path = os.tmpnam()
		os.mkdir(path)
		if file.filename.endswith('.zip'): ext = 'zip'
		elif file.filename.endswith('.tar'): ext = 'tar'
		elif file.filename.endswith('.tgz') or file.filename.endswith('.tar.gz'): ext = 'tgz'
		else: return '{"result": "fail", "error": "unknown archive format"}'
		fname = os.path.join(path, 'dump.' + ext)
		with open(fname, 'wb') as f: f.write(file.value)
		cmd = "cd %s; tar -xf %s" % (path, 'dump.' + ext)
		os.popen(cmd).read()
		old = os.path.join(path, 'formemob')
		new = os.path.join(path, 'test_formemob')
		os.rename(old, new)
		cmd = 'mongorestore -u admin -p {0} -d {1} --drop {2}'.format(settings.database['pass'], settings.database['named'],
		                                                              os.path.join(path, settings.database['name']) )
		os.popen(cmd).read()


def export_db_post():
#	path = '/home/user/workspace/aaa/'
#	dump = os.path.join(path, db)
	db = get_post('db_id')
	db = gat_settings('database')['name']
	path = os.tmpnam()
	os.mkdir(path)
	cmd = "mongodump -u admin -p {0} -d {1} -o {2}" .format(settings.database['pass'], settings.database['name'], path)
	os.popen(cmd).read()
	fname = db+'.tgz'
	cmd = "cd {0}; tar -czf {1} {2}" .format(path, fname, db)
	os.popen(cmd).read()
	s = session()
	if not 'db' in s: s['db'] = {}
	s['db'][db] = {'fullname': os.path.join(path, db+'.tgz'), 'filename': fname}
	s.save()
	return {"result": "ok", "link": '/mongo/exported/'+db}


def get_exp_file(db_id):
	s = session()
	(fullname, filename) = (s['db'][db_id]['fullname'], s['db'][db_id]['filename'])
	if filename.endswith('.tgz') or filename.endswith('.tar.gz'): mime = 'application/x-gzip'
	if filename.endswith('.zip'): mime = 'application/zip'
	if filename.endswith('.tar'): mime = 'application/tar'
	response.headers['Content-Type'] = mime
	response.headers['Content-Disposition'] = 'attachment; filename="%s"' % filename
	from core.union import static_file1
	# die(static_file1(fullname, root='/')[:100])
	return static_file1(fullname, root='/')


def import_doc_post():
	coll = get_post('coll')
	path = get_post('path')
	cmd = 'mongoimport -u admin -p Gthcgtrnbdf -d bezholopov -c obj -o bhmportfile.json' %  (coll, path)
	os.popen(cmd).read()


def export_doc_post():
	coll = get_post('coll')
	path = get_post('path')
	cmd = 'mongoexport -u admin -p Gthcgtrnbdf -d bezholopov -c obj -o bhmportfile.json' %  (coll, path)
	os.popen(cmd).read()


def create_doc_post():
	s = session()
	coll = get_post('coll')
	doc = json.loads(get_post('doc'))
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		db[coll].save(doc)
		return json.dumps({"result":"ok", "doc":doc, "coll":coll})


def get_docm_post():
	s = session()
	coll = get_post('coll')
	doc_id = get_post('doc_id')
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		doc = db[coll].find_one({"_id":doc_id})
		del doc['_id']
		return json.dumps({"result":"ok", "doc":json.dumps( doc, ensure_ascii=False, indent=4), "coll":coll})


def edit_doc_post():
	s = session()
	coll = get_post('coll')
	doc_id = get_post('doc_id')
#	doc = get_post('doc')
	doc = json.loads(get_post('doc'))
	doc.update({'_id':doc_id})
	if 'mongo' in s:
		db, cn = connect(**s['mongo'])
		db[coll].update({'_id':doc_id}, doc)
		doc = db[coll].find_one({"_id":doc_id})
		# die(doc)
		return json.dumps({"result":"ok", "doc":doc, "coll":coll})
	return {"result":"fail"}






