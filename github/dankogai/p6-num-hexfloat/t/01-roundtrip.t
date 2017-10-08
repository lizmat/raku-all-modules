use v6;
use Test;
use lib 'lib';
use Num::HexFloat;

my Num $d = 1e0;
my Num $f = $d;
for 0..53 {
    my $s = to-hexfloat($d);
    my $db = $d.base(10,17); #  Bug #127201 workaround
    is from-hexfloat($s), $d, 'from-hexfloat("' ~ $s ~ '") eq ' ~ $db;
    is to-hexfloat($d), $s, 'to-hexfloat(' ~ $db ~ ') == ' ~ $s;
    $f /= 2; $d += $f;
}
done-testing;
