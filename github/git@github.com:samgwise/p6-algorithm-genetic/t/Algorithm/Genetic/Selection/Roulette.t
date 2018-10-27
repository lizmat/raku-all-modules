#! /usr/bin/env perl6
use v6;
use Test;

use-ok 'Algorithm::Genetic::Selection::Roulette';
use Algorithm::Genetic::Selection::Roulette;
use Algorithm::Genetic::Genotype;

class Point does Algorithm::Genetic::Genotype {
  has Int $.x = (-10..10).pick;
  has Int $.y = (-10..10).pick;

  method !calc-score() returns Numeric {
    $!x * $!y
  }
}

class Cloud does Algorithm::Genetic::Selection::Roulette {
  has Point @.population handles<map elems>;
}

my Point @possible    = Point.new( :x(1), :y(1) ), Point.new( :x(2), :y(1) ), Point.new( :x(1), :y(2) ), ;
my Point @impossible  = Point.new( :x(0), :y(0) ), Point.new( :x(0), :y(1) ), Point.new( :x(1), :y(0) ), ;

my Cloud $test .= new( :population(
  |@possible,
  |@impossible,
) );

is $test.selection-strategy(@possible.elems).elems, @possible.elems, "Roulette selects correct number of elements";

is $test.selection-strategy($test.elems + 1).elems, $test.elems, "Roulette selects no more than it's maximum elements";

is $test.selection-strategy(0).elems, 0, "Roulette selects 0 elements for 0";
is $test.selection-strategy(1).elems, 1, "Roulette selects 1 elements for 1"; 

is $test.selection-strategy(@possible.elems).all, @possible.any, "Roulette select all possible canidates";

done-testing;
