(function(){
    var f = function(){
        var defaults = {};
        return {
            site_menu: function(parent, params){
				
				var options = $.extend({}, defaults, params);
			    $('.site_menu').css({ 'padding': '0px', 'margin': '0px'});
				
			    $('#lm').addClass('ui-widget-content ui-corner-all').css({ 'height': '100%', 'width':'100%'}).find('.site_menu').css({ 'margin': '5px', 'font-size': '14px'});

				$('#tm').addClass('ui-state-default').css({ 'height': 'auto'});

				if(options['type'] == 'horizontal'){
					var first_li = { 'display': 'inline-table', 'padding': '0px 10px', 'border': '1px solid transparent', 'width': 'auto', 'font-size': '14px', 'line-height': '30px'};
					var all_ul =   { 'position': 'absolute', 'padding': '0px', 'margin': '0px'};
					var all_ul_ul ={ 'top': '0px', 'left': '120px'};
					var all_li =   { 'position': 'relative', 'list-style-type': 'none', 'z-index': '10', 'text-align': 'left'};
					var all_li_li ={ 'display': 'block', 'width': '120px'};
				}else if(options['type'] == 'vertical'){
					var first_li = { 'display': 'block', 'width': '100px'};
					var all_ul =   { 'position': 'absolute', 'padding': '0px', 'top': '0px', 'left': '190px', 'margin': '0px'};
					var all_ul_ul = false;
                    var all_li =   { 'position': 'relative', 'list-style-type': 'none', 'z-index': '10', 'text-align': 'left', 'padding': '4px', 'width': '180px'};
					var all_li_li ={ 'display': 'block'};
				}
				
			    parent.find('.site_menu > li').css( first_li );
			
			    parent.find('.site_menu ul').css( all_ul ).addClass('ui-widget-content');
				
			    if(all_ul_ul) parent.find('.site_menu ul ul').css( all_ul_ul );
				
			    parent.find('.site_menu li').css( all_li );
				
			    parent.find('.site_menu li li').css( all_li_li );
				
				if (options['type'] == 'vertical') {
					var div_icon = $('<div class="ui-icon ui-icon-triangle-1-e" style="position:absolute; top:0px; right:0px;"></div>');
    			    parent.find('.submenu').parent().append(div_icon);
				}else if(options['type'] == 'horizontal'){
				    var div_icon = $('<div class="ui-icon ui-icon-triangle-1-e" style="position:absolute; top:0px; right:0px;"></div>');
                    parent.find('.submenu .submenu ').parent().append(div_icon);
				}

			    parent.find('.site_menu li ul li').hide();
			    parent.find('.site_menu li').hover(
			        function() {
						$(this).addClass('ui-widget-header');
						$(this).find('ul:first > li').show();
			        },
			        function() {
			            $(this).find('ul li').hide();
						$(this).removeClass('ui-widget-header');
			        }
			    );
				
            }
        }
    };
    $.extend(   window.dao, f(jQuery) );
})();
