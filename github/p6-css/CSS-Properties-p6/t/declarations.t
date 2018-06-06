use v6;
use Test;
plan 47;

use CSS::Properties;
use CSS::Properties::Property;
use CSS::Properties::Edges;
use CSS::Properties::Units :pt, :px;
use Color;

my $css = CSS::Properties.new( :!warn, :border-top-color<red> );
is $css.border-top-color, '#FF0000', ':values constructor';

my $margin-info = $css.info('margin');
isa-ok $margin-info, CSS::Properties::Edges, 'box property';
is-deeply [$margin-info.edges], ["margin-top", "margin-right", "margin-bottom", "margin-left"], 'edges property';

my $margin-left-info = $css.info('margin-left');
isa-ok $margin-left-info, CSS::Properties::Property, 'simple property';
is $margin-left-info.edge, 'margin', 'margin-left is a margin edge';

is $css.azimuth, 'center', 'default azimuth';
$css.azimuth = 'over-yonder';
is $css.azimuth, 'center', 'default azimuth';

is $css.background-position, [0, 0], 'default background position';
is $css.margin, [0, 0, 0, 0], 'default margin';
is $css.margin-left, 0, 'default margin-left';
is $css.margin-left.type, 'px', 'default margin left type';
isa-ok $css.background-color, Color, 'default background-color';
is-deeply $css.background-color.rgba, (0,0,0,0), 'default background-color';
is ~$css, 'border-top-color:red;', 'basic css rewritten';
$css.background-position = <top left>;
is $css.background-position[0], 'top', 'list parse';
is $css.background-position[0].type, 'keyw', 'list parse';
is ~$css, 'background-position:top left; border-top-color:red;', 'list parse';
$css.background-position = Nil;
is-deeply $css.background-color.rgba, (0,0,0,0), 'background-color reset';
is ~$css, 'border-top-color:red;', 'background-color reset';

$css.margin-top = 10pt;
is $css.margin-top, 10, 'updated margin-right value';
is $css.margin-top.type, 'pt', 'updated margin-right units';
$css.margin[1] = 20px;
is $css.margin-right.type, 'px', 'updated margin-right units';
is $css.margin, [10, 20, 0, 0], 'updated margin';
$css.border-color = [ :rgb[10,20,30], :color<red> ];
is $css.border-color, <#0A141E red #0A141E red>, 'named and rgb colors';

$css.margin = '0';
is $css.margin-left, 0, 'reset margin-left';

$css.border-color = 'green';
$css.border-top-color = 'blue';
is $css.border-color, <#0000FF #008000 #008000 #008000>, 'border-color string coercement';
$css.color = 'red';
$css.border-color = Nil;
is $css.border-color, <#FF0000 #FF0000 #FF0000 #FF0000>, 'border-color reset';

lives-ok { $css.border-top = '1pt dashed blue'}, 'struct str assignment';
$css.color = 'red';
my %border-top = $css.border-top;
is +%border-top, 3, 'border top';
is $css.border-top-width, 1pt, 'border top width';
is %border-top<border-top-width>, 1pt, 'border top width';
is %border-top<border-top-style>, 'dashed', 'border top color';
is %border-top<border-top-color>, '#0000FF', 'border top color';
%border-top<border-top-width> = 2pt;
%border-top<border-top-style> = :keyw<dashed>;
lives-ok { $css.border-top = %border-top}, 'struct hash assignment';
%border-top = $css.border-top;
is %border-top<border-top-width>, 2pt, 'border top width';
is %border-top<border-top-style>, 'dashed', 'border top color';
is %border-top<border-top-color>, '#0000FF', 'border top color';
enum Edges <Top Left Bottom Right>;
is $css.border<border-color>[Top], '#0000FF', 'border top color';
$css.border-top = Nil;
%border-top = $css.border-top;
is %border-top<border-top-width>, 'medium', 'reset border top width';
is %border-top<border-top-style>, 'none', 'reset border top color';

lives-ok { $css.info("background"); }, "info on a container property";

$css = CSS::Properties.new: :style("border-top-color:red");
my $original-css = $css;
$css = $css.clone;
is ~$css, "border-top-color:red;", 'cloned css';
$css.border-color = 'blue';
is ~$css, "border-color:blue;", 'cloned css';
is ~$original-css, "border-top-color:red;", 'original css';

# special handling of text-align. Default depends on direction

$css = CSS::Properties.new: :color<green>;
is $css.text-align, 'left', 'default text-align';
$css.direction = 'rtl';
is $css.text-align, 'right', 'default text-align (direction rtl)';
$css.text-align = 'left';
is $css.text-align, 'left', 'updated text-direction';

done-testing;
