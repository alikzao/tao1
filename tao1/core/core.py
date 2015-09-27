import os, time, asyncio

from pymongo import *

import settings

def die(mess):
    raise Exception(str(mess))

# @asyncio.coroutine
# def server_connect():
# 	if not db_conn['conn']:
# 		db = get_settings('database', {} )
# 		kw = {}
# 		db_conn['conn'] = MongoClient(db['host'], **kw)
# 	return db_conn['conn']
# @asyncio.coroutine
# def connect():
#     db = get_settings('database', {} )
#     mongo = MongoClient(db['host'], db['port'])
#     print( mongo)
#     db = mongo['tok']
#     db.authenticate('admin', settings.database['pass'] )
#     return db

@asyncio.coroutine
def get_settings(name, def_val=None):
    if name in settings.__dict__: return settings.__dict__[name]
    else: return def_val


@asyncio.coroutine
def locale_date(format, dt, loc = 'en_US.UTF-8'):
    """ dt - кортеж """
    import locale
    lc = locale.getdefaultlocale()
    # lc = locale.getlocale(locale.LC_ALL)
    locale.setlocale(locale.LC_ALL, loc)
    res = time.strftime(format, dt)
    locale.setlocale(locale.LC_ALL, lc)
    return res
