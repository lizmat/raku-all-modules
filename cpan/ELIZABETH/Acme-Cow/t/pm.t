use v6.c;
use Test;
plan 12;

use Acme::Cow::Frogs;

sub compare_bubbles($a,$b) {
    my @a = split("\n", $a);
    my @b = split("\n", $b);
    is +@a, +@b;
    @a>>.chomp;
    @b>>.chomp;
    for ^@a -> $i {
        is @a[$i], @b[$i];
    }
}

my $x = Acme::Cow::Frogs.new;
$x.text('Hi.');
compare_bubbles($x.as_string, Q:to/EOC/);
                                               _____
                                              < Hi. >
                                               -----
                                              /
                                            /
          oO)-.                       .-(Oo
         /__  _\                     /_  __\
         \  \(  |     ()~()         |  )/  /
          \__|\ |    (-___-)        | /|__/
          '  '--'    ==`-'==        '--'  '
EOC
$x.print;
