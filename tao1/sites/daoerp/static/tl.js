(function(){
	var f = function(){
	
		var defaults = {}
		
		return {
		/**
		 * В данном случае new_plugin - это фабрика экземпляров класса
		 */
			lang_proc: function(parent, params){
			
				// Правильное создание нового объекта с присвоением ему значений по-умолчанию и частично указанных новых значений
				var options = $.extend({}, defaults, params);
//alert ('sdkfhkdj');
                parent.hover (function (){
                    $(this).find ('ul').show();
                },function (){
                    $(this).find ('ul').hide();
                });
                    
                $('#div_lang li').click (function (){
//                      alert ('ksdfhsdk');
                var lang_id = $(this).attr('lang_id');
                    switch_lang(lang_id);
                });
                function switch_lang(lang_id){
                    $.ajax({
                        type: "POST",
                        url: options.set_url,
                        data: { lang_id: lang_id, action: 'switch_lang'  },
                        dataType: "json",
                        success: function(data){
                            if (data['result'] == 'ok'){ 
                                 window.location.reload();
                            }
                        }
                    });
                }
				
				var instance = {
					show: function(doc_id){
//						show(doc_id);
					}
				}
				return instance;
			} //processor: function
		}//return
	}//f = function()
	$.extend( window.dao, f(jQuery)	);  // расширяем
})();//(function()








