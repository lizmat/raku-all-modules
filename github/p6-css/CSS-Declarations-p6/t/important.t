use v6;
use Test;
plan 14;

use CSS::Declarations;

my $css = CSS::Declarations.new;

nok $css.important('background-image');
$css.important('background-image') = True;
ok $css.important('background-image');
$css.important('background-image') = False;
nok $css.important('background-image');

nok $css.important('margin-top');
nok $css.important('margin');

$css.important('margin-top') = True;
ok $css.important('margin-top'), 'importance setter';

$css.important('margin') = True;
ok $css.important('margin'), 'importance setter - box';
ok $css.important('margin-bottom'), 'importance setter - box';

$css.important('margin-bottom') = False;
nok $css.important('margin-bottom');
nok $css.important('margin');
ok $css.important('margin-top');

$css = CSS::Declarations.new( :style("border-top: 1px red !important"));
$css.important("border-top-width") = False;
ok $css.important("border-top-color");
nok $css.important("border-top-width");
nok $css.important("border-right-color");

done-testing;
