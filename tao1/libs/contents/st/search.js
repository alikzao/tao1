$('.search').attr('waiting-input', 'true')
    .css('color', '#708090')
    .val("search")
    .focus(function() {
        if ($(this).attr('waiting-input') == 'true')
            $(this).attr('waiting-input', 'false').css('color', 'black').val('');
    }).blur(function() {
        if ($(this).val() == '')
            $(this).attr('waiting-input', 'true').css('color', '#708090').val("search");
    });