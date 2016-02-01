from apps.app.view import  *
from core.union import route


route('GET', '/',          page,		 'page'       )
route('GET', '/test_db',   test_db,		 'test_db'    )
route('GET', '/chat',      ws,			 'ws'         )
route('GET', '/chat/h',    ws_handler,	 'ws_handler' )




