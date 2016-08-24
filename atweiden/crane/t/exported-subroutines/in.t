use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 1;

subtest
{
    my %h;

    in(%h, qw<a b c>) = 'Sea';
    is %h<a><b><c>, 'Sea', 'Is expected value';

    in(%h, qw<d e f>) = 'Bass';
    is %h<d><e><f>, 'Bass', 'Is expected value';

    in(%h, qw<d>, 0) = 'Fail?';
    is %h<d><0>, 'Fail?', 'Is expected value';

    in(%h, qw<g>, 0) = 'Maybe this time?';
    is %h<g>[0], 'Maybe this time?', 'Is expected value';

    throws-like {in(%h, qw<g h>, 10, 9, 8, 7, 6) = 'Y'},
        X::Crane::PositionalIndexInvalid,
        'In fails when Positional index invalid';

    in(%h, qw<h>) = [];
    is %h<h>, [], 'Is expected value';

    in(%h, 'h', 0, 'f') = 'Hasselhoff';
    is %h<h>[0]<f>, 'Hasselhoff', 'Is expected value';

    in(%h, 'h', 0, 'f') = 'Not Hasselhoff';
    is %h<h>[0]<f>, 'Not Hasselhoff', 'Is expected value';

    my %i;
    in(%i, qw<a b c>, *-0, *-0, *-0, *-0, *-0) = 'five';
    in(%i, qw<a b c>, *-0, *-0, *-0, *-0, *-0) = 'five again';
    is %i<a><b><c>[1][1][1][1][1], 'five', 'Is expected value';
    is %i<a><b><c>[2][1][1][1][1], 'five again', 'Is expected value';

    my %j;
    in(%j, 'a', 0, 1, *-0, 'b', 0, 'a', 2, qw<8 9 10>, *-0, 1) = 9999999;
    is %j<a>[0][1][1]<b>[0]<a>[2]<8><9><10>[1][1], 9999999, 'Is expected value';

    throws-like {in(my @a, 'a')}, X::Crane::PositionalIndexInvalid,
        'In fails when Positional index invalid';

    my %data = %TestCrane::data;
    my %legume = :instock(43), :name<black beans>, :unit<lbs>;
    in(%data, 'legumes', *-0) = %legume;
    is %data<legumes>[0]<instock>, 4, 'Is expected value';
    is %data<legumes>[1]<instock>, 21, 'Is expected value';
    is %data<legumes>[2]<instock>, 13, 'Is expected value';
    is %data<legumes>[3]<instock>, 8, 'Is expected value';
    is %data<legumes>[4]<instock>, 43, 'Is expected value';
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
