import sys
from urllib import *
import  urllib
from urllib.parse import *

import io

from aiohttp import MultiDict, web
import aiohttp
import email.utils
from PIL import Image, ImageDraw

import time, json, shutil, requests
from gridfs import GridFS
from libs.contents.contents import *

from settings import *



async def online(request):
    print('online->')

    ws = web.WebSocketResponse()
    await ws.prepare(request)

    async for msg in ws:
        if msg.tp == aiohttp.MsgType.text:
            if msg.data == 'close': await ws.close()
            else:
                e = json.loads(msg.data)
                print('msg.data->', e)

                if e['e'] == "new":
                    curr_date = time.time()
                    users = [doc['_id'] for doc in request.db.chat.find() ]
                    print('users->', users)
                    ws.send_str( json.dumps({"e":"on", "users":users }) )
        elif msg.tp == aiohttp.MsgType.error:
            print('ws connection closed with exception %s' % ws.exception())

    print('websocket connection closed')

    return ws




 # users = [doc['_id'] for doc in request.db.chat.find({"date":curr_date}) ]
