use v6;

=begin pod

=head1 NAME

Algorithm::Genetic::Genotype - A role for defining genotypes.

=begin code
unit role Algorithm::Genetic::Genotype does Algorithm::Genetic::Crossoverable;
=end code

=head1 METHODS

=end pod

use Algorithm::Genetic::Crossoverable;

unit role Algorithm::Genetic::Genotype does Algorithm::Genetic::Crossoverable;

my @mutators;
has Numeric $!score;

method score() returns Numeric
#= Score this genotype instance.
#= The score will be calculated and cached on the first call.
{
  $!score = self!calc-score unless $!score.defined;
  $!score;
}

multi sub trait_mod:<is> (Attribute $attr, :$mutable!) is export
#= The is mutable trait attaches a mutation function to an attribute.
#= the :mutable argument must be Callable.
#= On mutation the mutator will be executed with the current value of the attribute.
#= The return value of the mutator will be assigned to the attribute.
{
  die "Mutable trait requires a Callable arguement, recieved: '{ $mutable.WHAT.perl }'." unless $mutable ~~ Callable;
  @mutators.push: sub mutate-attribute($self) { $attr.set_value: $self, $mutable( $attr.get_value($self) ) }
}

method mutate(Rat $probability) {
  for @mutators -> $m {
    next unless 1000.rand <= $probability * 1000;
    $m(self);
  }
}

#
# Required methods
#

method !calc-score() returns Numeric
#= This method must be implemented by a consuming class.
#= The calc-score method is called by score the score method.
#= (This method is private but may not appear that way in the docs!)
{ ... }

#
# Default methods
#

method new-random() returns Algorithm::Genetic::Genotype
#= This method may be optionally overridden if the genotype has required values.
#= new-random is called when construction the initial population for a Algorithm::Genetic implementing class.
{
  self.new
}
