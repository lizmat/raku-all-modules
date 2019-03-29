use v6.c;
use Test;

plan 30;

use Acme::Cow;

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

my $x = Acme::Cow.new;
$x.text('Hi.');
compare_bubbles($x.as_string, Q:to/EOC/);
 _____
< Hi. >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
EOC
$x.print;

$x.think;
compare_bubbles($x.as_string, Q:to/EOC/);
 _____
( Hi. )
 -----
        o   ^__^
         o  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
EOC
$x.print;

$x.text(' Hi.');
compare_bubbles($x.as_string(), Q:to/EOC/);
 ______
(  Hi. )
 ------
        o   ^__^
         o  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
EOC
$x.print;
