import sys, os, time
import asyncio
import json
import traceback
import random
import math
from uuid import uuid4
from aiohttp import web
import aiohttp
from aiohttp.web import Application, Response, MsgType, WebSocketResponse
from core.union import response_json
from core.core import get_hash
import settings
from settings import *
from collections import defaultdict

from datetime import datetime
# rooms = defaultdict(list)
# players = rooms[msg.room]


class Player(list):
    last_id = 0
    __slot__ = []

    def __init__(self, client, room, x=0, y=0, z=0, a=0, b=0):
        assert isinstance(room, Room)
        list.__init__(self, (x, y, z, a, b))
        # клиент и комната, к которым относится игрок
        self._client = client
        self._room = room
        # вычисляем свой id
        Player.last_id += 1
        self._id = Player.last_id
        # add self in room
        room.add_player(self)

    @property
    def id(self):
        return self._id

    def __hash__(self): return hash(self.id)

    def __eq__(self, other): return other is self

    def __repr__(self): return 'Player(id={},pos={})'.format (self.id, ','.join(str(x) for x in self))

    @property
    def room(self):
        """:rtype: Room """
        return self._room

    @property
    def client(self):
        """:rtype: web.WebSocketResponse """
        return self._client

    def get_pos(self): return self[0:3]

    def get_rot(self): return self[3:5]

    def set_pos(self, x, y, z): self[0:3] = x, y, z

    def set_rot(self, a, b): self[3:5] = a, b

    def getX(self): return self[0]

    def getY(self): return self[1]

    def getZ(self): return self[2]

    def getA(self): return self[3]

    def getB(self): return self[4]

    def setX(self, newX): self[0] = newX

    def setY(self, newY): self[1] = newY

    def setZ(self, newZ): self[2] = newZ

    def setA(self, newA): self[3] = newA

    def setB(self, newB): self[4] = newB

    pos = property(get_pos, set_pos)
    rot = property(get_rot, set_rot)
    x = property(getX, setX)
    y = property(getY, setY)
    z = property(getZ, setZ)
    a = property(getA, setA)
    b = property(getB, setB)

    @property
    def as_dict(self):
        return dict(zip(('x', 'y', 'z', 'a', 'b'), self))

    @property
    def pos_as_dict(self):
        return dict(zip(('x', 'y', 'z'), self.pos))

    @property
    def rot_as_dict(self):
        return dict(zip(('a', 'b'), self.rot))


class Bot(Player):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.move_vec = ( 0, 0 )
        # self.run_task = asyncio.async(self.update)
        self.run_task = asyncio.ensure_future(self.update())
        self.run_task = asyncio.ensure_future(self.update_bot_vec())
        self.run_task = asyncio.ensure_future(self.shoot())

    def __repr__(self): return 'Bot(id={},pos={})'.format (self.id, ','.join(str(x) for x in self))

    async def update(self):
        last = datetime.now()
        while True:
            try:
                now = datetime.now()
                delta = (now - last).total_seconds()
                last = now
                for player in self.room.players:
                    if player is self:  continue
                    # sgn = self.x > player.x and 1 or -1
                    vx, vz = self.move_vec
                    # print(vx, vz)
                    self.x += .9 * vx * delta
                    self.z += .9 * vz * delta
                    self.y = -2
                    # print('self.x', self.x)
                    # print('new pos:', self.pos, 'delta', delta)
                    mess = dict(e="move", bot=1, id=self.id, **self.pos_as_dict)
                    self.room.send_all(mess, except_=(self,))

                    break
            except Exception as e:
                traceback.print_exc()
                print('Bot error: {}'.format( e ))
            await asyncio.sleep(0.1)

    async def shoot (self):
        # pass
        while True:
            try:
                players =list(sorted(self.room.players - {self}, key=lambda x: x.id))
                if players:
                    player = players[-1]

                dx = player.x - self.x
                dz = player.z - self.z
                self.b = math.atan2(dx, dz)
                mess = dict(e="rotate", bot=1, id=self.id, **self.rot_as_dict)
                self.room.send_all(mess, except_=(self,))

                dir =  {'z': dz, 'y': -2, 'x': dx}
                pos = {"x":self.x, "y":self.y, "z":self.x}
                mess = {'e':"shoot", 'id':self.id,    'pos':pos,   'dir':dir,  'msg':'', 'bot':1 }
                # mess = {'e':"shoot", 'id':self.id,  'pos':dir, 'dir':pos,  'msg':'', 'bot':1 }

                self.room.send_all(mess, except_=(self,))

            except Exception as e:
                traceback.print_exc()
                print('Bot error: {}'.format( e ))
            await asyncio.sleep(2)


    async def update_bot_vec (self):
        while True:
            try:
                players =list(sorted(self.room.players - {self}, key=lambda x: x.id))
                if players:
                    player = players[-1]
                # print('New bot target:', repr(player))
                self.move_vec = self.rotate(player.x - self.x, player.z - self.z, math.pi / 2.5)
                # print('vec:', self.move_vec)

                    # break
            except Exception as e:
                traceback.print_exc()
                print('Bot error: {}'.format( e ))
            await asyncio.sleep(0.5)

    def rotate (self, vx, vy, a):
        rx = vx * math.cos( a ) - vy * math.sin( a )
        ry = vx * math.sin( a ) + vy * math.cos( a )
        return rx, ry


def h_new(me, e):
    assert not hasattr(me, 'player'), [id(me), e]

    coor = random.sample([ 2, 3, 4, 5, 6, 7, 8, 9],  2) # get random coordinates 2 to 10
    me.player = Player(me, Room.get(e['room']), coor[0], coor[1])

    mess = dict(e="new", id=me.player.id, msg='newPlayer', **me.player.as_dict)
    me.player.room.send_all(mess, except_=(me.player,))
    # print ( 'me.', me.__dict__ , 'me.player.room', me.player.room.__dict__ , 'me.player.', me.player.__dict__ )
    # {'id': '044', 'bot': Bot(id=1,pos=6,4,0,0,0), '_players': {Bot(id=1,pos=6,4,0,0,0), Player(id=2,pos=5,8,0,0,0)}}

    for player in me.player.room.players:  # // Send existing players to the new player
        if player is me.player: continue
        is_bot = isinstance(player, Bot)
        print('is_bot', is_bot)
        mess = dict(e="new", id=player.id, bot=is_bot, msg='existingPlayer', **player.as_dict)
        me.send_str(json.dumps(mess))


def h_move(me, e):
    assert hasattr(me, 'player'), [id(me), e]
    me.player.set_pos(e['x'], e['y'], e['z'])
    mess = dict(e="move", id=me.player.id, **me.player.pos_as_dict)
    me.player.room.send_all(mess, except_=(me.player,))
    # bot_id = me.player.room.bot.id


def h_rotate(me, e):
    assert hasattr(me, 'player'), [id(me), e]
    me.player.set_rot(e['a'], e['b'])

    mess = dict(e="rotate", id=me.player.id, msg='rotate', **me.player.rot_as_dict)
    me.player.room.send_all(mess, except_=(me.player,))


def h_shoot(me, e):
    assert hasattr(me, 'player'), [id(me), e]
    print( 'dir :', e['dir'], 'pos :',e['pos'] )
    mess = {'e':"shoot", 'id':me.player.id, 'pos':e['pos'], 'dir':e['dir'], 'msg':'#{} shot'.format(me.player.id) }
    me.player.room.send_all(mess, except_=(me.player,))


def h_chat(me, e):
    assert hasattr(me, 'player'), [id(me), e]

    mess = {'e': "chat", 'id': me.player.id, 'mes': e['mes']}
    me.player.room.send_all(mess, except_=(me.player,))


class Room(object):
    # me.player.room {'id': '46c', '_players': {[4, 5, 0, 0, 0]}}
    @staticmethod
    def get(_id):
        if not _id in rooms:
            rooms[_id] = Room(_id)
        return rooms[_id]

    def __init__(self, _id):
        self._send_ctr = 0
        self.id = _id
        self._players = set()
        coor = random.sample([ 2, 3, 4, 5, 6, 7, 8, 9],  2)
        self.bot = Bot(FakeWS(), self, *coor)
        # self.bot.id = get_hash(3)

    def send_all(self, mess, except_=tuple()):

        self._send_ctr += 1
        mess['_ctr'] = self._send_ctr

        mess = json.dumps(mess)
        for player in self._players:
            if player not in except_:
                # print('send_all', 'player->', player, 'mess', mess)
                player.client.send_str(mess)

    @property
    def players(self):
        return frozenset(self._players)

    def add_player(self, player):
        assert isinstance(player, Player)
        self._players.add(player)
        # self.updated()

    def remove_player(self, player):
        assert isinstance(player, Player)
        self._players.remove(player)



class FakeWS(object):

    def send(*args, **kwargs):
        pass

    def close(*args, **kwargs):
        pass

    def send_str(*args, **kwargs):
        pass
# =====================================================================================================================

socket = None
clients = set()
rooms = dict()
number_bots = 1

# =====================================================================================================================

async def game(request):
    return templ('libs.game:game', request, {})


async def test_mesh(request):
    return templ('libs.game:test_mesh', request, {})


async def pregame(request):
    return templ('libs.game:pregame', request, {})


async def check_room(request):
    print ( 'rooms  => ', rooms )
    found = None
    for _id, room in rooms.items():
        if len(room.players) < 3:
            print('players in room < 3:', _id)
            found = _id
            break
    else:
        while not found:
            _id = uuid4().hex[:3]
            if _id not in rooms: found = _id
    return response_json(request, {"result": "ok", "room": found})


def babylon(request):
    """just draw a page of beginning of the game"""
    return templ('libs.game:game', request, {})


def clean(me):
    if hasattr(me, 'player'):
        me.player.room.remove_player(me.player)
        mess = {'e': "remove", 'id': me.player.id, 'msg': 'remove'}
        me.player.room.send_all(mess)
    else:
        print("onClientDisconnect   no player found", str(me.id))
    clients.remove(me)


# me.player.room {'id': '46c', '_players': {[4, 5, 0, 0, 0]}}
# me.player      {'_id': 1, 'last_id': 1, '_room': <libs.game.game.Room object at 0x7fae8e8324e0>, '_client': <WebSocketResp Switching Protocols GET /game_handler >, }

handlers = {
    'new': h_new,
    'move': h_move,
    'rotate': h_rotate,
    'shoot': h_shoot,
    'chat': h_chat,
}

# show all except 'move'
debug_handlers = set(handlers.keys()) - {'move'}


async def game_handler(request):
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    clients.add(ws)
    async for msg in ws:
        try:
            if msg.tp == MsgType.text:
                if msg.data == 'close':
                    print('client requests close')
                    #TODO remove from room the player if he closed session
                    await ws.close()
                    clean(ws)
                else:
                    e = json.loads( msg.data )
                    action = e['e']
                    # print( e )
                    if action in debug_handlers:
                        pass
                    if action in handlers:
                        handler = handlers[action]
                        # player = e['id']
                        # handler(player, e)
                        handler(ws, e)
                    else:
                        print('Unknown action:', e['e'], '->', e)
                        # send_all(e)
            elif msg.tp == aiohttp.MsgType.error:
                print('ws connection closed with exception ', ws.exception())
                clean(ws)
            else:
                print('unknow websocket message type:', msg.tp, id(ws))
        except Exception as e:
            print('Dark forces tried to break down our infinite loop', e)
            traceback.print_tb(e.__traceback__)
    print('websocket connection closed')
    clean(ws)
    return ws


