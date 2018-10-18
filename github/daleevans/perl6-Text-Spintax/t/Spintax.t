use Test;
use lib 'lib';

plan 2;

use Text::Spintax; pass "Import Text::Spintax";

{
    my $spintax = Text::Spintax.new;
    my $renderer = $spintax.parse('{a|b} {c|d {e|f}}');
    my %outputs;
    for 1 .. 100 -> $x {
       %outputs{$renderer.render} = 1;
    }
    my %expected = (
        'a c' => 1,
        'a d e' => 1,
        'a d f' => 1,
        'b c' => 1,
        'b d e' => 1,
        'b d f' => 1,
    );
    is-deeply %outputs, %expected, 'all options reachable';
}
