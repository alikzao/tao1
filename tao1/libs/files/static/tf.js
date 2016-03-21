;(function($){

    if (window.dao.file_processor) return;

	var defaults = {}
    window.dao.file_processor = function ( params){
        var options = $.extend({}, defaults, params);


        var dialog = $(
        	'<div class="modal" style="width:100%; height:100%; display:none; ">'+
        		'<div class="modal-dialog" style="width:70%; height:90%;" >'+
        			'<div class="modal-content" style="width:100%; height:100%;">'+
        				'<div class="modal-header">'+
                            '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Галерея</h3></div>' +
                            '<div class="modal-body row" style="position:absolute; top:50px; right:20px; left:20px; bottom:60px;" ></div>' +
                 '<input class="fi" type="file" min="1" max="20" multiple="true"  style="display:none;"/>' +
                            '<div class="modal-footer" style="position:absolute; bottom:0px; right:0;">' +
                                '<div class="btn-group"></div>'+
        				    '</div>'+
        			    '</div>'+
        		    '</div>'+
        	    '</div>'
        ).appendTo('body');

//        var dialog = $('<div class="modal hide fade " style="width:730px; margin-left:-365px;">'+
//            '<div class="modal-header">'+
//            '<button class="close" data-dismiss="modal">×</button><h3>Галерея</h3></div>' +
//            '<div class="modal-body" style="width:700px; height:600px;"></div>' +
//            '<input class="fi" type="file" min="1" max="20" multiple="true"  style="display:none;"/>' +
//            '<div class="modal-footer"><div class="btn-group">'+
//            '<span  class="btn cancel" data-dismiss="modal">Закрыть</span>'+
//            '</div></div></div>'
//        ).appendTo('body');

        var mainw = dialog.find('.modal-body');

        var main_div_img = $('<div class="" style="position: absolute; top: 0; bottom: 0; left: 0; right: 200px;"></div>').appendTo(mainw);
//        var img_large = $('<div class="big_img" type="img" attr="img"><img title="" class="img-thumbnail img_large " style="max-width:100%; max-height: 100%;"alt="image01" /></div>').appendTo(main_div_img);
        var img_large = $('<img title="" class="img-thumbnail img_large " style="max-width:100%; max-height: 100%;"alt="image01" />').appendTo(main_div_img);

        var main_ul_img = $('<ul class="thumbnails" style="position:absolute; width:200px; overflow:auto; list-style:none; padding:8px; top:5px; right:5px; bottom:0px;"></ul>').appendTo(mainw)
        if (options.has_toolbar) {
            var btn_panel = dialog.find('.modal-footer .btn-group');
            $('<span class="btn cancel btn-danger" data-dismiss="modal">Закрыть</span>' ).prependTo( btn_panel );
            $('<span class="btn btn-info update">'+dao.ct('refresh')+'</span>'          ).prependTo( btn_panel );
            //$('<span class="btn btn-info link_img">Ссылка</span>'                       ).prependTo( btn_panel );
            $('<span class="btn btn-info del">'+dao.ct('del')+'</span>'                 ).prependTo( btn_panel );
            $('<span class="btn btn-info default">По умолчанию</span>'                  ).prependTo( btn_panel );


            $('<div class="btn-group dropup">'+
                '<button type="button" class="btn btn-success dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> Добавить <span class="caret"></span> </button>'+
                '<ul class="dropdown-menu">'+
                    '<li><a href="#" class="btn link_img">Загрузить по ссылке</a></li>'+
                    '<li><a href="#" class="btn upload_file">Загрузить с диска</a></li>'+
                    '<li><a href="#" class="btn set_link_img">Установить ссылку</a></li>'+
                '</ul>'+
            '</div>').prependTo( btn_panel );


            //$('<span class="btn btn-info upload_file"> Добавить</span>'                 ).prependTo( btn_panel );
            if (options.on_select) {
                $('<span class="btn insert_text btn-info">'+dao.ct('insert_in_text')+'</span>').prependTo(btn_panel );
            }
        }
        var curent_doc_id ;

        dialog.on('click', '.btn.upload_file', function(){ add_file() });
        dialog.on('click', '.btn.update', function(){ update() });
        dialog.on('click', '.btn.link_img', function(){ link_upload(); });
        dialog.on('click', '.btn.del', function(){
            if($('.img_large[file_name]').length){
                var file_name = $('.img_large[file_name]').attr('file_name');
                console.info('file_name', file_name, $('.img_large'), $('.img_large[file_name]').attr('file_name'));
                del_file(file_name, 'img');
            }else{
                del_file($('.big_img').attr('attr'), 'video')
                console.info('video');
            }
        });
        dialog.on('click', '.btn.default', function(){
            set_def_img( img_large.attr('file_name'), curent_doc_id )
        });
        dialog.on('click', '.img_large', function(){
            if(!$(this).closest('[contenteditable="true"]').length){
                show_full_img($(this).attr('src'));
                return false;
            }
        });
        dialog.on('click', '.btn.insert_text', function(){
            if(options.on_select) {
                console.log('img_large');
                if($('.big_img').length){
                    console.log($('.big_img').length);
                    //options.on_select('/static/static/video/'+curent_doc_id+'/'+$('.big_img').attr('attr'), 'video');
                    options.on_select(img_large.attr('src'), 'img');
                }else{
                    console.log($('.big_img').length);
                    options.on_select(img_large.attr('src'), 'img');
                }
                dialog.modal('hide');
            }
        });

        //$(document).on( 'click', 'a[data-toggle="tab"]', function (e) {
        //    console.log('e.target---->', e.target);
        //});
        //dialog.on('hidden.bs.modal', function () {
        $(document).on('hidden.bs.modal', function () {
        //    console.error('wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww0->', form);
		 // $(this).removeData('bs.modal');
		 //   dialog.remove();
		 //   dialog.empty();
          //  dialog.find('.fi').reset();
          //  dialog.find('.fi').empty();
          //  dialog.find('.fi').remove();
          //  delete form;
            //$('frame').remove();
            //$('frame').empty();
            //console.error('wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww1->', form);

        });



        function update(){
            clear();
            $.ajax({
                url: '/get_file_names', type:'POST', dataType:'json',
                data: { proc_id:options.id, doc_id:curent_doc_id },
                beforeSend: function(){
                    img_large.attr('src', '/static/core/img/wait.gif');
                },
                success: function(data){
                    if (data.result == 'ok') {
                        draw(data.content, data.default_img);
                    }
                }
            });
        }
        function link_upload(){
            var dialog = $(

                	'<div class="modal" style="margin-top:100px;">'+
                		'<div class="modal-dialog">'+
                			'<div class="modal-content">'+
                				'<div class="modal-header">'+
                				'<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Картинка через ссылку</h3></div>' +
                				'<div class="modal-body" ><input class="form-control" type="text" placeholder="Сылка на картинку"/></div>' +
                				'<div class="modal-footer"><div class="btn-group">'+
                                '<span  class="btn btn-default cancel" data-dismiss="modal">Закрыть</span>'+
                                '<span  class="btn link1 btn-primary" data-dismiss="modal">Загрузить</span>'+
                				'</div>' +
                				'</div>' +
                			'</div>' +
                		'</div>' +
                	'</div>'

            ).appendTo('body');
            dialog.modal();
            dialog.on('click', '.btn.link1', function(){
                var link = dialog.find('.modal-body input').val();
                $.ajax({
                    url: '/file/link_upload', type:'POST', dataType:'json', data:{ proc_id:options.id, doc_id:curent_doc_id, link:link },
                    beforeSend: function(){ img_large.attr('src', '/static/core/img/wait.gif'); },
                    success: function(data){
                        if (data.result == 'ok') update();
                    }
                });
            });
        }
        function clear(){
            //TODO реализовать очистку галереи
            $(img_large).attr('src', '/static/core/img/clean.jpg');
            $(main_ul_img).empty();
        }
        function set_def_img(id_img, doc_id){
//            var doc_id = '';
            $.ajax({
                type:"POST", dataType:"json", url:'/set_def_img',
                data:{ proc_id:options.id, id_img:id_img, doc_id:doc_id },
                success:function (data) {
                    if (data.result == 'ok') {
                        update();
                    }
                }
            });
        }

        var small_img_size = '50px';
        function postupdate_file_manager(){
            $(img_large).click(function(){
                $(img_large).hide().attr({
                    "src": $(this).attr("href"),
                    "title": $("> img", this).attr("title")
                });
                $(img_large).html($("> img", this).attr("title"));
                return false;
            });

            $("#large>img").load(function(){
                //выбираем потомков главного дива (скрытые картинки) и показываем их
                $("#large>img:hidden").fadeIn("slow")
            });
        }




        function show(doc_id){
            //сначала нарисовать галерею пустую в ней значек загрузки
            curent_doc_id = doc_id;
            dialog.modal('show');
            update(curent_doc_id);
        }

        function draw(content, default_img){
//            console.log('content1'  );
            console.log( "content === >>>",  JSON.parse(content));
            console.log( "options.is_disk === >>> ", options.is_disk);
            if (content) {
                console.warn(content);
                var content = JSON.parse(content);
                for (var i in content) {
                    var t = $('<li class="col-xs-12"></li>').appendTo(main_ul_img);
                    t = $('<a style="position:relative;" class="thumbnail" href="'+content[i]['orig']+'"></a>').attr('file_name', i).appendTo(t);
                    if(content[i]['filename'].indexOf('.mp4') != -1){
                        var im = $('<i class="icon-film" attr="'+content[i]['filename']+'" style="font-size:100px; padding-left:15px;"></i>').appendTo(t);
                    }
                    else if(content[i]['filename'].indexOf('.doc') != -1){
                        var im = $('<i class="icon-file-text-alt" attr="'+content[i]['filename']+'"></i>').appendTo(t);
                    }
                    else{
                        var im = $('<img style="" src="'+content[i]['thumb']+'"/>').appendTo(t);
                    }

                    if( i == default_img){
                        im.css({'border':'3px solid violet'});
                        im.attr('title', 'По умолчанию');
                        $('<div style="position:absolute; bottom:10px; padding:0px 2px 0 2px; border-radius:2px; left:25px; background:white;">По умолчанию</div>').appendTo(t);
                    }
                }
                main_ul_img.on('click', 'a', function(){
                    if( $(this).attr('href') == 'undefined'){
                        main_div_img.empty();
                        var attr = $(this).find('i').attr('attr');
                        $('<div class="thumbnail big_img" type="video" attr="'+attr+'" style="font-size:24px;">' +
                            '<i class="icon-film" attr="'+attr+'" style="font-size:200px; padding:15px;"></i>'+attr+'</div>').appendTo(main_div_img);
                    }else{
                        main_div_img.empty();
                        img_large.appendTo(main_div_img);
                        img_large.attr('src', $(this).attr('href'));
                        img_large.attr('file_name', $(this).attr('file_name'));
                        console.log( "$(this).attr('href') === >>> ", $(this).attr('href') );

                    }
                    return false;
                });
                $(main_ul_img).find('a:first').click();
            }else{
                clear();
            }
        }

        function del_file(file_name, type){
            $.ajax({
                url: '/del_files', type: 'POST', dataType: 'json',
                data: {
                    proc_id: options.id,
                    file_name: file_name,
                    type: type,
                    action: 'del_file',
                    doc_id: curent_doc_id
                },
                beforeSend: function(){ img_large.attr('src', '/static/core/img/wait.gif'); },
                success: function(answer){ update(); }
            });
        }

        function progress_bar(target){
            var pb = $('<div class="progress progress-striped active" style="z-index:100000">'+
                '<div class="bar progress-bar" role="progressbar" style="width: 40%;"></div>'+
            '</div>').appendTo(target);
            return pb.find('.bar');
        }

        /**
         * добавление файлов к текущей записи
         */
        function on_change() {
            form = new FormData();
            form.append('MAX_FILE_SIZE', '1000000');
            form.append('action', 'add_file');
            form.append('proc_id', options.id);
            form.append('doc_id', curent_doc_id);
            $.each(this.files, function (i, file) {
        //      if (!file.type.match(/image.*/)) return true;  // Отсеиваем не картинки
        //        console.error('form ------> ', form);
                form.append('image', file);
            });
            var bef = $('<div style="position:absolute; left:20px; right:20px; top:100px;"></div>').appendTo(dialog.find('.modal-body'));
            var pb = progress_bar(bef);
            bef.click();
            $.ajax({
                type: 'POST', dataType: 'json', url: '/add_files', data: form,
                cache: false, contentType: false, processData: false,
                beforeSend: function (progress, total) {
                    dao.status_bar('В процессе', true);
                    pb.css({'width': progress / total * 100 + '%'});
                },
                success: function (data) {
                    bef.remove();
                    update();
                },
                error: function (jqXHR, textStatus, errorThrown) { }
            });
        }
        function add_file() {
            dialog.find('.fi').remove();
            $('<input class="fi" type="file" min="1" max="20" multiple="true"  style="display:none;"/>').appendTo('.modal-body.row');
            var fi = dialog.find('.fi');
            fi.on('change', on_change);
            fi.click();
        }
        this.show = show;
        this.show_full_img = show_full_img;
    };

    window.show_full_img = function (url){
        var dialog = $('<div class="full_img" style="background-repeat:no-repeat; background-position:center; background-color:rgba(0,0,0,.8); z-index:10000; position:fixed; right:0; top:32px; left:0px; bottom:0px; background-size: contain; background-image: url(\''+url+'\')">' +
            '<div class="close_b" style="position: absolute; right:10px; top:10px; width:16px; height:16px; background-image: url(/static/core/img/cancel.png)"></div>' +
            '</div>').appendTo($('body'));
//                    dialog.find('.close_b').click(function(){
        dialog.click(function(){
            dialog.remove();
        });
        return false;
    }
})(jQuery);







