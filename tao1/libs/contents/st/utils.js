;$(function(){
    //*subscribe start*/
    $('.subscribe input').click(function(){
        dao.ajax(
            '/subscribe',
            {
                channel:$(this).attr('name'),
                status:$(this).is(':checked')
            },
            function(){alert('Изменения подписки сохранены.')}
        )
    });
    // end subscribe
    $('.nav [lang_id] ').on( 'click', function (){
        console.log('ksdfhsdk');
        var lang_id = $(this).attr('lang_id');
        $.ajax({
            type: "POST",
            url: '/switch_lang',
            data: { lang_id: lang_id },
            dataType: "json",
            success: function(data){
                if (data.result == 'ok'){
    //								 setTimeout(function () {window.location.reload()}, 5000);
                     setTimeout(function () {window.location.reload()}, 250);
                }
            }
        });
    });
});

function show_d(text){
    var dialog =$(
    "<div class='modal fade' tabindex='-1' role='dialog' style='margin-top:60px;'>" +
        "<div class='modal-dialog'>"+
            "<div class='modal-content' style='min-height:150px;'>"+
                "<div class='modal-body' style='padding:30px;'>" +
                    "<button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>"+
                    "<p style='font-weight:bold; color:grey;'> "+text+"</p>" +
                "</div>" +
            "</div>"+
        "</div>"+
    "</div>").appendTo('body');
    dialog.modal('show');
}




function reset_ang(){
    var customInterpolationApp = angular.module('customInterpolationApp', []);
    customInterpolationApp.config(function($interpolateProvider) {
        $interpolateProvider.startSymbol('//');
        $interpolateProvider.endSymbol('//');
    });
}

function scroll_top(){
    $('<div id="toTop" style="display:none; position:fixed; right:10px; bottom:10px; padding:10px; background-color:rgba(0,0,0,.5); ' +
    'border-radius:10px; cursor:pointer;"> <i class=""><i class="fa fa-arrow-up" style="color:white; font-size:26px;"></i> </div>').appendTo( $('body') );
    $(window).scroll(function() {
        if($(this).scrollTop() != 0) $('#toTop').fadeIn();
        else $('#toTop').fadeOut();
    });
    $('#toTop').on('click', function() {
        $('body,html').animate({scrollTop:0},800);
    });
}


function spam(doc_id){
    // sending and complaints admin
    var toolbar = $('.in-toolbar');
    $('<div class="rb spam btn btn-sm"><i style="color:orange; font-size:14px;" class="fa fa-warning"></i> </div><span>&nbsp;</span>')
        .prependTo(toolbar);

    toolbar.on('click', '.rb.spam', spam_);
    $('body').on('click', '.btn.send_spam', spam_send);

    function spam_(){
        var dialog = $(
            '<div class="modal fade" style="zindex:1000000;">'+
                '<div class="modal-dialog">'+
                    '<div class="modal-content">'+
                        '<div class="modal-header">'+
                            '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>'+
                            '<h1 class="modal-title">Сообщить о нарушении</h1>'+
                        '</div>'+
                        '<div class="modal-body"></div>' +
                        '<div class="modal-footer">'+
                            '<span  class="btn send_spam btn-primary" data-dismiss="modal">Отправить жалобу</span>'+
                            '<span  class="btn btn-default cancel" data-dismiss="modal">Отмена</span>'+
                        '</div>'+
                   '</div>'+
                '</div>'+
            '</div>'
        ).appendTo('body');
        var tube = $('<label>Описание проблемы<br><textarea class="form-control" name="spam" style="height:150px; width:520px;"></textarea>' +
            '</label>').appendTo(dialog.find('.modal-body'));
        dialog.modal();
    }
    function spam_send(){
        var comm_id = $(this).closest('[id_comm]');
        if(comm_id.length){ comm_id = comm_id.attr('id_comm');}
        else{ comm_id = '';}
        $.ajax({
            type: "POST", dataType: "json", url:'/spam',
            data: {
                doc_id:doc_id,
                data:JSON.stringify({
                    user_id:current_user.id,
                    doc_id:doc_id,
                    com_id:comm_id,
                    is_doc:'doc',
                    link:location.protocol+'//'+location.hostname+'/news/'+doc_id+(comm_id ? '#comm_'+comm_id : ''),
                    title:$('.single_object').find('h1 a').text(),
                    body:$('.modal-body').find('[name=spam]').val()
                })
            },
            success: function (data) {
                if (data.result == 'ok') alert('Сообщение успешно отправлено!')
            }
        });
    }
}

function comments_proc(doc_id, comm_id, text_help, mode, id){
    mode = mode || 'strict';
    var click_answer = function(){
        move_editor($(this).closest('[id_comm]').attr('id_comm'));
        $('.container').focus();
        $('.hide_inp:last').focus();
        $('.hide_inp:first').focus();
        $('.container iframe').focus();
        return false;
    };
    var init_f = function() {
        $('li[id_comm]').each(function(){
            var id_comm = $(this).attr('id_comm');
            if(id_comm=='_')return;
            var user_id = $(this).attr('user_id');
            var toolbar = $(this).find('.in-toolbar:first');
            var children = $(this).find('li[id_comm]');
            if (current_user.is_admin ){
                $('<div id_comm="'+id_comm+'" class="rb comm_ban comm_ban1 btn btn-default btn-xs"> ban</div>' +
                    '<span>&nbsp;</span>').appendTo(toolbar);
            }
            if (current_user.is_admin || current_user.moderator_comm ||
                current_user.id == user_id && current_user.is_logged_in && !children.length || current_user.edit_comm){
                $('<div id_comm="' + id_comm+'" class="rb comm_edit btn btn-default btn-xs"><i class="fa fa-wrench fa-white"></i> ' +
                    '</div><span>&nbsp;</span>').appendTo(toolbar);
            }
            if (current_user.is_admin || current_user.moderator_comm ||
                current_user.id == user_id && current_user.is_logged_in && !children.length || current_user.del_comm){
                $(' <div id_comm="' + id_comm+'" class="rb comm_del btn btn-default btn-xs"><i class="fa fa-trash fa-white "></i>' +
                    '</div>').appendTo(toolbar);
            }
            toolbar.find('.comm_edit').click(edit_comm);
            toolbar.find('.comm_del').click(del_comm);
        });

        $('.comm_editor').find('[data=name]').text(current_user.name);
        if(!text_help){text_help='';}
        if(mode=="strict"){
            if (current_user.can_comment || current_user.is_admin){
                $('.comment_button').html('<div id_comm="_"><div class="add_comm_b btn btn-primary" style="margin:5px;">' +
                    ' Добавить комментарий </div></div>');
            }else {
                var mess = !current_user.is_logged_in
                    ? text_help
                    : '<span style="color:red;">У вас нет прав слишком часто добавлять коментарии, в связи с низкой кармой</span>';
                $('.comment_button').html(
                    '<div id_comm="_" class="row well" style="width:730px; margin-left:1px;">' +
                        '<div class="col-xs-4 btn btn-primary add_comm_b"><i class="fa fa-facebook-sign"></i> Добавить комментарий</div>' +
                        '<div class="col-xs-7"> </div>'+
                        '</div>'+
                        '<div style="text-align: center; color:#68a; padding:3px; border:1px solid #ddd;" class="ui-corner-all"> ' + mess + '</div>');
                $('.comm_answer').hide();
            }
            $('.add_comm_b').click(function(){
                if (current_user.can_comment) click_answer.call(this);
                else if( typeof fb_login == 'function' ) fb_login();
            });
        }else{

            setTimeout(function(){move_editor('_')}, 500);
            $('.add_comm_b').click(function(){
                click_answer.call(this);
            });
            if (current_user.is_logged_in){
                var user_comm = "<b data='name' style='display:inline-block; padding:15px 0 0 5px;'>"+current_user.name+"</b>"
            }else{
                var user_comm ='<input class="form-control input-sm" type="text" style="display: inline-block; width: 300px; margin: 10px 0 0 10px;" placeholder="Введите свое имя"/>'
            }
            $('.comm_editor .comm_title').append(user_comm);
        }
    };

    current_user.ready(function() { init_f() });

    function del_comm(){
        console.warn('del_comm');
        var comm_id = $(this).attr('id_comm');
        if (confirm(dao.ct('Вы действительно хотите удалить комментарий?'))) {
            var new_body = $('.t_rich_edit1[name="body1"]').val();
            $.ajax({
                type: "POST", url: '/comm/del', dataType: "json",
                data: { comm_id: comm_id},
                success: function(data){
                    if(data.result=="ok"){
                        if(data.action=="del_dom"){
                            $("li[id_comm="+comm_id+"]").remove();
                        }else{
                            $(".comm_comment[id_comm="+comm_id+"]").text('Коментарий удален.');
                            $(".un[id_comm="+comm_id+"]").text('');
                        }
                    }else{ alert(data.error); }
                }
            });
        } else { /* Do nothing!*/ }
    }


    function edit_comm(){
        var comm_id = $(this).attr('id_comm');
        var parent = $('div.comm_comment[id_comm="'+comm_id+'"]');
        var text_comm =parent.html();
        parent.html('<div><textarea class="form-control" style="width:98%; height:100px; border: 1px solid #ccc;"> </textarea></div>'+
            '<div class="" style="text-align: right; padding: 5px 50px;">' +
            '<div class="edit_comm btn btn-info" style="cursor: pointer; margin-right:5px;  font-size:14px;">'+ dao.ct('Отправить')+'</div>'+
        '<div class="cancel_comm btn btn-default" style="cursor: pointer; font-size:14px;">'+ dao.ct( 'Отмена')+'</div>'+
        '</div>');
        parent.find('.edit_comm, .cancel_comm').button();
        parent.find('textarea').val(text_comm);
        parent.find('.cancel_comm').click(function(){
            parent.html(text_comm);
        });
        parent.find('.edit_comm').click(function(){
            var new_body = parent.find('textarea').val();
            $.ajax({
                type: "POST", url: '/comm/edit', dataType: "json",
                data: {
                    comm_id: comm_id,
                    user: current_user.id,
                    body: new_body
                },
                success: function(data){
                    if(data.result=="ok"){
                        parent.html(new_body);
                    }else{ dao.user_mess(data.error, 'error'); }
                }
            });
        });
    }

    //    $('.comm_ban1').click(function(){
    $('.ul_comments').on('click', '.comm_ban', function(){
        var branch_id = $(this).attr('id_comm');
        $.ajax({
            url: '/comm/ban', type: 'POST', dataType: 'json',
            data: {
                proc_id: comm_id,
                branch_id: branch_id,
                parent_id: id_comm,
                doc_id: '', link: ''
            },
            beforeSend: function(){ },
            success: function(data){
                if(data.result == 'ok'){
                    alert('Пользователь '+data.user+' забанен.')
                }else dao.user_mess(data.error, 'error');
            }
        });
    });


//    var doc_id = "{{doc['id']}}";
    var id_comm = '_';
    var comm_editor = $('.comm_editor');
    var easewig = $('.easewig').css({'margin':'0px 5px 0px 5px'});

    $('.hide_inp').css({'position':'absolute', 'left':'-5000px'});

    window.move_editor = move_editor;
    function move_editor(_id_comm) {

        id_comm = _id_comm;
        $('[comm_cont="'+id_comm+'"]:first').get(0).appendChild(comm_editor.get(0));
        easewig = $('.easewig');
        name = $('.comm_title input');
        input = easewig.find('textarea');
        if (!input.length)
            input = $('<textarea class="form-control" style="width:99%; height:100px; border:1px solid #ccc;" class="ggg"/>').appendTo(easewig);
    }

    $('.comm_answer').click(click_answer);




    $('.ggg').css({'height': '440px', 'height': '220px'  });
    $('.comm_create').on('click', function(){

        var aa = $('.easewig textarea').val();
        var name = $('.comm_title input').val();
        var comm_id = $(this).attr('id_comm');

        $.ajax({
            url: '/comm/add', type: 'POST', dataType: 'json',
            data: {
                id:id, // id - this is the document ID of the article
                // proc_id: comm_id,
                comm_id: comm_id,
                doc_id: doc_id,
                // proc_id: doc_id,
                // doc_id: comm_id,
                parent: id_comm,
                title: name,
                descr: aa
            },
            beforeSend: function(){ },
            success: function(data){
                if(data.result == 'ok'){
                    draw_comm(data.content);
//                    if(mode=="strict")move_editor('__');
                    move_editor('_');
                    input.val('');
                    input.change();
                }else if(data.result == 'fail') dao.user_mess(data.error+' result.fail', 'error');
                else dao.user_mess(data.error+' error', 'error');

                $('input[name=captcha]').val('');
                $('input[name=hash]').val(data.hash);
                $('img[name=captcha]').attr('src', '/captcha?hash='+data.hash);
            }
        });
    });

    var comm_reversed = false;
    function draw_comm(content){
        var place = $('li[id_comm='+content.parent+'] >ul');
        var aaa = $('<li id_comm="'+content.id+'"><div class="body_comment ui-corner-all">'+
            '<div class="comm_title" style="border-bottom:1px solid #ddd; margin:0px 20px 0px 20px; padding:5px 10px 10px 10px ">'+
            '<div class="comm_name">'+(content.our == "true" ? '<b><a target="_blank" href="http://facebook.com/'+content.title.substr(3)+'">'+dao.ct(content.name)+'</a></b>' : content.title)+'</div>'+
            '<div class="comm_date"  style="color:#aaa;">'+content.date+'</div>'+

            ( current_user.is_admin || 'user:'+content.title ==current_user.id ?
                '<div class="in-toolbar">'+
                    '<div id_comm="'+content.id+'" class="rb comm_edit btn btn-info btn-sm"><i class="icon-wrench icon-white"></i></div> &nbsp;'+
                    '<div id_comm="'+content.id+'" class="rb comm_del btn btn-info btn-sm"><i class="icon-trash icon-white"></i></div>'+
                    '</div>' :'')+
            '</div>'+
            '<div class="comm_comment ui-corner-all" id_comm="'+content.id+'">'+content.body+'</div>'+
            '<div  class="comm_answer ui-corner-all" style="cursor: pointer; padding-bottom:10px;"> <a href="#">'+dao.ct('Ответить')+'</a></div>'+
            '<div comm_cont="'+content.id+'"></div>' +
        '</li>')[(comm_reversed ? 'prepend' : 'append')+'To'](place);
        if(!current_user.is_admin ) place.closest('[id_comm]').find('.in-toolbar:first').remove();
        aaa.append('<ul class="sub_comments ui-corner-all"></ul>');
        $('.comm_answer', aaa).click(click_answer);
        if ( current_user.is_admin || 'user:'+content.title ==current_user.id){
            $('.comm_edit', aaa ).on('click', edit_comm);
            $('.comm_del', aaa  ).on('click', del_comm );
        }
        aaa[0].scrollIntoView();
        window.scrollBy(0, -160);
        //aaa.css({'margin-top':'130px'});
    }

}

//*end comments*/
function make_lf2(){
    var lfnid = 0;
    var lfcycle = 25000;
    var lfactive = false;

    var target = $('.nr');
    var nl = target.find('.news-list');
    var ph = target.find('.news-image');

    $('.news-list').on('mouseover', 'a.item', function( event ) {
//        $('a.item').removeClass('active');
        $('a.item').parent().removeClass('active');
        $(this).parent().toggleClass('active');
        ph.find('.main-img').hide();
        ph.find('.news_title').hide();
        target.find('.news_descr').hide();
        $('#news_title'+$(this).attr('var')).show();
        $('#news_descr'+$(this).attr('var')).show();
        $('#news-image-'+$(this).attr('var')).show();
        console.log('img', $('#news-image-'+$(this).attr('var')).length);
        lfactive = true;
        return false;
    });
    $('.news-list').on('mouseout', 'a.item', function( event ) {
        lfnid = 1 * $(this).attr('var');
        lfactive = false;
        return false;
    });
    target.show();
    ph.find('.news_title').hide();
    ph.find('.main_img').hide();
    target.find('.news_descr').hide();
    $('#news-image-0').fadeIn("slow");
    $('#news_title0').fadeIn("slow");
    $('#news_descr0').fadeIn("slow");
    nl.find("a.item").parent().eq(0).toggleClass('active');
    setInterval(NewsRotate, lfcycle);

    function NewsRotate() {
        var lfnidb = lfnid;
        if(!lfactive) {
            nl.find("a.item").parent().removeClass('active');
            lfnid = (lfnid + 1) % nl.find("a.item").length;
            nl.find("a.item").parent().eq(lfnid).toggleClass('active');
            $('#news-image-'+lfnidb).fadeOut("slow",function() {
                $('#news-image-'+lfnid).fadeIn("slow");
            });
            $('#news_title'+lfnidb).fadeOut("slow",function() {
                $('#news_title'+lfnid).fadeIn("slow");
            });
            $('#news_descr'+lfnidb).fadeOut("slow",function() {
                $('#news_descr'+lfnid).fadeIn("slow");
            });
        }
    }
}
function make_lf3(){
    var lfnid = 0;
    var lfcycle = 25000;
    var lfactive = false;

    var target = $('.nr');
    var nl = target.find('.news-list');
    var ph = target.find('.news-image');

    $('.news-list').on('mouseover', 'a.item', function( event ) {
//        $('a.item').removeClass('active');
        $('a.item').parent().removeClass('active');
        $(this).parent().toggleClass('active');
        ph.find('.main-img').hide();
        ph.find('.news_title').hide();
        target.find('.news_descr').hide();
        $('#news_title'+$(this).attr('var')).show();
        $('#news_descr'+$(this).attr('var')).show();
        $('#news-image-'+$(this).attr('var')).show();
        console.log('img', $('#news-image-'+$(this).attr('var')).length);
        lfactive = true;
        return false;
    });
    $('.news-list').on('mouseout', 'a.item', function( event ) {
        lfnid = 1 * $(this).attr('var');
        lfactive = false;
        return false;
    });
    target.show();
    ph.find('.news_title').hide();
    ph.find('.main_img').hide();
    target.find('.news_descr').hide();
    $('#news-image-0').fadeIn("slow");
    $('#news_title0').fadeIn("slow");
    $('#news_descr0').fadeIn("slow");
    nl.find("a.item").parent().eq(0).toggleClass('active');
    setInterval(NewsRotate, lfcycle);

    function NewsRotate() {
        var lfnidb = lfnid;
        if(!lfactive) {
            nl.find("a.item").parent().removeClass('active');
            lfnid = (lfnid + 1) % nl.find("a.item").length;
            nl.find("a.item").parent().eq(lfnid).toggleClass('active');
            $('#news-image-'+lfnidb).fadeOut("slow",function() {
                $('#news-image-'+lfnid).fadeIn("slow");
            });
            $('#news_title'+lfnidb).fadeOut("slow",function() {
                $('#news_title'+lfnid).fadeIn("slow");
            });
            $('#news_descr'+lfnidb).fadeOut("slow",function() {
                $('#news_descr'+lfnid).fadeIn("slow");
            });
        }
    }
}

function make_lf(){
    var lfnid = 0;
    var lfcycle = 25000;
    var lfactive = false;

    target = $('.nr');
    var nl = target.find('.news-list');
    var ph = target.find('.news-image-placeholder');

    $('.news-list').on('mouseover', 'a.item', function( event ) {
        $('a.item').removeClass('active');
        $(this).toggleClass('active');
        ph.find('.news_title').hide();
        ph.find('> img').hide();
        $('#news_title'+$(this).attr('var')).show();
        $('#news-image-'+$(this).attr('var')).show();
        lfactive = true;
        return false;
    });
    $('.news-list').on('mouseout', 'a.item', function( event ) {
        lfnid = 1 * $(this).attr('var');
        lfactive = false;
        return false;
    });
    target.show();
    ph.find('.news_title').hide();
    $('#news-image-0').fadeIn("slow");
    $('#news_title0').fadeIn("slow");
    nl.find("a.item").eq(0).toggleClass('active');
    setInterval(NewsRotate, lfcycle);

    function NewsRotate() {
        var lfnidb = lfnid;
        if(!lfactive) {
            nl.find("a.item").removeClass('active');
            lfnid = (lfnid + 1) % nl.find("a.item").length;
            nl.find("a.item").eq(lfnid).toggleClass('active');
            $('#news-image-'+lfnidb).fadeOut("slow",function() {
                $('#news-image-'+lfnid).fadeIn("slow");
            });
            $('#news_title'+lfnidb).fadeOut("slow",function() {
                $('#news_title'+lfnid).fadeIn("slow");
            });
        }
    }
}


var current_user = function() {
    var on_ready = [];
    init();
    return make_user({});

    // -------------------------------------------------------------------------

    function ready(callback) {
        if (current_user.name) {
            callback();
        } else {
            on_ready.push(callback);
        }
    }

    function make_user(user) {
        user.ready = ready;
        return user;
    }

    function init() {
        $.ajax({
            type:"POST", dataType:"json", url:'/user_status', data: {},
            success:function (data) {
                if (data.result == 'ok') {
                    // current user
                    current_user = make_user(data.user);
                    // panel
                    $('#header .placeholder').parent().append($(data.panel));
                    init_panel();
                }
            }
        });
    }
}();


function init_panel() {
    if( typeof fb_login == 'function' ) $('[name=facebook]'     ).click(fb_login);
    if( typeof tw_login == 'function' ) $('[name=twitter]'      ).click(tw_login);
    if( typeof vk_login == 'function' ) $('[name=vk]'           ).click(vk_login);
    if( typeof vk_login == 'function' ) $('[name=odnoklassniki]').click(ok_login);
    if( typeof gl_login == 'function' ) $('[name=google]'       ).click(gl_login);
    if( typeof ya_login == 'function' ) $('[name=ya]'           ).click(ya_login);
}


function ok_login(){
//    encodeURIComponent
    var redirect = 'http://'+window.location.host+'/oauth_ok';
    var scope = 'email,useroffline';
    var scope = 'VALUABLE_ACCESS;PHOTO_CONTENT';
    var loc = 'http://www.odnoklassniki.ru/oauth/authorize?client_id='+window.ok_id+'&scope='+scope+'&redirect_uri='+redirect+'&response_type=code';

    window.location = loc;
    return false;
}

function vk_login(){
    var redirect = 'http://'+window.location.host+'/oauth_vk';
    var scope = 'email,useroffline';
    var loc = 'http://api.vk.com/oauth/authorize?client_id='+window.vk_id+'&scope='+scope+'&redirect_uri='+redirect+'&response_type=code';
    window.location = loc;
    return false;
}
auth_options = {
    fb: {
        scope: 'email,user_birthday,user_about_me,user_photos,publish_actions,user_checkins,user_actions.music,manage_pages'
    }
};
function fb_login(){
    var scope = auth_options.fb.scope;
    //var redirect = 'http://'+window.location.host+'/oauth_fb?wwww='+dao.base64_encode(window.location.toString());
    var redirect = 'http://'+window.location.host+'/oauth_fb';
    var loc = 'http://graph.facebook.com/oauth/authorize?display=page&client_id='+window.fb_id+'&type=web_server&scope='+scope+'&redirect_uri='+redirect+'&response_type=token';
    window.location = loc;
    return false;
}

function tw_login(){
    var loc = 'http://'+window.location.host+'/oauth_tw_login';
    window.location = loc;
    return false;
}
function ya_login(){
    var loc = 'http://'+window.location.host+'/oauth_ya_login';
    window.location = loc;
    return false;
}

function gl_login(){
    var loc = 'http://'+window.location.host+'/oauth_gl_login';
    window.location = loc;
    return false;
}


function auto_loader(){
    $(window).on('scroll', function(){
        $('.loader').each(function(){
            var $this = $(this);
            var base_skip = $this.attr('skip') || 0;
            base_skip = parseInt(base_skip);

            var aaa = $this.offset().top + $this.height() - $(window).scrollTop() - $('html')[0].offsetHeight;
            if(aaa < 0 && !$this.data('is_loading')){
                $this.data('is_loading', true);
                var waiter = $('<div>Загрузка</div>').appendTo($this);
                load($this.attr('slot'), $this.find('.cell').length + base_skip, function(data) {
                    waiter.remove();
                    $this.append(data.content);
                    if (data.len_dv) $this.data('is_loading', false);
                });

            }
        });
    });
    function load(slot, skip, cb){
        var url ='/loader/slot'+window.location.search;
        $.ajax({
            type: "POST", dataType: "json", url: url,
            data: { slot:slot, skip:skip },
            success: function (data) {
                if (data.result == 'ok') {
                    cb(data);
                }
            }
        });
    }
}





