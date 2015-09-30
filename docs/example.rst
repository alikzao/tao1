
Deploy
======
When you develop enough to run the file ``python3 index.py``.
For production to run ``index.py``, is better to use the ``supervisor`` and ``nginx``.
Settings supervisor in ``/etc``::

   [program:name]
   command=python3 index.py
   directory=/path/to/your/project
   user=nobody
   autorestart=true
   redirect_stderr=true

Settings nginx in ``/etc``::

    server {
        server_name    name.dev;
        location / {
             proxy_pass http://127.0.0.1:6677;
        }
    }
Structure
=========
Project structure::

   project_name_
                |
                 apps_
                      |
                      app1 ...
                      app1 ...
                 static ...
                 templ ...
                 __init__.py
                 index.py
                 settings.py
                 routes.py
                 view.py

Module structure::

   module_name_
               |
               static ...
               templ ...
               __init__.py
               routes.py
               view.py

Routes
======
Example route in file ``routes.py``::

   route( '/ws',    ws,	 'GET',  'ws' )
Templates
=========
In framework integrated ``jinja2``. Templates are always in the ``templ`` folder.
To call the template function ``templ`` and pass it the template name. If the template is in some sort of module,
the call looks like this ``apps.modul_name.templ_name``. If the template is in the root of the project in the templ folder,
then simply write his name. Example::

   def page(request):
       return templ('index', request, {'key':'val'} )

Websockets
==========
The websocket to create games and chat very easy to use.
The first is the need to call route with the template to draw the route and chat with the handler for chat::

   route( '/ws',   ws,          GET', 'ws' )
   route( '/wsh',  ws_handler,  GET', 'ws_handler' )

These routes work you can see an example.

The second is the functions themselves::

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


Static files
============
 Static files it is better to entrust ``nginx`` but ``tao1`` able return files.
 All files must be located in the folder static.
 If they are the root of the project then the path will be like this ``/static/static/file_name.pg``.
 If the files are in a certain module, then the path like this ``/static/module_name/file_name.jpg``.

Caching
=======
Create cache for function 5 second, the first parameter - name::

   @cache("main_page", expire=5)
   @asyncio.coroutine
   def page(request):
       return templ('index', request, {'key':'val'} )
Inline Markup
=============
Words can have *emphasis in italics* or be **bold** and you can
define code samples with back quotes.

This is an example on how to link images:

.. image:: _static/in.jpg
