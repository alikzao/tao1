
{% set description = 'Корзина' %}
{% extends "shop.tpl" %}
{% block shop %}





<div class="row row_basket" >
    <dl class="dl-horizontal">
        {% if not basket %}
            <h3 style="margin:40px;"><span class="label label-warning" >Корзина пуста</span></h3>
        {% else %}
            <div class="basket_list" style="margin:40px;">
                <div class="btn btn-default check_shop"> <i class="icon-check" style="color:green;"></i> &nbsp;Оформить заказ</div>
                <div class="btn btn-default clean_basket"><i class="icon-remove" style="color:red;"></i> &nbsp;Очистить корзину</div>
            </div>
            {% for i in basket  %}
                <dt>Товар:</dt>      <dd>{{ basket[i].title }}</dd>
                <dt>Количество:</dt> <dd>{{ basket[i].quantity }}</dd>
            {% endfor %}
            <hr/>
            <dt>Сумма:</dt> <dd>{{ amount|float }} грн.</dd>

        {% endif %}
    </dl>
</div>




<script type="text/javascript">
    var bas = $('.basket_list');
    bas.on('click', '.clean_basket', clean_basket);
    bas.on('click', '.check_shop', check_shop);

    function clean_basket(){
        $.ajax({
            url: '/basket/clean', type: 'POST', dataType: 'json',
            data: {  },
            beforeSend: function(){ },
            success: function(answer){
                if (answer.result == 'ok') {
                    $('.row_basket').empty();
                    $('<h3 style="margin:40px;"><span class="label label-warning" >Корзина пуста</span></h3>').appendTo('.row_basket');

                }else{
                    alert(''+dao.translate('basket_not_clean')+'');
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
                    url: '/basket/add_order', type:'POST', dataType:'json', data:{ phone:phone, basket:'true',owner:owner },
                     success: function(data){
                        if(data.result == 'ok'){
                            alert('Ваш заказ добавлен');
                        }
                     },error:function(e){
                        alert('Ошибка');
                    }
                });

           });
    }
</script>





{% endblock %}
