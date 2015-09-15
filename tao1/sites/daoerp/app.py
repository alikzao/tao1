#!/usr/bin/env python
# coding: utf-8

import sys, os
assert sys.version >= '3.3', 'Please use Python 3.4 or higher.'


import settings
sys.path.append(settings.root)
sys.path.append( os.path.dirname( __file__ ) )

from tao1.core.union import init_gunicorn
app = init_gunicorn()

# gunicorn app:app -k aiohttp.worker.GunicornWebWorker -b localhost:6677
