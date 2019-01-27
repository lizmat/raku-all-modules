use v6;
use Test;
plan 38;

use CSS::Properties;

my $style = 'font:italic bold 10pt/12pt times-roman;';
my CSS::Properties $css .= new: :$style;
is $css.font-style, 'italic', 'font-style';
is $css.font-weight, 'bold', 'font-weight';
is $css.font-family, 'times-roman', 'font-family';
is $css.font-size, 10, 'font-size';
is $css.line-height, 12, 'line-height';
is ~$css, $style, 'serialization';

# check round-trip of font properties samples

my @props = (:font-style<italic>, :font-weight<bold>,
             :font-size<10pt>, :line-height<12pt>,
             :font-family<times-roman>
            );

# basic check that every combination of font properties can be serialised and round-tripped
for 0 ..^ 2**5 -> $mask {
    my @pick = $mask.fmt('%05b').comb>>.Int;
    my %props = @props.keys.grep({@pick[$_]}).map({@props[$_]});
    my CSS::Properties $css .= new: |%props;
    my $style = ~$css;
    $css .= new: :$style;
    my @prop-names = %props.keys.sort;
    is-deeply $css.keys.sort.Array, @prop-names, (@prop-names||'(empty)').join(' ');
}

done-testing;
