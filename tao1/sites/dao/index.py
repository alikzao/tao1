#!/usr/bin/env python


import sys, os
assert sys.version_info >= (3, 5)
import asyncio


# Basic path for all stuff. There must be placed file settings.py
sys.path.append(os.path.dirname(__file__))

import settings

# Tao1 also need to be added into path
sys.path.append(settings.tao_path)

# Tao1 also need to be added into path
from core.union import init


loop = asyncio.get_event_loop()
srv, handler, app= loop.run_until_complete( init( loop ) )
try:
	loop.run_forever()
except KeyboardInterrupt:
	pass
finally:
	srv.close()
	loop.run_until_complete(srv.wait_closed())
	loop.run_until_complete(handler.finish_connections(1.0))
	loop.run_until_complete(app.finish())
loop.close()

	# if not loop.is_closed():
	# 	loop.call_soon(loop.stop)
	# 	loop.run_forever()
	# 	loop.stop()




