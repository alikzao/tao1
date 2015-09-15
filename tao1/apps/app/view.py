#!/usr/bin/env python
# coding: utf-8

# from app.user_site import *
# from app.perm.perm import *
# from app.tree.tree import *

import asyncio
import aiohttp_jinja2
import jinja2


@asyncio.coroutine
def test_lib_mod(request):
    return templ('apps.app:lib_mod', request, {'key':'val'})

