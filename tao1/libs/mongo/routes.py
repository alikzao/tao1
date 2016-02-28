from libs.mongo.mongo import  *
from core.union import route

route( 'GET' , 	'/mongodb/{db_id}',         mongodb,			'mongo_db'      	)
route( 'GET' , 	'/mongodb',		            mongodb_,			'mongodb'      	    )
route( 'POST', 	'/mongodb/{db_id}/del_db',  del_db,			    'del_db'            )
route( 'POST', 	'/mongodb/login',  		    db_login_post,		'db_login_post'   	)
route( 'GET' , 	'/mongodb/login/{db_id}',	db_login,		    'db_login'      	)
route( 'POST', 	'/mongo/get_coll',  	    get_docs,		    'get_coll'      	)
route( 'POST', 	'/mongo/get_doc',  	        get_doc_mongo,		'get_doc_mongo'	    )
route( 'POST', 	'/mongo/search_docs', 	    search_docs,	    'search_docs'     	)
route( 'POST',  '/mongo/edit_key', 		    edit_key_post,		'edit_key_post'     )
route( 'POST',  '/mongo/edit_val', 		    edit_val_post,		'edit_val_post'     )
route( 'POST', 	'/mongo/del_doc', 		    del_doc_post,       'del_doc_post'     	)
route( 'POST',  '/mongo/import_db', 	    import_db_post,     'import_db_post'    )
route( 'GET' ,  '/mongo/exported/{db_id}',  get_exp_file,       'import_db'        	)
route( 'POST',  '/mongo/export_db',         export_db_post,     'export_db_post'    )
route( 'POST',  '/mongo/import_doc', 	    import_doc_post,    'import_doc_post'   )
route( 'POST',  '/mongo/export_doc', 	    export_doc_post,    'export_doc_post'   )
route( 'POST',  '/mongo/create_doc', 	    create_doc_post,    'create_doc_post'   )
route( 'POST',  '/mongo/edit_doc', 		    edit_doc_post,    	'edit_doc_post'     )
route( 'POST', 	'/mongo/get_docm', 	        get_docm_post,    	'get_doc_post'      )





