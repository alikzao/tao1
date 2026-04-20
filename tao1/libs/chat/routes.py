from libs.chat.chat import *
from core.union import route

route("GET", "/online", online, "online")


route("GET", "/chat", ws, "w_s")
route("GET", "/wsh", ws_handler, "ws_h")

asyncio.ensure_future(ping_chat_task())
asyncio.ensure_future(check_online_task())
