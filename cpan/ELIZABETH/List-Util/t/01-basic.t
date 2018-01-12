use v6.c;
use Test;
use List::Util;

my @supported = <
 reduce any all none notall first max maxstr min minstr product sum sum0
 pairs unpairs pairkeys pairvalues pairfirst pairgrep pairmap shuffle
 uniq uniqnum uniqstr
>.map: '&' ~ *;

plan @supported * 2;

for @supported {
    ok !defined(::($_))                # nothing here by that name
      || ::($_) !=== List::Util::{$_}, # here, but not the one from List::Util
      "is $_ NOT imported?";
    ok defined(List::Util::{$_}), "is $_ externally accessible?";
}

# vim: ft=perl6 expandtab sw=4
