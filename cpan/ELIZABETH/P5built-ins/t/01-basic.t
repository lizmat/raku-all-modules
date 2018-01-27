use v6.c;
use Test;
use P5built-ins;

my @supported = <
 caller chomp chop chr each fc hex index lc lcfirst length oct ord pack quotemeta
 ref rindex substr tie tied times uc ucfirst unpack untie
>.map: '&' ~ *;

plan +@supported;

for @supported {
    ok defined(::($_))              # something here by that name
      && ::($_) !=== SETTING::{$_}, # here, but not from the core Setting
      "is $_ imported?";
}

# vim: ft=perl6 expandtab sw=4
