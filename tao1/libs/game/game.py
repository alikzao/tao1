import sys, os, time, asyncio, jinja2, aiohttp_jinja2, json, traceback
from uuid import uuid4
from aiohttp import web
import aiohttp
from aiohttp.web import Application, Response, MsgType, WebSocketResponse

from settings import *


@asyncio.coroutine
def game(request):
    # room = request.match_info.get('room', "1")
    # with open('db.txt', 'r') as f:
    #     room = f.read()
    #     print ("file not empty: "+room, )

    return templ('libs.game:babylon', request, {})


@asyncio.coroutine
def test_mesh(request):
    return templ('libs.game:test_mesh', request, {})


@asyncio.coroutine
def check_room(request):
    room=1
    with open('db.txt', 'r') as f:
        rooms = json.dumps( f.read() )
        for k, v in rooms.items():
            if len(v) < 5:
                room = k
        # print(room, file=f)
        f.close()
    if room==1:
        room = uuid4().hex[:4]

    return {"result":"ok", "room":room}

@asyncio.coroutine
def pregame(request):
    room = {"1":[]}

    if os.stat("db.txt").st_size == 0:
        with open('db.txt', 'w', encoding='utf-8') as f:
            print ("file is empty", room)
            print(room, file=f)
            f.close()
    else:
        with open('db.txt', 'r') as f:
            room = f.read()
            print ("file not empty: "+room, )
    free_room = ''
    return templ('libs.game:pregame', request, {"room":room})


def babylon(request):
    """just draw a page of beginning of the game"""
    return templ('libs.game:game', request, {})


class Player():
    def __init__(self, startX, startY):
        self.id = None
        self._x = startX; self._y = startY; self._z = 0
        self._a = 0; self._b = 0

    def set_pos(self, x, y, z):
        self.x, self.y, self.z = x, y, z

    def set_rot(self, a, b):
        self.a, self.b = a, b

    def getX(self):
        return self._x

    def getY(self):
        return self._y

    def getZ(self):
        return self._z

    def getA(self):
        return self._a

    def getB(self):
        return self._b

    def setX(self, newX):
        self._x = newX

    def setY(self, newY):
        self._y = newY

    def setZ(self, newZ):
        self._z = newZ

    def setA(self, newA):
        self._a = newA

    def setB(self, newB):
        self._b = newB

    x = property(getX, setX)
    y = property(getY, setY)
    z = property(getZ, setZ)
    a = property(getA, setA)
    b = property(getB, setB)


socket = None
players = set()
clients = set()
last_id = 0


def send_all(mess, except_=tuple()):
    mess = json.dumps(mess)
    # print('mess', mess)
    for client in clients:
        if client not in except_:
            client.send_str(mess)


def h_new(me, e):
    global last_id
    assert not hasattr(me, 'player'), id(me)

    me.player = Player(e['x'], e['y'])
    me.player.client = me
    me.player.id = last_id
    me.player.room = e['room']
    last_id += 1

    mess = {'e': "new", 'id': me.player.id, 'x': me.player.x, 'y': me.player.y, 'z': me.player.z, 'msg':'newPlayer', 'room':e['room'] }
    send_all(mess, except_=(me,))

    for player in players:  # // Send existing players to the new player
        mess = {'e': "new", 'id': player.id, 'x': player.x, 'y': player.y, 'z': player.z, 'msg': 'existingPlayer'}
        me.send_str(json.dumps(mess))

    players.add(me.player)


def h_move(me, e):
    assert hasattr(me, 'player'), id(me)
    me.player.set_pos(e['x'], e['y'], e['z'])

    mess = {'e': "move", 'id': me.player.id, 'x': me.player.x, 'y': me.player.y, 'z': me.player.z, 'msg':'move', 'room':e['room']}
    send_all(mess, except_=(me,))


def h_rotate(me, e):
    assert hasattr(me, 'player'), id(me)
    me.player.set_rot(e['a'], e['b'])

    mess = {'e': "rotate", 'id': me.player.id, 'a': me.player.a, 'b': me.player.b, 'msg':'rotate', 'room':e['room']}
    send_all(mess, except_=(me,))


def h_shoot(me, e):
    assert hasattr(me, 'player'), id(me)
    mess = {'e':"shoot", 'id':me.player.id, 'pos':e['pos'], 'dir':e['dir'], 'd2':e['d2'], 'msg':'#{} says: pif-paf'.format(me.player.id), 'room':e['room']}
    send_all(mess, except_=(me,))


def h_chat(me, e):
    assert hasattr(me, 'player'), id(me)

    mess = {'e': "chat", 'id': me.player.id, 'mes': e['mes']}
    send_all(mess, except_=(me,))


def close(me):
    assert hasattr(me, 'player'), id(me)
    print('serv onclose; id', str(me.id))

    yield from me.close()
    clean(me)


def clean(me):
    if hasattr(me, 'player'):
        players.remove(me.player)
    else:
        print("onClientDisconnect   no player found", str(me.id))

    clients.remove(me)

    print('close players => ', players)
    print('close clients => ', clients)

    mess = {'e': "remove", id: me.player.id, 'msg': 'remove'}
    send_all(mess)


def handle_game(me, e):
    e = json.loads(e)
    action = e['e']
    if action in debug_handlers:
        print('Requested action:', action)
        # print ( '======================>>>>>>>>>>>>>>>', e )
    if action in handlers:
        handler = handlers[action]
        handler(me, e)
    else:
        print('Unknown action:', e['e'], '===>>>', e)
        # send_all(e)

handlers = {
    'new': h_new,
    'move': h_move,
    'rotate': h_rotate,
    'shoot': h_shoot,
    'chat': h_chat,
}

# show all except 'move'
debug_handlers = set(handlers.keys()) - {'move'}


@asyncio.coroutine
def game_handler(request):
    # init connection
    ws = web.WebSocketResponse()
    ws.start(request)
    clients.add(ws)

    # infinite message loop
    while True:
        msg = yield from ws.receive()
        # print('yield from ', msg)
        try:
            if msg.tp == MsgType.text:
                if msg.data == 'close':
                    print('client requests close')
                    #TODO удалить из комнаты игрока если он закрыл сессию.
                    close(ws)
                else:
                    handle_game(ws, msg.data)
            elif msg.tp == aiohttp.MsgType.close:
                print('websocket connection closed')
                clean(ws)
            elif msg.tp == aiohttp.MsgType.error:
                print('ws connection closed with exception ', ws.exception())
                clean(ws)
            else:
                print('unknow websocket message type:', msg.tp, id(ws))

        except Exception as e:
            print('Dark forces tried to break down our infinite loop', e)
            traceback.print_tb(e.__traceback__)

    return ws


def playerById(id):
    # for i in range(0, players):
    #     if players[i].id == id: return players[i];
    # return False
    for player in players:
        if player.id == id:
            return player
    return None



# def cannot():
#     return templ('libs.game:cannot')
#
# def explosion():
#     return templ('libs.game:explosion')
#
# def oimo():
#     return templ('libs.game:oimo')
#
# def node():
#     return templ('libs.game:node')
#
# def node1():
#     return templ('libs.game:node1')
#
# def game1():
#     return templ('libs.game:game1')
#
#
# def edit3d():
#     return templ('libs.game:edit3d')
#
# def edit3dt():
#     return templ('libs.game:edit3dt')
#
# def text():
#     return templ('libs.game:text')







   #  def __init__(self, startX, startY):
   #      self._x = startX
   #
   #  # Getters and setters
   # @property
   # def x(self):
   #      return self._x
   #
   # @x.setter
   # def x(self, newX):
   #      self._x = newX