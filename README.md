
# Introduction.
This asynchronous framework with a modular structure like Django. But with mongodb, jinja2, websocket out of the box, 
and more than a simple barrier to entry.

#Framework Installation
```python
$ pip install tao1
```
#Getting Started

Create a project anywhere:
```python
   $ utils.py -p name
```
Create an application in the folder of the project apps:
```python
   $ utils.py -a name
```   
Run server:
```python
   $ python3 index.py
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






Example `routes.py`:
```python
from apps.app.view import  page
from core.union import route

route( '/',       page,		'GET' )
route( '/login',  login,	'GET' )
```

Example `view.py`:
```python
#!/usr/bin/env python
# coding: utf-8

@asyncio.coroutine
def page(request):
	return templ('apps.app:index', request, {'key':'val'})
```


