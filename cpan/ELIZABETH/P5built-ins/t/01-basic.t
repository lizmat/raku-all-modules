use v6.c;
use Test;
use P5built-ins;

my @supported = <
  caller chdir chomp chop chr each fc fileno hex index lc lcfirst length
  oct ord pack pop push quotemeta readlink ref rindex seek sleep study
  substr tie tied times uc ucfirst unpack untie

  prefix:<-r> prefix:<-w> prefix:<-x> prefix:<-e> prefix:<-d> prefix:<-f>
  prefix:<-s> prefix:<-z> prefix:<-l>
>.map: '&' ~ *;

plan +@supported;

for @supported {
    ok defined(::($_))              # something here by that name
      && ::($_) !=== SETTING::{$_}, # here, but not from the core Setting
      "is $_ imported?";
}

# vim: ft=perl6 expandtab sw=4
