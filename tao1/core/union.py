import sys, os
assert sys.version >= '3.4', 'Please use Python 3.4 or higher.'

import asyncio
import builtins
import jinja2
import aiohttp_jinja2
from aiohttp import web
from aiohttp.multidict import MultiDict

import aiohttp_debugtoolbar
from aiohttp_debugtoolbar import toolbar_middleware_factory
from aiohttp_session import session_middleware
from aiohttp_session.cookie_storage import EncryptedCookieStorage


from apps.app.view import *
import settings
# from core.utils import db_handler



# @aiohttp_jinja2.template('index.tpl')
# @aiohttp_jinja2.template('tmpl.jinja2')
# @asyncio.coroutine
# def page(request):
# 	return aiohttp_jinja2.render_template('index.tpl', request, {'key':'val'})
	# aiohttp_jinja2.setup(app, loader=jinja2.FileSystemLoader(['/path/to/templates', '/other/path']))
	# aiohttp_jinja2.setup(app, loader=jinja2.FunctionLoader ( load_templ ) )
	# app.router.add_route('GET', '/', page)

	
routes = []
@asyncio.coroutine
def init(loop):
	app = web.Application(loop=loop, middlewares=[ aiohttp_debugtoolbar.middleware, db_handler(), 
		session_middleware(EncryptedCookieStorage(b'Sixteen byte key')) ])
	# app = web.Application(loop=loop, middlewares=[ db_handler() ])
	# app['sockets'] = []
	aiohttp_debugtoolbar.setup(app)

	# mod = builtins.__import__('apps.app.routes', globals=globals())
	aiohttp_jinja2.setup(app, loader=jinja2.FunctionLoader ( load_templ ) )

	mod  = union_routes(os.path.join ( settings.root, 'apps') )
	mod1 = union_routes(os.path.join ( os.getcwd(), 'apps'  ) )

	for res in routes:
		print(res)
		app.router.add_route( res[2], res[0], res[1], name=res[3])
	app.router.add_route('GET', '/static/{component:[^/]+}/{fname:.+}', union_stat)	

	srv = yield from loop.create_server(app.make_handler(), '127.0.0.1', 6677)
	print("Server started at http://127.0.0.1:6677")
	return srv


def init_gunicorn():
	app = web.Application( middlewares=[ aiohttp_debugtoolbar.middleware, db_handler(), 
		session_middleware(EncryptedCookieStorage(b'Sixteen byte key')) ])
	aiohttp_debugtoolbar.setup(app)

	aiohttp_jinja2.setup(app, loader=jinja2.FunctionLoader ( load_templ ) )

	union_routes(os.path.join ( settings.root, 'apps') )
	union_routes(os.path.join ( os.getcwd(), 'apps'  ) )

	for res in routes:
		print(res)
		app.router.add_route( res[2], res[0], res[1], name=res[3])
	app.router.add_route('GET', '/static/{component:[^/]+}/{fname:.+}', union_stat)	

	return app

# @route('/static/<component>/<fname:re:.*>', domain='*')
# def union_stat(component, fname):
# def  union_stat(**kwargs): http://hl.mailru.su/gcached?q=cache:http://pauluskp.com/news/463c6e7d3



@asyncio.coroutine
def union_stat(request, *args):
	component = request.match_info.get('component', "Anonymous")
	fname = request.match_info.get('fname', "Anonymous")
	path = os.path.join( settings.root, 'apps', component, 'static', fname ) 
	# print()
	# search in project directory 
	if component == 'static':
		path = os.path.join( os.getcwd(), 'static') 
	# search in project components
	elif not os.path.exists( path ):
		path = os.path.join( os.getcwd(), 'apps', component, 'static' )
	# search in core components
	else:
		path = os.path.join( settings.root, 'apps', component, 'static') 
	content, headers = get_static_file(fname, path)
	return web.Response(body=content, headers=MultiDict( headers ) )


def get_static_file( filename, root ):
	import mimetypes, time

	root = os.path.abspath(root) + os.sep
	filename = os.path.abspath(os.path.join(root, filename.strip('/\\')))
	headers = {}

	mimetype, encoding = mimetypes.guess_type(filename)
	if mimetype: headers['Content-Type'] = mimetype
	if encoding: headers['Content-Encoding'] = encoding

	stats = os.stat(filename)
	headers['Content-Length'] = stats.st_size
	from tao1.core.core import locale_date
	lm = locale_date("%a, %d %b %Y %H:%M:%S GMT", time.gmtime(stats.st_mtime), 'en_US.UTF-8')
	headers['Last-Modified'] = str(lm)
	headers['Cache-Control'] = 'max-age=604800'
	with open(filename, 'rb') as f:
		content = f.read()
		f.close()
	return content, headers


def route(t, r, func, name='name'):
	routes.append((t, r, func, name))


def union_routes(dir):
	routes = []
	name_app = dir.split(os.path.sep)
	name_app = name_app[len(name_app) - 1]
	for name in os.listdir(dir):
		path = os.path.join(dir, name)
		if os.path.isdir ( path ) and os.path.isfile ( os.path.join( path, 'routes.py' )):
			name = name_app+'.'+path[len(dir)+1:]+'.routes'
			builtins.__import__(name, globals=globals())
			# module = get_full_path(name)
			# routes.append ( module )
	# return routes


def get_full_path(app):
	if type(app) == str:
		__import__(app) 
		app = sys.modules[app] 
	return app.__file__


def get_path(app):
	if type(app) == str:
		__import__(app) # - импортирует модуль по имени. Например имя будет "news".
		app = sys.modules[app] # - по имени "news" мы получам сам модуль news и присваиваем его переменной app
	return os.path.dirname(os.path.abspath(app.__file__))


def get_templ_path(path):
	module_name = ''; module_path = ''; file_name = ''; name_templ = 'default'; 
	if ':' in path:
		module_name, file_name = path.split(":", 1) # app.table main
		module_path = os.path.join( get_path( module_name), "templ")
	else:
		module_path = os.path.join( os.getcwd(), 'templ', name_templ)
	return module_name, module_path, file_name+'.tpl'


def render_templ(t, request, p):
	# если хотим написать параметры через = то p = dict(**p)
	return aiohttp_jinja2.render_template( t, request, p )


def load_templ(t, **p):
	(module_name, module_path, file_name) = get_templ_path(t)
	def load_template (module_path, file_name):
		path = os.path.join(module_path, file_name)
		template = ''
		filename = path if os.path.exists ( path ) else False
		if filename:
			with open(filename, "rb") as f:
				template = f.read()
		return template
	template = load_template( module_path, file_name)
	if not template: return 'Template not found {}' .format(t)
	return template.decode('UTF-8')
	
builtins.templ = render_templ


# @asyncio.coroutine
def db_handler():
    @asyncio.coroutine
    def factory(app, handler):
        @asyncio.coroutine
        def middleware(request):
            if request.path.startswith('/static/') or request.path.startswith('/_debugtoolbar'):
                response = yield from handler(request)
                return response
            # init
            db_inf = settings.database
            kw = {}
            if 'rs' in db_inf: kw['replicaSet'] = db_inf['rs']

            from pymongo import MongoClient
            mongo = MongoClient( db_inf['host'], 27017)
            db = mongo[ db_inf['name'] ]
            db.authenticate('admin', settings.database['pass'] )
            request.db = db
            # процессинг запроса (дальше по цепочки мидлверов и до приложения)
            response = yield from handler(request)
            mongo.close() # yield from db.close() 
            # экземеляр рабочего объекта по цепочке вверх до библиотеки
            return response
        return middleware
    return factory


@asyncio.coroutine
def redirect(request, url='/', code=None):
    data = yield from request.post() 
    if code is None:
        return web.HTTPSeeOther(url)

    url = request.app.router['test'].url()
    return web.HTTPFound( url )

