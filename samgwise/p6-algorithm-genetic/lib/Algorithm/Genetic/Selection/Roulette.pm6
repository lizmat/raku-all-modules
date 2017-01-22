use v6;

=begin pod

=head1 NAME

Algorithm::Genetic::Selection::Roulette - A role for roulette selection.

=begin code
unit role Algorithm::Genetic::Selection::Roulette does Algorithm::Genetic::Selection;
=end code

=head1 METHODS

=end pod

use Algorithm::Genetic::Selection;

unit role Algorithm::Genetic::Selection::Roulette does Algorithm::Genetic::Selection;

method selection-strategy(Int $selection = 2)
#= implements roulette selection for a population provided by the population method.
#= Roulette selection selects randomly from the population with a preference towards higher scoring individuals.
{
  given self.population.elems -> $size {
    when $selection < 1 {
      succeed ()
    }
    when $size < 1 {
      succeed ()
    }
    default {
      succeed gather for self.population.kv.map( -> $i, $p { $i => $p.score * $size } ).sort( *.value )[$size - ($selection min $size).. *] -> $e {
        take self.population[$e.key];
      }
    }
  }
}
