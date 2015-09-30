
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
In framework integration ``jinja2``.
Websockets
==========
 * Item Foo
 * Item Bar

Static files
============
 * Item Foo
 * Item Bar

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
