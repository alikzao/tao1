


<div class="btn-group basket">
    <button type="button" class="buy dropdown-toggle" data-toggle="dropdown" >
        <span class="caret"></span> &nbsp; <i class="icon-shopping-cart"></i> &nbsp; КУПИТЬ
    </button>
    <ul class="dropdown-menu" role="menu">
        <li class="callback"><a href="#"><i class="icon-share-alt"></i> &nbsp;Обратный вызов</a></li>
        <li class="add_ware" ware_id="{{ doc.id }}" title="{{ ct( doc.doc.title) }}"><a href="#"><i class="icon-shopping-cart"></i> &nbsp;Положить в корзину</a></li>
        <li class="check_shop" ware_id="{{ doc.id }}" title="{{ ct( doc.doc.title) }}"><a href="#"><i class="icon-check"></i> &nbsp;Оформить заказ</a></li>
        <li class="#"><a href="/list/basket"><i class="icon-list-ul"></i> &nbsp;Посмотреть корзину</a></li>
{#        <li class="divider"></li>#}
{#        <li><a href="#">123</a></li>#}
    </ul>
</div>


<script type="text/javascript">
$(function(){
    var basket = $('.basket');

{#    basket.on('click', '.add_ware', add_basket);#}
{#    basket.find('.add_ware').click(add_basket);#}

{#    basket.find('.add_ware').click(function(e){#}
{#    basket.on('click', '.add_ware', function(e){#}
    var doc_id = '{{ doc.id }}';
    basket.on('click', '.add_ware[ware_id='+doc_id+']', add_basket);
    basket.on('click', '.check_shop[ware_id='+doc_id+']', check_shop);

    function add_basket(){
{#        console.log('33333333333333333');#}
        var doc_id = '{{ doc.id }}';
        var title = '{{ ct(doc.doc.title) }}';
{#        var ware_id = $(this).parent().closest('.ware_id').attr('ware_id');#}
{#        console.info(ware_id);#}
        var quantity = 1;
{#        var title = $(this).closest('.ware_id').attr('title');#}
{#        var title = $('.ware_id').attr('title');#}
{#        console.info(title);#}
        var dialog = $(
        	'<div class="modal">'+
        		'<div class="modal-dialog">'+
        			'<div modal_id="{{ doc._id }}" class="modal-content" style="width:80%; height:80%;">'+
        				'<div class="modal-header">'+
        				'<button class="close" data-dismiss="modal">×</button><h3 class="modal-title" style="color:#c01213;">Добавить в корзину</h3></div>' +
        				'<div class="modal-body" >' +
                            '<div class="row">' +
	                            '<div class="col-xs-6">' +
	                                '<img style="max-width:160px; max-height:160px;" src="/img/des:ware/{{doc._id}}/{{ img1[0] }}/img">' +
	                                '<h3 style="color:#00a1cd; font-size:14px; margin:20px 0;">{{  ct( doc.doc.title) }} </h3>' +
	                                '<span style="font-size:17px; padding-top:20px; margin-top:20px;"> <span style="font-size:13px;">Цена:</span> {{ doc.doc.price }} Грн./{{ doc.units }} </span><br>' +
                    '<span style="border-bottom:1px dotted; font-size:11px">Оптовая цена:</span> <span style="font-size:11px">{{ doc.doc.price_opt }} Грн./{{ doc.units }} <br>'  +
                                        '<span style="font-size:10px;">при заказе от {{ ct(doc.doc.count_opt) }} {{ doc.units }}</span> </span>'+
	                            '</div>' +
	                            '<div class="col-xs-6">' +
	                                '<span style="color:grey;"> Количество ({{ doc.units }})</span>' +
                                    '<div class="input-group number-spinner" spinner_id="{{ doc._id }}" style="margin:20px 0;">'+
										'<span class="input-group-btn">'+
											'<button class="btn btn-default" data-dir="dwn"><span class="glyphicon glyphicon-minus"></span></button>'+
										'</span>'+
										'<input type="text" class="form-control text-center quantity_ware" value="1">'+
										'<span class="input-group-btn">'+
											'<button class="btn btn-default" data-dir="up"><span class="glyphicon glyphicon-plus"></span></button>'+
										'</span>'+
									'</div>'+
	                                '<span style="color:grey;"> К оплате: ' +
                                        '<span class="count_pay" style="color:green;">{{ doc.doc.price }}</span>  '+
                                        '<span style="visibility:hidden; color:blue;" class="count_pay_opt">{{ doc.doc.price_opt }}</span> '+
                                        '<span> грн.</span> '+
                                    '</span>' +
{#	                                '<span style="color:grey;"> К оплате: <span class="count_pay_opt">{{ doc.doc.price_opt }}</span></span>' +#}
	                                '<hr>' +
	                                '<div style="color:#00a1cd;">Электротек</div>' +
	                                '<div style="color:grey;"><i class="icon-phone"></i> +380 (99) 039-16-03 </div>' +
	                                '<div style="color:grey;"><i class="icon-phone"></i> +380 (68) 439-41-16 </div>' +
	                            '</div>'+

                            '</div>' +
                        '</div>' +
        				'<div class="modal-footer"><div class="btn-group">'+
        				'<span  class="btn yes btn-warning" data-dismiss="modal">Добавить в корзину</span>'+
        				'<span  class="btn cancel btn-default" data-dismiss="modal">Отменить</span>'+
        				'</div>' +
        				'</div>' +
        			'</div>' +
        		'</div>' +
        	'</div>'
        ).appendTo('body');
{#        var tube = $('<textarea name="tube" style="height:200px; width:400px;">').appendTo(dialog.find('.modal-body'));#}
        dialog.modal();
        dialog.on('click', '.btn.yes', function(){
            quantity = $('.quantity_ware').val();
            console.log(quantity);
	        $.ajax({
	            url: '/basket/add', type: 'POST', dataType: 'json',
	            data: {
	                ware_id: doc_id,
	                quantity: quantity
	            },
	            beforeSend: function(){	 },
	            success: function(answer){
	                if (answer.result == 'ok') {
	                    alert('Товар '+title+' добавлен в корзину');
	                }else{
	                    console.error(dao.translate('ware_not_basket'));
	                    alert(''+dao.translate('ware_not_basket')+'');
	                }
	            }
	        });
        });
    }

    function check_shop(){
        var par = {'user':'user' };
        var owner = 'user'
         var dialog = $(

                '<div class="modal">'+
                    '<div class="modal-dialog">'+
                        '<div class="modal-content">'+
                            '<div class="modal-header">'+
                            '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Обратный звонок</h3></div>' +
                            '<div class="modal-body" ><input class="form-control" type="text" placeholder="Номер телефона для связи"/></div>' +
                            '<div class="modal-footer"><div class="btn-group">'+
                            '<span  class="btn btn-default cancel" data-dismiss="modal">Закрыть</span>'+
                            '<span  class="btn link1 btn-primary" data-dismiss="modal">Отправить</span>'+
                            '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>'

            ).appendTo('body');
            dialog.modal();
            dialog.on('click', '.btn.link1', function(){
                var phone = dialog.find('.modal-body input').val();
                $.ajax({
                    url: '/basket/add_order', type:'POST', dataType:'json', data:{ phone:phone, basket:'true', owner:owner },
                     success: function(data){
                        if(data.result == 'ok'){
                            alert('Ваш заказ добавлен');
                        }
                     },error:function(e){
                        console.error(e.responseText);
{#                        alert('Ошибка');#}
                    }
                });

           });
    }

{#    var price = 0.0;#}
{#    var price_opt = 0.0;#}
{#    var old_price = 0.0;#}
{#    var old_price_opt = 0.0;#}

    $(document).on('hidden.bs.modal', function() {
        $(this).removeData('bs.modal');
{#        price = 0.0;#}
{#        price_opt = 0.0;#}
{#        old_price = 0.0;#}
{#        old_price_opt = 0.0;#}
{#        $("[modal_id='{{ doc._id }}']").find('.count_pay').text({{ doc.doc.price }});#}
{#        $("[modal_id='{{ doc._id }}']").find('.count_pay_opt').text({{ doc.doc.price_opt }});#}
        $("[modal_id='{{ doc._id }}']").find('.count_pay').text('');
        $("[modal_id='{{ doc._id }}']").find('.count_pay_opt').text('');
    });


{#    $('.number-spinner').find('input').on('keyup', function(e){#}
    $('[spinner_id="06bcdd34736043db9ceed922f4c26a0d"] input');
    $(document).on('keyup', '[spinner_id="{{ doc._id }}"] input', function(e){
        var $this = $(this);
		setTimeout(function(){
	        console.log('key upped');
	        var count_pay     = $('.count_pay');
	        var count_pay_opt = $('.count_pay_opt');
	        var newVal    = $this.val().trim();
	        var price     = parseFloat({{ doc.doc.price     }});
	        var price_opt = parseFloat({{ doc.doc.price_opt }});
{#	        var price     = parseFloat($('.count_pay').text());#}
{#	        var price_opt = parseFloat($('.count_pay_opt').text());#}

    		var count_opt = parseFloat({{ ct(doc.doc.count_opt) }});
            if( isNaN(count_opt)){ count_opt = 0.00; }

	        //присваиваем значения нужные
	        count_pay.text((newVal*price).toFixed(2));
	        count_pay_opt.text((newVal*price_opt).toFixed(2));

	        if(count_opt != 0 && newVal >= count_opt){
	            count_pay_opt.css({'visibility':'visible'});
	            count_pay.css({'visibility':'hidden'});
	        }else if(newVal < count_opt){
	            count_pay_opt.css({'visibility':'hidden'});
	            count_pay.css({'visibility':'visible'});
	        }
		}, 1250);
    });

	$(document).on('click', '[spinner_id="{{ doc._id }}"] button', function () {
        console.log('2 --- old_price=>', old_price, 'old_price_opt=>', old_price_opt, 'newVal=>', newVal);
{#        console.log('1 --- price=>', price, 'price_opt=>', price_opt, 'newVal=>', newVal);#}
		var btn = $(this);
        var count_pay     = $('.count_pay');
        var count_pay_opt = $('.count_pay_opt');
        var oldValue = btn.closest('.number-spinner').find('input').val().trim();
        var old_price     = parseFloat($('.count_pay').text().trim());
        var old_price_opt = parseFloat($('.count_pay_opt').text().trim());
        console.log('2 --- old_price=>', old_price, 'old_price_opt=>', old_price_opt, 'newVal=>', newVal);

        var newVal = 0;
        var price     = {{ doc.doc.price     }};
        var price_opt = {{ doc.doc.price_opt }};

		var count_opt = parseFloat({{ ct(doc.doc.count_opt) }});
        if( isNaN(count_opt)){ count_opt = 0.00; }

{#		console.log({{ ct(doc.doc.count_opt) if count_opt in doc.doc else 0.00 }});#}
{#		console.log({{ ct(doc.doc.count_opt) }});#}

        console.log('2 --- price=>', price, 'price_opt=>', price_opt, 'newVal=>', newVal);
		if (btn.attr('data-dir') == 'up') {
            newVal    = parseInt(oldValue)      + 1;
            price     = parseFloat(old_price)     + price;
            price_opt = parseFloat(old_price_opt) + price_opt;
{#            console.log('if===>', price, newVal, count_opt)#}
        }
		else {
			if (oldValue > 1) {
                newVal    = parseInt(oldValue)      - 1;
                price     = parseFloat(old_price)     - price;
                price_opt = parseFloat(old_price_opt) - price_opt;
{#                console.log('if===>', price, newVal, count_opt)#}
            } else {
                newVal = 1;
            }
		}
        console.log('3 --- price=>', price, 'price_opt=>', price_opt, 'newVal=>', newVal, 'count_opt', count_opt);
		btn.closest('.number-spinner').find('input').val(newVal);
        count_pay_opt.text(price_opt.toFixed(2));
        count_pay.text(price.toFixed(2));
		if(count_opt != 0 && newVal >= count_opt){
            count_pay_opt.css({'visibility':'visible'});
            count_pay.css({'visibility':'hidden'});
        }else if(newVal < count_opt){
            count_pay_opt.css({'visibility':'hidden'});
            count_pay.css({'visibility':'visible'});
        }
	});


});
{#    $('.callback').click(function(){#}
{#         var dialog = $(#}
{##}
{#            '<div class="modal">'+#}
{#                '<div class="modal-dialog">'+#}
{#                    '<div class="modal-content">'+#}
{#                        '<div class="modal-header">'+#}
{#                        '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Обратный звонок</h3></div>' +#}
{#                        '<div class="modal-body" ><input class="form-control" type="text" placeholder="Номер телефона для связи"/></div>' +#}
{#                        '<div class="modal-footer"><div class="btn-group">'+#}
{#                        '<span  class="btn btn-default cancel" data-dismiss="modal">Закрыть</span>'+#}
{#                        '<span  class="btn link1 btn-primary" data-dismiss="modal">Отправить</span>'+#}
{#                        '</div>' +#}
{#                        '</div>' +#}
{#                    '</div>' +#}
{#                '</div>' +#}
{#            '</div>'#}
{##}
{#        ).appendTo('body');#}
{#        dialog.modal();#}
{#        dialog.on('click', '.btn.link1', function(){#}
{#            var phone = dialog.find('.modal-body input').val();#}
{#            $.ajax({#}
{#                url: '/callback', type:'POST', dataType:'json', data:{ phone:phone },#}
{#                success: function(data){#}
{#                }#}
{#            });#}
{##}
{#        });#}
{#    });#}
{#380969446402@sms.kyivstar.net#}
</script>


