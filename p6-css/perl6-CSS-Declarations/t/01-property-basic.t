use v6;
use Test;
plan 15;

use CSS::Declarations::Property;
use CSS::Declarations::Edges;
use CSS::Declarations;
use CSS::Declarations::Units;

pass('compiles');

my $sample-prop = CSS::Declarations::Property.new( :name<background-image> );

is-deeply $sample-prop.name, 'background-image', '$prop.name';
is-deeply $sample-prop.box, False, '$prop.box';
is-deeply $sample-prop.inherit, False, '$prop.inherit';
is-deeply $sample-prop.synopsis, '<uri> | none', '$prop.synopsis';
is-deeply $sample-prop.default, "none", '$prop.default';
is-deeply $sample-prop.default-ast, [:keyw<none>, ], '$prop.default-ast';

$sample-prop = CSS::Declarations::Edges.new( :name<margin> );

is-deeply $sample-prop.name, 'margin', '$prop.name';
is-deeply $sample-prop.box, True, '$prop.box';
is-deeply $sample-prop.inherit, False, '$prop.inherit';
is-deeply $sample-prop.synopsis, '<margin-width>{1,4}', '$prop.synopsis';

my $css = CSS::Declarations.new: :margin(5pt), :width(4px);
is $css.width, 4px, 'declared property';
is $css.height, 'auto', 'defaulted property';
is $css.write, 'margin:5pt; width:4px;', 'construction';
$css = CSS::Declarations.new: :style("margin:5pt; width:4px");
is $css.write, 'margin:5pt; width:4px;', 'construction';

done-testing;
