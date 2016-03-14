from libs.chat.chat import  *
from core.union import route
import asyncio

route('GET',  	'/online',		online,			'online'      )

async def test( name ):
    ctr = 0
    while True:
        await asyncio.sleep(10)
        ctr += 1
        print("Task {}: test({})".format( ctr, name ))

asyncio.ensure_future( test("A") )
asyncio.ensure_future( test("B") )
asyncio.ensure_future( test("C") )


# route('POST', 	'/check_room',	check_room,		'check_room')
# route('GET',  	'/babylon',		babylon,		'babylon'   )
# route('GET',  	'/game_handler',game_handler,	'g_h'       )






