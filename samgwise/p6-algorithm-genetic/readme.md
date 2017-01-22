[![Build Status](https://travis-ci.org/samgwise/p6-algorithm-genetic.svg?branch=master)](https://travis-ci.org/samgwise/p6-algorithm-genetic)
NAME
====

Algorithm::Genetic - A basic genetic algorithm implementation for Perl6!

Use the Algorithm::Genetic distribution to implement your own evolutionary searches.

This library was written primarily for learning so there likely are some rough edges. Feel to report any issues and contributions are welcome!

SYNOPSIS
========

```perl6
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
```

DESCRIPTION
===========

Algorithm::Genetic distribution currently provides the following classes:

  * Algorithm::Genetic

  * Algorithm::Genetic::Crossoverable

  * Algorithm::Genetic::Genotype

  * Algorithm::Genetic::Selection

  * Algorithm::Genetic::Selection::Roulette

AUTHOR
======

Sam Gillespie <samgwise@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Reference
=========

NAME
====

Algorithm::Genetic - A role for genetic algorithms.

```
unit role Algorithm::Genetic does Algorithm::Genetic::Selection
```

METHODS
=======

```
method new(
Int:D                         :$population-size       = 100,
Rat:D                         :$crossover-probability = 7/10,
Rat:D                         :$mutation-probability  = 1/100,
Algorithm::Genetic::Genotype  :$genotype is required
)
```

Probability values are expected to be between 0 and 1.

### method generation

```
method generation() returns Int
```

Returns the current generation. Returns 0 if there have been no evolutions

### method population

```
method population() returns Seq
```

Returns a sequence of the current population. This may be an empty list if no calls to Evolve have been made.

### method evolve

```
method evolve(
    Int :$generations = 1, 
    Int :$size = 1
) returns Mu
```

Evolve our population. generations sets an upper limit of generations if the conditions in is-finished our not satisfied. Size is how many couples to pair each generation.

### method sort-population

```
method sort-population() returns Mu
```

Sort our population by score. The higher the score the better! (This is a private method but may not appear that way in the doc...)

### method is-finished

```
method is-finished() returns Bool
```

The termination condition for this algorithm. This must be implemented by an algorithm for assessing if we have achieved our goal.
NAME
====

Algorithm::Genetic::Selection - A role for selection algorithms.

```
unit role Algorithm::Genetic::Selection;
```

METHODS
=======

### method selection-strategy

```
method selection-strategy(
    Int $selection = 2
) returns Seq
```

The selection strategy for an algorithm. This method holds the logic for a selection strategy and must be implemented by consuming roles. The selection parameter specifies how many entities from our population to select.

### method population

```
method population() returns Seq
```

A method for accessing a population. We expect that all elements of the returned list will implement the score method as per Genotype.
NAME
====

Algorithm::Genetic::Selection::Roulette - A role for roulette selection.

```
unit role Algorithm::Genetic::Selection::Roulette does Algorithm::Genetic::Selection;
```

METHODS
=======

### method selection-strategy

```
method selection-strategy(
    Int $selection = 2
) returns Mu
```

implements roulette selection for a population provided by the population method. Roulette selection selects randomly from the population with a preference towards higher scoring individuals.
NAME
====

Algorithm::Genetic::Genotype - A role for defining genotypes.

```
unit role Algorithm::Genetic::Genotype does Algorithm::Genetic::Crossoverable;
```

METHODS
=======

### method score

```
method score() returns Numeric
```

Score this genotype instance. The score will be calculated and cached on the first call.

### sub trait_mod:<is>

```
sub trait_mod:<is>(
    Attribute $attr, 
    :$mutable!
) returns Mu
```

The is mutable trait attaches a mutation function to an attribute. the :mutable argument must be Callable. On mutation the mutator will be executed with the current value of the attribute. The return value of the mutator will be assigned to the attribute.

### method calc-score

```
method calc-score() returns Numeric
```

This method must be implemented by a consuming class. The calc-score method is called by score the score method. (This method is private but may not appear that way in the docs!)

### method new-random

```
method new-random() returns Algorithm::Genetic::Genotype
```

This method may be optionally overridden if the genotype has required values. new-random is called when construction the initial population for a Algorithm::Genetic implementing class.
NAME
====

Algorithm::Genetic::Crossoverable - A role providing crossover behaviour of attribute values.

```
unit role Algorithm::Genetic::Crossoverable;
```

METHODS
=======

### method crossover

```
method crossover(
    Algorithm::Genetic::Crossoverable $other, 
    Rat $ratio
) returns List
```

Crossover between this and another Crossoverable object. Use the ratio to manage where the crossover point will be. standard attribute types will be swapped by value and Arrays will be swapped recursively. Note that this process effectively duck types attributes so best to only crossover between instances of the same class!
