
{% extends "layout.tpl" %}
{% block content %}



<div class="container main_">
  	<div class="row">

        <div class="col-xs-2">
            <ul id="sidebar" class="nav nav-stacked affix">
                <li class="navbar-header">
                    <a class="brand" href="/">
                        <img src="/static/static/img/img-logo-heritage.png" alt="nexus" width="120"/>
                    </a>
                </li>
                <li class=""><a href="/question">   <i class="icon-question-sign"></i>&nbsp; Вопрос-ответ</a></li>
                <li class=""><a href="/reishi">     <i style="color:#a00000;" class="icon-youtube-sign"></i> &nbsp;Гриб Рейши</a></li>
                <li class=""><a href="/kletchatka"> <i style="color:green;"class="icon-picture"></i> &nbsp;Клетчатка</a></li>
                <li class=""><a href="/center">     <i style="color:#bc8626;"class="icon-user"></i> &nbsp;Контакты</a></li>
                <li class="callback"><a href="#">   <i style="color:#535966;" class="icon-share-sign"></i> &nbsp;Обратный звонок</a></li>
                <li class=""><a href="/list/basket"><i style="color:#336600;" class="icon-shopping-cart"></i> &nbsp;Моя корзина</a></li>
                <li class=""><a href="#">           <i class="icon-phone"></i> &nbsp;+38 062 387 06 06</a></li>
            </ul>
        </div>


        <div class="col-xs-10">
            <div class="row row_basket" style="">

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
                        <dt>Сумма:</dt> <dd>{{ amount|float }}</dd>

                    {% endif %}
                </dl>

            </div>
        </div>



    </div>
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
                    url: '/basket/add_order', type:'POST', dataType:'json', data:{ phone:phone, owner:owner },
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