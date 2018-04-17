use v6.c;

use List::MoreUtils <mode>;
use Test;

plan 6;

my $lorem = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.";

my @lorem = $lorem.comb( / \w+ | <[,.]> / );
my $n_comma = @lorem.grep( ',' ).elems;

is mode(@lorem,:scalar), $n_comma, 'is number of , the mode';
is mode(@lorem), (11,','), 'we do not have other things with that frequency';

{
    my @probes = |(1 xx 3), |(2 xx 4), |(3 xx 2), |(4 xx 7), |(5 xx 2), |(6 xx 4);
    is-deeply mode(@probes), [7, 4], "unimodal result in list context";
    is mode(@probes,:scalar), 7, "unimodal result in scalar context";
}

{
    my @probes = |(1 xx 3),|(2 xx 4),|(3 xx 2),|(4 xx 7),|(5 xx 2),|(6 xx 4),|(7 xx 3),|(8 xx 7);
    my @m = mode @probes;
    my $m = shift @m; @m = sort @m; unshift @m, $m;  # make predictable order
    is-deeply @m, [7, 4, 8], "bimodal result in list context";
    is mode(@probes,:scalar), @m[0], "bimodal result in scalar context";
}
# vim: ft=perl6 expandtab sw=4
