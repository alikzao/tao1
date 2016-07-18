from libs.table.table import  *
from libs.contents.contents import table_get_field_post
from core.union import route



# route('GET' ,   '/table/data/{proc_id}',		table_data,				  'table_data'     		    )
route('GET' ,   '/table/in/{proc_id}',		    table_data,			      'table_data'			    )
route('POST',   '/table/data/{proc_id}',		table_data_post,		  'table_data_post'	        )
route('POST',   '/table/add_row',	            table_add_row_post,		  'table_add_row'		    )
route('POST',   '/table/update_cell/{proc_id}', table_update_cell_post,	  'table_update_cell'	    )
route('POST',   '/table/del_row',               table_del_row_post,		  'table_del_row' 		    )
route('POST',   '/table/get_row',				table_get_row_post,		  'table_get_row'		    )
route('POST',   '/table/transfer',         	    table_transfer_post,	  'table_transfer'		    )
route('POST',   '/table/preedit_row',	        table_preedit_row_post,	  'table_preedit_row'       )
route('POST',   '/table/edit_row/{proc_id}',	table_update_row_post,	  'table_edit_row'		    )
route('POST',   '/table/del_field',			    table_del_field_post,	  'table_del_field'	        )
route('POST',   '/table/add_field',			    table_add_field_post,	  'table_add_field'	        )
route('POST',   '/table/edit_field', 			table_edit_field_post,	  'table_edit_field'	    )
route('POST',   '/table/get_field', 			table_get_field_post,	  'table_get_field'	        )
route('POST',   '/table/sort_columns', 		    table_sort_columns_post,  'table_sort_columns'	    )
route('POST',   '/table/copy/doc', 		        table_copy_doc,           'table_copy_doc'	        )
route('POST',   '/get_des_field', 				get_des_field_post, 	  'get_des_field' 		    )
route('POST',   '/list/field',					get_field_post,			  'list_field'			    )
route('POST',   '/table/sort/date',			    table_sort_post,		  'sort_date' 			    )


