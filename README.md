

[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=plastic)](http://opensource.org/licenses/MIT)
[![PyPI version](https://badge.fury.io/py/tao1.svg)](https://badge.fury.io/py/tao1)


# Introduction.
This asynchronous framework with a modular structure like Django. But with mongodb, jinja2, websocket out of the box,
and more than a simple barrier to entry.

Built on the basis of asyncio and aiohttp. In the framework, have batteries. The prototype of the game framework as a component.

###Requirements

Python >= 3.5.1   
aiohttp == 0.20.2
aiohttp_jinja2    
aiohttp_session      
aiohttp_debugtoolbar        
aiomcache     
pymongo        

###Installation Python 3.5 for ubuntu 
```bash
sudo add-apt-repository ppa:fkrull/deadsnakes
sudo apt-get update
sudo apt-get install python3.5 python3.5-dev 
```

#Framework Installation
```bash
$ pip install tao1
```
##Getting Started

Create a project anywhere:
```bash
   utils.py -p name
```
Create an application in the folder of the project apps:
```bash
   utils.py -a name
```   
Run server:
```bash
   python3 index.py
```   
##License

It's *MIT* licensed and freely available.

##Deploy
When you develop enough to run the file `python3 index.py`.
For production to run `index.py`, is better to use the `supervisor` and `nginx`.
Settings supervisor in `/etc`:
```python
   [program:name]
   command=python3 index.py
   directory=/path/to/your/project
   user=nobody
   autorestart=true
   redirect_stderr=true
```
Settings nginx in `/etc` together with proxy websocket::
```nginx
server {
        server_name        aio.dev;
         location / {
                 proxy_pass http://127.0.0.1:8080;
         }
        location /ws {
              proxy_pass http://127.0.0.1:8080;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
       }
}
```

###Routes

Example route in file `routes.py`::
```python
   from libs.game.game import  *
   from core.union import route
   
   route('GET', '/ws',  ws,	'ws' )
```   
###Templates

In framework integrated `jinja2`. Templates are always in the `templ` folder.

To call the template function `templ` and pass it the template name. If the template is in some sort of module,
the call looks like this `libs.modul_name.templ_name`.

If the template is in the root of the project in the templ folder, then simply write his name.

Example:
```python
   def page(request):
       return templ('index', request, {'key':'val'} )
```

###Websockets

The websocket to create games and chat very easy to use.

The first is the need to call route with the template to draw the route and chat with the handler for chat:

```python
   route('GET', '/ws',   ws,    'ws' )
   route('GET', '/wsh',  ws_handler, 'ws_handler' )
```
These routes work you can see an example.

The second is the functions themselves.
Function for render chat page:
```python
   async def ws(request):
       return templ('libs.app:chat', request, {} )
```
Function handler chat:

```python  
   async def ws_handler(request):
      ws = web.WebSocketResponse()
      await ws.prepare(request)
      async for msg in ws:
          if msg.tp == aiohttp.MsgType.text:
              if msg.data == 'close':
                  await ws.close()
              else:
                  ws.send_str(msg.data + '/answer')
          elif msg.tp == aiohttp.MsgType.error:
              print('ws connection closed with exception %s' % ws.exception())
      print('websocket connection closed')
      return ws
```

###Database

To write the database query you need to `request.db`
and then as usual.

```python
    async def test_db(request):
	    # save doc
	    request.db.doc.save({"_id":"test", "status":"success"})
	    # find doc
	    val = request.db.doc.find_one({"_id":"test"})
	    return templ('apps.app:db_test', request, {'key':val})
```

###Static files

 Static files it is better to entrust `nginx` but `tao1` able return files.

 All files must be located in the folder static.

 If they are the root of the project then the path will be like this `/static/file_name.pg`.
 If the files are in a certain module, then the path like this `/static/module_name/file_name.jpg`.

###Caching

Create cache for function 5 second, the first parameter - name::

```python
   @cache("main_page", expire=5)
   async def page(request):
       return templ('index', request, {'key':'val'} )
```

#Game 
In this case, the game framework is a battery, the basic framework. The game is a 3D multiplayer shooting.
Prototype game framework have  multiplayer mode, the mini-map, rooms, bot, several typical models of tanks.
The client side is written in the framework `WEBGL` babylon.js.
###Game start
Game start is located on the route `/pregame`.   
   
![Image alt](https://github.com/alikzao/tao1/raw/master/docs/_static/game.jpg)

###More detail documentation about game.
<http://tao1.readthedocs.org/en/latest/game.html>


###More detailed documentation about base framework 

<http://tao1.readthedocs.org/en/latest/>


