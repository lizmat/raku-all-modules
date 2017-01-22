#! /usr/bin/env perl6
use v6;
use Test;

use-ok 'Algorithm::Genetic::Crossoverable';
use Algorithm::Genetic::Crossoverable;

class Point does Algorithm::Genetic::Crossoverable {
  has Int $.x;
  has Int $.y;
}

{
  my Point $a .= new( :x(0), :y(0) );
  my Point $b .= new( :x(1), :y(1) );

  my ($c, $d) = |$a.crossover($b, 1/2);

  is $c.x, 1, "Child Point A.x post crossover";
  is $c.y, 0, "Child Point A.y post crossover";

  is $d.x, 0, "Child Point B.x post crossover";
  is $d.y, 1, "Child Point B.y post crossover";
}

class Point3D is Point {
  has Int $.z;
}

{
  my Point3D $a .= new( :x(0), :y(0), :z(0) );
  my Point3D $b .= new( :x(1), :y(1), :z(1) );

  my ($c, $d) = |$a.crossover($b, 1/2);

  is $c.x, 1, "Child Point3D A.x post crossover";
  is $c.y, 0, "Child Point3D A.y post crossover";
  is $c.z, 1, "Child Point3D A.z post crossover";

  is $d.x, 0, "Child Point3D B.x post crossover";
  is $d.y, 1, "Child Point3D B.y post crossover";
  is $d.z, 0, "Child Point3D B.z post crossover";
}

done-testing;
