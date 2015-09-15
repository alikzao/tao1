<<<<<<< HEAD
<<<<<<< HEAD
# Example of a simple module.
You can create a module in the library and in the project.
The modules can be placed in two locations in folders "apps".
Example of the structure of the module. 

* apps 
    * module 
      * locale
      * stat
      * templ
      * routes.py
      * view.py

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

=======
# tao
>>>>>>> bdde3467fde44ee7fb4804658844ff166ef97f55
=======
# tao1
>>>>>>> 1bd543bc26b5a6e6238cd4b6bf18ad41f9bdcc07
