use v6.c;

use List::MoreUtils <occurrences>;
use Test;

plan 8;

my $lorem = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.";

my @lorem = $lorem.comb( / \w+ | <[,.]> / );
my $n_comma = @lorem.grep( ',' ).elems;
my $n_dot   = @lorem.grep( '.' ).elems;
my $n_et    = @lorem.grep( 'et' ).elems;

{
    my @o = occurrences @lorem;
    is @o[0], Any, "Each word is counted";
    is @o[1], Any, "Text too long, each word is there at least twice";
    is-deeply @o[$n_comma], [','], "$n_comma comma";
    is-deeply @o[$n_dot],   ['.'], "$n_dot dot";
    is-deeply @o[$n_et],   ['et'], "$n_et et";

    @o = occurrences @lorem.grep: { /\w+/ };
    is @o.pairs.grep( *.value.defined ).map( { .key * .value } ).sum, 124,
      "Words are as many as requested at www.loremipsum.de";
}

{
    my @probes = |(1 xx 3), |(2 xx 4), |(3 xx 2), |(4 xx 7), |(5 xx 2), |(6 xx 4);
    # probes are not guaranteed to be in order, make sure they are
    my @o = occurrences(@probes).map: { .defined ?? [.sort] !! $_ };
    is-deeply @o, [Any,Any,[3,5],[1],[2,6],Any,Any,[4]],
      "occurrences of integer probes";
}

{
    my @probes = |(1 xx 3), Any, |(2 xx 4), Any, |(3 xx 2), Any, |(4 xx 7), Any, |(5 xx 2), Any, |(6 xx 4);
    # probes are not guaranteed to be in order, make sure they are
    my @o = occurrences(@probes).map: { .defined ?? [.sort] !! $_ };
    is-deeply @o, [Any,Any,[3,5],[1],[2,6],[Any],Any,[4]],
      "occurrences of integer / Any probes";
}

# vim: ft=perl6 expandtab sw=4
