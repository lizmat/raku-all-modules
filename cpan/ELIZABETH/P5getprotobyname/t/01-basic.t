use v6.c;
use Test;
use P5getprotobyname;

my @supported = <
  endprotoent getprotobyname getprotobynumber getprotoent setprotoent
>.map: '&' ~ *;

plan @supported * 2;

for @supported {
    ok defined(::($_)),                "is $_ imported?";
    nok P5getprotobyname::{$_}:exists, "is $_ NOT externally accessible?";
}

# vim: ft=perl6 expandtab sw=4
