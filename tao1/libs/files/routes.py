from libs.files.files import  *
from core.union import route

route('GET' , '/img/{proc_id}/{doc_id}', 	            img, 			    'img_'			)
route('GET' , '/img/{proc_id}/{doc_id}/{img}/{action}', img,	            'img'			)

route('POST', '/get_file_names', 			            get_file_names_post,'get_file_names')
route('POST', '/add_files', 					        add_files_post, 	'add_files'		)
route('POST', '/del_files', 					        del_files_post, 	'del_files'		)
route('POST', '/set_def_img', 				            set_def_img,     	'set_def_img'	)
route('POST', '/file/link_upload',			            link_upload_post,   'link_upload'	)

#	'get_name_files': 		('/get_name_files', 			get_name_files_post, 	'POST')
	




