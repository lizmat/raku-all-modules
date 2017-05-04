use v6;
use Test;
plan 7;

use CSS::Declarations;
use CSS::Declarations::Font;
use CSS::Declarations::Units :px;
my $font-style = 'italic bold 10pt/12pt times-roman';
my $font = CSS::Declarations::Font.new: :$font-style;
is $font.em, 10, 'em';
is $font.ex, 7.5, 'ex';
is $font.style, 'italic', 'font-style';
is $font.weight, '700', 'font-weight';
is $font.family, 'times-roman', 'font-family';
is $font.leading, 12, 'leading';
is $font.length(15px), 11.25;

done-testing;
