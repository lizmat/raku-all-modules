use v6;
use Test;
plan 5;

use CSS::Declarations;

my $style = 'font:italic bold 10pt/12pt times-roman;';
my $css = CSS::Declarations.new: :$style;
is $css.font-style, 'italic', 'font-style';
is $css.font-weight, 'bold', 'font-weight';
is $css.font-family, 'times-roman', 'font-family';
is $css.line-height, 12, 'line-height';
is ~$css, $style, 'serialization';

done-testing;
