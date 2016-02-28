from libs.contents.contents import  *
from core.union import route


route( 'POST',   '/list/cascad_doc',		get_list_cascad_doc_post, 'list_cascad_doc' )
route( 'POST',   '/get/doc',			    get_doc_post,	          'get_doc'		    )
route( 'POST',   '/list/doc',				get_list_doc_post,		  'list_doc'	    )
route( 'POST',   '/list/rb',				get_list_rb_post,		  'list_rb'		    )
route( 'POST',   '/list/branch/{proc_id}',	get_list_branch_post,	  'list_branch'	    )
route( 'POST',   '/list/conf_docs',			get_list_conf_docs_post,  'list_conf_docs'  )
route( 'POST',   '/switch_lang', 		    switch_lang, 			  'switch_lang'	    )

route( 'GET' , 	'/add_func',				add_func,		    	 'add_func_post')
route( 'POST', 	'/add_func',				add_func_post,			 'add_func'		)
route(  'GET', 	'/sandbox',				    sandbox,     		     'test_test'	)
route( 'POST',  '/sandbox',     			sandbox_post,		     'sandbox_post' )

# route( 'POST', 	'/get/event',				get_event_post,			 'get_event_f'	)
# route( 'POST', 	'/get/func',				get_func_text_post,		 'get_func_text')
# route( 'POST', 	'/list/func',				get_list_func_post,		 'list_func'	)







