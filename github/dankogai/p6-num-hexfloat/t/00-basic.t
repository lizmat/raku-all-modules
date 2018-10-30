use v6;
use Test;
use lib 'lib';
use Num::HexFloat;
use-ok('Num::HexFloat');

my $hexfloat;
is from-hexfloat($hexfloat = '0x1.921fb54442d18p+1'),  pi, "$hexfloat == pi";
is from-hexfloat($hexfloat = '-0x1.5bf0a8b145769p+1'), -e, "$hexfloat == -e";
my $src = "e=0x1.5bf0a8b145769p+1, pi=0x1.921fb54442d18p+1";
my $dst = "e={e}, pi={pi}";
is $src.subst($RE_HEXFLOAT, &from-hexfloat, :g), $dst, $dst;
my $log2hex = '0x1.62e42fefa39efp-1';
is log(2).&to-hexfloat, $log2hex, "log(2).&to-hexfloat eq $log2hex";
my $min = {num => 2e0**(-1074), str => '0x1p-1074'};
is $min<num>.&to-hexfloat, $min<str>, "$min<num> == $min<str>";
is $min<str>.&from-hexfloat, $min<num>, "$min<str> == $min<num>";
my $max = {
    num => :16('1.FFFFFFFFFFFFF') * 2e0**1023,
    str => '0x1.fffffffffffffp+1023'
};
is $max<num>.&to-hexfloat, $max.<str>, "$max<num> == $max<str>";
is $max<str>.&from-hexfloat, $max<num>, "$max<str> == $max<num>";
is from-hexfloat('0x0p+0'),  0e0, "from-hexfloat('0e0')";
is from-hexfloat('-0x0p+0'),-0e0, "from-hexfloat('-0e0')";
is from-hexfloat('inf'),     Inf, "from-hexfloat('inf')";
is from-hexfloat('-inf'),   -Inf, "from-hexfloat('-inf')";
is from-hexfloat('uninfected'), NaN, "from-hexfloat('uninfected')";
is to-hexfloat(+0e0),  '0x0p+0',  "to-hexfloat(0e0)";
is to-hexfloat(-0e0), '-0x0p+0',  "to-hexfloat(-0e0)";
is to-hexfloat(+Inf),  'inf',     "to-hexfloat(Inf)";
is to-hexfloat(-Inf), '-inf',     "to-hexfloat(-Inf)";
is to-hexfloat(NaN),   'nan',     "to-hexfloat(NaN)";
done-testing;
