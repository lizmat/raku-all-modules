use v6.c;
use Test;
use P5getpriority;

my @supported = <
  getpgrp getppid getpriority setpgrp setpriority
>.map: '&' ~ *;

plan @supported * 2;

for @supported {
    ok defined(::($_)),             "is $_ imported?";
    nok P5getpriority::{$_}:exists, "is $_ NOT externally accessible?";
}

# vim: ft=perl6 expandtab sw=4
