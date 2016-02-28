
var local_stream;
var remote_stream;
var channelReady = false;
var localVideo;
var miniVideo;
var remoteVideo;
var localStream;
var remoteStream;
var channel;
var channelReady = false;
var pc;
var socket;
var initiator = 0;
var started = false;
// Set up audio and video regardless of what devices are present.
var sdpConstraints = {'mandatory': {
    'OfferToReceiveAudio':true,
    'OfferToReceiveVideo':true }};
var isVideoMuted = false;
var isAudioMuted = false;
function chat_tv(global, local){

    var getUserMedia;
    var browserUserMedia = navigator.webkitGetUserMedia  || navigator.mozGetUserMedia || navigator.getUserMedia;
    if ( !browserUserMedia ) throw 'Your browser do not support WebRTC';

    getUserMedia = browserUserMedia.bind( navigator );

    getUserMedia(
        { audio: true, video: true },
        function( stream ) {
            var URL = window.URL || window.webkitURL
            var local_video = document.getElementById(local);
            var global_video= document.getElementById(global);
//            var videoElement = document.getElementsByTagName('video')[0];
            local_video.src = URL.createObjectURL( stream );
            local_stream = stream;
            if (initiator) maybeStart();

        },
        function( err ) { console.log( err ); }
    );

    var PeerConnection =	webkitRTCPeerConnection	|| mozRTCPeerConnection	|| RTCPeerConnection;
    if ( !PeerConnection ) throw 'Your browser doesn\'t support WebRTC';
//}
//function chat_tv(){

    var pc_config = {"iceServers": [{"url": "stun:stun.l.google.com:19302"}]};

    var pc_constraints = {"optional": [{"DtlsSrtpKeyAgreement": true}]};
    try {
        // Create an RTCPeerConnection via the polyfill (adapter.js).
        var pc = new PeerConnection(pc_config, pc_constraints);
        pc.onicecandidate = onicecandidate;
        console.log("Created RTCPeerConnnection with:\n" +
            "  config: \"" + JSON.stringify(pc_config) + "\";\n" +
            "  constraints: \"" + JSON.stringify(pc_constraints) + "\".");
    } catch (e) {
        console.log("Failed to create PeerConnection, exception: " + e.message);
        alert("Cannot create RTCPeerConnection object; WebRTC is not supported by this browser.");
        return;
    }

    pc.onaddstream = onRemoteStreamAdded;
    pc.onremovestream = onRemoteStreamRemoved;

    console.log("Initializing; room=97446676.");
//    card = document.getElementById("card");
    openChannel('AHRlWrrBWZFlOBAKUIYTGr8dCKlSRbM71LrtYMjUyWMM6B011fYEEov7VhWZH_Y4y64zx42HmHCkS0swNraWIV_2tIpbxY1_Iy7UAV5B-f2Z7CmSMGXugBo');
//    doGetUserMedia();
}

function openChannel(channelToken) {
    console.log("Opening channel.");
    var channel = new goog.appengine.Channel(channelToken);
    var handler = {
        'onopen': onChannelOpened,
        'onmessage': onChannelMessage,
        'onerror': onChannelError,
        'onclose': onChannelClosed
    };
    socket = channel.open(handler);
}

function onicecandidate(e){ alert(e.candidate); }
function onRemoteStreamAdded(e){
    alert('onRemoteStreamAdded');
    waitForRemoteVideo(event.stream);
}
function onRemoteStreamRemoved(e){ alert('onRemoteStreamRemoved'); }
function waitForRemoteVideo(remoteStream ) {
    // Call the getVideoTracks method via adapter.js.
    videoTracks = remoteStream.getVideoTracks();
    if (videoTracks.length === 0 || remoteVideo.currentTime > 0) { alert('transitionToActive();'); }
    else { setTimeout(waitForRemoteVideo, 100); }
}

function processSignalingMessage(message) {
    var msg = JSON.parse(message);
    if (msg.type === 'offer') {
        // Callee creates PeerConnection
        if (!initiator && !started)
            maybeStart();

        pc.setRemoteDescription(new RTCSessionDescription(msg));
        doAnswer();
    } else if (msg.type === 'answer' && started) {
        pc.setRemoteDescription(new RTCSessionDescription(msg));
    } else if (msg.type === 'candidate' && started) {
        var candidate = new RTCIceCandidate({sdpMLineIndex:msg.label,
            candidate:msg.candidate});
        pc.addIceCandidate(candidate);
    } else if (msg.type === 'bye' && started) {
        onRemoteHangup();
    }
}
function doAnswer() {
    console.log("Sending answer to peer.");
    pc.createAnswer(setLocalAndSendMessage, null, sdpConstraints);
}
var initiator = 0;
function onChannelOpened() {
    console.log('Channel opened.');
    channelReady = true;
    if (initiator) maybeStart();
}

function onChannelMessage(message) {
    console.log('S->C: ' + message.data);
    processSignalingMessage(message.data);
}
function onChannelError(e) {
    console.log(['Channel error.',e]);
}
function onChannelClosed() {
    console.log('Channel closed.');
}


function maybeStart() {
    if (!started && local_stream && channelReady) {
//        createPeerConnection();
        console.log("Adding local stream.");
        pc.addStream(local_stream);
        started = true;
        // Caller initiates offer to peer.
        if (initiator)
            doCall();
    }
}

function doCall() {
    var constraints = {"optional": [], "mandatory": {"MozDontOfferDataChannel": true}};
    // temporary measure to remove Moz* constraints in Chrome
    for (prop in constraints.mandatory) {
        if (prop.indexOf("Moz") != -1) {
            delete constraints.mandatory[prop];
        }
    }
    constraints = mergeConstraints(constraints, sdpConstraints);
    console.log("Sending offer to peer, with constraints: \n" +
        "  \"" + JSON.stringify(constraints) + "\".")
    pc.createOffer(setLocalAndSendMessage, null, constraints);
}


function mergeConstraints(cons1, cons2) {
    var merged = cons1;
    for (var name in cons2.mandatory) {
        merged.mandatory[name] = cons2.mandatory[name];
    }
    merged.optional.concat(cons2.optional);
    return merged;
}

function setLocalAndSendMessage(sessionDescription) {
    // Set Opus as the preferred codec in SDP if Opus is present.
    sessionDescription.sdp = preferOpus(sessionDescription.sdp);
    pc.setLocalDescription(sessionDescription);
    sendMessage(sessionDescription);
}

function sendMessage(message) {
    var msgString = JSON.stringify(message);
    console.log('C->S: ' + msgString);
    path = '/message?r=97446676' + '&u=37470209';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', path, true);
    xhr.send(msgString);
}



// Set Opus as the default audio codec if it's present.
function preferOpus(sdp) {
    var sdpLines = sdp.split('\r\n');

    // Search for m line.
    for (var i = 0; i < sdpLines.length; i++) {
        if (sdpLines[i].search('m=audio') !== -1) {
            var mLineIndex = i;
            break;
        }
    }
    if (mLineIndex === null) return sdp;

    // If Opus is available, set it as the default in m line.
    for (var i = 0; i < sdpLines.length; i++) {
        if (sdpLines[i].search('opus/48000') !== -1) {
            var opusPayload = extractSdp(sdpLines[i], /:(\d+) opus\/48000/i);
            if (opusPayload)
                sdpLines[mLineIndex] = setDefaultCodec(sdpLines[mLineIndex], opusPayload);
            break;
        }
    }

    // Remove CN in m line and sdp.
    sdpLines = removeCN(sdpLines, mLineIndex);

    sdp = sdpLines.join('\r\n');
    return sdp;
}

function extractSdp(sdpLine, pattern) {
    var result = sdpLine.match(pattern);
    return (result && result.length == 2)? result[1]: null;
}

// Set the selected codec to the first in m line.
function setDefaultCodec(mLine, payload) {
    var elements = mLine.split(' ');
    var newLine = new Array();
    var index = 0;
    for (var i = 0; i < elements.length; i++) {
        if (index === 3) // Format of media starts from the fourth.
            newLine[index++] = payload; // Put target payload to the first.
        if (elements[i] !== payload)
            newLine[index++] = elements[i];
    }
    return newLine.join(' ');
}

// Strip CN from sdp before CN constraints is ready.
function removeCN(sdpLines, mLineIndex) {
    var mLineElements = sdpLines[mLineIndex].split(' ');
    // Scan from end for the convenience of removing an item.
    for (var i = sdpLines.length-1; i >= 0; i--) {
        var payload = extractSdp(sdpLines[i], /a=rtpmap:(\d+) CN\/\d+/i);
        if (payload) {
            var cnPos = mLineElements.indexOf(payload);
            if (cnPos !== -1) {
                // Remove CN payload from m line.
                mLineElements.splice(cnPos, 1);
            }
            // Remove CN line in sdp
            sdpLines.splice(i, 1);
        }
    }

    sdpLines[mLineIndex] = mLineElements.join(' ');
    return sdpLines;
}







function qqq(){

var peerConnCreated = false;
var peerConn = null;
var cameraOn = false;
var clientId = 0;
var svcName = "";
var clientIdRecvd = false;
var myname = "";
var hisname = "";
var myJsep;
var hisJsep;
var mySdp;
var hisSdp;

function login() {
    var loginid = document.getElementById("login").value;
    var jsonText = {"clientid":clientId, "service":"rtc", "mtype": "online", "username": loginid};
    myname = loginid;
    socket.send(JSON.stringify(jsonText));
}

function iceCallback(canditate, moreToFollow) {
    if(canditate) {
        console.log("ice canditate");
        var jsonText = {"clientid":clientId, "service":"rtc", "mtype": "canditate", "sndr": myname, "rcpt": hisname,
            "label": canditate.label, "cand": canditate.toSdp()};
        socket.send(JSON.stringify(jsonText));
    }
}

function onSessionConnecting(message) { console.log("session connecting ..."); }

function onRemoteStreamRemoved(event) {
    console.log("remote stream removed");
    remotevid.src = "";
}

function onSessionOpened(message) { console.log("session opened"); }

function onRemoteStreamAdded(event) {
    console.log("remote stream added");
    remotevid.src = window.webkitURL.createObjectURL(event.stream);
    remotevid.style.opacity = 1;
}

function createPeerConnection() {
    if (peerConnCreated) return;
    peerConn = new webkitPeerConnection00("STUN stun.l.google.com:19302", iceCallback);
    peerConn.onconnecting = onSessionConnecting;
    peerConn.onopen = onSessionOpened;
    peerConn.onaddstream = onRemoteStreamAdded;
    peerConn.onremovestream = onRemoteStreamRemoved;
    console.log("peer connection created");
    peerConnCreated = true;
}

function turnOnCameraAndMic() {
    navigator.webkitGetUserMedia({video:true, audio:true}, successCallback, errorCallback);
    function successCallback(stream) {
        sourcevid.style.opacity = 1;
        sourcevid.src = window.webkitURL.createObjectURL(stream);
        peerConn.addStream(stream);
        console.log("local stream added");
    }
    function errorCallback(error) {
        console.error('An error occurred: [CODE ' + error.code + ']');
    }
    cameraOn = true;
}

function dialUser(user) {
    if (!peerConnCreated) createPeerConnection();
    hisname = user;
    var localOffer = peerConn.createOffer({has_audio:true, has_video:true});
    peerConn.setLocalDescription(peerConn.SDP_OFFER, localOffer);
    mySdp =  peerConn.localDescription;
    myJsep = mySdp.toSdp();
    var call = {"clientid":clientId, "service":"rtc", "mtype": "call", "sndr": myname, "rcpt": hisname, "jsepdata": myJsep};
    socket.send(JSON.stringify(call));
    console.log("sent offer");
    //console.log(myJsep);
    peerConn.startIce();
    console.log("ice started ");
}

//handle the message from the sip server
//There is a new connection from our peer so turn on the camera
//and relay the stream to peer.
function handleRtcMessage(request) {
    var sessionRequest = eval('(' + request + ')');
    switch(sessionRequest.mtype) {
        case 'online':
            console.log("new user online");
            var newuser = sessionRequest.username;
            var li = document.createElement("li");
            var name = document.createTextNode(newuser);
            li.appendChild(name);
            li.onclick = function() { dialUser(newuser); };
            document.getElementById("Contact List").appendChild(li);
            break;

        case 'call':
            console.log("recvng call");
            alert("Incoming call ...");
            if (!peerConnCreated) createPeerConnection();
            peerConn.setRemoteDescription(peerConn.SDP_OFFER, new SessionDescription(sessionRequest.jsepdata));
            hisname = sessionRequest.sndr;
            var remoteOffer = peerConn.remoteDescription;
            //console.log("remoteOffer" + remoteOffer.toSdp());
            var localAnswer = peerConn.createAnswer(remoteOffer.toSdp(), {has_audio:true, has_video:true});
            peerConn.setLocalDescription(peerConn.SDP_ANSWER, localAnswer);
            var jsonText = {"clientid":clientId,"service":"rtc", "mtype": "pickup", "sndr" :myname, "rcpt": hisname, "jsepdata": localAnswer.toSdp()};
            socket.send(JSON.stringify(jsonText));
            console.log("sent answer");
            //console.log(localAnswer.toSdp());
            peerConn.startIce();
            if (!cameraOn) turnOnCameraAndMic();
            break;

        case 'pickup':
            console.log("recvd pickup");
            peerConn.setRemoteDescription(peerConn.SDP_ANSWER, new SessionDescription(sessionRequest.jsepdata));
            hisname = sessionRequest.sndr;
            if (!cameraOn) turnOnCameraAndMic();
            break;

        case 'canditate':
            console.log("recvd canditate");
            var canditate = new IceCandidate(sessionRequest.label, sessionRequest.cand);
            peerConn.processIceMessage(canditate);
            break;

        case 'bye':
            console.log("recvd bye");
            break;
    }
}

//open the websocket  to the antkorp webserver
var socket = new WebSocket('ws://bldsvrub:9981');
var sourcevid = null;
var remotevid = null;

socket.onopen = function () {
    console.log("websocket opened");
    sourcevid = document.getElementById("sourcevid");
    remotevid = document.getElementById("remotevid");
};

socket.onmessage = function (event) {
    if (!clientIdRecvd) {
        var reqObj = eval('(' + event.data + ')');
        clientId = reqObj.clientid;
        svcName  = reqObj.service;
        clientIdRecvd = true;
    } else {
        //hookup the new handler to process session requests
        handleRtcMessage(event.data);
    }
};

socket.onclose = function (event) { socket = null; };
}