use v6.c;
use Test;
use Sub::Util;

my @supported   = <subname set_subname>;
my @unsupported = <prototype set_prototype>;
my @all = (|@supported, |@unsupported).map: '&' ~ *;

plan @all * 2 + @unsupported;

for @all {
    ok !defined(::($_)), "is $_ NOT imported?";
    ok defined(Sub::Util::{$_}), "is $_ externally accessible?";
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
    Sub::Util::{'&' ~ $function}();  # should die, if not: not enough tests
}

# vim: ft=perl6 expandtab sw=4
