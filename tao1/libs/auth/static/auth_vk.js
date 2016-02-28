;$(function(){

//    2739851
//    wEvne5ulwMMdQz6sQsu4
window.vkAsyncInit = function() {
    VK.init({
        apiId: 2739851, onlyWidgets:1
//        nameTransportPath: '/xd_receiver.html'
    });
//VK.UI.button('vk_login');
aaa(true);
test_m(true);
user_blog_vk(true);
//VK.Observer.subscribe('auth.login', function(response) {
//    window.location = baseURL + '?op=main&page=auth';
//    });
//VK.Observer.subscribe('auth.logout', function() {
//    console.log('logout');
//    });
//VK.Observer.subscribe('auth.statusChange', function(response) {
//    console.log('statusChange');
//    });
//VK.Observer.subscribe('auth.sessionChange', function(r) {
//    console.log('sessionChange');
//    });
//
};
setTimeout(function() {
    var el = document.createElement('script');
    el.type = 'text/javascript';
    el.src = 'http://vk.com/js/api/openapi.js?3';
    el.async = true;
    document.getElementById('vk').appendChild(el);
//	alert(document.getElementById('vk'));
    }, 0);
});


//{["uid": 32259840,
//    "first_name": "Александр",
//    "last_name": "Иванов",
//    "photo": "http://cs4442.userapi.com/u32259840/e_8eb4cdd1.jpg",
//    "photo_medium_rec": "http://cs4442.userapi.com/u32259840/d_0303c494.jpg",
//    "sex": 2,
//    "online": 1]}

//[1,{
//    "id": 6,
//        "from_id": -41949400,
//        "to_id": -41949400,
//        "date": 1345110862,
//        "text": "www",
//        "can_edit": 1,
//        "comments": { "count": 0 },
//        "likes": { "count": 0 },
//        "reposts": { "count": 0 }
//}]

//[ {
//    "gid": 41949400,
//    "name": "test1",
//    "screen_name": "club41949400",
//    "is_closed": 0,
//    "type": "page",
//    "photo": "http://vk.com/images/question_c.gif",
//    "photo_medium": "http://vk.com/images/question_100.gif",
//    "photo_big": "http://vk.com/images/question_a.gif"
//} ]

var t = "<div class='item'rec_id='<%= id %>'>" +
"<div><%= (new Date(date*1000)).toLocaleDateString() %></div>"+
"<img style='float:left; width:45px; padding:2px; border:1px solid #808080; margin:4px 4px 4px 0;' src='<%=signer.photo_medium_rec %>'/>" +
"<div style='font-weight:bold; '><a href='<%= signer ? '/user_page_vk/'+to_id+'/'+signer.uid : '' %>'><%= signer ? signer.last_name+' '+ signer.first_name : '' %></a></div>"+
"<div><%= text.substr(0, 50) %> ... </div>"+
"<div style='clear: both;'></div>" +
"</div>";

var vk_t = "<div class='item'rec_id='<%= id %>'>" +
    "<div><%= (new Date(date*1000)).toLocaleDateString() %></div>"+
    "<img style='float:left; padding:2px; border:1px solid #808080; margin:4px 4px 4px 0;' src='<%=signer.photo_medium_rec %>'/>" +
    "<div style='font-weight:bold; '><%= signer ? signer.last_name+' '+ signer.first_name : '' %></div>"+
    "<div><%= text %> </div>"+
    "<div style='clear: both;'></div>" +
    "</div>";
//"from_id", "to_id", "date", "text", "attachment", "attachments", "comments", "likes", "reposts"

//window.onbeforeunload = function(){return confirm('Уходим');}

function check_auth(cb){
    VK.Auth.getLoginStatus(function(response) {
        if (response.session) {
            if (typeof cb == 'function') cb();
        } else {
            doLogin(cb);
        }
    });
}

//var group = '-41945892'; //test
var group = '-41949400'; //test1

function aaa(first){
//	VK.api('wall.get', {owner_id:'-16065223'}, function(r) { //группа махариши -16065223, задорнов 87896266
	VK.api('wall.get', {owner_id:group, count:5, extended:1}, function(r) {
//	VK.api('wall.get', {owner_id:'26244674'}, function(r) {
        var www = '';
        var groups = r.response['groups'];
        var wall = r.response['wall'];
        var profiles = r.response['profiles'];
//        vd(profiles);
//        vd(wall);
//        vd(groups);
        delete wall[0];
        _.each(wall, function(v, k){
            if(!v.text) return;
            v['signer'] = '';
            for(var i in profiles){
                if(profiles[i]['uid'] == v['signer_id']){
                    v['signer'] = profiles[i];
                    break;
                }
            }
            www += _.template(t, v);
        });
        $('.wall_a').html(www);
    });
    if (first) setTimeout(aaa, 500);
        //aaa();
}
function test_m(first){
	VK.api('wall.get', {owner_id:-16065223, count:5, extended:1}, function(r) {
        var www = '';
        var groups = r.response['groups'];
        var wall = r.response['wall'];
        var profiles = r.response['profiles'];
//                vd(wall);
        delete wall[0];
        _.each(wall, function(v, k){
            if(!v.text) return;
            v['signer'] = '';
            for(var i in profiles){
                if(profiles[i]['uid'] == v['from_id']){
                    v['signer'] = profiles[i];
                    break;
                }
            }
            www += _.template(t, v);
        });
        $('.wall_m').html(www);
    });
    if (first) setTimeout(test_m, 500);
}

function user_blog_vk(first){
    var uid = $('#user_blog_vk').attr('uid');
    var gid = $('#user_blog_vk').attr('gid');
    VK.api('wall.get', {owner_id:gid, count:100, extended:1}, function(r) {
        var www = '';
        var groups = r.response['groups'];
        var wall = r.response['wall'];
        var profiles = r.response['profiles'];
//        vd(profiles);
//        vd(wall);
//        vd(groups);
        delete wall[0];
        _.each(wall, function(v, k){
            if(!v.text) return;
            if (v['signer_id'] && v['signer_id'] != uid) return;
            else if ( !v['signer_id'] && v['from_id'] != uid) return;
            v['signer'] = '';
            for(var i in profiles){
                if(profiles[i]['uid'] == (v['signer_id'] || v['from_id'])){
                    v['signer'] = profiles[i];
                    break;
                }
            }

            www += _.template(vk_t, v);
        });
        $('#user_blog_vk').html(www);
    });
    if (first) setTimeout(user_blog_vk, 500);
}

/*
Павел Гершкулов
"error_code":15,"error_msg":"Access denied: user should be group admin"
в группе я админ
приложение прикреплено к группе
отдельного выбора группы не заметил... или id группы писать после -

Павел Гершкулов
owner_id:-(id группы) пришлось полистать запросы и ответы чтобы разговырять Id группы. решено...
*/
function wall_post(mess){
    check_auth(function () {
//        var mess = 'test';

        VK.api('wall.post', {owner_id:group, message:mess, from_group:1, signed:1}, function(r) {
//    VK.Api.call('wall.post', {owner_id:'26244674', message:mess}, function(r) {
//        {"response":{"post_id":215}}
            aaa();
            dao.log(r);
//            var www = ''; $('#wall').html(www);
        });
    });

}
    //	 VK.api('getProfiles', {uids:"1,2,3,4"}, function(r) {
//		 alert('dddddd');
//		 if(r.response) {
//			 alert('Привет, ' + r.response);
//		 }
    //	 });

var vk_members_data = {}, lastCommentsResponse, lastCommentsPage = null, baseURL = window.location.protocol + '//' + window.location.hostname + '/';

function array_unique(ar){
    if (ar.length && typeof ar !== 'string') {
        var sorter = {};
        var out = [];
        for (var i=0, j=ar.length; i<j; i++) {
            if(!sorter[ar[i]+typeof ar[i]]){
                out.push(ar[i]);
                sorter[ar[i]+typeof ar[i]]=true;
            }
        }
    }
    return out || ar;
}



function doLogin(cb) {
    VK.Auth.login(cb, VK.access.FRIENDS | VK.access.WIKI | VK.access.WALL | 8192);
}
function doLogout() { VK.Auth.logout(logoutOpenAPI); }

function loginOpenAPI() { getInitData(); }

function logoutOpenAPI() { /*window.location.reload();*/ window.location = baseURL; }

function getInitData() {
    var code;
    code = 'return {';
    code += 'me: API.getProfiles({uids: API.getVariable({key: 1280}), fields: "photo"})[0]';
    code += ',info: API.getGroupsFull({gids:1})[0]';
    code += ',news: API.pages.get({gid:1, pid: 2424933, need_html: 1})';
    code += ',friends: API.getProfiles({uids: API.getAppFriends(), fields: "photo"})';
    code += '};';
    VK.Api.call('execute', {'code': code}, onGetInitData);
}

function onGetInitData(data) {
	var r, i, j, html;
	if (data.response) {
		r = data.response;
		/* Insert user info */
		if (r.me) {
			ge('openapi_user').innerHTML = r.me.first_name + ' ' + r.me.last_name;
			ge('openapi_userlink').href = '/id' + r.me.uid;
			ge('openapi_userphoto').src = r.me.photo;
		}
		/* Insert Group info */
		if (r.info) {
			ge('group_link').href = '/club' + r.info.gid;
			ge('logo_img').src = r.info.photo;
		}
		/* Insert news */
		if (r.news) {
			ge('news_title').innerHTML = r.news.title;
			ge('news').innerHTML = r.news.html;
		}
		/* Insert friends */
		html = '';
		for (i = 0, j = r.friends.length; i < j; i++) {
			if (i >= 12) break;
			html += '<div onmouseout="this.className=\'list_cell\';" onmouseover="this.className=\'list_cell_over\'" class="list_cell"><a href="/id'+r.friends[i]['uid']+'">' +
                '<div class="list_border_wrap"><div class="list_wrap"><div class="list_div"><div class="list_image"><img width="50" src="'+r.friends[i]['photo']+'">' +
                '</div></div><div class="list_name">'+(r.friends[i]['first_name']+' '+r.friends[i]['last_name'])+'</div></div></div></a></div>';
        }
        ge('friends_list').innerHTML = html;
        hide('openapi_login_wrap');
        show('openapi_block');
        show('openapi_wrap');
        getComments();
    }else{}
}

function printCommentRow(id, uid, name, sex, photo, date, date_ts, comment) {
    return (
        '<div class="separator"></div>' +
        '<div id="comm'+id+'" class="comment">' +
        '<div class="notebody">' +
        '<a href="/id'+uid+'" class="userpic"><img src="'+photo+'"></a>' +
        '<div class="justComment">' +
        '<div class="header"><a class="memLink" href="/id'+uid+'">'+name+'</a> написал'+(sex == 1 ? 'a' : '')+'<br />'+date+'</div>' +
        '<div class="text">'+comment+'</div>' +
        '<div class="actions"><img id="action_progress'+id+'" src="images/upload.gif"/>'+
        ((VK._session.mid == uid && date_ts > (((new Date()).getTime() / 1000) - 15 * 60))
        ? '<a href="'+document.URL+'#" onclick="return deleteComment('+id+'); "><small>Удалить</small></a></div>'
        : ''
        )+
        '</div></div></div>'
    );
}

function renderPagination(current, total, progress) {
    var start, end, html = '';

    start = current - 4;
    if(start < 1) { start = 1; }
    end = current + 4;
    if (end > total) { end = total; }
    //alert(start+','+end+','+total);

    html += '<div class="commentsPagesWrap standard"><ul class="commentsPages">';
    for (i = start; i <= end; i++) {
        if (i != current) {
            html += '<li onclick="getComments(' + i + ');" onmouseover="setStyle(this, \'textDecoration\', \'underline\')" onmouseout="setStyle(this, \'textDecoration\', \'none\')"><span>' + i + '</span></li>';
        } else { html += '<li class="current"><span>' + i + '</span></li>'; }
    }
    html += '</ul><div class="progrWrap" style="height: 20px;"><img id="' + progress + '" src="images/upload.gif" style="vertical-align: -4px;"></div></div>';

        return html;
}

function renderCommentsPage(data) {
    var cmm, count, pages, member, name, html, i, j;

    count = data.shift();
    pages = Math.ceil(count / 10);
    if (lastCommentsPage === null) { lastCommentsPage = pages; }
    html = renderPagination(lastCommentsPage, pages, 'progressTop');
    for (i = 0, j = data.length; i < j; i++) {
        cmm = data[i];
        member = vk_members_data[cmm.uid];
        name = member.first_name + ' ' + member.last_name;
        html += printCommentRow(cmm.id, cmm.uid, name, member.sex, member.photo, cmm.date, cmm.date_ts, cmm.comment);
    }
    html += renderPagination(lastCommentsPage, pages, 'progressBottom');
    return html;
}

function onCommentsResponse(response) {
	var uids  = [], i, j;
	//alert(responseText);
	lastCommentsResponse = response;
	for (i = 0, j = response.length; i < j; i++) {
		if(response[i]['uid']) {
			uids.push(response[i]['uid']);
		}
	}
	uids = array_unique(uids);
	VK.Api.call('getProfiles', {'uids': uids.join(','), 'fields': 'photo,sex'}, onGetProfilesData);
}

function getComments(s) {
	var onSuccess = function(ajaxObj, responseText) {
		var response = eval('(' + responseText + ')');
        onCommentsResponse(response);
    };
    var onFail = function(ajaxObj, responseText) {
        responseText = responseText || 'Request error.';
        alert(responseText);
    }
    Ajax.Send(baseURL, { 'op':'a_get_comments', 's':s || 0 }, { 'onSuccess':onSuccess, 'onFail':onFail });
    lastCommentsPage = s || null;
    show('progressTop', 'progressBottom');
	return false;
}

function onGetProfilesData(r) {
	var data, html, i, j;
	if (r.response) {
		data = r.response;
		for (i =0, j = data.length; i < j; i++) {
			if (!vk_members_data[data[i]['uid']]) {
				vk_members_data[data[i]['uid']] = data[i];
			}
		}
	}
	html = renderCommentsPage(lastCommentsResponse);
	ge('comments_list').innerHTML = html;
	hide('progressTop', 'progressBottom');
}

function postComment() {
	var comment = ge('comment').value, onSuccess, onFail;
	if(comment) {
		onSuccess = function(ajaxObj, responseText) {
			var response = eval('(' + responseText + ')');
            lastCommentsPage = null;
            ge('comment').value = '';
			onCommentsResponse(response);
		};
		onFail = function(ajaxObj, responseText) {
			responseText = responseText || 'Request error.';
			alert(responseText);
		}
		Ajax.Send(baseURL, {'op':'a_add_comment', 'comment':comment}, {'onSuccess':onSuccess, 'onFail':onFail});
	} else ge('comment').focus();
	return false;
}

function deleteComment(cid) {

	var onSuccess = function(ajaxObj, responseText) {
		var response = eval('(' + responseText + ')');
        if(response.ok == 1) {
            commentBox = ge('comm' + response.cid);
            commentBox.innerHTML = '<div class="dld" style="font-weight:normal;">Комментарий удален.</div>';
        }
    };
    var onFail = function(ajaxObj, responseText) {
        responseText = responseText || 'Request error.';
        alert(responseText);
    }
    Ajax.Send(baseURL, { 'op':'a_del_comment', 'cid':cid }, { 'onSuccess': onSuccess, 'onFail': onFail });
    return false;
}

