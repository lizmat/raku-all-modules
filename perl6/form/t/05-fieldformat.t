use v6;

use Test;

plan 22;

use Form::Field;
use Form::Types;

my $right-text-field = Form::Field::Text.new(
    :block(Bool::False),
    :width(10),
    :alignment(Alignment::top),
    :justify(Justify::right)
);

ok($right-text-field ~~ Form::Field::Text, "Right-justified text field constructed");

my $data = "foo";

my @lines = $right-text-field.format($data);

ok(@lines.elems == 1, "Right text field format returned one line");
ok(@lines[0].chars == $right-text-field.width, "Right text field format returned correct length line");
ok(@lines[0] eq "       foo", "Right text field format returned correct line");

my $centre-text-field = Form::Field::Text.new(
    :block(Bool::True),
    :width(10),
    :alignment(Alignment::middle),
    :justify(Justify::centre)
);

ok($centre-text-field ~~ Form::Field::Text, "Centre text field constructed");

$data = "foo bar baz foo bar baz";
@lines = $centre-text-field.format($data);
ok(@lines.elems == 3, "Centre text field format returned three lines");
ok(([==] @lines.map: *.chars), "Centre text field format lines are equal lengths");
ok(@lines[0].chars == $centre-text-field.width, "Centre text field format lines are the correct length");
ok(@lines[0] eq " foo bar  ", "Centre text field first line is correct");
ok(@lines[1] eq " baz foo  ", "Centre text field second line is correct");
ok(@lines[2] eq " bar baz  ", "Centre text field third line is correct");

# Test vertical alignment
my @aligned = $centre-text-field.align(@lines, 6);
ok(@aligned.elems == 6, "Centre text field align returned six lines");
ok(([==] @aligned.map: *.chars), "Centre text field align returned lines are equal lengths");
ok(@aligned[0].chars == $centre-text-field.width, "Centre text field aligned lines are the correct length");
ok(@aligned[0] eq " " x $centre-text-field.width, "CTF align first line correct");
ok(@aligned[1] eq " foo bar  ", "CTF align second line is correct");
ok(@aligned[2] eq " baz foo  ", "CTF align third line is correct");
ok(@aligned[3] eq " bar baz  ", "CTF align fourth line is correct");
ok(@aligned[4] eq " " x $centre-text-field.width, "CTF align fifth line correct");
ok(@aligned[5] eq " " x $centre-text-field.width, "CTF align sixth line correct");


# Test numeric field formatting
{
	my Form::Field::Numeric $number-field .= new(ints-width => 4, fracs-width => 3);
	my Real $datum = 15.6;
	my $result = $number-field.format($datum);
	ok($result ~~ Array, "Number field format returned an array");
	ok($result[0] eq "  15.6  ", "Number field format returned correct value");
}

# vim: ft=perl6 sw=4 ts=4 noexpandtab


