import sys, os, time, asyncio, jinja2, aiohttp_jinja2
from aiohttp import web
import aiohttp
from aiohttp.web import Application, Response, MsgType, WebSocketResponse

from core.union import cache

from pymongo import *
# from gridfs import GridFS
from aiohttp_session import get_session


@cache("main_page", expire=5)
@asyncio.coroutine
def page(request):
    return templ('apps.app:index', request, {'key':'val'} )


@asyncio.coroutine
def test_db(request):
    session = yield from get_session(request)
    session['last_visit'] = time.time()
    request.db.doc.save({"_id":"test", "val":"test_db", "status":"success"})
    val = request.db.doc.find_one({"_id":"test"})
    return templ('apps.app:db_test', request, {'key':val})


@asyncio.coroutine
def ws(request):
    return templ('apps.app:chat', request, {} )

@asyncio.coroutine
def ws_handler(request):
    ws = web.WebSocketResponse()
    ws.start(request)
    while True:
        msg = yield from ws.receive()
        if msg.tp == MsgType.text:
            if msg.data == 'close':
                yield from ws.close()
            else:
                ws.send_str(msg.data + '/answer')
        elif msg.tp == aiohttp.MsgType.close: print('websocket connection closed')
        elif msg.tp == aiohttp.MsgType.error: print('ws connection closed with exception %s', ws.exception())
    return ws




























