// (function(){

    function get_online(users) {
        console.log('users', users);
        var wsUri = (window.location.protocol == 'https:' && 'wss://' || 'ws://') + window.location.hostname + ':80/online';
        ws = new WebSocket(wsUri);


        // setTimeout(function() {
        //     ws.send( JSON.stringify( { 'e':'ping' } ) );
        // }, 1000);



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
                console.warn('ping', msg);
                ws.send( JSON.stringify( { 'e':'pong'} ) );
            } else {

            }
        };
        ws.onclose = function (e)     { console.log('Connection close:', e     ); };
        ws.onerror = function (error) { console.log('Connection error:', error ); };
    }


// });



// "кто из этого списка онлайн"
// "обновить состояние онлайн"
// "удалить тех, кого давно нет онлайн"








