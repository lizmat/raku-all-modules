#!/usr/bin/env perl6

use v6;

use Test;

use Form::TextFormatting;

plan 19;

my $text = "The quick brown fox, jumps over the lazy dog.";
my $fitted;
my $remainder;

($fitted, $remainder) = Form::TextFormatting::fit-in-width($text, 6);
ok($fitted eq 'The', "First line fitted correctly");
ok($remainder eq 'quick brown fox, jumps over the lazy dog.', "First line remainder correct");
($fitted, $remainder) = Form::TextFormatting::fit-in-width($text, 20);
ok($fitted eq 'The quick brown fox,', "Wider line fitted correctly");
ok($remainder eq 'jumps over the lazy dog.', "Wider line remainder correct");
($fitted, $remainder) = Form::TextFormatting::fit-in-width($text, 2);
ok($fitted eq 'Th', 'Partial word fill correct');
ok($remainder eq 'e quick brown fox, jumps over the lazy dog.', 'Partial word remainder correct');


# now wrapping whole sets of lines
my @lines = Form::TextFormatting::unjustified-wrap($text, 6);
# okay, we should have...
my @expected = <The quick brown fox, jumps over the lazy dog.>;
ok(@lines.elems == 9, "Correct number of lines.");
my $lines_correct = all(map -> $g, $e { $g eq $e }, (@lines Z @expected)) == 1;
ok($lines_correct, "Lines were correct");

# justification checks
my $str = "ABCD";
ok(Form::TextFormatting::left-justify($str, $str.chars) eq $str, "left-justify to string width causes no change");
ok(Form::TextFormatting::right-justify($str, $str.chars) eq $str, "right-justify to string width causes no change");
ok(Form::TextFormatting::centre-justify($str, $str.chars) eq $str, "centre-justify to string width causes no change");

ok(Form::TextFormatting::left-justify($str, 6) eq "ABCD  ", "left-justify correct");
ok(Form::TextFormatting::right-justify($str, 6) eq "  ABCD", "right-justify correct");
ok(Form::TextFormatting::centre-justify($str, 6) eq " ABCD ", "centre-justify correct");
ok(Form::TextFormatting::centre-justify($str, 7) eq " ABCD  ", "uneven centre-justify correct");

ok(Form::TextFormatting::full-justify($str, 6) eq "ABCD  ", "fully justify with one word correct");
ok(Form::TextFormatting::full-justify("A B", 6) eq "A    B", "fully justify with two words correct");
ok(Form::TextFormatting::full-justify("A B C", 9) eq "A   B   C", "fully justify with three words correct");
ok(Form::TextFormatting::full-justify("A B C", 10) eq "A    B   C", "fully justify with three words uneven correct");

# vim: ft=perl6 sw=4 ts=4 noexpandtab

