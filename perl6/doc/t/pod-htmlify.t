use v6;
use Test;
use lib 'lib';
use File::Temp;

BEGIN {
    unless (try require URI::Escape) {
        warn "URI::Escape required to run these tests";
        plan 0;
        exit;
    }
}

plan 4;

use-ok('Pod::Htmlify');
use Pod::Htmlify;

subtest {
    plan 7;

    eval_dies_ok('use Pod::Htmlify; url-munge();', "requires an argument");
    is(url-munge("http://www.example.com"), "http://www.example.com",
        "plain url string with explicit protocol");
    is(url-munge("Class::Something"), "/type/Class%3A%3ASomething",
        "type name input");
    is(url-munge("funky-routine"), "/routine/funky-routine",
        "routine name input");
    is(url-munge('&stuff'), "/routine/stuff", "identifier (sub) input");
    is(url-munge("infix<+>"), "/routine/infix%3C%2B%3E", "operator input");
    is(url-munge('$*VAR'), '$*VAR', "sigil/twigil input");
}, "url-munge";

subtest {
    plan 1;
    isnt(footer-html("/home/camelia/this_text.pod"), "", "footer text isn't empty");
}, "footer-html";

subtest {
    plan 1;

    my $test-svg = q:to/EOF/;
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
     "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <!-- Generated by graphviz version 2.38.0 (20140413.2041)
     -->
    <!-- Title: perl6&#45;type&#45;graph Pages: 1 -->
    <svg width="66pt" height="188pt"
     viewBox="0.00 0.00 66.49 188.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    </svg>
    EOF

    my ($filename, $filehandle) = tempfile;
    $filehandle.IO.spurt($test-svg);
    $filehandle.flush;

    my $expected-svg = q:to/EOF/;
    <svg width="66pt" height="188pt"
     viewBox="0.00 0.00 66.49 188.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    </svg>
    EOF
    my $svg = svg-for-file($filename);
    is($svg, $expected-svg.chomp, "SVG content extracted correctly");
}, "svg-for-file";

# vim: expandtab shiftwidth=4 ft=perl6
