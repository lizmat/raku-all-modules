use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan(1);

subtest({
    my %data = %TestCrane::data;
    is(Crane.at(%data, 'legumes').WHAT, Array, "It's an Array");
    is(Crane.at(%data, 'legumes', 0).WHAT, Hash, "It's a Hash");
    is(Crane.at(%data, 'legumes', 1).WHAT, Hash, "It's a Hash");
    is(Crane.at(%data, 'legumes', 2).WHAT, Hash, "It's a Hash");
    is(Crane.at(%data, 'legumes', 3).WHAT, Hash, "It's a Hash");

    is(Crane.at(%data, 'legumes', 0, 'instock'), 4, "It's the value expected");
    is(Crane.at(%data, qw<legumes>, 0)<instock>, 4, "It's the value expected");
    my @path = 'legumes', 1, 'instock';
    is(Crane.at(%data, @path), 21, "It's the value expected");
    is(Crane.at(%data, |@path), 21, "It's the value expected");
    sub getpath() { ('legumes', 2, 'instock') }
    is(Crane.at(%data, getpath()), 13, "It's the value expected");
    is(Crane.at(Crane.at(Crane.at(%data, 'legumes'), 2), <instock>), 13, "It's the value expected");
    is(Crane.at(Crane.at(%data, qw<legumes>, 2), <instock>), 13, "It's the value expected");
    is(Crane.at(Crane.at(%data, <legumes>)[2], <instock>), 13, "It's the value expected");
    is(Crane.at(%data<legumes>[2], <instock>), 13, "It's the value expected");
    is(Crane.at(%data, 'legumes', 3, 'instock'), 8, "It's the value expected");
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
