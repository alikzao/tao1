// (function(){

    function get_online(users) {
        console.log('users', users);
        var wsUri = (window.location.protocol == 'https:' && 'wss://' || 'ws://') + window.location.hostname + ':80/online';
        ws = new WebSocket(wsUri);


        // setTimeout(function() {
        //     var user_id = $('[user_id]'); //TODO
        //     // ws.send( JSON.stringify( { 'e':'upd_on', 'id':user_id} ) );
        //     ws.send( JSON.stringify( { 'e':'upd_on', 'id':'user_id'} ) );
        // }, 300);

        setTimeout(function() {
            ws.send( JSON.stringify( { 'e':'ping' } ) );
        }, 1000);



        ws.onopen = function () {
            ws.send(JSON.stringify({'e':"new", 'users':users} ) );
        };
        ws.onmessage = function (event) {
            var msg = JSON.parse(event.data);
            console.warn('msg', msg);
            if (msg.e == 'on') {
                var us = msg.users;
                for(var res in us) {
                    $('[user_id="' + us[res] + '"]').find('.fa-circle').css('color', '#00a300');
                }
            } else if (msg.e == 'ping') {
                ws.send( JSON.stringify( { 'e':'ping'} ) );
            } else if (msg.e == 'move') {

            } else {

            }
        };
        ws.onclose = function (e) {
            console.log('close: ', e);
            if (e.wasClean) console.log('Connection was closed cleanly');
            else console.log('Disconnect the connection');
        };
        ws.onerror = function (error) {
            console.log("Error: error " + error);
        };
    }


// });



// "кто из этого списка онлайн"
// "обновить состояние онлайн"
// "удалить тех, кого давно нет онлайн"








