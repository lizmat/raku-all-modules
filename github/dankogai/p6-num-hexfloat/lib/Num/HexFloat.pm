use v6;
unit module Num::HexFloat;
our $RE_HEXFLOAT is export = rx:i{
    $<sign>  = [<[+-]>?]
    0x
    $<int>   = [<[0..9A..F]>+]
    '.'?
    $<fract> = [<[0..9A..F]>*]
    'P'
    $<exp>   = [<[+-]>? <[0..9]>+]
};
proto from-hexfloat($arg) returns Num is export { * }
multi sub from-hexfloat(Match:D $m) returns Num {
    my $sign = $m<sign> eq '-' ?? -1e0 !! 1e0;
    my $mantissa = :16( $m<int> ~ $m<fract> );
    my $exponent = $m<exp>.Num - 4*$m<fract>.chars;
    return $sign * $mantissa * 2e0 ** $exponent;
}
multi sub from-hexfloat(Str:D $s) returns Num {
    if my $m = $s.match($RE_HEXFLOAT) {
        return from-hexfloat($m);
    }
    elsif my $mx = $s.match(rx:i{(<< || <[+-]>)inf[inity]?>>}) {
        return Inf * ($mx[0] eq '-' ?? -1 !! +1);
    }
    NaN;
}
proto sub to-hexfloat($num) returns Str is export { * }
multi sub to-hexfloat($num) returns Str {
    to-hexfloat($num.Num)
}
multi sub to-hexfloat(Num $num) returns Str {
    return 'nan' if $num.isNaN;
    return '0x0p+0'  if $num === +0e0;
    return '-0x0p+0' if $num === -0e0;
    my $s = $num < 0 ?? '-' !! '';
    my $a = $num.abs;
    return $s ~ 'inf' if $a == Inf;
    my $p = 0;
    if $a < 1 { while $a < 1  { $a *= 2; $p--} }
    else      { while $a >= 2 { $a /= 2; $p++} }
    my $m = $a.base(16, 14).lc;
    $m ~~ s/0+$//;
    $m ~~ s/\.?$//;
    my $es = $p < 0 ?? '' !! '+';
    return $s ~ '0x' ~ $m ~ 'p' ~ $es ~ $p.base(10);
}
