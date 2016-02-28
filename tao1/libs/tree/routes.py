from libs.tree.tree import  *
from core.union import route


route('POST', 	'/tree/data/{proc_id}',		tree_post,				'tree_data_post'	)
route('POST', 	'/tree/add_vote',  			add_vote_comm_post,		'add_vote_comm_post')
route('POST', 	'/comments/accept/pre',		accept_comm_post,		'comm_accept_post'	)
route('POST', 	'/comm/add',				add_comm_post,			'comm_add_post'		)
route('POST', 	'/comm/del',				del_comm_post,			'comm_del_post'		)
route('POST', 	'/comm/edit',				edit_comm_post,			'comm_edit_post'	)
route('POST', 	'/comm/ban',				ban_comm_post,			'comm_ban_post'		)
# route('POST', 	'/menu/iface', 				left_menu_post,			'left_menu1'		)
route('GET' , 	'/menu/{action}',			conf_menu_get,		    'menu' 			    )
