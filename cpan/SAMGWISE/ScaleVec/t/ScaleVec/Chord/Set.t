#! /usr/bin/env perl6
use v6;
use Test;
plan 7;

use-ok 'ScaleVec::Chord::Set';
use ScaleVec::Chord::Set;
use ScaleVec;

my ScaleVec::Chord::Set $major .= new(
  :chords(
    <I ii iii IV V vi vii°>.kv.map( -> $n, $symbol {
      $symbol => ScaleVec.new( :vector( (0, 2, 4, 7).map(* + $n) ) )
    })
  )
);

is $major.defined, True, "Created ScaleVec::Chord::Set";

my ScaleVec $major-scale .= new( :vector(0, 2, 4, 5, 7, 9, 11, 12) );

my ScaleVec %scales =
  C => $major-scale;

my $world = $major.build-system(%scales).ok("Building chord system failed!");
is $world.graph.defined,            True, "Graph is defined";
is $world.map.defined,              True, "Map is defined";
is $world.graph<C>:exists,          True, "Graph for provided scale C exists";
is $world.graph<C>.vectors.elems,   7,    "Graph is complete";
is $world.map.tuples.elems,         7,    "Map is complete";
