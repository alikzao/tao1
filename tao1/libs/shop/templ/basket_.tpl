


<div class="btn-group basket">
    <button type="button" class="btn btn-success dropdown-toggle" data-toggle="dropdown">
        <span class="caret"></span> &nbsp; <i class="icon-shopping-cart"></i> &nbsp; КУПИТЬ
    </button>
    <ul class="dropdown-menu" role="menu">
        <li class="callback"><a href="#"><i class="icon-share-alt"></i> &nbsp;Обратный вызов</a></li>
        <li class="add_ware"   ware_id="{{ ware_id }}" title="{{ title }}"><a href="#"><i class="icon-shopping-cart"></i> &nbsp;Положить в корзину</a></li>
        <li class="check_shop" ware_id="{{ ware_id }}" title="{{ title }}"><a href="#"><i class="icon-check"></i> &nbsp;Оформить заказ</a></li>
        <li class="#"><a href="/list/basket"><i class="icon-list-ul"></i> &nbsp;Посмотреть корзину</a></li>
{#        <li class="divider"></li>#}
{#        <li><a href="#">123</a></li>#}
    </ul>
</div>


<script type="text/javascript">
$(document).ready(function(){
    var basket = $('.basket');

{#    var title = '{{ doc.doc.title }}';#}
{#    basket.on('click', '.add_ware', add_basket);#}
{#    basket.on('click', '.check_shop', check_shop);#}
    var doc_id = '{{ ware_id }}';
    basket.on('click', '.add_ware[ware_id='+doc_id+']', add_basket);
    basket.on('click', '.check_shop[ware_id='+doc_id+']', check_shop);

    function add_basket(){
{#        var doc_id = '{{ doc.id }}';#}
{#        var title = '{{ ct(doc.doc.title) }}';#}
{#        var ware_id = $('.ware_id');#}
{#        var doc_id = ware_id.attr('ware_id');#}
        var quantity = 1;
{#        var title = $(this).closest('.ware_id').attr('title');#}
{#        var title = ware_id.attr('title');#}
        var doc_id = '{{ ware_id }}';
        var title =  '{{ title }}';

        console.info(doc_id);
        console.info(title);
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
{#        return false;#}
{#    });#}

</script>



