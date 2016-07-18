import settings
from libs.sites.sites import  *
from core.union import route, reg_tpl_global

reg_tpl_global( 'short_text',    short_text,    need_request=False )
reg_tpl_global( 'get_slot',      get_slot,      need_request=True )
reg_tpl_global( 'get_full_user', get_full_user, need_request=True )
reg_tpl_global( 'get_tags',      get_tags,      need_request=True )
reg_tpl_global( 'wiki',          wiki,          need_request=True )

if settings.reg_routes['sites']:
	route( 'GET',   '/',							     show_main_page,	'index'		      )

route( '*',     '/user_status',					     user_status_post,	'soc_u_post'      )
route( 'GET',   '/posts/{user_id}',                  user_posts, 		'user_post'	      )
route( 'GET',   '/comments/{user_id}',               user_posts, 	    'user_comments'   )
route( 'GET',   '/profile/{u}',     		         user_profile,		'user_profile'	  )
route( 'GET',   '/news/{doc_id}/print',			     print_web_doc,		'print'		      )
route( 'GET',   '/news/{doc_id}',			         show_obj,		    'show_obj'	      )
route( 'GET',   '/add/news/{proc_id}',               add_news,        	'news_add'        )
route( 'POST',  '/news/accept',                      news_accept_post,  'news_accept_post')
route( 'GET',   '/wiki/add',                         add_news,        	'news_add_wiki'   )
route( 'GET',   '/news/edit/{doc_id}',               news_edit,        	'news_edit'       )
route( 'GET',   '/wiki/{title}',                     show_wiki,	        'doc_wiki'   	  )
route( 'GET',   '/arhiv/{date}',                     show_list,	        'list1'       	  )
# route( 'GET',   '/blogs/',                           blogs,    	        'blogs'       	  )
# route( 'GET',   '/wiki/',                            wiki_,    	        'wiki'       	  )
# route( 'GET',   '/wiki',                             wiki_,    	        'wiki1'       	  )
route( 'GET',   '/news/',                            news,    	        'news'       	  )
route( 'GET',   '/sitemap.xml',                      get_sitemap,    	'sitemap'   	  )
route( 'GET',   '/chat/{doc_id}',                    chat,              'chat'            )
route( 'GET',   '/show/comments/answer/{user_id}',   show_comm_answ,	'list_answ_comm'  )
route( 'POST',  '/comments/answer/del/',             hide_comm_answ,	'del_answ_comm'   )
route( 'GET',   '/show/{proc_id}/list', 		     show_list, 		'show_list'	      )
route( 'GET',   '/show/{proc_id}/action/{action}',   show_list, 		'show_list_action')
route( 'GET',   '/show/{proc_id}/tags/{tags}',       list_tags, 		'show_list_tags'  )

route( 'GET',   '/show_list_pm/{proc_id}/{action}',  show_list,			'show_list_pm'	  )
route( 'GET',   '/show_list_friend/{action}',	     show_list,			'show_list_friend')
route( 'GET',   '/slot/{slotname}',                  get_slot_list,	    'show_list_slot'  )
route( 'GET',   '/search/full_text/{filter}',        search_full_text,	'search_full_text')
route( 'POST',  '/rating/vote',				         add_rating_post,	'add_rating'	  )
route( 'POST',  '/vote/add',		                 add_vote_post,     'vote_add_post'   )
# route( 'GET',   '/reset_cache',                      reset_caches,      'reset_cache'     )
route( 'POST',  '/spam',                             spam_post, 	    'spam_post'       )
route( 'GET',   '/test',                             test,	            'test'            )
route( 'POST',  '/loader/slot',                      loader_slot,	    'loader'          )
route( 'GET',   '/contacts',                         contacts,	        'contacts'        )








