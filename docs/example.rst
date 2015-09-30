
Deploy
======
 * Item Foo
 * Item Bar

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
 * Item Foo
 * Item Bar

Templates
=========
 * Item Foo
 * Item Bar

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
define code samples with back quotes, like when you talk about a 
command: ``sudo`` gives you super user powers! 

This is an example on how to link images:

.. image:: _static/in.jpg
