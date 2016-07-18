import os

addr = ['127.0.0.1', 8080]

session_key = b'Thirty  two  length  bytes  key.'

debug = True
reload = True

img_to_disk = True

root_path = os.path.dirname(__file__)
tao_path  = '/home/user/dev/tao1'

database = {"auth":False, "login":"admin", "passw":"123456", "host":["127.0.0.1:27017"], 'name':'test'}
memcache = { "addr":"127.0.0.1", "port":11211 }
admin="test"

oauth_ok, oauth_fb, oauth_vk = {}, {}, {}

reg_routes = {
    "db":True,
    "sites": True,
    "admin": True,
    "game" : True,
    "blog" : False,
    "shop" : False,
    "clip" : False,
}


