use v6;
use Test;
plan 27;

use CSS::Declarations;
use Color;

my $css = CSS::Declarations.new :border-top-color<red>;
isa-ok $css.border-top-color, Color, ':values constructor';
is $css.border-top-color, '#FF0000', ':values constructor';
is ~$css, 'border-top-color:red;', 'serialization';

$css = CSS::Declarations.new :border-top-color<rgb(50%,0,0)>;
isa-ok $css.border-top-color, Color, ':values constructor';
is $css.border-top-color, '#800000', ':values constructor';
is-approx $css.border-top-color.a, 255, ':values constructor';
is ~$css, 'border-top-color:maroon;', 'serialization';

$css = CSS::Declarations.new :border-top-color<rgba(50%,0,0,1.0)>;
is-approx $css.border-top-color.a, 255, ':values constructor';

$css = CSS::Declarations.new :border-top-color<rgba(255,0,0,.5)>;
isa-ok $css.border-top-color, Color, ':values constructor';
is $css.border-top-color, '#FF0000', ':values constructor';
is-approx $css.border-top-color.a, 128, ':values constructor';
is ~$css, 'border-top-color:rgba(255, 0, 0, 0.5);', 'serialization';

$css = CSS::Declarations.new :border-top-color<hsl(120,100%,50%)>;
isa-ok $css.border-top-color, Color, ':values constructor';
is $css.border-top-color, '#00FF00', ':values constructor';
is-approx $css.border-top-color.a, 255, ':values constructor';
is ~$css, 'border-top-color:hsl(120, 100%, 50%);', 'serialization';

$css = CSS::Declarations.new :border-top-color<hsla(120,100%,50%,.5)>;
isa-ok $css.border-top-color, Color, ':values constructor';
is $css.border-top-color, '#00FF00', ':values constructor';
is-approx $css.border-top-color.a, 128, ':values constructor';
is ~$css, 'border-top-color:hsla(120, 100%, 50%, 0.5);', 'serialization';

$css = CSS::Declarations.new :background-color<transparent>;
isa-ok $css.background-color, Color, ':values constructor';
is $css.background-color, '#000000', ':values constructor';
is-approx $css.background-color.a, 0, ':values constructor';
is ~$css, '', 'serialization';

# special handling of border colors. These default to the current color

$css = CSS::Declarations.new: :color<green>;
is $css.border-top-color, '#008000', 'border-*-color default';
$css.color = 'red';
is $css.border-top-color, '#FF0000', 'border-*-color default';
is $css.border-right-color, '#FF0000', 'border-*-color default';

done-testing;
