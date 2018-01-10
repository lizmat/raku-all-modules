jQuery(function ($) {
    setup_nodes();
});

function setup_nodes() {
    $('body').css({'height': document.body.scrollHeight + 'px'});
    $('.node-with-kids').on('click', function(e) {
        e.stopPropagation();
        console.log("meow");
        $(this).find('> ul').toggle('fast', function() {
            $(this).parent('.node-with-kids').toggleClass('collapsed');
        });
    });
}
