import sys
from urllib import *
import urllib
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
    return templ("test_chat", request, {})


clients = []


async def ws_handler(request):
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    clients.append(ws)

    async for msg in ws:
        try:
            if msg.tp == aiohttp.MsgType.text:
                if msg.data == "close":
                    await ws.close()
                    clients.remove(ws)
                else:
                    for client in clients:
                        if ws != client:
                            client.send_str(msg.data + "/answer")
            elif msg.tp == aiohttp.MsgType.error:
                print("ws connection closed with exception %s" % ws.exception())
        except Exception as e:
            print("Dark forces tried to break down our infinite loop", e)
            traceback.print_tb(e.__traceback__)
    print("websocket connection closed")
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
                if msg.data == "close":
                    finish(ws)
                else:
                    e = json.loads(msg.data)

                    if e["e"] == "new":
                        try:
                            users = [doc["_id"] for doc in request.db.on.find()]
                            print("ws users->", users)
                            for client in clients:
                                msg = {"e": "on", "users": users}
                                print("ws send", msg)
                                client.send_str(json.dumps(msg))
                        except:
                            pass
                    elif e["e"] == "pong":
                        if "user_id" in s or s["user_id"] != 0:
                            if s["user_id"] != "guest":
                                print("ws update time s[user_id]", s["user_id"])
                                request.db.on.update(
                                    {"_id": s["user_id"]},
                                    {"$set": {"date": time.time()}},
                                )
            elif msg.tp == aiohttp.MsgType.error:
                print("ws connection closed with exception %s" % ws.exception())
                finish(ws)
        except Exception as e:
            print("Dark forces tried to break down our infinite loop", e)
            traceback.print_tb(e.__traceback__)

    print("websocket connection closed")
    finish(ws)
    return ws


async def finish(ws):
    if ws in clients:
        clients.remove(ws)
    if not ws.closed:
        await ws.close()


tm = 3600
sl = 20


async def ping_chat_task():
    while True:
        try:
            for client in clients:
                try:
                    print("ping_task=>", client)
                    client.send_str(json.dumps({"e": "ping"}))
                except Exception as e:
                    traceback.print_exc()
                    print("Ping task error: {}".format(e))
        except Exception as e:
            traceback.print_exc()
            print("Ping task error: {}".format(e))

        await asyncio.sleep(sl)


async def check_online_task():
    while True:
        try:
            for res in app.db.on.find():
                ts = time.time() - tm
                if res["date"] < ts:
                    print("check_online_task if res=>", res)
                    app.db.on.remove({"_id": res["_id"]})
                    app.db.doc.update(
                        {"_id": "user:" + res["_id"]}, {"$set": {"status": "off"}}
                    )
        except Exception as e:
            traceback.print_exc()
            print("Ping task error: {}".format(e))
        await asyncio.sleep(sl)
