from libs.admin.admin import  *
from core.union import route


route( 'POST',  '/get_data_slot',		get_data_slot,	         'get_data_slot'		)
route( 'POST',  '/save_slot',      		save_slot,	             'save_slot'		    )
route( 'GET' ,  '/recover',        		recover,	             'recover'  			)
route( 'POST',  '/recover',        		recover_post,            'recover_post'  		)
route( 'GET' ,  '/add_rb', 				add_rb,    			     'add_ref'				)
route( 'POST',  '/add_ref',				add_ref_post,			 'add_ref_post'		    )
route( 'GET' ,  '/del_rb',	    		del_rb,    			     'del_ref'				)
route( 'POST',  '/del_ref',				del_ref_post,			 'del_ref_post'		    )
route( 'GET' ,  '/conf_rb_doc',			edit_conf,  			 'edit_conf'    		)
route( 'POST',  '/conf_rb_doc',			edit_conf_post,			 'edit_conf_post'		)
route( 'GET' ,  '/conf',				show_conf,				 'conf'				    )
route( 'GET' ,  '/conf/',				show_conf,				 'conf_'				)
route( 'GET' ,  '/conf_templ',			conf_templ,				 'conf_templ'			)
route( 'POST',  '/conf_templ',			save_templ_conf,		 'conf_templ_post'		)
route( 'GET' ,  '/edit_templ',			get_list_templ,		     'edit_templ'			)
route( 'POST',  '/get_templ',			get_templ_post,			 'get_templ'			)
route( 'POST',  '/save_templ',			save_templ_post,		 'save_templ'			)
route( 'POST',  '/meal',				save_templ_post,		 'meal_post'			)


