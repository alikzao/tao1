

Game framework
==============

About game framework
--------------------
In this case, the game framework is a battery, the basic framework. The game is a 3D multiplayer shooting.
Prototype game framework have  multiplayer mode, the mini-map, rooms, bot, several typical models of tanks.
The client side is written in the framework ``WEBGL`` babylon.js.

.. image:: _static/game.jpg

Game consists of `babylon.js <https://github.com/alikzao/tao1/issues>`_ and python 3.5.

Getting Started
---------------
Game start is located on the route ``/pregame``.

Low-level game framework
========================

Import models and blender
-------------------------
.. image:: https://habrastorage.org/files/f64/0b6/366/f640b63667a146019cd9dc76b21fac64.jpg

Loading models in the game with babylon.js and the models themselves
--------------------------------------------------------------------
.. image:: _static/game_en_1.jpg

Of movement, the minimap and the sound of babylon.js
----------------------------------------------------

The websocket and sync game
---------------------------
.. image:: _static/game_en_0.jpg

Backend
-------

Balancing players by rooms
--------------------------

.. image:: _static/game_en_2.jpg

Asyncio and generation behavior of the bot
------------------------------------------

.. image:: _static/game_en_3.jpg

Nginx and proxying sockets
--------------------------

Roadmap game
------------

- Is bot
- Is room
- Multiplayer shooter


.. code-block:: python

   #route( 'GET', '/ws',   ws,          'ws' )


