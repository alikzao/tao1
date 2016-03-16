from libs.chat.chat import  *
from core.union import route
# import asyncio

route('GET',  	'/online',		online,			'online'      )

# chat_task()

route('GET', '/chat',   ws,		    'w_s'  )
route('GET', '/wsh',    ws_handler,	'ws_h' )

asyncio.ensure_future( ping_chat_task() )
asyncio.ensure_future( check_online_task() )

# asyncio.ensure_future( test("A") )
# asyncio.ensure_future( test("B") )
# asyncio.ensure_future( test("C") )


# route('POST', 	'/check_room',	check_room,		'check_room')
# route('GET',  	'/babylon',		babylon,		'babylon'   )
# route('GET',  	'/game_handler',game_handler,	'g_h'       )






