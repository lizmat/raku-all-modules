use v6;
use Test;

plan 6;

use Form::Field;

my $textfield;
lives-ok(
	{
		$textfield = Form::Field::Text.new;
	},
	"TextField constructs with no parameters"
);

ok($textfield, "TextField constructor returned an object");

{
    my $numeric-field;
    lives-ok( { $numeric-field = Form::Field::Numeric.new; },
              'NumericField constructs with no parameters'
    );
    ok($numeric-field.defined, 'NumericField constructor returned an object');
}

{
	my $verbatim-field;
	lives-ok( { $verbatim-field = Form::Field::Verbatim.new; },
			'VerbatimField constructs with no parameters'
	);
	ok($verbatim-field.defined, 'VerbatimField constructor returns an onbject');
}

# vim: ft=perl6 sw=4 ts=4 noexpandtab
