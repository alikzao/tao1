

[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=plastic)](http://opensource.org/licenses/MIT)
[![PyPI version](https://badge.fury.io/py/tao1.svg)](https://badge.fury.io/py/tao1)


# Introduction.
This asynchronous framework with a modular structure like Django. But with mongodb, jinja2, websocket out of the box, 
and more than a simple barrier to entry. 

Built on the basis of asyncio and aiohttp.

#Framework Installation
```bash
$ pip install tao1
```
#Getting Started

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
#License

It's *MIT* licensed and freely available.

#Deploy
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
Settings nginx in `/etc`::
```python
    server {
        server_name    name.dev;
        location / {
             proxy_pass http://127.0.0.1:6677;
        }
    }
```

#Routes

Example route in file `routes.py`::
```python
   route('GET', '/ws',  ws,	'ws' )
```   
#Templates

In framework integrated `jinja2`. Templates are always in the `templ` folder.

To call the template function `templ` and pass it the template name. If the template is in some sort of module,
the call looks like this `libs.modul_name.templ_name`.

If the template is in the root of the project in the templ folder, then simply write his name.

Example:
```python
   def page(request):
       return templ('index', request, {'key':'val'} )
```

#Websockets

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
   @asyncio.coroutine
   def ws(request):
       return templ('libs.app:chat', request, {} )
```
Function handler chat:

```python
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
           elif msg.tp == aiohttp.MsgType.close:
               print('websocket connection closed')
       return ws
```

#Database

To write the database query you need to `request.db`
and then as usual.

```python
    # save doc
    request.db.doc.save({"_id":"test", "status":"success"})
    # find doc
    val = request.db.doc.find_one({"_id":"test"})
```

#Static files

 Static files it is better to entrust `nginx` but `tao1` able return files.

 All files must be located in the folder static.

 If they are the root of the project then the path will be like this `/static/file_name.pg`.
 If the files are in a certain module, then the path like this `/static/module_name/file_name.jpg`.

#Caching

Create cache for function 5 second, the first parameter - name::
```python
   @cache("main_page", expire=5)
   @asyncio.coroutine
   def page(request):
       return templ('index', request, {'key':'val'} )
```
