use v6;
use lib 'lib';

use CompUnit::Search;

my @compUnits = search-provides(* ~~ /JSON\:\:.*/);

for @compUnits -> $compUnit {
  say $compUnit;
}
