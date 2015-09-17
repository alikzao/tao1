from apps.app.view import  *
from core.union import route


route( '/',         page,				'GET', 'page' )
route( '/db',       test_db,			'GET', 'test_db' )

route( '/ws',       ws,					'GET', 'ws' )
route( '/wsh',      ws_handler,			'GET', 'ws_handler' )




