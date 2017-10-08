use v6;
use NativeCall;

# libSystem should maybe be libm on Linux?

sub erf(num64) returns num64 is native(Str)  { * }
sub error-function(Real $a) is export { erf($a.Num) }

sub erfc(num64) returns num64 is native(Str)  { * }
sub complementary-error-function(Real $a) is export { erfc($a.Num) }

sub tgamma(num64) returns num64 is native(Str)  { * }
multi Γ(Real $a) is export { $a == 0 ?? NaN !! tgamma($a.Num) }
multi Γ(Int $a) is export {
    given $a {
        when * < 1 { NaN }
        when * < 13 { tgamma($a.Num).round }
        default { [*] 1..($a - 1) }
    }
}

sub lgamma(num64) returns num64 is native(Str)  { * }
multi logΓ(Real $a) is export { $a == 0 ?? NaN !! lgamma($a.Num) }

sub log1p-num(num64) returns num64 is native(Str) is symbol('log1p')  { * }
multi log1p(Real $a) is export { log1p-num($a.Num) }

sub expm1-num(num64) returns num64 is native(Str) is symbol('expm1')  { * }
multi expm1(Real $a) is export { expm1-num($a.Num) }

# sub expm1(Real $a) is export { $a.abs < 1e-5 ?? $a + 0.5*$a*$a !! $a.exp - 1 }

