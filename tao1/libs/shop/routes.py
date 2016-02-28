from libs.shop.shop import  *
from core.union import route

route( 	'POST',   '/basket', 					    show_basket_post, 		'show_basket' )
route( 	'GET' ,   '/class/{cls}', 				    list_class, 		'class_list'     )
route( 	'GET' ,   '/class/{cls}/filter/{filters}/',	list_filters, 		'filter'     )
route( 	'GET' ,   '/ware/{doc_id}', 				ware_page, 		    'ware_page'     )
route( 	'POST',   '/basket/order', 				    make_order_post, 	'make_order'	 )
route( 	'POST',   '/basket/add_order', 			    add_order_web_post, 'add_order'	 )
route( 	'POST',   '/basket/add', 				    add_basket_post, 		'add_basket' )
route( 	'GET' ,   '/list/basket', 				    list_basket, 		'list_basket'     )
route( 	'POST',   '/basket/clean', 				    wares_clean, 		'clean_basket'     )
route(  'POST',   '/callback',                      callback_post,	        'callback'    )
route(  'GET' ,   '/list/orders',                   list_orders,	        'list_orders' )

