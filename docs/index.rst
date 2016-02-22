.. test documentation master file, created by
   sphinx-quickstart on Fri Dec 10 09:13:46 2010.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Introduction
============
This asynchronous framework with a modular structure like Django. But with mongodb, jinja2, websocket out of the box,
and more than a simple barrier to entry.

Built on the basis of asyncio and aiohttp. In the framework, have batteries. The prototype of the game framework as a component.

Framework Installation
----------------------

::

   $ pip install tao1


Getting Started
---------------

Create a project anywhere::

   $ utils.py -p name

Create an application in the folder of the project apps::

   $ utils.py -a name
Run server::

   $ python3 index.py


Source code
-----------

The project is hosted on `GitHub <https://github.com/alikzao/tao1>`_

Please feel free to file an issue on the `bug tracker
<https://github.com/alikzao/tao1/issues>`_ if you have found a bug
or have some suggestion in order to improve the library.

Dependencies
------------
Python 3.5+ and `aiohttp <https://github.com/KeepSafe/aiohttp>`_

License
-------

It's *MIT* licensed and freely available.

Feel free to improve this package and send a pull request to `GitHub <https://github.com/alikzao/tao1>`_.



Contents:

.. toctree::
   :maxdepth: 2

   example.rst
   game.rst

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

