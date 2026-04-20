
{% set description = 'Cart' %}
{% extends "shop.tpl" %}
{% block shop %}





<div class="row row_basket" >
    <dl class="dl-horizontal">
        {% if not basket %}
            <h3 style="margin:40px;"><span class="label label-warning" >Cart is empty</span></h3>
        {% else %}
            <div class="basket_list" style="margin:40px;">
                <div class="btn btn-default check_shop"> <i class="icon-check" style="color:green;"></i> &nbsp;Checkout</div>
                <div class="btn btn-default clean_basket"><i class="icon-remove" style="color:red;"></i> &nbsp;Clear cart</div>
            </div>
            {% for i in basket  %}
                <dt>Product:</dt>      <dd>{{ basket[i].title }}</dd>
                <dt>Quantity:</dt> <dd>{{ basket[i].quantity }}</dd>
            {% endfor %}
            <hr/>
            <dt>Amount:</dt> <dd>{{ amount|float }} UAH</dd>

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
                    $('<h3 style="margin:40px;"><span class="label label-warning" >Cart is empty</span></h3>').appendTo('.row_basket');

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
                            '<button class="close" data-dismiss="modal">×</button><h3 class="modal-title">Callback</h3></div>' +
                            '<div class="modal-body" ><input class="form-control" type="text" placeholder="Phone number for contact"/></div>' +
                            '<div class="modal-footer"><div class="btn-group">'+
                            '<span  class="btn btn-default cancel" data-dismiss="modal">Close</span>'+
                            '<span  class="btn link1 btn-primary" data-dismiss="modal">Send</span>'+
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
                            alert('Your order has been added');
                        }
                     },error:function(e){
                        alert('Error');
                    }
                });

           });
    }
</script>





{% endblock %}
