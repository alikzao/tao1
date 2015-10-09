
function Player(startX, startY) {
	var x = startX, y = startY, z=0, id, a=0, b=0;
	// Getters and setters
	this.getX = function()     { return x; };
	this.getY = function()     { return y; };
	this.getZ = function()     { return z; };
	this.setX = function(newX) { x = newX; };
	this.setY = function(newY) { y = newY; };
	this.setZ = function(newZ) { z = newZ; };

	this.getA = function()     { return a; };
	this.getB = function()     { return b; };
	this.setA = function(newA) { a = newA; };
	this.setB = function(newB) { b = newB; };
	// Define which variables and methods can be accessed
	//return { getX:getX, getY:getY,getZ:getZ, setX:setX, setY:setY,setZ:setZ,     getA:getA, getB:getB, setA:setA, setB:setB,   id:id }
}

var socket, players=[], clients={}, max_id = 0;
function init() {
	var WebSocketServer = require('ws').Server , wss = new WebSocketServer({port: 9999});
    wss.on('connection', function(ws) {
        max_id += 1;  // math.random()
        console.log("Новое соединение, клиент " + max_id);
        clients[max_id] = ws;
        this.id = max_id;
        ws.id = max_id;
        console.log("Список клиентов: " + clients);
        ws.on('message', function(e) {

            var e =JSON.parse(e);
            //console.log('message', e );

            if(e.e == 'new'){
                //console.log('__onNewPlayer__', max_id, e);
                var newPlayer = new Player(e.x, e.y);
                newPlayer.id = max_id;
                this.player = newPlayer;
                //console.log('__onNewPlayer__ New player '+newPlayer.id+' has joined');
                var mess = JSON.stringify( {'e':"new", 'id':newPlayer.id, 'x':newPlayer.getX(), 'y':newPlayer.getY(),'z':newPlayer.getZ(), 'msg':'newPlayer'} );
                for(var i in clients) {
                    if (clients[i].player.id != this.player.id)
                        clients[i].send(mess);
                }
                //for(var i in clients) clients[i].send(mess);
                for (var i = 0; i < players.length; i++) {  // Send existing players to the new player
                    var existingPlayer = players[i];
                    var mess = JSON.stringify( {'e':"new", 'id': existingPlayer.id, 'x':existingPlayer.getX(), 'y':existingPlayer.getY(),'z':existingPlayer.getZ(), 'msg':'existingPlayer'} );
                    ws.send( mess);
                }
                players.push(newPlayer);
            }else if (e.e == 'move') {
                //console.log('__onMovePlayer__ ');
                //var movePlayer = playerById(max_id);
                var movePlayer = this.player;
                if (!movePlayer) { console.log("__onMovePlayer__ Player not found: "+max_id); return; }
                movePlayer.setX(e.x);
                movePlayer.setY(e.y);
                movePlayer.setZ(e.z);
                //console.log('Player '+max_id+' move has joined', 'id', movePlayer.id, 'x', movePlayer.getX(), 'y',movePlayer.getY());
                var mess = JSON.stringify( {'e':"move", 'id':movePlayer.id, 'x':movePlayer.getX(), 'y':movePlayer.getY(),'z':movePlayer.getZ(), 'msg':'move'} );
                for(var i in clients) {
                    console.warn('===clients->', this.player.id);
                    if (clients[i].player && clients[i].player.id != this.player.id) {
                            //clients[i].send(mess);
                        if (clients[i].readyState != this.OPEN) console.error('Client state is ' + clients[i].readyState);
                        else clients[i].send(mess);
                    }
                }
            }else if (e.e == 'rotate') {
                //console.log('__rotate__');
                //var movePlayer = playerById(this.player);
                var movePlayer = this.player;
                if (!movePlayer) { console.log("__onRotatePlayer__ Player not found: "+max_id); return; }
                movePlayer.setA(e.a);
                movePlayer.setB(e.b);
                //console.log('Player '+max_id+' move has joined', 'id', movePlayer.id, 'x', movePlayer.getX(), 'y',movePlayer.getY());
                var mess = JSON.stringify( {'e':"rotate", 'id':movePlayer.id, 'a':movePlayer.getA(), 'b':movePlayer.getB(), 'msg':'move'} );
                for(var i in clients) {
                    //if (clients[i].player.id != this.player.id)
                     if (clients[i].player && clients[i].player.id != this.player.id)
                        clients[i].send(mess);
                }
            }else if (e.e == 'shoot') {
                console.log('__shoot__', e);
                var sPlayer = this.player;
                if (!sPlayer) { console.log("__onShootPlayer__ Player not found: "+max_id); return; }
                console.log('Player '+max_id+' shoot has joined', 'id', sPlayer.id, 'x', sPlayer.getX(), 'y',sPlayer.getY());
                var mess = JSON.stringify( {'e':"shoot", 'id':sPlayer.id, 'pos':e.pos, 'dir':e.dir, 'd2':e.d2} );
                for(var i in clients) {
                     if (clients[i].player && clients[i].player.id != this.player.id){
                         clients[i].send(mess);
                         console.warn('shoot request=====================================');
                     }
                }
            }else if (e.e == 'chat') {
                console.log('__chat__', e);
                var chatPlayer = this.player;
                //if (!chatPlayer) { console.log("__onChatPlayer__ Player not found: "+max_id); return; }
                console.log('Player '+max_id+' chat has joined', 'id', chatPlayer.id, 'mess', e.mes);
                var mess = JSON.stringify( {'e':"chat", 'id':chatPlayer.id, 'mes':e.mes} );
                for(var i in clients) {
                    if (clients[i].player && clients[i].player.id != this.player.id)
                        clients[i].send(mess);
                }

            }else{
                console.log('получено сообщение ' + e);
                for(var i in clients)
                    clients[i].send(e);
            }

        });
        ws.on("close", function(e){
            console.log('serv onclose '+e, 'max_id', ws.id);
            var removePlayer = playerById(ws.id);
            if (!removePlayer) { console.log("onClientDisconnect   Player not found: "+ws.id); return; }
            console.log('close players => ', players);
            console.log('close clients => ', clients);
            //clients.splice(clients.indexOf(ws), 1);
            //delete clients[this.id];
            //delete clients[max_id];
            delete clients[ws.id];
            players.splice(players.indexOf(removePlayer), 1);

            console.log('==================================  close  ================================== ');
            console.log('close players => ', players);
            console.log('close clients => ', clients);

            var mess = JSON.stringify( {'e':"remove", id: max_id, 'msg':'remove'} );
            for(var i in clients) {
                try {
                    clients[i].send(mess);
                } catch(e) {
                    console.error('# error exception => # '+e);
                };
            }
        });
    });
}
function playerById(id) {
//    console.log('players', players);
	for (var i = 0; i < players.length; i++) {
		if (players[i].id == id) return players[i];
	}
	return false;
}

init();



//var WebSocketServer = require('ws').Server , wss = new WebSocketServer({port: 8088});
//wss.on('connection', function(ws) {
//    ws.on('message', function(message) {
//        console.log('received: %s', message);
//    });
//    ws.send('something');
//});








//var http = require('http');
//var Static = require('node-static');


