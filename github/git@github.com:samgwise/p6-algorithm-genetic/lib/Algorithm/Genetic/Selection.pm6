use v6;

=begin pod

=head1 NAME

Algorithm::Genetic::Selection - A role for selection algorithms.

=begin code
unit role Algorithm::Genetic::Selection;
=end code

=head1 METHODS

=end pod

unit role Algorithm::Genetic::Selection;

method selection-strategy(Int $selection = 2) returns Seq
#= The selection strategy for an algorithm.
#= This method holds the logic for a selection strategy and must be implemented by consuming roles.
#= The selection parameter specifies how many entities from our population to select.
{ ... }

method population() returns Seq
#= A method for accessing a population.
#= We expect that all elements of the returned list will implement the score method as per Genotype.
{ ... }
