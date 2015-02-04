use v6;

use Test;
use Form::NumberFormatting;

plan 4;

my @parts = Form::NumberFormatting::obtain-number-parts(3.14);
ok(@parts[0] == 3, "Whole number part correct");
ok(@parts[1] == 14, "Fractional number part correct");
@parts = Form::NumberFormatting::obtain-number-parts(-3.14);
ok(@parts[0] == -3, "Whole number part correct (negative)");
ok(@parts[1] == 14, "Fractional number part correct (negative)");

# vim: ft=perl6 sw=4 ts=4 noexpandtab

