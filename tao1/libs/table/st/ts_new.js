;(function($){
    var defaults = {}

    window.dao.scroll = function(vertical_bar_place, horizontal_bar_place, params){
        // Правильное создание нового объекта с присвоением ему значений по-умолчанию и частично указанных новых значений
        var options = $.extend({}, defaults, params);
        var aside_scroll_bar = null;
        var aside_scroll_space = null;
        var aside_scroll_caret = null;
        var bottom_scroll_bar = null;
        var bottom_scroll_space = null;
        var bottom_scroll_caret = null;
        var h_scrollSpace = 0;
        var h_scrollSize = 1;
        var v_scrollSpace = 0;
        var v_scrollSize = 1;
        var scroll_width = 0;
        var is_scrolling = false;

//        $('[proc_id="'+options.proc_id+'"] .icon-refresh').click();
        bottom_scroll_bar = $('<div style="position:absolute; top:0px; bottom:0px; left:120px; right:0px; border:1px solid #eee;"></div>').appendTo(horizontal_bar_place);
        var bottom_scroll_left = $('<div style="position:absolute; top:0px; bottom:0px; left:0px; width:18px; text-align:center; border:1px solid #eee;" class="ui-corner-left"></div>').appendTo(bottom_scroll_bar);
        bottom_scroll_left.html('◂');
        var bottom_scroll_right = $('<div style="position:absolute; top:0px; bottom:0px; right:0px; width:18px; text-align:center; border:1px solid #ccc;" class="ui-corner-right"></div>').appendTo(bottom_scroll_bar);
        bottom_scroll_right.html('▸');
        bottom_scroll_space = $('<div style="position:absolute; top:0px; bottom:0px; left:21px; right:21px; border:1px solid #ccc;" class="ui-corner-all"></div>').appendTo(bottom_scroll_bar);
        bottom_scroll_caret = $('<div style="position:absolute; top:0px; bottom:0px; background-color:#c9ad91;  left:0px; width:60px; text-align:center; border:1px solid #ccc;"  class="ui-corner-all"></div>').appendTo(bottom_scroll_space)
            .draggable({
                containment: 'parent',
                axis: 'x',
                start: function(){
                    $(this).addClass('ui-state-active');
                },
                drag: function(){
                    _updateScroll();
                },
                stop: function(){
                    $(this).removeClass('ui-state-active');
                    if(options.stopscroll){
                        options.stopscroll();
                    }
                }
            });

        bottom_scroll_left.click(function(){
            var poss = bottom_scroll_caret.position();
            if(poss.left > 0){
                poss.left -= poss.left > 30 ? 30 : poss.left;
                bottom_scroll_caret.css({'left':poss.left+'px'});
                _updateScroll();
            }
        });
        bottom_scroll_right.click(function(){
            var poss = bottom_scroll_caret.position();
            var sc_w = bottom_scroll_caret.width();
            var sp_wh = bottom_scroll_space.width();
            var sp = sp_wh - sc_w - poss.left - 2;
            if(sp > 0){
                poss.left += sp > 30 ? 30 : sp;
                bottom_scroll_caret.css({'left':poss.left+'px'});
                _updateScroll();
            }
        });


        // переинициализируем плавающие элементы сетки
        $(window).resize(function(){
            _initScroll();
        });
        //              this.bottom_scroll_caret.text('◦◦◦');
        bottom_scroll_bar.find('.ui-widget-header').hover(function(){
            $(this).addClass('ui-state-hover');
        }, function(){
            $(this).removeClass('ui-state-hover');
        });


        aside_scroll_bar = $('<div style="border:1px solid #ccc; position:absolute; top:50px; right:0px; left:0px; bottom:0px;"></div>').appendTo(vertical_bar_place);
        var aside_scroll_top = $('<div class="ui-corner-top" style="border:1px solid #ccc; position:absolute; top:0px;  right:0px; left:0px; height:18px; text-align:center;"></div>').appendTo(aside_scroll_bar);
        aside_scroll_top.html('▴');
        var aside_scroll_bottom = $('<div class="ui-corner-bottom" style="border:1px solid #ccc; position:absolute; height:18px; right:0px; left:0px; bottom:0px; text-align:center;"></div>').appendTo(aside_scroll_bar);
        aside_scroll_bottom.html('▾');
        aside_scroll_space = $('<div class="ui-corner-all" style="border:1px solid #eee; position:absolute; top:21px; right:0px; left:0px; bottom:21px;"></div>').appendTo(aside_scroll_bar);
        aside_scroll_caret = $('<div class="ui-corner-all" style="border:1px solid #eee; background-color:#c9ad91; position:absolute; top:0px; right:0px; left:0px; height:60px; text-align:center;"></div>').appendTo(aside_scroll_space)
            .draggable({
                containment: 'parent',
                axis: 'y',
                start: function(){
                    $(this).addClass('ui-state-active');
                },
                drag: function(){
                    _updateScroll();
                },
                stop: function(){
                    $(this).removeClass('ui-state-active');
                    if(options.stopscroll){
                        options.stopscroll();
                    }
                }
            });

        aside_scroll_top.click(function(){
            var poss = aside_scroll_caret.position();
            if(poss.top > 0){
                poss.top-= poss.top > 30 ? 30 : poss.top;
                aside_scroll_caret.css({'top':poss.top+'px'});
                _updateScroll();
            }
        });
        aside_scroll_bottom.click(function(){
            var poss = aside_scroll_caret.position();
            var sc_w = aside_scroll_caret.height();
            var sp_wh = aside_scroll_space.height();
            var sp = sp_wh - sc_w - poss.top - 2;
            if(sp > 0){
                poss.top+= sp > 30 ? 30 : sp;
                aside_scroll_caret.css({'top':poss.top+'px'});
                _updateScroll();
            }
        });

        aside_scroll_bar.find('.ui-widget-header').hover(function(){
            $(this).addClass('ui-state-hover');
        }, function(){
            $(this).removeClass('ui-state-hover');
        });
        // Назначаем обработчик прокрутки
        options.vertical_target.scroll(function(){
            _initScroll();
            _updateScroll();
        });
        options.horizontal_target.scroll(function(){
            _initScroll();
            _updateScroll();
        });
        reinit();

        function reinit(){
            _initScroll();
            // Инициализируем плавающие элементы сетки
            options.horizontal_target.triggerHandler('scroll');
            options.vertical_target.triggerHandler('scroll');
        }

        function _prepareScroll(){
//            $('.icon-refresh').click();

            // перед прокруткой вычисляет координаты
            var width = options.horizontal_target.width();
            var height = options.vertical_target.height();
            var scrollWidth = options.horizontal_target.get(0).scrollWidth;
            h_scrollSpace = scrollWidth - width;
            h_scrollSize = width / scrollWidth;
            var scrollHeight = options.vertical_target.get(0).scrollHeight;
            v_scrollSpace = scrollHeight - height;
            v_scrollSize = height / scrollHeight;
        }

        /**
         * Подготавливает элементы управления и приводит их в соответствие с реальным положением вещей
         */
        function _initScroll(){
            _prepareScroll();
            if (h_scrollSpace > 0) {
                var space = bottom_scroll_space.innerWidth(); // ширина линии ползунка.
                var size = Math.round(space * h_scrollSize); // получили длину самого ползунка вродебы
                if (size < 30) size = 30;
                if (size >= space - 3) size = space - 3;
                if (size >= 30) {
                    var h_space = bottom_scroll_space.innerWidth() - bottom_scroll_caret.outerWidth(); // свободное пространство
                    var h_scroll = options.horizontal_target.scrollLeft(); //
                    var left = Math.round(h_space * h_scroll / h_scrollSpace);
                    bottom_scroll_caret.css({ 'display': 'block', 'width': size + 'px', 'left': left + 'px' });
                }
            }
            else bottom_scroll_caret.css('display', 'none');
//                alert( v_scrollSpace);
            if (v_scrollSpace > 0) {
                var space = aside_scroll_space.innerHeight();
                var size = Math.round(space * v_scrollSize);
                if (size < 30) size = 30;
                if (size >= space - 3) size = space - 3;
//                        alert( options.vertical_target.scrollTop());
                if (size >= 30) {
                    var v_space = aside_scroll_space.innerHeight() - aside_scroll_caret.outerHeight();
                    var v_scroll = options.vertical_target.scrollTop();
                    var top = v_space * v_scroll / v_scrollSpace;
                    aside_scroll_caret.css({'display':'block', 'height':size + 'px', 'top':top + 'px'});
                }
            }
            else aside_scroll_caret.css('display', 'none');
        }

        function _updateScroll(){ // в соответствии с позицией бегунка выставляет положение таблички
            if (is_scrolling) return;
            is_scrolling = true;
            _prepareScroll();
            var h_space = bottom_scroll_space.innerWidth() - bottom_scroll_caret.outerWidth();
            var h_pos = bottom_scroll_caret.position().left;
            var h_back = h_space - h_pos;
            var v_space = aside_scroll_space.innerHeight() - aside_scroll_caret.outerHeight();
            var v_pos = aside_scroll_caret.position().top;
            var v_back = v_space - v_pos;
            var left;
            var top;
//                    alert( h_scrollSpace);
            if (h_scrollSpace > 0) {
                if (h_back == 0) left = h_scrollSpace;
                else {
                    left = Math.round(h_scrollSpace * h_pos / h_space);
                    if (left > h_scrollSpace) left = h_scrollSpace;
                }
                options.horizontal_target.scrollLeft(left);
            }
//                    alert(v_scrollSpace );
            if (v_scrollSpace > 0) {
                if (v_back == 0) top = v_scrollSpace;
                else {
                    top = Math.round(v_scrollSpace * v_pos / v_space);
                    if (top > v_scrollSpace) top = v_scrollSpace;
                }
                options.vertical_target.scrollTop(top);
            }
            if( options.onscroll && (v_scrollSpace>0 || h_scrollSpace>0)) options.onscroll(left, top);
            is_scrolling = false;
        }

        this.reinit = reinit;
        this.width = function(){ return scroll_width; }
        this.height = function(){ return scroll_height;}

    }
})(jQuery);//(function()








