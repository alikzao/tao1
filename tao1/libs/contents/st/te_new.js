;(function($){
    if (window.dao.te_new ) return;
    window.dao.te_new = te_new;
    //TODO когда кликаеш по картинке нужно чтоб в хроме она принудительно выделилась,


    function te_new(_parent, params){
        var options = $.extend({is_show_close:true}, params);
        var toolbar = null, back = null, parent = null, cm_pane = null;
        var cursor; var myCodeMirror = null;

         function show(){
            if(toolbar) return;
    	    console.log('show after toolbar');

            back = _parent;
            parent = $(back[0].outerHTML);
            parent.insertAfter(back);

	        init_codemirror();
	        // init_ace();

            back.hide();
            back.addClass('back');
            parent.addClass('parent');
            img_resize();

            parent.attr('contenteditable', 'true');
            parent.css('clear', 'both');
            draw_tolbar();
            parent.focus();
            update_cursor();
            parent.css({'border':'3px solid #eee', 'border-radius':'8px'});
            init_events();
        }

        function cancel() {
            hide_te();
            options.cancel();
        }

        function hide_te(){
            console.log('toolbar', toolbar);
            parent.remove();
            cm_pane.remove();
            myCodeMirror = null;
            back.show();
            toolbar.remove();
            toolbar = null;

        }

        function draw_tolbar(){
            toolbar = $(
                '<div class="toolbar_live_edit" style="min-height:50px;">' +
                '<style>.toolbar_live_edit>.btn-group>*{vertical-align:top;}</style>' +
                '<div class="navbar navbar-default">'+
                '<div class="nav navbar-nav" style="padding-left:5px;padding-right:5px; text-align:center;">'+
//                '<div class="container">'+
                '<div class="ee_toolbar btn-toolbar" style="z-index:100 ">'+
                '<div class="btn-group btn-group-sm" style="margin-top:10px;">'+


                '<button class="btn btn-default bold" data-content="Выделение жирным нужного участка текста" data-placement="top" rel="popover" data-trigger="hover" title="Выделение жирным"><i class="fa fa-bold"></i></button>'+
                '<button class="btn btn-default italic" data-content="Выделение курсивом определённого участка текста" data-placement="top" rel="popover" data-trigger="hover" title="Выделение курсивом"><i class="fa fa-italic"></i></button>'+
                '<button class="btn btn-default underline" data-content="Подчеркивание выделеного участка текста" data-placement="top" rel="popover" data-trigger="hover" title="Выделение подчеркиванием"><i class="fa fa-underline"></i></button>'+
                '<button class="btn btn-default strikethrough" data-content="Перечеркивание выделеного участка текста" data-placement="top" rel="popover" data-trigger="hover" title="Перечеркивание выделеного"><i class="fa fa-strikethrough"></i></button>'+

                '<button class="btn btn-default code" data-content="Программный код" data-placement="top" rel="popover" data-trigger="hover" title="Программный код"><i class="fa fa-code"></i></button>'+

                '<button class="btn btn-default img" data-content="Показ галереи для работы с изображениями" data-placement="top" rel="popover" data-trigger="hover" title="Галерея"><i class="fa fa-picture-o"></i></button>'+
                '<button class="btn btn-default film" data-content="Вставка HTML, требуется для вставки флеша и других подобных вещей" data-placement="top" rel="popover" data-trigger="hover" title="Вставка HTML"><i class="fa fa-film"></i></button>'+
                '<button class="btn btn-default link" data-content="Создание ссылок" data-placement="top" rel="popover" data-trigger="hover" title="Ссылки"><i class="fa fa-link"></i></button>'+
(document.createElement("input").webkitSpeech !== undefined ?
                    '<input class="input-sm mic" data-placement="top" style="float:left; height:32px;width:32px; vertical-align:top;padding:0 4px; margin:0;" data-content="Начитывание текста после произнесения текст появляется в редакторе (только chrome)" title="Начитываение текста" x-webkit-speech="" speech="" type="text" name="text">'
                : ''
                )+
                '<br/>'+

                '<button class="btn btn-default eraser" data-content="Очистить стили" data-placement="top" rel="popover" data-trigger="hover" title="Очистить стили"><i class="fa fa-eraser"></i></button>'+

                '<div class="btn-group">'+
                '<button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" data-content="Величина шрифта" data-placement="top" rel="popover" data-trigger="hover" title="Величина шрифта"><i class="fa fa-font"></i>&nbsp;<span class="caret"></span></button>'+
                '<ul class="dropdown-menu font_size" role="menu">'+
                    '<li><a href="#">9px</a></li>'+
                    '<li><a href="#">10px</a></li>'+
                    '<li><a href="#">12px</a></li>'+
                    '<li><a href="#">14px</a></li>'+
                    '<li><a href="#">16px</a></li>'+
                    '<li><a href="#">18px</a></li>'+
                    '<li><a href="#">20px</a></li>'+
                    '<li><a href="#">22px</a></li>'+
                    '<li><a href="#">32px</a></li>'+
                '</ul>'+
                '</div>'+

                '<div class="btn-group">'+
                '<button class="btn btn-default btn-sm  dropdown-toggle" data-toggle="dropdown" data-content="HTML заголовки" data-placement="top" rel="popover" data-trigger="hover" title="HTML заголовки"><span style="font-weight:bold;">H <span class="caret"></span></button>'+
                '<ul class="dropdown-menu h" role="menu">'+
                    '<li><a href="#">h2</a></li>'+
                    '<li><a href="#">h3</a></li>'+
                    '<li><a href="#">h4</a></li>'+
                    '<li><a href="#">h5</a></li>'+
                    '<li><a href="#">h6</a></li>'+
                '</ul>'+
                '</div>'+

                '<button class="btn btn-default center" data-content="Центрирование текста" data-placement="top" rel="popover" data-trigger="hover" title="Центрирование"><i class="fa fa-align-center"></i></button>'+
                '<button class="btn btn-default left" data-content="Выровнять по левому краю" data-placement="top" rel="popover" data-trigger="hover" title="Выровнять текст по левому краю"><i class="fa fa-align-left"></i></button>'+
                '<button class="btn btn-default right" data-content="Выровнять по правому краю" data-placement="top" rel="popover" data-trigger="hover" title="Выровнять текст по правому краю"><i class="fa fa-align-right"></i></button>'+

                '<button class="btn btn-default list_ul" data-content="Нумерованый список" data-placement="top" rel="popover" data-trigger="hover" title="Нумерованый список"><i class="fa fa-list-ul"></i></button>'+
                '<button class="btn btn-default list_ol" data-content="Список" data-placement="top" rel="popover" data-trigger="hover" title="Список"><i class="fa fa-list-ol"></i></button>'+

//                '<button class="btn btn-default copy" data-content="Скопировать текст" data-placement="top" rel="popover" data-trigger="hover" title="Скопировать текст"><i class="fa fa-copy"></i></button>'+
//                '<button class="btn btn-default paste" data-content="Вставить текст" data-placement="top" rel="popover" data-trigger="hover" title="Вставить текст"><i class="fa fa-paste"></i></button>'+

            '</div>'+

            (options.is_show_close ?
            '<div class="btn-group btn-group-sm" style="margin-top:10px;">'+
                '<span class="btn btn-success save-body news_add" ><i class="fa fa-check fa fa-white"></i> Сохранить</span>'+
                '<span class="btn btn-info  draft-body news_draft" ><i class="fa fa-th fa fa-white"></i> В черновики</span>'+
                '<span class="btn btn-danger  cancel_body" ><i class="fa fa-trash fa fa-white"></i> Отмена</span>'+
            '</div>'
            : '')+
            '<div class="btn-group btn-group-sm" style="margin-top:10px;">'+
                '<button type="button" class="btn btn-primary text_html html" ><i class=""></i>HTML</button>'+
            '</div>'+
            '</div>'+
            '</div>'+
//            '</div>'+
            '</div>').insertBefore(parent);


            $('html').css({'position':'relative'});
            $(window).on('scroll', function(){
                if(!toolbar)return;
                var aaa = toolbar.offset().top - $(window).scrollTop();
                if(aaa < 100) toolbar.find('.navbar').addClass('navbar-fixed-top').css({'position':'fixed', 'top':options.margin_top});
                else         toolbar.find('.navbar').removeClass('navbar-fixed-top').css({'position':'relative', 'top':'0px'});
            });

            toolbar.find('[rel="popover"]').popover();
//        main.css({"position":"fixed", "top":"50px", "top":"50px"});
        }


//        var main = $(document);
//        var main2 = window.document;
        var main = _parent.parent();

        var main2 = window;

    function init_events(){
        parent.on('click', function(){update_cursor(); return false; });
        parent.on('keyup', function(){update_cursor(); return false; });

	    toolbar.on('click', '.btn.cancel_body', cancel);

//        toolbar.on('click', '.news_add, .news_draft', news_add);
        main.on('click', '.news_add, .news_draft', news_add);

        toolbar.on('webkitspeechchange','.mic', show_mic);
        toolbar.on('click','.mic', function(){ $(this).val(''); });
//        toolbar.on('change','.mic', function(){show_mic(); return false; });
        toolbar.on('click', '.btn.img', function(){show_img(); return false; });
        toolbar.on('click', '.btn.film', function(){text_film(); return false; });

//        toolbar.on('click', '.btn.copy', function(){
//            var r = document.getSelection().createRange();
//            r.execCommand('copy');
//            return false;
//        });
//        toolbar.on('click', '.btn.paste', function(){
//            var r = window.clipboardData.getData('Text');
//            alert(r)
//            r.execCommand('paste');
//            return false;
//        });

        toolbar.on('click', 'ul.font_size li', function(){
            //alert('btn click');
            var fs = $(this).closest('li').text();
            var doc = document;
            var text = get_select();
            var tag = doc.createElement('span');
            var sel2 = text.getRangeAt(0); //получаем выделение
            var sel = sel2.extractContents(); //вырезаем из него контент
            tag.appendChild(sel); // вставляем контент в тег
            sel2.insertNode(tag); // вставляем кат с контентом туда где было выделение.
            tag.style.fontSize=fs;
            //return false;
        });
        toolbar.on('click', 'ul.h li', function(){
            var tag_ = $(this).closest('li').text();
            var doc = document;
            var text = get_select();
            var tag = doc.createElement(tag_);
            var sel2 = text.getRangeAt(0);
            var sel = sel2.extractContents();
            tag.appendChild(sel);
            sel2.insertNode(tag);
            //return false;
        });
//        $('.btn.font_size li').click(function(){
//            return false;
//        });
        toolbar.on('click', '.btn.eraser', function(){
            var range = window.getSelection().getRangeAt(0);
            var content = range.extractContents();
            var div = document.createElement('div');
            div.appendChild(content);
            div.innerHTML = div.innerHTML.replace(/style\s*=\s*\"[^\"]*\"/g,'');
            range.insertNode(div);
            return false;
        });
        toolbar.on('click', '.btn.bold', function(){text_r('b'); return false; });
        toolbar.on('click', '.btn.italic', function(){text_r('i'); return false; });
        toolbar.on('click', '.btn.underline', function(){text_r('u'); return false; });
        toolbar.on('click', '.btn.strikethrough', function(){text_r('s'); return false; });
        toolbar.on('click', '.btn.code', function(){
            text_r('article');
            text_r('code');
            return false;
        });

        toolbar.on('click', '.btn.right', function(){
            var doc = document;
            var text = get_select();
            var tag = doc.createElement('div');
            var sel2 = text.getRangeAt(0); //получаем выделение
            var sel = sel2.extractContents(); //вырезаем из него контент
            tag.appendChild(sel); // вставляем контент в тег
            sel2.insertNode(tag); // вставляем кат с контентом туда где было выделение.
            tag.style.textAlign='right';
            return false;
        });
        toolbar.on('click', '.btn.center', function(){text_r('center'); return false; });
        toolbar.on('click', '.btn.left', function(){
            var doc = document;
            var text = get_select();
            var tag = doc.createElement('div');
            var sel2 = text.getRangeAt(0); //получаем выделение
            var sel = sel2.extractContents(); //вырезаем из него контент
            tag.appendChild(sel); // вставляем контент в тег
            sel2.insertNode(tag); // вставляем кат с контентом туда где было выделение.
            tag.style.textAlign='left';
            return false;
        });

        toolbar.on('click', '.btn.link', function(){text_a(); return false; });
        toolbar.on('click', '.btn.cant', function(){text_cant(); return false; });

        toolbar.on('click', '.btn.html', function(){text_is_html(); return false; });
        toolbar.on('click', '.btn.textt', function(){html_is_text(); return false; });
}

        $('img').css({'cursor': 'pointer'});

//        if (document.createElement("input").webkitSpeech === undefined) {
//            alert("Speech input is not supported in your browser.");
//        }

//        var cursor;
        function update_cursor(){
            var text = get_select();
            cursor = text.getRangeAt(0);
        }

//        var myCodeMirror = null;

        function font_size_(){
            var fs = $(this).closest('li').text();
            var doc = document;
            var text = get_select();
            var tag = doc.createElement('span');
            var sel2 = text.getRangeAt(0); //получаем выделение
            var sel = sel2.extractContents(); //вырезаем из него контент
            tag.appendChild(sel); // вставляем контент в тег
            sel2.insertNode(tag); // вставляем кат с контентом туда где было выделение.
            tag.style.fontSize=fs;
            return tag;
        }

        function show_mic(){
            cursor.extractContents();
//            var tag = document.createElement('#text');
            var tag = document.createTextNode($(this).val());
            cursor.insertNode(tag);
//            tag.innerHTML = $(this).val()
//            cursor.setContent($(this).val());
//            var span = text_r('span');
//            $(span).text($(this).val());
        }
//        function fix_sel() {
//            sl = getSelection()
//            sel2 = sl.getRangeAt(0); //получаем выделение
//        }
//        function text_r(tag){
//            var doc = document;
//            var tag = doc.createElement(tag);
//            sel = sel2.extractContents(); //вырезаем из него контент
//            tag.appendChild(sel); // вставляем контент в тег
//            sel2.insertNode(tag); // вставляем кат с контентом туда
//            return tag
//        }



    // function init_ace() {
    //     var hh = parent.height();
	 //    cm_pane = $('<div></div>').insertAfter(parent);
    //     var ta = $('<textarea id="editor"></textarea>').appendTo(cm_pane);
    //     var editor = ace.edit("editor");
    // }
    function init_codemirror() {
        var hh = parent.height();
	    cm_pane = $('<div></div>').insertAfter(parent);
        var ta = $('<textarea></textarea>').appendTo(cm_pane);
        myCodeMirror = CodeMirror.fromTextArea(ta.get(0), {
//              var myCodeMirror = CodeMirror.fromTextArea(ta, {
                lineNumbers: true,               // показывать номера строк
                matchBrackets: true,             // подсвечивать парные скобки
                mode:  "htmlmixed",
                theme: "solarized",
//            theme: "twilight", theme: "ambiance", theme: "eclipse", theme: "lesser-dark", theme: "monokai",
            //mode: 'application/x-httpd-php', // стиль подсветки
                indentUnit: 4,                    // размер табуляции
                tabSize: 4,
                indentWithTabs: true,
                lineWrapping: true,
                gutter: true, // полоса слева
                fixedGutter: true,
                onChange: function(){
                ta.val(myCodeMirror.getValue());

            }
        });
        myCodeMirror.setSize("100%", "100%");
        myCodeMirror.setSize(500, 500);
//        myCodeMirror.setSize(null, '1000px');
        ta.data('rich_edit', myCodeMirror);
//        cm_pane.css({'visibility': 'hidden'});
        myCodeMirror.setSize(null, hh+'px');
   	    cm_pane.css({'visibility':'hidden', 'height':'0', 'min-height':'0'});

	}


     function text_is_html(){
        toolbar.find('.html').removeClass('btn-primary').addClass('btn-warning');
        toolbar.find('.text_html').addClass('textt').removeClass('html');
        toolbar.find('.text_html').text('Редактор');
        toolbar.find('.textt').text('Редактор');

        var htm = parent.html();
        myCodeMirror.setValue(htm);
        parent.hide();
        cm_pane.css({'visibility': 'visible', 'height': 'auto', 'min-height':'150px'});
        myCodeMirror.setSize("100%", "100%");

    }

    function html_is_text(){
        toolbar.find('.textt').removeClass('btn-warning').addClass('btn-primary');
        toolbar.find('.textt').text('HTML');
        toolbar.find('.text_html').removeClass('textt').addClass('html');

        var htm = myCodeMirror.getValue();
        parent.html(htm);
	    parent.show();
   	    cm_pane.css({'visibility': 'hidden', 'height': '0', 'min-height':'0'});
        myCodeMirror.setSize("100%", "100%");
    }



        function text_cant(){

        }
        function text_a(){
            var tag = text_r('a');
            var link = prompt('Введите адрес ссылки');
            $(tag).attr('href', link);
        }
        function text_film(){
            // wrapper_command('Undo', '');
            var dialog = $(
                '<div class="modal" style="margin-top:'+options.margin_top+';">'+ //100
                    '<div class="modal-dialog">'+
                        '<div class="modal-content">'+
                            '<div class="modal-header">'+
                            '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Вставка кода</h3></div>' +
                            '<div class="modal-body" ></div>' +
                            '<div class="modal-footer"><div class="btn-group">'+
                            '<span  class="btn yes btn-primary" data-dismiss="modal">Вставить</span>'+
                            '<span  class="btn cancel btn-danger" data-dismiss="modal">Закрыть</span>'+
                            '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>'
            ).appendTo('body');
//            $('<label>'+dao.ct('Код')+'</label>').appendTo(mainw);
            var fd = document;
            var tube = $('<textarea class="form-control" name="tube" style="height:200px; width:400px;">').appendTo(dialog.find('.modal-body'));
            dialog.modal();
            dialog.on('click', '.btn.yes', function(){
                var aaa = tube.val();
                var div_img = fd.createElement('div');
                cursor.insertNode(div_img); // вставляем кат с контентом туда где было выделение.
                div_img.innerHTML = aaa;
            });

        }
        function show_img(){

            var file_manager = new dao.file_processor({
//                url: options.url,
                id: options.id,
                has_toolbar: true,
                on_select: function(url, tag){
                    text_i(url, tag)
                }
            });
            file_manager.show(options.doc_id);
//            e.stopPropagation();
            return false;
        }

        function text_r(tag){
//            var doc = parent;
            var doc = document;
            var text = get_select();
            var tag = doc.createElement(tag);
            var sel2 = text.getRangeAt(0); //получаем выделение
            var sel = sel2.extractContents(); //вырезаем из него контент
            tag.appendChild(sel); // вставляем контент в тег
            sel2.insertNode(tag); // вставляем кат с контентом туда где было выделение.
            return tag
        }


        function text_i(url, tagg){
            var doc = document;
            var tag = doc.createElement(tagg);
            tag.setAttribute('src', url);
            if(tagg=='video'){
                tag.setAttribute('controls', "controls");
                tag.setAttribute('loop', "loop");
                tag.setAttribute('tabindex', "0");
                tag.setAttribute('height', '390px');
                tag.setAttribute('width', '640px');
            }
            if (cursor){
                cursor.insertNode(tag); // вставляем кат с контентом туда где было выделение.
            }
        }

        function get_select(){
//            var cw = parent;
            var cw = main2;
            var text = '';
            if (cw.getSelection) {
                text = cw.getSelection();
            } else if (cw.getSelection) {
                text = cw.getSelection();
            } else if (cw.selection) {
                text = cw.selection;
            }
            return text;
        }

//        main.click(function(e){
//            var target = $(e.target);
//            if (target.closest('.btn.cancel').length) {
//                hide_te();
//            }
//        });



//        var body = document.getElementsByTagName('body')[0];
//        var html = $(parent)[0];
        var bbb = undefined;
        function img_resize(){ }


        function news_add(){
            var is_draft = $(this).is('.news_draft');
	        var body;
	        if (parent.is(':visible')) body = parent.html();
	        else body = myCodeMirror.getValue();

            if(typeof(options.success) == 'function'){
                options.success(body, is_draft);
            }
            return false;
        }

        var instance = {
            'show':show,
            'hide':hide_te
        };
        return instance;
    }
})(jQuery);//(function()








