(function(){
	var f = function(){
	
		var defaults = {}
		
		return {
		/**
		 * В данном случае new_plugin - это фабрика экземпляров класса
		 */
			basket_proc: function(target, params){
			 
				// Создание нового объекта с присвоением ему значений по-умолчанию и частично указанных новых значений
				var options = $.extend({}, defaults, params);
				var quantity = null;
				var ware = null;
				var mainw = $('<div/>').css({
					'position':'relative',
					'height': '600px',
					'width': '600px'
				});
				//инициализация диалога для
				var dialog = $("<div></div>");
				var dialog_perform = $("<div></div>");
				dialog.dialog({
					bgiframe: true, autoOpen: false, height: 500, width: 300, modal: true,
					buttons: {
						'Отмена': function(){ $(this).dialog('close'); }
					}
				});
				//инициализация аякса для показа количества товара в корзине при загрузке страницы
				$.ajax({
					url: '/basket', type: 'POST', dataType: 'json',
					data: { },
					beforeSend: function(){  },
					success: function(answer){
						if (answer.result == 'ok') {
							target.find('.count_ware').text(answer.quantity);
							ware = answer.basket;
							show_basket();
//							 dao.vd(answer);
						}
					}
				});
				
				function add_basket(ware_id, quantity){
//					dao.vd(options);
					$.ajax({
						url: '/basket/add', type: 'POST', dataType: 'json',
						data: {
//							proc_id: 'proc_id',
							ware_id: ware_id,
							quantity: quantity
						},
						beforeSend: function(){	 },
						success: function(answer){
							dao.vd(answer);
							if (answer.result == 'ok') {
								target.find('.count_ware').text(answer.quantity);
								ware = answer.basket;
								show_basket();
							}else{
								alert(''+dao.translate('ware_not_basket')+'')
							}
						}
					});
				}
				
				function show_dialog_basket(){
					dialog.dialog('open');
				}
				
				function show_basket(){
					dialog.empty();
					var form = $('<form><form>').appendTo(dialog);
					var formbody = $('<fieldset></fieldset>').appendTo(form);
					var nest = $('<div class="nest"></div>').appendTo(formbody);
					var amount = 0;
					for (var i in ware) {
						$('<label>'+dao.translate('ware')+': '+ware[i]['title']+'</label>').appendTo(nest);
						$('<label>'+dao.translate('quantity')+': '+ware[i]['quantity']+'</label>').appendTo(nest);
						amount += ware[i]['quantity']*ware[i]['price'];
//						count_price++;
					}
					$('<label>'+dao.translate('amount')+': '+amount+'</label>').appendTo(nest);
					$('<div class = "proc_check ui-corner-all ui-state-default">'+dao.translate('checkout')+'</div>').appendTo(nest);
					$('<div class = "proc_check ui-corner-all ui-state-default">'+dao.translate('Очистить')+'</div>').appendTo(nest);
				}
				
				function clean_basket(ware_id){
					$.ajax({
						url: '/basket/clean', type: 'POST', dataType: 'json', 
						data: {  ware_id: ware_id },
						beforeSend: function(){ },
						success: function(answer){
							if (answer.result == 'ok') {
								target.find('.count_ware').text(answer.quantity);
								ware = answer.basket;
								show_basket();
							}else{
								alert(''+dao.translate('basket_not_clean')+'');
							}
						}
					});	
				}
				// Ebay.com * Amazon. com * Target.com * Walmart.com * Newegg.com * Dhgate.com
				var crn = dao.tp_site({
					url:'/view_table',
					proc_id: 'des:web_order',
					columns:options.map
				});
				function perform(){
					par = {'user':'user' };
					function add_order(owner){
						$.ajax({
							url:'/basket/add_order', type:'POST', dataType:'json',
							data:{owner:owner},
							beforeSend:function(){},
							success: function(data){
								if(data.result == 'ok'){
									alert('Ваш заказ добавлен');
                                    target.find('.count_ware').text('0');
                                    show_basket();
								}
							},
							error:function(e){ dao.vd(e); }
						});
					}
					//noinspection JSCheckFunctionSignatures
                    crn.create(par, '_', '_',  add_order);
				}
				
				var instance = {
					add_basket: add_basket,
					show_basket: show_basket,
					show_dialog_basket: show_dialog_basket,
					perform: perform,
					clean_basket: clean_basket
				}
				return instance;
			} //processor: function
		}//return
	}//f = function()
	$.extend( window.dao, f(jQuery)	);  // расширяем
})();//(function()








