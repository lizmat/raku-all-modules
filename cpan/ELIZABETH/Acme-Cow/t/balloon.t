use v6.c;
use Test;
plan 20;

use Acme::Cow::TextBalloon;
pass;

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

my $x = Acme::Cow::TextBalloon.new;
$x.text("Hi.");
compare_bubbles($x.as_string, Q:to/EOB/);
 _____
< Hi. >
 -----
EOB
$x.print;

$x.think;
$x.adjust(0);
$x.text(" Hi.");
$x.over(6);
compare_bubbles($x.as_string, Q:to/EOB/);
       ______
      (  Hi. )
       ------
EOB
$x.print();

$x.adjust(0);
$x.say;
$x.over(0);
$x.text(
"A limerick packs laughs anatomical\n",
"Into space that is quite economical.\n",
"\tBut the good ones I've seen\n",
"\tSo seldom are clean\n",
"And the clean ones so seldom are comical.\n"
);

compare_bubbles($x.as_string, Q:to/EOB/);
 ___________________________________________
/ A limerick packs laughs anatomical        \
| Into space that is quite economical.      |
|         But the good ones I've seen       |
|         So seldom are clean               |
\ And the clean ones so seldom are comical. /
 -------------------------------------------
EOB
$x.print;
