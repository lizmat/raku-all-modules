#
use v6;
use Test;

plan 38;

use Form::Grammar;
use Form::Actions;
use Form::Field;
use Form::Types;

my $actions = Form::Actions.new;
ok($actions, "Form::Actions constructs");

my $result = Form::Grammar.parse('{[[[}', :actions($actions));
ok($result, "Parse left block field with actions succeeds");


my $fields = $result.ast;
my $field = $fields[0];
ok($field ~~ Form::Field::Text, "Parse returned Form::Field::Textresult object (it was a {$field.^name})");

ok($field.block, "Parsed left block field block state is true");
ok($field.width == 5, "Parsed left block field width is correct");
ok($field.alignment == Alignment::top, "Parsed left block field alignment is top");
ok($field.justify == Justify::left, "Parsed left block field justification is left");

my $r-result = Form::Grammar.parse('{>>>>>>}', :actions($actions));
ok($r-result, "Parse right line field with actions succeeds");

my $r-field = $r-result.ast[0];
ok($r-field ~~ Form::Field::Text, "Parse returned a Form::Field::Textresult object");
ok(!$r-field.block, "Parsed right line field object is not a block");
ok($r-field.width == 8, "Parsed right line field width is correct");
ok($r-field.alignment == Alignment::top, "Parsed right line field alignment is top");
ok($r-field.justify == Justify::right, "Parsed right line field justification is right ({$field.justify})");

$r-result = Form::Grammar.parse('{><}', :actions($actions));
ok($r-result, "Parse centred line field with actions succeeds");
ok($r-result.ast[0] ~~ Form::Field::Text, "Parse centred line field result object is Text");
ok($r-result.ast[0].width == 4, "Parsed centred line field has correct width");
ok($r-result.ast[0].justify == Justify::centre, "Parsed centred line field justification is centre");

$r-result = Form::Grammar.parse('{[[]}', :actions($actions));
ok($r-result, "Parse justified line field with actions succeeds");
ok($r-result.ast[0] ~~ Form::Field::Text, "Parse justified line field result object is Text");
ok($r-result.ast[0].width == 5, "Parsed justified line field has correct width");
ok($r-result.ast[0].justify == Justify::full, "Parsed justified line field justification is full");



# Now for mixed literals, multiple fields
my $mixed-string = 'hello{[[[} goodbye{>>}{><}';
my $mixed-results = Form::Grammar.parse($mixed-string, :actions($actions));
ok($mixed-results.ast ~~ Array, "Mixed field parse returned an array");
ok($mixed-results.ast.elems == 5, "Mixed field parse had the correct number of elements");

my $c = 1;
for $mixed-results.ast Z (Str, Form::Field::Text, Str, Form::Field::Text, Form::Field::Text) -> $r, $e {
	ok($r ~~ $e, "Mixed field section {$c++} has type {$e.^name} ({$r.^name})");
}

my $v-string = '{\'\'\'}';
my $v-results = Form::Grammar.parse($v-string, :actions($actions));
ok($v-results.ast ~~ Array, "Verbatim field parse returned an array");
ok($v-results.ast.elems == 1, "Verbatim field parse has one element");
ok($v-results.ast[0] ~~ Form::Field::Verbatim, "Verbatime field object is a Verbatim");
ok($v-results.ast[0].width == 5, "Verbatim field object has correct width");
ok($v-results.ast[0].block == Bool::False, "Verbatim field object is not a block");


{
	my $source = '{>>>.<<<}';
	my $r = Form::Grammar.parse($source, :actions($actions));
	ok($r.ast ~~ Array, "Numeric field parse returned an array");
	my $ast = $r.ast;
	ok($ast.elems == 1, "Numeric field parse has one element");
	my $field = $ast[0];
	ok($field.block == Bool::False, "Numeric field object is not a block");
	ok($field.ints-width == 4, "Numeric field int-width is correct");
	ok($field.fracs-width == 4, "Numeric field fracs-width is correct");
}

# vim: ft=perl6 sw=4 ts=4 noexpandtab
