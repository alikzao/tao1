;$(function(){


window.fbAsyncInit = function() {
    FB.init({
        appId      : '312290002124713', // App ID
//        channelUrl : '//WWW.YOUR_DOMAIN.COM/channel.html', // Channel File
        status     : true, // check login status
        cookie     : true, // enable cookies to allow the server to access the session
        xfbml      : true  // parse XFBML
    });
    // Additional initialization code here
    FB.getAuthResponse();
    setTimeout(function(){
        get_posts('172466856141886', 5);
//        get_posts('341375239282904', 5);//Ttt
//        get_posts_m('477596152258286', 5);//test
//        get_posts_m('350206461728430', 5);//test_page
    }, 1500);
};

// Load the SDK Asynchronously
(function(){
    var d = document;
    var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
    if (d.getElementById(id)) {return;}
    js = d.createElement('script'); js.id = id; js.async = true;
    js.src = "//connect.facebook.net/en_US/all.js";
//    js.src = "http://connect.facebook.net/en_US/all.js";
    ref.parentNode.insertBefore(js, ref);
})();


});

function get_user(id){ // получение инфы по текущему авторизованому пользователю
    if (!id) id = 'me'
    FB.api('/'+id, function(response) {
//        alert('Your name is ' + response.name);
        vd(response);
    });
}


var t1 = "<div class='item'rec_id='<%= id %>'>" +
    "<div><%= creaated_time ? (new Date(creaated_time)).toLocaleDateString() : '? time ?' %></div>"+
    "<img style='float:left; width:45px; padding:2px; border:1px solid #808080; margin:4px 4px 4px 0;' src='<%= icon %>'/>" +
    "<div style='font-weight:bold; '><a href='<%= '/user_page_fb/'+from.id %>'><%= from.name %></a></div>"+
    "<div><%= name %> </div>"+
    "<div><%= description %> </div>"+
    "<div style='clear: both;'></div>" +
    "</div>";

var t1_fb = "<div class='item'rec_id='<%= id %>'>" +
    "<div><%= creaated_time ? (new Date(creaated_time)).toLocaleDateString() : '? time ?' %></div>"+
    "<img style='float:left; width:45px; padding:2px; border:1px solid #808080; margin:4px 4px 4px 0;' src='<%= icon %>'/>" +
    "<div style='font-weight:bold; '><a href='<%= '/user_page_fb/'+from.id %>'><%= from.name %></a></div>"+
    "<div><%= name %> </div>"+
    "<div><%= description %> </div>"+
    "<div><%= message %> </div>"+
    "<div style='clear: both;'></div>" +
    "</div>";

//get_posts(10);
function get_posts(id, limit){
//    pages/ARI/172466856141886
    if (!id) id = 'me'
    FB.api('/'+id+'/posts', { limit: limit }, function(r) {
        var www = '';
        var wall = r['data'];
        _.each(wall, function(v, k){
            v['creaated_time'] = v['creaated_time'] ? v['creaated_time'] : '';
            www += _.template(t1, v);
        });
//        alert(www);
        $('.wall_b').html(www);
    });
}

function get_posts_m(id, limit){
//    pages/ARI/172466856141886
    if (!id) id = 'me'
    FB.api('/'+id+'/posts', { limit: limit }, function(r) {
        var www = '';
        var wall = r['data'];
        _.each(wall, function(v, k){
            v['creaated_time'] = v['creaated_time'] ? v['creaated_time'] : '';
            v['description'] = v['description'] ? v['description'] : '';
            v['message'] = v['message'] ? v['message'] : '';
            v['icon'] = v['icon'] ? v['icon'] : '';
            www += _.template(t1_fb, v);
        });
//        alert(www);
        $('.wall_n').html(www);
    });
}

function add_post_fb(id){
//    if (!id) id = 'me'
//    FB.api('/'+id+'/posts', function(r) {
//
//    });
    FB.ui(
        {
//            to:'/pages/Test/'+id,
            method: 'feed',
            message: 'getting educated about Facebook Connect',
            name: 'Connect',
            caption: 'The Facebook Connect JavaScript SDK',
            description: (
                'A small JavaScript library that allows you to harness ' +
                    'the power of Facebook, bringing the user\'s identity, ' +
                    'social graph and distribution power to your site.'
                ),
            link: 'http://www.fbrell.com/',
            picture: 'http://www.fbrell.com/f8.jpg',
            actions: [
                { name: 'fbrell', link: 'http://www.fbrell.com/' }
            ],
            user_message_prompt: 'Share your thoughts about RELL'
        },
        function(response) {
            if (response && response.post_id) {
                alert('Post was published.');
            } else {
                alert('Post was not published.');
            }
        }
    );
}

function del_post(post_id){
//    var post_id = '1234567890';
    FB.api(post_id, 'delete', function(r) {
        if (!r || r.error) {
            alert('Error occured');
        } else {
            alert('Post was deleted');
        }
    });
}

function login_fb(){
    FB.login(function(r) {
        if (r.authResponse) {
            console.log('Welcome!  Fetching your information.... ');
            FB.api('/me', function(r) {
                console.log('Good to see you, ' + r.name + '.');
            });
        } else {
            console.log('User cancelled login or did not fully authorize.');
        }
    }, {scope: 'email,user_likes,user_groups,user_about_me,user_interests,user_photos'});
}

function logout_fb(){
    FB.logout(function(r) {
        // user is now logged out
    });
}

function get_fb(){
    FB.api('/platform', function(r) {
        alert(r.company_overview);
    });
}

