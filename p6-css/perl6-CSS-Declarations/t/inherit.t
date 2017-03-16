use v6;
use Test;
plan 17;
use CSS::Declarations;

my $inherit = CSS::Declarations.new: :style("margin-top:5pt; margin-right: 10pt; margin-left: 15pt; margin-bottom: 20pt; color:rgb(0,0,255)!important");

my $css = CSS::Declarations.new( :style("margin-top:25pt; margin-right: initial; margin-left: inherit"), :$inherit );

nok $css.handling("margin-top"), 'overridden value';
is $css.margin-top, 25, "overridden value";

is $css.handling("margin-right"), "initial", "'initial'";
is $css.margin-right, 0, "'initial'";

is $css.handling("margin-left"), "inherit", "'inherit'";
is $css.margin-left, 15, "'inherit'";

is $css.info("color").inherit, True, 'color inherit metadata';
is $css.color, '#0000FF', "inheritable property";

is $css.info("margin-bottom").inherit, False, 'margin-bottom inherit metadata';
is $css.margin-bottom, 0, "non-inhertiable property";

$css = CSS::Declarations.new( :style("margin: inherit"), :$inherit);
is $css.margin-top, 5, "inherited box value";
is $css.margin-right, 10, "inherited value";

$css = CSS::Declarations.new( :style("margin: initial; color:purple"), :$inherit);
is $css.margin-top, 0, "initial box value";
is $css.color, '#0000FF', "inheritable !important property";
ok $css.important("color"), 'inherited !important stickyness';

# inherit from css object
is ~$css, 'color:blue!important; margin-bottom:initial; margin-left:initial; margin-right:initial;', 'inherit from object';

# inherit from style string
$css = CSS::Declarations.new( :inherit(~$inherit));
is ~$css, 'color:blue!important;', 'inherit from object';

done-testing;
