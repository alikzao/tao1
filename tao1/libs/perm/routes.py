from libs.perm.perm import  *
from core.union import route, reg_tpl_global

reg_tpl_global( 'has_perm',          user_has_permission,         need_request=True )
reg_tpl_global( 'is_admin',          is_admin,                    need_request=True )
reg_tpl_global( 'is_logged',         user_is_logged_in,           need_request=True )

route( 'GET',  '/settings/group_perm',		group_perm,			 'group_perm'			)
route( 'POST', '/settings/group_perm',		group_perm_post,	 'group_perm_post'		)
route( 'GET',  '/settings/users_group',		users_group,		 'users_group'			)
route( 'POST', '/settings/users_group',		users_group_post,	 'users_group_post'		)
route( 'POST', '/users_group/update_cell',	users_group_uc_post, 'users_group_uc_post'	)
route( 'POST', '/group_perm/update_cell',	group_perm_uc_post,	 'group_perm_uc_post'	)




