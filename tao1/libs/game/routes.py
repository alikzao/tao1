
from libs.game.game import  *
from core.union import route


route( 	'/pregame',	        pregame,	    'GET',  'pregame'    )
route( 	'/game',		    game,		    'GET',  'game'       )
route( 	'/check_room',	    check_room,	    'POST', 'check_room' )


route( 	'/babylon',	        babylon,	    'GET',  'babylon'    )
route( 	'/game_handler',	game_handler,	'GET',  'g_h'        )

route( 	'/test/mesh',	    test_mesh,	    'GET',  'test_mesh'  )




