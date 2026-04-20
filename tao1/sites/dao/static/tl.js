(function() {
    var f = function() {

        var defaults = {}

        return {
            /* Legacy comment translated from Russian. */
            lang_proc: function(parent, params) {

                // Legacy comment translated from Russian.
                var options = $.extend({}, defaults, params);
                //alert ('sdkfhkdj');
                parent.hover(function() {
                    $(this).find('ul').show();
                }, function() {
                    $(this).find('ul').hide();
                });

                $('#div_lang li').click(function() {
                    //                      alert ('ksdfhsdk');
                    var lang_id = $(this).attr('lang_id');
                    switch_lang(lang_id);
                });

                function switch_lang(lang_id) {
                    $.ajax({
                        type: "POST",
                        url: options.set_url,
                        data: {
                            lang_id: lang_id,
                            action: 'switch_lang'
                        },
                        dataType: "json",
                        success: function(data) {
                            if (data['result'] == 'ok') {
                                window.location.reload();
                            }
                        }
                    });
                }

                var instance = {
                    show: function(doc_id) {
                        //						show(doc_id);
                    }
                }
                return instance;
            } //processor: function
        } //return
    } //f = function()
    $.extend(window.dao, f(jQuery)); // Legacy comment translated from Russian.
})(); //(function()