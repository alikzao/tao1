import sys
from urllib import *
import  urllib
from urllib.parse import *

import io
import asyncio

from aiohttp import MultiDict, web
import aiohttp
import email.utils
from PIL import Image, ImageDraw

import time, json, shutil, requests
from gridfs import GridFS
from libs.contents.contents import *

from settings import *

from core.union import app


clients = []

async def ws(request):
    return templ('test_chat', request, {} )


clients = []

async def ws_handler(request):
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    # if not ws in clients:
    clients.append(ws)

    async for msg in ws:
        try:
            if msg.tp == aiohttp.MsgType.text:
                if msg.data == 'close':
                    await ws.close()
                    clients.remove(ws)
                else:
                    # print('clients=>', clients)
                    for client in clients:
                        if ws != client:
                            client.send_str(msg.data + '/answer')
            elif msg.tp == aiohttp.MsgType.error:
                print('ws connection closed with exception %s' % ws.exception())
        except Exception as e:
            print('Dark forces tried to break down our infinite loop', e)
            traceback.print_tb(e.__traceback__)
    print('websocket connection closed')
    clients.remove(ws)
    return ws


async def online(request):
    s = await get_session(request)
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    clients.append(ws)

    async for msg in ws:
        try:
            if msg.tp == aiohttp.MsgType.text:
                if msg.data == 'close': await ws.close()
                elif msg.tp == aiohttp.MsgType.pong:
                    print('ws pong')
                    if 'user_id' in s or s['user_id'] != 0 or s['user_id'] != 'guest':
                        request.db.on.update({"_id": s['user_id']}, {"$currentDate": {"date": {"$type": "timestamp"}}})
                else:
                    e = json.loads(msg.data)
                    print('msg.data->', e)

                    if e['e'] == "new":
                        curr_date = time.time()
                        users = [doc['_id'] for doc in request.db.on.find() ]
                        print('users->', users)
                        for client in clients:
                            if ws != client:
                                client.send_str(json.dumps({"e":"on", "users":users }))
                                # ws.send_str( json.dumps({"e":"on", "users":users }) )
                    elif e['e'] == "upd_on":
                        request.db.on.update({"_id":e['user_id']}, {"$currentDate": {"date": {"$type": "timestamp"}}} )
                        # request.db.on.update({"_id":e['user_id']}, {"date":""})
            elif msg.tp == aiohttp.MsgType.error:
                print('ws connection closed with exception %s' % ws.exception())
        except Exception as e:
            print('Dark forces tried to break down our infinite loop', e)
            traceback.print_tb(e.__traceback__)


    print('websocket connection closed')

    return ws


async def ping_chat_task():
    while True:
        for client in clients:
            client.pong(message=b'pong')
            break
        await asyncio.sleep(20)


async def check_online_task():
    while True:
        ts = time.time()
        for res in app.db.chat.find():
            print(res, res['date'])
            if res['date'] < 30: #600
                app.on.chat.remove({"_id":res['_id']})
            break
        await asyncio.sleep(15)




    # users = [doc['_id'] for doc in request.db.chat.find({"date":curr_date}) ]
