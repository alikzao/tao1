#!/usr/bin/env python


import sys, os
assert sys.version >= '3.3', 'Please use Python 3.4 or higher.'
import asyncio


import settings
sys.path.append( settings.root )
sys.path.append( os.path.dirname( __file__ ) )

from tao1.core.union import init


loop = asyncio.get_event_loop()
loop.run_until_complete( init( loop ) )
try: loop.run_forever()
except KeyboardInterrupt:  pass 




