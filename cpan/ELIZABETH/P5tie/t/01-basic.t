use v6.c;
use Test;
use P5tie;

my @exported = <tie tied untie>.map: '&' ~ *;;

plan @exported * 2;

for @exported {
    ok defined(::($_)), "is $_ imported?";
    ok !defined(P5tie::{$_}), "is $_ externally NOT accessible?";
}

# vim: ft=perl6 expandtab sw=4
