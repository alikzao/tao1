from libs.auth.auth import  *
from core.union import route, reg_tpl_global

# reg_tpl_global( 'short_text',    short_text,    need_request=False )


route(	'GET' ,   '/oauth_vk',					oauth_vk,			'oauth_vk'		    )
route(	'GET' ,   '/oauth_fb',					oauth_fb,   		'oauth_fb'			)
route(	'GET' ,   '/oauth_ok',					oauth_ok,   		'oauth_ok'			)
route(	'GET' ,   '/oauth_tw',					oauth_tw,   		'oauth_tw'			)
route(	'GET' ,   '/oauth_tw_login',			oauth_tw_login,		'oauth_tw_login'	)

route(	'GET' ,   '/oauth_gl',					oauth_gl,   		'oauth_gl'			)
route(	'GET' ,   '/oauth_gl_login',			oauth_gl_login,		'oauth_gl_login'	)

route(	'GET' ,   '/oauth_ya',					oauth_ya,   		'oauth_ya'			)
route(	'GET' ,   '/oauth_ya_login',			oauth_ya_login,		'oauth_ya_login'	)
route(	'POST',   '/oauth_action',				oauth_action_post,	'oauth_action'		)

route(	'GET' ,   '/login',						login,				'login'				)
route(	'GET' ,   '/signup',					signup,				'signup'			)
route(	'POST',   '/login',						login_post,			'login_post'		)
route(	'POST',   '/signup',					signup_post,		'signup_post'		)
route(	'GET' ,   '/logout',					logout_get,			'logout'			)
route(	'POST',   '/user/ban',				    user_ban,			'ban'				)

