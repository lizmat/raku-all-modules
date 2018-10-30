#! /usr/bin/env perl6
use v6;
use Test;

use-ok 'Algorithm::Genetic::Genotype';
use Algorithm::Genetic::Genotype;

class Point does Algorithm::Genetic::Genotype {
  my sub mutate-int (Numeric $v) returns Int {
    (-1, 1).pick + $v
  }

  has Int $.x is mutable( &mutate-int );
  has Int $.y is mutable( &mutate-int );
}

my Point $test .= new( :x(0), :y(0) );

$test.mutate(1/1);

is $test.x, any(1, -1), "point.x is mutated";
is $test.y, any(1, -1), "point.y is mutated";

done-testing;
