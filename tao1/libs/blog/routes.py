from libs.blog.blog import  *
from core.union import route


route( 'GET' , 	'/u/{u}',     		                 user,       		 'user'     	  )
route( 'POST', 	'/add/mess',     		             add_mess,       	 'add_mess'    	  )
route( 'POST', 	'/add/fr',     		                 add_fr,       		 'add_fr'     	  )
route( 'POST', 	'/add/sub',     		             add_sub,       	 'add_sub'     	  )
route( 'POST', 	'/main_page_signup',     		     main_page_signup,   'tw_signup'      )
route( 'POST', 	'/main_page_login',     		     main_page_login,    'tw_login'       )
route( 'GET' ,  '/signup/in/{mail}/{code}',          signup_in,          'signup_in'      )
route( 'GET' ,  '/add_email',                        add_email,          'add_email'      )
route( 'POST',  '/add_email',                        add_email_post,     'add_email_'     )
route( 'GET' ,  '/list/users',                       list_users,         'list_users'     )

route( 'GET' ,  '/subscribe',                        subscribe,          'subscribe'      )
route( 'POST',  '/subscribe',                        subscribe_post,     'subscribe_post' )
route( 'POST',  '/subscribe/new',                    subscribe_new,      'subscribe_new'  )
route( 'GET' ,  '/subscribe/in/{mail}/{code}',       subscribe_in,       'subscribe_in'   )
route( 'GET' ,  '/subscribe/out/{mail}/{code}',      subscribe_out,      'subscribe_out'  )





