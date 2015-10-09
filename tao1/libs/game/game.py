import sys, os, time, asyncio, jinja2, aiohttp_jinja2, json, traceback
from aiohttp import web
import aiohttp
from aiohttp.web import Application, Response, MsgType, WebSocketResponse

from settings import *

@asyncio.coroutine
def babylon(request):
    return templ('libs.game:babylon', request, {})


def pregame(request):
    return templ('libs.game:pregame')


def game(request):
    """just draw a page of beginning of the game"""
    return templ('libs.game:game')


socket = None
players=[]
# clients={}
clients=set()
max_id = 0

class Player():
    def __init__(self, startX, startY):
        self.id = None
        self.x = startX; self.y = startY; self.z = 0
        self.a = 0; self.b = 0
    def getX(self):
        return self.x
    def getY(self):
        return self.y
    def getZ(self):
        return self.z

    def setX(self, newX):
        self.x = newX
    def setY(self, newY):
        self.y = newY
    def setZ(self, newZ):
        self.z = newZ

    def getA(self):
        return self.a
    def getB(self):
        return self.b
    def setA(self, newA):
        self.a = newA
    def setB(self, newB):
        self.b = newB


@asyncio.coroutine
def game_handler(request):
    ws = web.WebSocketResponse()
    ws.start(request)
    clients.add(ws)
    while True:
        msg = yield from ws.receive()
        # print('yield from ', msg)
        if msg.tp == MsgType.text:
            # e = json.loads( msg.data )
            if msg.data == 'close':
                yield from ws.close()
                print('serv onclose '+e, 'max_id',str(ws.id))
                removePlayer = playerById(ws.id)
                if not removePlayer: print("onClientDisconnect   Player not found: "+str(ws.id))
                print('close players => ', players)
                print('close clients => ', clients)

                # delete clients[ws.id];
                # players.splice(players.indexOf(removePlayer), 1);


                mess = json.dumps( {'e':"remove", id: max_id, 'msg':'remove'} )
                for client in clients:
                    try:
                        client.send_str(mess)
                    except(e):
                        print('# error exception => # '+e)
            else:
                try:
                    #     ws.send_str(msg.data + '/answer')
                    e = json.loads( msg.data )
                    # print ( '======================>>>>>>>>>>>>>>>', e )
                    if e['e'] == 'new':
                        print(' :: if e.e == "new":', e,  id(ws) )
                        newPlayer = Player(e['x'], e['y'])
                        newPlayer.id = max_id
                        # player = newPlayer
                        player = newPlayer
                        ws.player = player

                        mess = json.dumps( {'e':"new", 'id':newPlayer.id, 'x':newPlayer.getX(), 'y':newPlayer.getY(),'z':newPlayer.getZ(), 'msg':'newPlayer'} )
                        print( 'mess', mess)
                        for client in clients:
                            print( 'client =>', client )
                            # if client.player.id != player.id:
                            if hasattr(client, 'player') and client.player.id != player.id:
                                client.send_str(mess)

                        # //for(var i in clients) clients[i].send(mess);
                        for i in range(0, len(players)):  #// Send existing players to the new player
                            existingPlayer = players[i]
                            mess = json.dumps( {'e':"new", 'id': existingPlayer.id, 'x':existingPlayer.getX(), 'y':existingPlayer.getY(),'z':existingPlayer.getZ(), 'msg':'existingPlayer'} )
                            ws.send_str( mess)

                        players.append(newPlayer)
                    elif e['e'] == 'move':
                        # print(' :: if e.e == "move":', e,  id(ws) )
                        movePlayer = player
                        if not movePlayer:
                            print("__onMovePlayer__ Player not found: "+ str(max_id))
                            return
                        movePlayer.setX(e['x'])
                        movePlayer.setY(e['y'])
                        movePlayer.setZ(e['z'])
                        # //console.log('Player '+max_id+' move has joined', 'id', movePlayer.id, 'x', movePlayer.getX(), 'y',movePlayer.getY());
                        mess = json.dumps( {'e':"move", 'id':movePlayer.id, 'x':movePlayer.getX(), 'y':movePlayer.getY(),'z':movePlayer.getZ(), 'msg':'move'} )
                        print('move clients', clients)
                        for client in clients:
                            print('===clients->', player.id)
                            # if client.player.id != player.id:
                            if hasattr(client, 'player') and client.player.id != player.id:

                                    # //clients[i].send(mess);
                                # if clients[i].readyState != OPEN: print('Client state is ' + clients[i].readyState)
                                # else:
                                client.send_str(mess)
                    elif e['e'] == 'rotate':
                        print(' :: if e.e == "rot":', e,  id(ws) )
                        rotPlayer = player
                        if not rotPlayer:
                            print("__onRotatePlayer__ Player not found: "+str(max_id))
                            return
                        rotPlayer.setA(e['a'])
                        rotPlayer.setB(e['b'])
                        # //console.log('Player '+max_id+' move has joined', 'id', movePlayer.id, 'x', movePlayer.getX(), 'y',movePlayer.getY());
                        mess = json.dumps( {'e':"rotate", 'id':rotPlayer.id, 'a':rotPlayer.getA(), 'b':rotPlayer.getB(), 'msg':'move'} )
                        for client in clients:
                            # //if (clients[i].player.id != this.player.id)
                            # if client.player.id != player.id:
                            if hasattr(client, 'player') and client.player.id != player.id:

                                client.send_str(mess)
                    elif e['e'] == 'shoot':
                        print(' :: if e.e == "shot":', e,  id(ws) )
                        sPlayer = player
                        ws.player = player
                        if not sPlayer:
                            print("__onShootPlayer__ Player not found: "+str(max_id))
                            return
                        print('Player '+str(max_id)+' shoot has joined', 'id', sPlayer.id, 'x', sPlayer.getX(), 'y',sPlayer.getY())
                        mess = json.dumps( {'e':"shoot", 'id':sPlayer.id, 'pos':e['pos'], 'dir':e['dir'], 'd2':e['d2']} )
                        for client in clients:
                            # if client.player.id != player.id:
                            if hasattr(client, 'player') and client.player.id != player.id:

                                 client.send_str(mess)
                                 print('shoot request=====================================')
                    elif e['e'] == 'chat':
                        print(' :: if e.e == "chat":', e,  id(ws) )
                        chatPlayer = player
                        # //if (!chatPlayer) { console.log("__onChatPlayer__ Player not found: "+max_id); return; }
                        print('Player '+str(max_id)+' chat has joined', 'id', chatPlayer.id, 'mess', e['mes'])
                        mess = json.dumps( {'e':"chat", 'id':chatPlayer.id, 'mes':e['mes']} )
                        for client in clients:
                            # if client.player.id != player.id:
                            if hasattr(client, 'player') and client.player.id != player.id:

                                client.send_str(mess)
                    else:
                        print('получено сообщение ' + e)
                        for client in clients:
                            client.send_str(e)
                except Exception as e:
                    print('EXCEPTION', e)
                    traceback.print_tb(e.__traceback__)
        elif msg.tp == aiohttp.MsgType.close:
            print('websocket connection closed')
            # break
        elif msg.tp == aiohttp.MsgType.error:
            print('ws connection closed with exception %s', ws.exception())
            # break
    return ws


def playerById(id):
#    console.log('players', players);
    for i in range(0, players):
        if players[i].id == id: return players[i];
    return False





# def cannot():
#     return templ('app.game:cannot')
#
# def explosion():
#     return templ('app.game:explosion')
#
# def oimo():
#     return templ('app.game:oimo')
#
# def node():
#     return templ('app.game:node')
#
# def node1():
#     return templ('app.game:node1')
#
# def game1():
#     return templ('app.game:game1')
#
#
# def edit3d():
#     return templ('app.game:edit3d')
#
# def edit3dt():
#     return templ('app.game:edit3dt')
#
# def text():
#     return templ('app.game:text')







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