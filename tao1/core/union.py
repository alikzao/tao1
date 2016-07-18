import sys, os, json, pickle, gettext, hashlib


import aiohttp.web_reqrep

assert sys.version_info >= (3, 5), 'Please use Python 3.5 or higher.'

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
from datetime import datetime
from time import time
import aiohttp_autoreload



routes = []
tpl_globals = {
    # 'lang':cur_lang,
    'auth':{'vk':settings.oauth_vk, 'fb':settings.oauth_fb, 'ok':settings.oauth_ok},
    'debug':settings.debug,
    'domain':settings.domain,
    'session_get_mess':dict,
    'str':str,
    'len':len,
    'int':int,
    'list':list,
    'float':float,
    'quote_url':quote,
    'urlparse':urlparse,
    'user':{'id':"", 'name':"", 'is_admin':"", 'is_logged':"", 'info': '', 'branch':'', 'has_perm':"", "full_id": "", 'rate': ""},
    'format_date':format_date,
    'h':htmlspecialchars,
}
mc = None
app = None
debug = settings.debug
reload = settings.reload

async def init(loop):
    global mc
    global app

    middlewares = []
    # middlewares.append(aiohttp_debugtoolbar.middleware) # debugtoolbar.intercept_redirects = false

    middlewares.append(db_handler())
    if settings.debug:
        middlewares.append( session_middleware(SimpleCookieStorage()) )
    else:
        middlewares.append( session_middleware(EncryptedCookieStorage(settings.session_key)) )

    app = web.Application(loop=loop, middlewares=middlewares)

    # aiohttp_debugtoolbar.setup(app)
    # debugtoolbar.intercept_redirects = False
    # aiohttp_debugtoolbar.intercept_redirects = False

    aiohttp_jinja2.setup(app, loader=jinja2.FunctionLoader(load_templ ), bytecode_cache = None, cache_size=0 )

    # Memcache init
    app.mc = aiomcache.Client( settings.memcache['addr'], settings.memcache['port'], loop=loop)

    # Mongo init
    db_connect(app)

    union_routes( os.path.join(settings.tao_path, 'libs' ) )
    union_routes( os.path.join(settings.root_path, 'apps') )
    union_routes( os.path.join(settings.root_path ), p=True )


    for res in routes:
        name = res[3]
        if name is None: name = '{}:{}'.format(res[0], res[2])
        app.router.add_route( res[0], res[1], res[2], name=name)

    path = os.path.join(settings.root_path, 'static')
    # print('path->', path)
    app.router.add_static('/static/', os.path.join(settings.root_path, 'static'))
    sites = os.path.join(settings.tao_path, 'libs', 'sites', 'st')
    # print('sites->', sites)
    app.router.add_static('/st/sites/', os.path.join(settings.tao_path, 'libs', 'sites', 'st'))
    app.router.add_static('/st/table/', os.path.join(settings.tao_path, 'libs', 'table', 'st'))
    app.router.add_static('/st/tree/', os.path.join(settings.tao_path,  'libs', 'tree', 'st'))
    app.router.add_static('/st/admin/', os.path.join(settings.tao_path, 'libs', 'admin', 'st'))
    app.router.add_static('/st/contents/', os.path.join(settings.tao_path, 'libs', 'contents', 'st'))
    app.router.add_static('/st/chat/',  os.path.join(settings.tao_path, 'libs', 'chat',  'st'))
    app.router.add_static('/st/files/', os.path.join(settings.tao_path, 'libs', 'files', 'st'))
    app.router.add_static('/st/game/',  os.path.join(settings.tao_path, 'libs', 'game',  'st'))
    app.router.add_static('/st/perm/',  os.path.join(settings.tao_path, 'libs', 'perm',  'st'))


    # app.router.add_route('GET', '/static/{dir}/{fname}', st_file, name='static')

    handler = app.make_handler(debug=True )
    if debug and reload:
        aiohttp_autoreload.start()
    srv = await loop.create_server(handler, settings.addr[0], settings.addr[1])
    print("Server started at "+settings.addr[0] +' '+ str(settings.addr[1]))

    return srv, handler, app


from pathlib import Path
def st_file(request):
    fname = request.match_info.get('fname')
    try:
        dir = Path(os.path.join(settings.root_path, 'static')).resolve()
        filepath = dir.joinpath(fname).resolve()
        # filepath.relative_to(dir)
    except (ValueError, FileNotFoundError) as error:
        raise web.HTTPNotFound


async def union_stat(request, *args):
    component = request.match_info.get('component', "Anonymous")
    fname = request.match_info.get('fname', "Anonymous")
    path = os.path.join( settings.tao_path, 'libs', component, 'static', fname )
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
    global mc

    middlewares = []

    middlewares.append(db_handler())
    if settings.debug:
        middlewares.append( session_middleware(SimpleCookieStorage()) )
    else:
        middlewares.append( session_middleware(EncryptedCookieStorage(settings.session_key)) )
    app = web.Application( middlewares=middlewares )

    aiohttp_jinja2.setup(app, loader=jinja2.FunctionLoader ( load_templ ) )

    # Memcache init
    app.mc = aiomcache.Client( settings.memcache['addr'], settings.memcache['port'])

    # Mongo init
    db_connect(app)

    union_routes( os.path.join(settings.tao_path, 'libs' ) )
    union_routes( os.path.join(settings.root_path, 'apps') )
    union_routes( os.path.join(settings.root_path ), p=True )

    for res in routes:
        name = res[3]
        if name is None: name = '{}:{}'.format(res[0], res[2])
        app.router.add_route( res[0], res[1], res[2], name=name)

    path = os.path.join(settings.root_path, 'static')
    app.router.add_static('/static/', path, name='static')

    return app


def route(t, r, func, name=None):
    routes.append((t, r, func, name))


def reg_tpl_global(name, item, need_request=False):
    if need_request: item.need_request=True
    tpl_globals[name] = item

reg_tpl_global('ct', ct, need_request=True)


def union_routes(dir, p=False):
    routes = []
    name_app = dir.split(os.path.sep)
    name_app = name_app[len(name_app) - 1]
    if p:
        builtins.__import__('routes', globals=globals())
    else:
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


def get_path(module_name, pp=""):
    # print('app->', app)
    if type(module_name) == str:
        try:
            # print('module_name->', module_name)
            __import__(module_name) # - import module name. For example the name will "news".
        except:
            print(pp, module_name)
        module_name = sys.modules[module_name] # - named "news" we receive the news itself module and assign it to the variable app
    return os.path.dirname(os.path.abspath(module_name.__file__)) # like this:     import site;  site.__file__ --> '/usr/lib/python3.1/site.py'


def get_templ_path(path):
    module_name = ''; module_path = ''; file_name = ''; name_templ = 'default'
    if ':' in path:
        module_name, file_name = path.split(":", 1) # app.table main
        module_path = os.path.join( get_path( module_name, path), "templ")
    else:
        module_path = os.path.join(  settings.root_path, 'templ', name_templ)
        file_name = path
    file_name = file_name if 'tpl' in file_name else file_name+'.tpl'
    return module_name, module_path, file_name


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
    async def factory(app, handler):
        async def middleware(request):
            if request.path.startswith('/static/') or request.path.startswith('/_debugtoolbar'):
                response = await handler(request)
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
            response = await handler(request)
            # mongo.close() # yield from db.close()
            return response
        return middleware
    return factory


def cache_(request, name, expire=0):
    def decorator(func):
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
        async def wrapper(request=None, **kwargs):
            args = [r for r in [request] if isinstance(r, aiohttp.web_reqrep.Request)]
            key = cache_key(name, kwargs)

            # print( request.__dict__ )
            mc = request.app.mc
            value = await mc.get(key)
            if value is None:
                value = await func(*args, **kwargs)
                v_h = {}
                if isinstance(value, web.Response):
                    v_h = value._headers
                    value._headers = [(k, v) for k, v in value._headers.items()]
                await mc.set(key, pickle.dumps(value, protocol=pickle.HIGHEST_PROTOCOL), exptime=expire)
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
    """ Return path with modules (lang) """
    lang = cur_lang()
    if not lang in langs: langs[lang] = {}
    if not module in langs[lang]:
        langs[lang][module] = []
        load_lang( os.path.join( settings.lib_path,'app'), module, lang)
        load_lang( os.path.join( os.getcwd(),'app'), module, lang)
        if not module: load_lang( os.path.join (os.getcwd()), '', lang)
    return langs[lang][module]


def trans(module, s):
    """ It takes the component name and the string that needs to be translated and translates"""
    translated = s
    lng = get_lng(module)
    if lng:
        for i in reversed(lng):
            translated = i.gettext(s)
            # if it transferred to the transleyt different from the original and does not need to look further.
            if s != translated: break
    return translated


def get_trans(module):
    """ returns a function that translates the word, phrase, """
    return lambda s: trans(module, s)



async def union_stat(request, *args):
    component = request.match_info.get('component', "Anonymous")
    fname = request.match_info.get('fname', "Anonymous")
    path = os.path.join( settings.tao_path, 'libs', component, 'static', fname )
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

# test
