from libs.clip.clip import  *
from core.union import route


route( 'POST',  '/add/clip/{doc_id}',                       add_clip,	       'add_clip'           )
# route( 'POST',      '/add/clip',                       add_clip,	      'add_clip'    )

route( 'POST',  '/down/clip/{doc_id}',                      down_clip,	       'down_clip'          )
# route(  'POST',      '/down/clip',                      down_clip,	      'down_clip'   )

route( 'GET' ,  '/list/clips',                              list_clips,	   'clip_list'              )
route( 'GET' ,  '/edit/clip/{doc_id}',                      clip_page,	       'edit_clip'          )
route( 'POST',  '/clip/del/fragment/{doc_id}',              del_fragment,     'del_fragment'        )
route( 'POST',  '/clip/drag/fragment/{doc_id}',             drag_fragment,    'drag_fragment'       )
route( 'POST',  '/clip/add/fragment/{doc_id}',              add_fragment,     'add_fragment'        )
route( 'POST',  '/clip/edit/fragment/{doc_id}',             edit_fragment,    'edit_fragment'       )
route( 'POST',  '/rolik/pub/{doc_id}',                      rolik_pub,	       'pub_rolik'          )
route( 'POST',  '/clip/pub/{doc_id}',                       clip_pub,	       'pub_clip'           )
route( 'POST',  '/rolik/add',                               add_rolik,	       'add_rolik'          )
route( 'POST',  '/rolik/del/{doc_id}',                      del_rolik,	       'del_rolik'          )
route( 'POST',  '/rolik/get/status/{doc_id}',               get_status,	   'get_status'             )
route( 'POST',  '/clip/add/descr/{doc_id}',                 add_descr,	       'add_descr'          )
route( 'POST',  '/clip/add/file/{doc_id}',                  upload_clip,      'add_file'            )
route( 'POST',  '/clip/add/img/{doc_id}',                   draw_img,	       'add_img'            )
route( 'POST',  '/clip/upload/{doc_id}',                    clip_upload,      'add_soc'             )



