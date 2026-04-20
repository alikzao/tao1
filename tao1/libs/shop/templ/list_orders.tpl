
{% set description = 'Health products' %}
{% extends "shop.tpl" %}
{% block shop %}


<div class="row" style="">
	<h3>Order list</h3>
{#            {{ web_order  }}#}
{#            {{ web_order_ware  }}#}
    <div class="" style="margin-top:20px;">
    {% for doc1 in web_order %}
        <dl class="dl-horizontal">
            <dt> Date</dt><dd style="color:#ff8241; font-weight:bold;"> {{ format_date(doc1.doc.date[:10], '%d %b %Y') }} </dd>
            <dt> Phone</dt><dd style="color:#5b803f;">  {{ doc1.doc.phone}} </dd>
            <dt> Amount</dt><dd style="color:#5b803f;">  {{ doc1.doc.amount}} <span style="color:black;"> &nbsp;UAH</span></dd>
            <dt> Name</dt><dd style="color:#5b803f; ">  -- </dd>
        </dl>
        <div class="table-responsive">
            <table class="table">
                <thead><tr><th>Product name</th><th>Qty</th><th>Cost</th></tr></thead>
                <tbody>
        {% for doc in web_order_ware %}
            {% if doc1.id == doc.owner%}
                {% for doc_ware in ware %}
                    {% if doc.doc.title == doc_ware.id %}
                        <tr><td style="width:350px;"> {{ ct(doc_ware.doc.title) }}</td> <td>{{ doc.doc.quantity }} pcs</td>
                            <td>{{ doc_ware.doc.price }} UAH</td></tr>
                    {% endif %}
                {%  endfor%}

            {% endif %}

        {% endfor %}
                </tbody>
            </table>
        </div>
        <div style="width:100%; border-top:1px solid black;"></div>
        <br/>
        <br/>
        <br/>
    {% endfor %}
    </div>
</div>





{% endblock %}








