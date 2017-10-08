use Test;
use SP6;

plan 5;

my $templ_dir = 't/templ';

my $sp6 = SP6.new( :templ_dir($templ_dir), );
is $sp6.process(tstr => q{foobar}), 'foobar', 'base eval';
is $sp6.process(tstr => q{aa{"\nline-" ~ $?LINE} bb}), "aa\nline-1 bb", 'LINE';
is $sp6.process(tstr => q{aa {include "eval-inner.sp6"} cc}), 'aa inner-text cc', 'include';

# inside
is $sp6.process(
		tstr => q{main-tstr},
		inside_tfpath => 'inside-outher.sp6'
	),
	'outherA main-tstr outherB',
	'istr inside outher';
# vars
is $sp6.process(
		tstr => q|aa<{%v<varA> = 'varAtext'; ''}{include "eval-inner-vars.sp6"}>bb<{ %v<inX>:exists ?? 'yes' !! 'no' }>cc|
	),
	'aa<xx-yy[varAtext]zz>bb<no>cc',
	'istr vars';
