use SVG;
use Test;

plan 3;

my $s = SVG.serialize('svg' => []);
ok $s ~~ / 'xmlns="http://www.w3.org/2000/svg"'/,
    'xmlns included by default' or diag $s;

$s = SVG.serialize('svg' => [
    :width(100), :height(100),
    :rect[:x<5>, :y<5>, :width<90>, :height<90>, :stroke<black>],
]);

ok $s ~~ / 'xmlns="http://www.w3.org/2000/svg"'/,
    'xmlns included by default, even for non-trivial SVG' or diag $s;
ok $s ~~ /«rect»/, 'and the rest of the SVG is also present' or diag $s;
