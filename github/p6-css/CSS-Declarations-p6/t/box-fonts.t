use v6;
use Test;
plan 9;

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
is $font.line-height, 12, 'line-height';
is $font.length(15px), 11.25, 'length';
is $font.fontconfig-pattern, 'times-roman:slant=italic:weight=bold', 'fontconfig-pattern';

is CSS::Declarations::Font.new( :font-style("500 condensed 12px/30px Georgia, serif, Times") ).fontconfig-pattern, 'Georgia serif,Times:weight=medium:width=condensed', 'fontconfig-pattern';

done-testing;
