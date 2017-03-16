use v6;
use Test;
plan 9;

use CSS::Declarations;
use CSS::Declarations::Units;
use CSS::Declarations::Box;

my $css = CSS::Declarations.new;

$css.padding = 5pt;
$css.border-width = 3pt;
$css.margin = [1pt, 2pt, 3pt, 4pt];

my $top    = 80e0pt;
my $right  = 50e0pt;
my $bottom = 0e0pt;
my $left   = 0e0pt;

my $box = CSS::Declarations::Box.new( :$top, :$left, :$bottom, :$right, :$css );

is-deeply $box.Array, [$top, $right, $bottom, $left];
is $box.padding, [$top+5, $right+5, $bottom-5, $left-5];
is $box.border, [$top+8, $right+8, $bottom-8, $left-8];
is $box.margin, [$top+9, $right+10, $bottom-11, $left-12];

is-deeply $box.padding, [$box.padding-top, $box.padding-right, $box.padding-bottom, $box.padding-left];
is-deeply $box.border, [$box.border-top, $box.border-right, $box.border-bottom, $box.border-left];
is-deeply $box.margin, [$box.margin-top, $box.margin-right, $box.margin-bottom, $box.margin-left];

is-approx $box.border-width, ($box.border-right - $box.border-left);
is-approx $box.border-height, ($box.border-top - $box.border-bottom);

done-testing;
