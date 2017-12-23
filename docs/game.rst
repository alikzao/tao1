

Game framework
==============

About game framework
--------------------
In this case, the game framework is a battery, the basic framework. The game is a 3D multiplayer shooting.
Prototype game framework have  multiplayer mode, the mini-map, rooms, bot, several typical models of tanks.
The client side is written in the framework ``WEBGL`` babylon.js.

.. image:: _static/game.jpg

Game consists of `babylon.js <https://www.babylonjs.com/>`_ and python 3.5.

Getting Started
---------------
Game start is located on the route ``/pregame``.

Low-level game framework
========================

Import models and blender
-------------------------
For games need 3D models to represent characters and landscape. For this you can use a free 3D editor `blender <https://www.blender.org/>`_.
Model you can draw or import with free resources, for example `here <http://tf3dm.com/>`_ or `here <http://www.blendswap.com/blends>`_.

If the model will move around the map, they need to do monolithic. There are two ways.
First method. To make all elements in the model as one object. If there is only one texture.
You need to select all model elements, they are highlighted in orange. And in the ``object`` menu select ``join``.

.. image:: https://habrastorage.org/files/f64/0b6/366/f640b63667a146019cd9dc76b21fac64.jpg

Second method. To associate all the elements of the model according to the principle of parent-child.
This option can be used if we have a lot of textures in the model.
To do this, right-click to select alternately the parent and the child, press ``ctrl+P`` to select the menu ``object``.

.. image:: https://habrastorage.org/files/b7b/b83/01d/b7bb8301db2c407f96a020b42d9bc408.jpg

Loading models in the game with babylon.js and the models themselves
--------------------------------------------------------------------
Loading models can be done very simply.

.. code-block:: javascript

	var loader = new BABYLON.AssetsManager(scene);
	mesh  = loader.addMeshTask('enemy1', "", "/static/game/t3/", "enemy.babylon");

The most common operation is object cloning. For example, there are trees,
so as not to load each tree, you can load one tree to clone it around the scene with different coordinates:

.. code-block:: javascript

	var palm = loader.addMeshTask('palm', "", "/static/game/g6/", "tree.babylon");
	palm.onSuccess = function (task) {
	        var p = task.loadedMeshes[0];
	        p.position   = new BABYLON.Vector3(25, -2, 25);
	        var p1 = p.clone('p1');
	        p1.position = new BABYLON.Vector3(10, -2, 20);
	        var p2 = p.clone('p2');
	        p2.position = new BABYLON.Vector3(15, -2, 30);
	};

When you load the models it is convenient to use ``AssetsManager``. Need to avoid uploading anything during the game,
for various reasons.

A simplified scheme of loading of objects looks like this:

.. image:: _static/game_en_1.jpg


Of movement, the minimap and the sound of babylon.js
----------------------------------------------------
To control the character used ``FreeCamera``. This is not quite correct in the case of tanks.
But in the next version of the game, I want to make a futuristic map like this ``star wars``.
And more convenient to use for controlling character will be ``FreeCamera``.

An example of the most common cameras for games:

.. code-block:: javascript

	//FollowCamera
	var camera = new BABYLON.FollowCamera("camera1", new BABYLON.Vector3(0, 2, 0), scene);
	camera.target = mesh;

	//FreeCamera
	var camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3( 0, 2, 0), scene);
	mesh.parent = camera;

At this time, the game has the sound of a gunshot, the sound of an explosion and the sound of movement technique.

The sound of a gunshot. Occurs when mouse click:
.. code-block:: javascript

	var gunS = new BABYLON.Sound("gunshot", "static/gun.wav", scene);
	window.addEventListener("mousedown", function (e) {
	      if (!lock && e.button === 0) gunS.play();
	});

The sound of movement technique:
.. code-block:: javascript

    var ms = new BABYLON.Sound("mss", "static/move.mp3", scene, null, { loop: true, autoplay: false });
    document.addEventListener("keydown",  function(e){
        switch (e.keyCode) {
           case 38: case 40: case 83: case 87:
        if (!ms.isPlaying) ms.play();
        break;
        }
    });
    document.addEventListener("keyup",   function(e){
        switch (e.keyCode) {
            case 38:  case 40: case 83: case 87:
                if (ms.isPlaying) ms.pause();
                break;
               }
    });

Any shooters there is always a ``minimap``. The ``minimap`` is done with the camera positioned above the scene.
View from this camera is displayed in the right place.

.. code-block:: javascript

	var camera2 = new BABYLON.FreeCamera("minimap", new BABYLON.Vector3(0,170,0), scene);

	camera2.viewport = new BABYLON.Viewport(x, y, width, height);

	scene.activeCameras.push(camera);
	scene.activeCameras.push(camera2);



Backend, websocket and sync game
--------------------------------

Connection between client and server is done using ``websockets``.
Simple scheme looks so:

.. image:: _static/game_en_0.jpg

On the server we receive from a clien message, watch the action, and in accordance with the desired function is called,
event handler:

.. code-block:: python

	async def game_handler(request):
	    .  .  .
	    async for msg in ws:
	        if msg.tp == MsgType.text:
	             if msg.data == 'close':
	                 await ws.close()
	             else:
	                 e = json.loads( msg.data )
	                 action = e['e']
	                 if action in handlers:
	                     handler = handlers[action]
	                     handler(ws, e)
	                     .  .  .

if ``action : move`` We transmit these coordinates to the Player class, it processes them and returns back,
and we broadcast them to all other players in the room.

.. code-block:: python

	def h_move(me, e):
	    me.player.set_pos(e['x'], e['y'], e['z'])
	    mess = dict(e="move", id=me.player.id, **me.player.pos_as_dict)
	    me.player.room.send_all(mess, except_=(me.player,))



Balancing players by rooms
--------------------------

If in the same room more players than specified in the settings, we create a new room and placed the player there.
The room number is assigned when a player with page ``/pregame``, comes into game.

.. code-block:: python

	def check_room(request):
	    found = None
	    for _id, room in rooms.items():
	        if len(room.players) < 3:
	            found = _id
	            break
	    else:
	        while not found:
	            _id = uuid4().hex[:3]
	            if _id not in rooms: found = _id


Scheme of work with rooms:

.. image:: _static/game_en_2.jpg

Asyncio and generation behavior of the bot
------------------------------------------
In game framework, there is a bot.
Bot to move in concentric circles, approaching the last player appeared.

Scheme of work bot

.. image:: _static/game_en_3.jpg


Roadmap game
------------

- Movement at different angles
- Space scene
- A detailed review of all movements on the server
- Check vector of shot on the server
- Artificial intelligence for bots
- Showcase playersрещзрещз



