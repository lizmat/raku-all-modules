use v6;
use Test;
plan 10;

use CSS::Declarations;

my $css = CSS::Declarations.new: :style("color: orange; text-align: center!important; margin: 2pt; border-width: 1px 2px 3pt");

is $css.color, '#FFA500';
is $css.color.type, 'rgb';
is $css.text-align, "center";
is $css.margin, [2 xx 4];
is $css.margin-top, 2;
is $css.margin-top.type, 'pt';
is $css.border-width, [1, 2, 3, 2];

ok $css.important("text-align"), "important property";
nok $css.important("color"), "unimportant property";

$css = CSS::Declarations.new: :style("border: 2.5px");
is $css.border-width, [2.5 xx 4];

done-testing;
