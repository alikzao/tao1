from libs.game.game import  *
from core.union import route


route('GET',  	'/pregame',		pregame,		'pregame'   )
route('GET',  	'/game',		game,			'game'      )
route('POST', 	'/check_room',	check_room,		'check_room')
route('GET',  	'/babylon',		babylon,		'babylon'   )
route('GET',  	'/game_handler',game_handler,	'g_h'       )
route('GET',  	'/test/mesh',	test_mesh,		'test_mesh' )




