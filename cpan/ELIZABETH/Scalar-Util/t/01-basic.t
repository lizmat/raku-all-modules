use v6.c;
use Test;
use Scalar::Util;

my @supported =
  <blessed dualvar isdual readonly refaddr reftype isvstring looks_like_number>;
my @unsupported =
  <weaken isweak unweaken openhandle set_prototype tainted>;
my @all = (|@supported, |@unsupported).map: '&' ~ *;

plan @all * 2 + @unsupported;

for @all {
    ok !defined(::($_)), "is $_ NOT imported?";
    ok defined(Scalar::Util::{$_}), "is $_ externally accessible?";
}

for @unsupported -> $function {
    CATCH {
        when X::AdHoc {
            ok .message.starts-with("'$function'"), "did calling &$function die?";
            .resume;
        }
        default {
            fail "calling &$function died with $_.^name()";
            .resume;
        }
    }
    Scalar::Util::{'&' ~ $function}();  # should die, if not: not enough tests
}

# vim: ft=perl6 expandtab sw=4
