;
(function($) {
    if (window.dao.te_new) return;
    window.dao.te_new = te_new;
    // Legacy comment translated from Russian.


    function te_new(_parent, params) {
        var options = $.extend({
            is_show_close: true
        }, params);
        var toolbar = null,
            back = null,
            parent = null,
            cm_pane = null;
        var cursor;
        var myCodeMirror = null;

        function show() {
            if (toolbar) return;
            console.log('show after toolbar');

            back = _parent;
            parent = $(back[0].outerHTML);
            parent.insertAfter(back);

            init_codemirror();

            back.hide();
            back.addClass('back');
            parent.addClass('parent');
            img_resize();

            parent.attr('contenteditable', 'true');
            parent.css('clear', 'both');
            draw_tolbar();
            parent.focus();
            update_cursor();
            parent.css({
                'border': '3px solid #eee',
                'border-radius': '8px'
            });
            init_events();
        }

        function cancel() {
            hide_te();
            options.cancel();
        }

        function hide_te() {
            console.log('toolbar', toolbar);
            parent.remove();
            cm_pane.remove();
            myCodeMirror = null;
            back.show();
            toolbar.remove();
            toolbar = null;

        }

        function draw_tolbar() {
            toolbar = $(
                '<div class="toolbar_live_edit" style="min-height:50px;">' +
                '<style>.toolbar_live_edit>.btn-group>*{vertical-align:top;}</style>' +
                '<div class="navbar navbar-default">' +
                '<div class="nav navbar-nav" style="padding-left:5px;padding-right:5px; text-align:center;">' +
                '<div class="ee_toolbar btn-toolbar" style="z-index:100 ">' +
                '<div class="btn-group btn-group-sm" style="margin-top:10px;">' +


                '<button class="btn btn-default bold" data-content="Bold selection for selected text" data-placement="top" rel="popover" data-trigger="hover" title="Bold text"><i class="fa fa-bold"></i></button>' +
                '<button class="btn btn-default italic" data-content="Italic selection for selected text" data-placement="top" rel="popover" data-trigger="hover" title="Italic text"><i class="fa fa-italic"></i></button>' +
                '<button class="btn btn-default underline" data-content="Underline selected text" data-placement="top" rel="popover" data-trigger="hover" title="Underline text"><i class="fa fa-underline"></i></button>' +
                '<button class="btn btn-default strikethrough" data-content="Strikethrough selected text" data-placement="top" rel="popover" data-trigger="hover" title="Strikethrough text"><i class="fa fa-strikethrough"></i></button>' +

                '<button class="btn btn-default code" data-content="Code" data-placement="top" rel="popover" data-trigger="hover" title="Code"><i class="fa fa-code"></i></button>' +

                '<button class="btn btn-default img" data-content="Open gallery for image editing" data-placement="top" rel="popover" data-trigger="hover" title="Gallery"><i class="fa fa-picture-o"></i></button>' +
                '<button class="btn btn-default film" data-content="HTML insert, used for embedding external content" data-placement="top" rel="popover" data-trigger="hover" title="HTML insert"><i class="fa fa-film"></i></button>' +
                '<button class="btn btn-default link" data-content="Create links" data-placement="top" rel="popover" data-trigger="hover" title="Links"><i class="fa fa-link"></i></button>' +
                (document.createElement("input").webkitSpeech !== undefined ?
                    '<input class="input-sm mic" data-placement="top" style="float:left; height:32px;width:32px; vertical-align:top;padding:0 4px; margin:0;" data-content="Speech-to-text input (Chrome only)" title="Speech input" x-webkit-speech="" speech="" type="text" name="text">' :
                    ''
                ) +
                '<br/>' +

                '<button class="btn btn-default eraser" data-content="Clear styles" data-placement="top" rel="popover" data-trigger="hover" title="Clear styles"><i class="fa fa-eraser"></i></button>' +

                '<div class="btn-group">' +
                '<button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" data-content="Font size" data-placement="top" rel="popover" data-trigger="hover" title="Font size"><i class="fa fa-font"></i>&nbsp;<span class="caret"></span></button>' +
                '<ul class="dropdown-menu font_size" role="menu">' +
                '<li><a href="#">9px</a></li>' +
                '<li><a href="#">10px</a></li>' +
                '<li><a href="#">12px</a></li>' +
                '<li><a href="#">14px</a></li>' +
                '<li><a href="#">16px</a></li>' +
                '<li><a href="#">18px</a></li>' +
                '<li><a href="#">20px</a></li>' +
                '<li><a href="#">22px</a></li>' +
                '<li><a href="#">32px</a></li>' +
                '</ul>' +
                '</div>' +

                '<div class="btn-group">' +
                '<button class="btn btn-default btn-sm  dropdown-toggle" data-toggle="dropdown" data-content="HTML headings" data-placement="top" rel="popover" data-trigger="hover" title="HTML headings"><span style="font-weight:bold;">H <span class="caret"></span></button>' +
                '<ul class="dropdown-menu h" role="menu">' +
                '<li><a href="#">h2</a></li>' +
                '<li><a href="#">h3</a></li>' +
                '<li><a href="#">h4</a></li>' +
                '<li><a href="#">h5</a></li>' +
                '<li><a href="#">h6</a></li>' +
                '</ul>' +
                '</div>' +

                '<button class="btn btn-default center" data-content="Center text" data-placement="top" rel="popover" data-trigger="hover" title="Center align"><i class="fa fa-align-center"></i></button>' +
                '<button class="btn btn-default left" data-content="Align left" data-placement="top" rel="popover" data-trigger="hover" title="Align text left"><i class="fa fa-align-left"></i></button>' +
                '<button class="btn btn-default right" data-content="Align right" data-placement="top" rel="popover" data-trigger="hover" title="Align text right"><i class="fa fa-align-right"></i></button>' +

                '<button class="btn btn-default list_ul" data-content="Numbered list" data-placement="top" rel="popover" data-trigger="hover" title="Numbered list"><i class="fa fa-list-ul"></i></button>' +
                '<button class="btn btn-default list_ol" data-content="List" data-placement="top" rel="popover" data-trigger="hover" title="List"><i class="fa fa-list-ol"></i></button>' +

                '</div>' +

                (options.is_show_close ?
                    '<div class="btn-group btn-group-sm" style="margin-top:10px;">' +
                    '<span class="btn btn-success save-body news_add" ><i class="fa fa-check fa fa-white"></i> Save</span>' +
                    '<span class="btn btn-info  draft-body news_draft" ><i class="fa fa-th fa fa-white"></i> To drafts</span>' +
                    '<span class="btn btn-danger  cancel_body" ><i class="fa fa-trash fa fa-white"></i> Cancel</span>' +
                    '</div>' :
                    '') +
                '<div class="btn-group btn-group-sm" style="margin-top:10px;">' +
                '<button type="button" class="btn btn-primary text_html html" ><i class=""></i>HTML</button>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>').insertBefore(parent);


            $('html').css({
                'position': 'relative'
            });
            $(window).on('scroll', function() {
                if (!toolbar) return;
                var aaa = toolbar.offset().top - $(window).scrollTop();
                if (aaa < 100) toolbar.find('.navbar').addClass('navbar-fixed-top').css({
                    'position': 'fixed',
                    'top': options.margin_top
                });
                else toolbar.find('.navbar').removeClass('navbar-fixed-top').css({
                    'position': 'relative',
                    'top': '0px'
                });
            });

            toolbar.find('[rel="popover"]').popover();
        }

        var main = _parent.parent();

        var main2 = window;

        function init_events() {
            parent.on('click', function() {
                update_cursor();
                return false;
            });
            parent.on('keyup', function() {
                update_cursor();
                return false;
            });

            toolbar.on('click', '.btn.cancel_body', cancel);

            main.on('click', '.news_add, .news_draft', news_add);

            toolbar.on('webkitspeechchange', '.mic', show_mic);
            toolbar.on('click', '.mic', function() {
                $(this).val('');
            });
            toolbar.on('click', '.btn.img', function() {
                show_img();
                return false;
            });
            toolbar.on('click', '.btn.film', function() {
                text_film();
                return false;
            });

            toolbar.on('click', 'ul.font_size li', function() {
                //alert('btn click');
                var fs = $(this).closest('li').text();
                var doc = document;
                var text = get_select();
                var tag = doc.createElement('span');
                var sel2 = text.getRangeAt(0); // Legacy comment translated from Russian.
                var sel = sel2.extractContents(); // Legacy comment translated from Russian.
                tag.appendChild(sel); // Legacy comment translated from Russian.
                sel2.insertNode(tag); // Legacy comment translated from Russian.
                tag.style.fontSize = fs;
            });
            toolbar.on('click', 'ul.h li', function() {
                var tag_ = $(this).closest('li').text();
                var doc = document;
                var text = get_select();
                var tag = doc.createElement(tag_);
                var sel2 = text.getRangeAt(0);
                var sel = sel2.extractContents();
                tag.appendChild(sel);
                sel2.insertNode(tag);
            });
            toolbar.on('click', '.btn.eraser', function() {
                var range = window.getSelection().getRangeAt(0);
                var content = range.extractContents();
                var div = document.createElement('div');
                div.appendChild(content);
                div.innerHTML = div.innerHTML.replace(/style\s*=\s*\"[^\"]*\"/g, '');
                range.insertNode(div);
                return false;
            });
            toolbar.on('click', '.btn.bold', function() {
                text_r('b');
                return false;
            });
            toolbar.on('click', '.btn.italic', function() {
                text_r('i');
                return false;
            });
            toolbar.on('click', '.btn.underline', function() {
                text_r('u');
                return false;
            });
            toolbar.on('click', '.btn.strikethrough', function() {
                text_r('s');
                return false;
            });
            toolbar.on('click', '.btn.code', function() {
                text_r('article');
                text_r('code');
                return false;
            });

            toolbar.on('click', '.btn.right', function() {
                var doc = document;
                var text = get_select();
                var tag = doc.createElement('div');
                var sel2 = text.getRangeAt(0); // Legacy comment translated from Russian.
                var sel = sel2.extractContents(); // Legacy comment translated from Russian.
                tag.appendChild(sel); // Legacy comment translated from Russian.
                sel2.insertNode(tag); // Legacy comment translated from Russian.
                tag.style.textAlign = 'right';
                return false;
            });
            toolbar.on('click', '.btn.center', function() {
                text_r('center');
                return false;
            });
            toolbar.on('click', '.btn.left', function() {
                var doc = document;
                var text = get_select();
                var tag = doc.createElement('div');
                var sel2 = text.getRangeAt(0); // Legacy comment translated from Russian.
                var sel = sel2.extractContents(); // Legacy comment translated from Russian.
                tag.appendChild(sel); // Legacy comment translated from Russian.
                sel2.insertNode(tag); // Legacy comment translated from Russian.
                tag.style.textAlign = 'left';
                return false;
            });

            toolbar.on('click', '.btn.link', function() {
                text_a();
                return false;
            });
            toolbar.on('click', '.btn.cant', function() {
                text_cant();
                return false;
            });

            toolbar.on('click', '.btn.html', function() {
                text_is_html();
                return false;
            });
            toolbar.on('click', '.btn.textt', function() {
                html_is_text();
                return false;
            });
        }

        $('img').css({
            'cursor': 'pointer'
        });

        function update_cursor() {
            var text = get_select();
            cursor = text.getRangeAt(0);
        }

        function font_size_() {
            var fs = $(this).closest('li').text();
            var doc = document;
            var text = get_select();
            var tag = doc.createElement('span');
            var sel2 = text.getRangeAt(0); // Legacy comment translated from Russian.
            var sel = sel2.extractContents(); // Legacy comment translated from Russian.
            tag.appendChild(sel); // Legacy comment translated from Russian.
            sel2.insertNode(tag); // Legacy comment translated from Russian.
            tag.style.fontSize = fs;
            return tag;
        }

        function show_mic() {
            cursor.extractContents();
            var tag = document.createTextNode($(this).val());
            cursor.insertNode(tag);
        }

        function init_codemirror() {
            var hh = parent.height();
            cm_pane = $('<div></div>').insertAfter(parent);
            var ta = $('<textarea></textarea>').appendTo(cm_pane);
            myCodeMirror = CodeMirror.fromTextArea(ta.get(0), {
                lineNumbers: true, // Legacy comment translated from Russian.
                matchBrackets: true, // Legacy comment translated from Russian.
                mode: "htmlmixed",
                theme: "solarized",
                // Legacy comment translated from Russian.
                indentUnit: 4, // Legacy comment translated from Russian.
                tabSize: 4,
                indentWithTabs: true,
                lineWrapping: true,
                gutter: true, // Legacy comment translated from Russian.
                fixedGutter: true,
                onChange: function() {
                    ta.val(myCodeMirror.getValue());

                }
            });
            myCodeMirror.setSize("100%", "100%");
            myCodeMirror.setSize(500, 500);
            ta.data('rich_edit', myCodeMirror);
            myCodeMirror.setSize(null, hh + 'px');
            cm_pane.css({
                'visibility': 'hidden',
                'height': '0',
                'min-height': '0'
            });

        }


        function text_is_html() {
            toolbar.find('.html').removeClass('btn-primary').addClass('btn-warning');
            toolbar.find('.text_html').addClass('textt').removeClass('html');
            toolbar.find('.text_html').text('Editor');
            toolbar.find('.textt').text('Editor');

            var htm = parent.html();
            myCodeMirror.setValue(htm);
            parent.hide();
            cm_pane.css({
                'visibility': 'visible',
                'height': 'auto',
                'min-height': '150px'
            });
            myCodeMirror.setSize("100%", "100%");

        }

        function html_is_text() {
            toolbar.find('.textt').removeClass('btn-warning').addClass('btn-primary');
            toolbar.find('.textt').text('HTML');
            toolbar.find('.text_html').removeClass('textt').addClass('html');

            var htm = myCodeMirror.getValue();
            parent.html(htm);
            parent.show();
            cm_pane.css({
                'visibility': 'hidden',
                'height': '0',
                'min-height': '0'
            });
            myCodeMirror.setSize("100%", "100%");
        }



        function text_cant() {

        }

        function text_a() {
            var tag = text_r('a');
            var link = prompt('Enter link URL');
            $(tag).attr('href', link);
        }

        function text_film() {
            // wrapper_command('Undo', '');
            var dialog = $(
                '<div class="modal" style="margin-top:' + options.margin_top + ';">' + //100
                '<div class="modal-dialog">' +
                '<div class="modal-content">' +
                '<div class="modal-header">' +
                '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Code insert</h3></div>' +
                '<div class="modal-body" ></div>' +
                '<div class="modal-footer"><div class="btn-group">' +
                '<span  class="btn yes btn-primary" data-dismiss="modal">Insert</span>' +
                '<span  class="btn cancel btn-danger" data-dismiss="modal">Close</span>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>'
            ).appendTo('body');
            // Legacy comment translated from Russian.
            var fd = document;
            var tube = $('<textarea class="form-control" name="tube" style="height:200px; width:400px;">').appendTo(dialog.find('.modal-body'));
            dialog.modal();
            dialog.on('click', '.btn.yes', function() {
                var aaa = tube.val();
                var div_img = fd.createElement('div');
                cursor.insertNode(div_img); // Legacy comment translated from Russian.
                div_img.innerHTML = aaa;
            });

        }

        function show_img() {

            var file_manager = new dao.file_processor({
                id: options.id,
                has_toolbar: true,
                on_select: function(url, tag) {
                    text_i(url, tag)
                }
            });
            file_manager.show(options.doc_id);
            //            e.stopPropagation();
            return false;
        }

        function text_r(tag) {
            var doc = document;
            var text = get_select();
            var tag = doc.createElement(tag);
            var sel2 = text.getRangeAt(0); // Legacy comment translated from Russian.
            var sel = sel2.extractContents(); // Legacy comment translated from Russian.
            tag.appendChild(sel); // Legacy comment translated from Russian.
            sel2.insertNode(tag); // Legacy comment translated from Russian.
            return tag
        }


        function text_i(url, tagg) {
            var doc = document;
            var tag = doc.createElement(tagg);
            tag.setAttribute('src', url);
            if (tagg == 'video') {
                tag.setAttribute('controls', "controls");
                tag.setAttribute('loop', "loop");
                tag.setAttribute('tabindex', "0");
                tag.setAttribute('height', '390px');
                tag.setAttribute('width', '640px');
            }
            if (cursor) {
                cursor.insertNode(tag); // Legacy comment translated from Russian.
            }
        }

        function get_select() {
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

        var bbb = undefined;

        function img_resize() {}


        function news_add() {
            var is_draft = $(this).is('.news_draft');
            var body;
            if (parent.is(':visible')) body = parent.html();
            else body = myCodeMirror.getValue();

            if (typeof(options.success) == 'function') {
                options.success(body, is_draft);
            }
            return false;
        }

        var instance = {
            'show': show,
            'hide': hide_te
        };
        return instance;
    }
})(jQuery); //(function()