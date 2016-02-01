import sys, os, json, pickle, gettext, hashlib


import aiohttp.web_reqrep

assert sys.version_info >= (3, 4), 'Please use Python 3.4 or higher.'

from urllib.parse import quote, urlparse
import asyncio
import builtins
import jinja2
import aiohttp_jinja2
from aiohttp import web, HttpMessage
from aiohttp.multidict import MultiDict
from aiohttp import  MultiDict, CIMultiDict
from functools import partial

import aiomcache
import aiohttp_debugtoolbar
from aiohttp_debugtoolbar import toolbar_middleware_factory
from aiohttp_session import session_middleware, get_session, SimpleCookieStorage
from aiohttp_session.cookie_storage import EncryptedCookieStorage

import pymongo
# from libs.app.view import *
import settings
# from core.utils import db_handler
from core.core import cur_lang, ct, htmlspecialchars, format_date
# from libs.sites.sites import short_text, get_slot


routes = []
tpl_globals = {
    # 'lang':cur_lang,
    'auth':{'vk':settings.oauth_vk, 'fb':settings.oauth_fb, 'ok':settings.oauth_ok},
    'debug':settings.debug,
    'session_get_mess':dict,
    'str':str,
    'len':len,
    'int':int,
    'float':float,
    'quote_url':quote,
    'urlparse':urlparse,
    'user':{'id':"", 'name':"", 'is_admin':"", 'is_logged':"", 'info': '', 'branch':'', 'has_perm':"", "full_id": "", 'rate': ""},
    'format_date':format_date,
    'h':htmlspecialchars,
}
mc = None
@asyncio.coroutine
def init(loop):
    global mc

    middlewares = []
    # middlewares.append(aiohttp_debugtoolbar.middleware) # debugtoolbar.intercept_redirects = false

    middlewares.append(db_handler())
    if settings.debug:
        middlewares.append( session_middleware(SimpleCookieStorage()) )
    else:
        middlewares.append( session_middleware(EncryptedCookieStorage(settings.session_key)) )

    app = web.Application(loop=loop, middlewares=middlewares)
    # app = web.Application(loop=loop, middlewares=[ db_handler() ])

    # aiohttp_debugtoolbar.setup(app)
    # debugtoolbar.intercept_redirects = False
    # aiohttp_debugtoolbar.intercept_redirects = False



    # mod = builtins.__import__('apps.app.routes', globals=globals())
    aiohttp_jinja2.setup(app, loader=jinja2.FunctionLoader ( load_templ ) )

    # Memcache init
    app.mc = aiomcache.Client( settings.memcache['addr'], settings.memcache['port'], loop=loop)

    # Mongo init
    db_connect(app)

    union_routes(os.path.join ( settings.tao_path, 'libs' ) )
    union_routes(os.path.join ( settings.root_path, 'apps') )

    # union_tpl_global(os.path.join ( settings.tao_path, 'libs' ) )
    # union_tpl_global(os.path.join ( settings.root_path, 'apps') )

    for res in routes:
        name = res[3]
        if name is None: name = '{}:{}'.format(res[0], res[2])
        # print(name, res)
        app.router.add_route( res[0], res[1], res[2], name=name)

    # app.router.add_route('GET', '/static/{component:[^/]+}/{fname:.+}', union_stat)
    # app.router.add_static('/static/static/img/taiji.jpg', '/home/user/dev/tao1/sites/daoerp/static/img/', name='static')
    # app.router.add_static('/static/', '/home/user/dev/tao1/sites/daoerp/static/', name='static')
    path = os.path.join(settings.root_path, 'static')
    print('path', path)
    app.router.add_static('/static/', path, name='static')

    handler = app.make_handler()
    srv = yield from loop.create_server(handler, settings.addr[0], settings.addr[1])
    print("Server started at http://127.0.0.1:6677")
    return srv, handler, app


def get_trans(var):
    pass

def db_connect(app):
    if settings.database is not None:
        db_inf, kw = settings.database, dict()
        if 'rs' in db_inf: kw['replicaSet'] = db_inf['rs']
        mongo = pymongo.MongoClient(db_inf['host'], 27017)
        app.db = mongo[db_inf['name']]
        if settings.database['auth']:
            app.db.authenticate(settings.database['login'], settings.database['pass'])
    else:
        app.db = None


def init_gunicorn():
    app = web.Application( middlewares=[ aiohttp_debugtoolbar.middleware, db_handler(), 
        session_middleware(EncryptedCookieStorage(b'Sixteen byte key')) ])
    aiohttp_debugtoolbar.setup(app)

    aiohttp_jinja2.setup(app, loader=jinja2.FunctionLoader ( load_templ ) )

    union_routes(os.path.join ( settings.tao_path, 'libs' ) )
    union_routes(os.path.join ( settings.root_path, 'apps') )

    for res in routes:
        # print(res)
        app.router.add_route( res[0], res[1], res[2], name=res[3])
    app.router.add_route('GET', '/static/{component:[^/]+}/{fname:.+}', union_stat)
    # app.router.add_static('/static/static/img/taiji.jpg', '/home/user/dev/tao1/sites/daoerp/static/img/taiji.jpg', name='static')

    return app

# @route('/static/<component>/<fname:re:.*>', domain='*')
# def union_stat(component, fname):
# def  union_stat(**kwargs): http://hl.mailru.su/gcached?q=cache:http://pauluskp.com/news/463c6e7d3



@asyncio.coroutine
def union_stat(request, *args):
    component = request.match_info.get('component', "Anonymous")
    fname = request.match_info.get('fname', "Anonymous")
    path = os.path.join( settings.tao_path, 'libs', component, 'static', fname )
    # print(os.path.join(  settings.root_path, 'static'))
    # search in project directory
    if component == 'static':
        path = os.path.join(  settings.root_path, 'static')
    # search in project components
    elif not os.path.exists( path ):
        path = os.path.join(  settings.root_path, 'apps', component, 'static' )
    # search in core components
    else:
        path = os.path.join( settings.tao_path, 'libs', component, 'static')
    # app.router.add_static()
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
    from core.core import locale_date
    lm = locale_date("%a, %d %b %Y %H:%M:%S GMT", time.gmtime(stats.st_mtime), 'en_US.UTF-8')
    headers['Last-Modified'] = str(lm)
    headers['Cache-Control'] = 'max-age=604800'
    with open(filename, 'rb') as f:
        content = f.read()
        f.close()
    return content, headers


def route(t, r, func, name=None):
    routes.append((t, r, func, name))


def reg_tpl_global(name, item, need_request=False):
    if need_request: item.need_request=True
    tpl_globals[name] = item

reg_tpl_global('ct', ct, need_request=True)

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


def get_path(app, pp=""):
    if type(app) == str:
        try:
            __import__(app) # - импортирует модуль по имени. Например имя будет "news".
        except: print(pp, app)
        app = sys.modules[app] # - по имени "news" мы получам сам модуль news и присваиваем его переменной app
    return os.path.dirname(os.path.abspath(app.__file__))


def get_templ_path(path):
    module_name = ''; module_path = ''; file_name = ''; name_templ = 'default'
    if ':' in path:
        module_name, file_name = path.split(":", 1) # app.table main
        # print( path )
        module_path = os.path.join( get_path( module_name, path), "templ")
    else:
        module_path = os.path.join(  settings.root_path, 'templ', name_templ)
        file_name = path
    file_name = file_name if 'tpl' in file_name else file_name+'.tpl'
    return module_name, module_path, file_name




# def render_templ(t, request, p):
# def render_templ(template_name, request, context):
#     ps = tpl_globals.copy()
#     ps.update(context)
#     lang = cur_lang(request)
#     return aiohttp_jinja2.render_template( template_name, request, ps )

def render_templ(template_name, request, context):
    ps = dict()
    for k, v in tpl_globals.items():
        ps[k] = partial(v, request) if callable( v ) and hasattr(v, 'need_request') else v
    ps.update(context)
    return aiohttp_jinja2.render_template( template_name, request, ps )

def render_templ_str(template_name, request, context):
    ps = dict()
    for k, v in tpl_globals.items():
        ps[k] = partial(v, request) if callable( v ) and hasattr(v, 'need_request') else v
    ps.update(context)
    return aiohttp_jinja2.render_string( template_name, request, ps )


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
builtins.templ_str = render_templ_str


# @asyncio.coroutine
def db_handler():
    @asyncio.coroutine
    def factory(app, handler):
        @asyncio.coroutine
        def middleware(request):
            if request.path.startswith('/static/') or request.path.startswith('/_debugtoolbar'):
                response = yield from handler(request)
                return response
            # # init
            # db_inf = settings.database
            # kw = {}
            # if 'rs' in db_inf: kw['replicaSet'] = db_inf['rs']

            # from pymongo import MongoClient
            # mongo = MongoClient( db_inf['host'], 27017)
            # db = mongo[ db_inf['name'] ]
            # db.authenticate(settings.database['login'], settings.database['pass'] )
            request.db = app.db
            # процессинг запроса (дальше по цепочки мидлверов и до приложения)
            response = yield from handler(request)
            # mongo.close() # yield from db.close()
            # экземеляр рабочего объекта по цепочке вверх до библиотеки
            return response
        return middleware
    return factory


def cache_(request, name, expire=0):
    def decorator(func):
        # @asyncio.coroutine
        def wrapper(**kwargs):
            mc = request.app.mc
            assert isinstance(mc, aiomcache.Client)
            key = cache_key(name, kwargs)
            value = yield from mc.get(key)
            if value is None:
                print('Key not found, calling function and storing value...')
                value = func(**kwargs)
                # value = yield from func(request, **kwargs)
                yield from mc.set(key, pickle.dumps(value, protocol=pickle.HIGHEST_PROTOCOL), exptime=expire)
            else:
                print('Key found, restoring value...')
                value = pickle.loads(value)
            # print(value)
            return value

        return wrapper


    return decorator


def cache_key(name, kwargs):
    key = [bytes(name, 'utf-8')] + [bytes(k, 'utf-8') + b'\xff' + pickle.dumps( v ) for k, v in kwargs.items()]
    key = b'\xff'.join(key)
    key = bytes(hashlib.sha1(key).hexdigest(), 'ascii')
    return key

# if isinstance(func, asyncio.coro)
def cache(name, expire=0):
    def decorator(func):
        @asyncio.coroutine
        def wrapper(request=None, **kwargs):
            args = [r for r in [request] if isinstance(r, aiohttp.web_reqrep.Request)]
            key = cache_key(name, kwargs)

            # print( request.__dict__ )
            mc = request.app.mc
            value = yield from mc.get(key)
            if value is None:
                value = yield from func(*args, **kwargs)
                v_h = {}
                if isinstance(value, web.Response):
                    v_h = value._headers
                    value._headers = [(k, v) for k, v in value._headers.items()]
                yield from mc.set(key, pickle.dumps(value, protocol=pickle.HIGHEST_PROTOCOL), exptime=expire)
                if isinstance(value, web.Response):
                    value._headers = v_h
            else:
                value = pickle.loads(value)
                if isinstance(value, web.Response):
                    value._headers = CIMultiDict(value._headers)
            return value

        return wrapper

    return decorator


def clean_cache(key):
    # yield from mc.delete(b"another_key")
    yield from mc.delete( key )


# example   `invalidate_cache('silngle_page', id=123123)`.
def invalidate_cache(name, **kwargs):
    key = cache_key(name, kwargs)
    yield from mc.delete(key)


def response_string(request, text: str, encoding='utf-8'):
    response = web.Response()
    response.content_type = 'text/html'
    response.charset = encoding
    response.text = text
    return response


def response_json(request, struct, encoding='utf-8'):
    response = web.Response()
    response.content_type = 'application/json'
    response.charset = encoding
    response.text = json.dumps(struct)
    return response


langs = {}
def load_lang(path, module_name, lang):
    """ Loads modules с языками """
    if not module_name in langs[lang]: langs[lang][module_name] = []
    path = os.path.join( path, module_name, 'locale') if module_name else os.path.join( path, 'locale')
    if os.path.isdir(path):
        t = gettext.translation('_', path, [lang], codeset='UTF-8')
        langs[lang][module_name].append(t)


def get_lng(module):
    """ Возвращает пути с модули с языками """
    lang = cur_lang()
    if not lang in langs: langs[lang] = {}
    if not module in langs[lang]:
        langs[lang][module] = []
        load_lang( os.path.join( settings.lib_path,'app'), module, lang)
        load_lang( os.path.join( os.getcwd(),'app'), module, lang)
        if not module: load_lang( os.path.join (os.getcwd()), '', lang)
    return langs[lang][module]


def trans(module, s):
    """ принимает имя компонента и строчку, которую надо перевести
    и непосредственно переводит"""
    translated = s
    lng = get_lng(module)
    if lng:
        for i in reversed(lng):
            translated = i.gettext(s)
            # если удалось перевести то транслейтед отличается от оригинала и дальше не надо искать.
            if s != translated: break
    return translated


def get_trans(module): # возвращает функцию которая переводит само слово, саму фразу
    return lambda s: trans(module, s)


