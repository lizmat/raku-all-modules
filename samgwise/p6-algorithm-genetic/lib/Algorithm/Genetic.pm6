use v6;

=begin pod

=head1 NAME

Algorithm::Genetic - A basic genetic algorithm implementation for Perl6!

Use the Algorithm::Genetic distribution to implement your own evolutionary searches.

This library was written primarily for learning so there likely are some rough edges.
Feel to report any issues and contributions are welcome!

=head1 SYNOPSIS

=begin code :info<perl6>

use Algorithm::Genetic;
use Algorithm::Genetic::Genotype;
use Algorithm::Genetic::Selection::Roulette;

my $target = 42;

# First implement the is-finished method for our specific application.
# Note that we compose in our selection behaviour of the Roulette role.
class FindMeaning does Algorithm::Genetic does Algorithm::Genetic::Selection::Roulette {
  has int $.target;
  method is-finished() returns Bool {
    #say "Gen{ self.generation } - pop. size: { @!population.elems }";
    self.population.tail[0].result == $!target;
  }
}

# Create our Genotype
class Equation does Algorithm::Genetic::Genotype {
  our $eq-target = $target;
  our @options = 1, 9;

  # Note that we use the custom is mutable trait to provide a routine to mutate our attribute.
  has Int $.a is mutable( -> $v { (-1, 1).pick + $v } ) = @options.pick;
  has Int $.b is mutable( -> $v { (-1, 1).pick + $v } ) = @options.pick;

  method result() { $!a * $!b }

  # A scoring method is required for our genotype :)
  method !calc-score() returns Numeric {
    (self.result() - $eq-target) ** 2
  }
}

# Instantiate our search
my FindMeaning $ga .= new(
  :genotype(Equation.new)
  :mutation-probability(4/5)
  :$target
);

# Go!
$ga.evolve(:generations(1000), :size(16));

say "stopped at generation { $ga.generation } with result: { .a } x { .b } = { .result } and a score of { .score }" given $ga.population.tail[0];

=end code

=head1 DESCRIPTION

Algorithm::Genetic distribution currently provides the following classes:

=item Algorithm::Genetic
=item Algorithm::Genetic::Crossoverable
=item Algorithm::Genetic::Genotype
=item Algorithm::Genetic::Selection
=item Algorithm::Genetic::Selection::Roulette

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=head1 Reference

=head1 NAME

Algorithm::Genetic - A role for genetic algorithms.

=begin code
unit role Algorithm::Genetic does Algorithm::Genetic::Selection
=end code

=head1 METHODS

=begin code
method new(
Int:D                         :$population-size       = 100,
Rat:D                         :$crossover-probability = 7/10,
Rat:D                         :$mutation-probability  = 1/100,
Algorithm::Genetic::Genotype  :$genotype is required
)
=end code

Probability values are expected to be between 0 and 1.

=end pod

use Algorithm::Genetic::Selection;

unit role Algorithm::Genetic does Algorithm::Genetic::Selection;
use Algorithm::Genetic::Genotype;

has Algorithm::Genetic::Genotype          @!population;
has Int                                   $!generation            = 0;
has Int:D                                 $.population-size       = 100;
has Rat:D                                 $.crossover-probability = 7/10;
has Rat:D                                 $.mutation-probability  = 1/100;
has Algorithm::Genetic::Genotype          $.genotype              is required;

method generation() returns Int
#= Returns the current generation.
#= Returns 0 if there have been no evolutions
{ $!generation }
method population() returns Seq
#= Returns a sequence of the current population.
#= This may be an empty list if no calls to Evolve have been made.
{ @!population.values }

method evolve(Int :$generations = 1, Int :$size = 1)
#= Evolve our population.
#= generations sets an upper limit of generations if the conditions in is-finished our not satisfied.
#= Size is how many couples to pair each generation.
{
  self!init unless @!population.elems > 0;

  for 1..$generations -> $gen {
    self!sort-population;
    my $parrents = self.selection-strategy($size * 2);

    my @pairings;
    for $parrents.rotor(2) -> $parrent {
      # @pairings.push: start {
        if 1000.rand <= $!crossover-probability * 1000 {
          my $children = $parrent[0].crossover($parrent[1], 1/2);
          $children>>.mutate($!mutation-probability);

          # Update population
          for $children.values -> $c {
            @!population.shift;
            @!population.push: $c;
          }
        }
        # CATCH { warn $_ }
      # }
    }
    # await Promise.allof: @pairings;

    ++$!generation;
    last if self.is-finished;
  }
}

method !init()
#= Lazy initilisation of our population, creates and scores up to our population size.
{
  for 1..$!population-size {
    @!population.push: $!genotype.new-random;
  }
}

method !sort-population()
#= Sort our population by score.
#= The higher the score the better!
#= (This is a private method but may not appear that way in the doc...)
{
  @!population .= sort: {$^a.score <=> $^b.score }
}

#
# Required methods
#

method is-finished() returns Bool
#= The termination condition for this algorithm.
#= This must be implemented by an algorithm for assessing if we have achieved our goal.
{ ... }
