#! /usr/bin/env perl6
use v6;
use Test;

use-ok('ScaleVec::Chord::Graph');
use ScaleVec::Chord::Graph;

my ScaleVec::Chord::Graph $graph .= new;

$graph.add-pc(0..11);
is $graph.pitch-classes, 0..11, "pitch-classes matches input";

$graph.add-pc(0..11);
is $graph.pitch-classes, 0..11, "add-pc does not add non-unique elements";

$graph.add-pv((0, 4, 7));
is $graph.links.elems, 3, "add-pv creates links";
is $graph.vectors.head.vector, (0, 4, 7), "add-pv then vector to check links to PCs";
is $graph.pitches.head.collect-pitch-vectors.head.vector, (0, 4, 7), "add-pv then pitches to check links to PVs";

is $graph.to-map,
  {
    pitch-classes => [0..11],
    pitch-vectors => [ [0, 4, 7] ]
  },
  "to-map output structure without links";

is $graph.from-map($graph.to-map).to-map, $graph.to-map, "to-map <=> from-map round trip";

$graph.add-pv: (2, 5, 9);     # ii
$graph.add-pv: (4, 7, 11);    # iii
$graph.add-pv: (5, 9, 0);     # IV
$graph.add-pv: (7, 11, 2);    # V
$graph.add-pv: (7, 11, 2, 5); # V7
$graph.add-pv: (9, 0, 4);     # vi
$graph.add-pv: (11, 2, 5);    # vii dim
my ($i, $ii, $iii, $iv, $v, $v7, $vi, $vii) = $graph.vectors;
is $i.difference($ii), 3, "difference I to ii";
is $i.difference($iii), 1, "difference I to iii";
is $i.difference($iv), 2, "difference I to IV";
is $i.difference($v), 2, "difference I to V";
is $i.difference($v7), 3, "difference I to V7";
is $i.difference($vi), 1, "difference I to vi";
is $i.difference($vii), 3, "difference I to vii";

is $i.neighbours.elems, 5, "neighbours returns all connected chords";
is $v7.neighbours.elems, 6, "neighbours returns all connected chords";

is $i.is-eqv($i), True, "is-eqv I = I?";
is $i.is-eqv($v), False, "is-eqv I = V?";
is $v.is-eqv($v7), False, "is-eqv V = V7?";
is $v7.is-eqv($v), False, "is-eqv V7 = V?";

is $graph.progression-lazy($i, (), 0, $i).elems, 2, "progression-lazy provides correct number of chords";
is $graph.progression-lazy($i, (2, 1, 2), 3, $i).elems, 5, "progression-lazy provides correct number of chords";
is $graph.progression-lazy($i, (2, 1, 1, 1), 4, $i).elems, 6, "progression-lazy provides correct number of chords";

my $graph-dmajor = ScaleVec::Chord::Graph.new;
for $graph.vectors {
  $graph-dmajor.add-pv( .vector.map( (* + 2) % 12) )
}
is $graph-dmajor.vectors.elems, 8, "graph size for d-major, after generation";

my $graph-c-and-d = $graph.graph-union($graph-dmajor);
is $graph-c-and-d.vectors.elems, $graph-dmajor.vectors.elems + $graph.vectors.elems, "graph size unioned";

# Test lazy progression planner
{
  my @progression = $graph-c-and-d.progression-lazy($i, (2, 1, 2), 3, $graph-dmajor.vectors.head);
  is @progression.head, $i, "Chord progression (lazy) starts on the chord the generator was given.";
  is @progression.tail, $graph-dmajor.vectors.head, "Chord progression (lazy) ends on the chord the generator was given.";
  is @progression.elems, 5, "Progression (lazy) is the correct length.";
  # Test differences
  is @progression[1].difference(@progression[0]), 2, "Progression (lazy) difference 0 <- 1";
  is @progression[2].difference(@progression[1]), 1, "Progression (lazy) difference 1 <- 2";
  #is @progression[1].difference(@progression[0]), 2, "Progression difference 0 <- 1"; # Lazy generator cannot allways satisfy this criteria.
  is @progression[4].difference(@progression[3]), 2, "Progression (lazy) difference 3 <- 4";
}

# Test eager progression planner
{
  my @progression = $graph-c-and-d.progression-eager($i, (2, 1, 2), $graph-dmajor.vectors.head);
  is @progression.head, $i, "Chord progression (eager) starts on the chord the generator was given.";
  is @progression.tail, $graph-dmajor.vectors.head, "Chord progression (eager) ends on the chord the generator was given.";
  is @progression.elems, 4, "Progression (eager) is the correct length.";
  # Test differences
  is @progression[1].difference(@progression[0]), 2, "Progression (eager) difference 0 <- 1";
  is @progression[2].difference(@progression[1]), 1, "Progression (eager) difference 1 <- 2";
  is @progression[3].difference(@progression[2]), 2, "Progression (eager) difference 2 <- 3";
}

# Test exhaustive progression planner
diag "{ '-' x 78 }\n Beginning progression planner (exhastive) tests.\n{ '-' x 78 }";
{
  my $solution-count = 0;
  for $graph-c-and-d.progression-exhaustive($i, (2, 1, 2), $graph-dmajor.vectors.head) -> @progression {
    ++$solution-count;
    is @progression.head, $i, "Chord progression (exhaustive) starts on the chord the generator was given.";
    is @progression.tail, $graph-dmajor.vectors.head, "Chord progression (exhaustive) ends on the chord the generator was given.";
    is @progression.elems, 4, "Progression (exhaustive) is the correct length.";
    # Test differences
    is @progression[1].difference(@progression[0]), 2, "Progression (exhaustive) difference 0 <- 1";
    is @progression[2].difference(@progression[1]), 1, "Progression (exhaustive) difference 1 <- 2";
    is @progression[3].difference(@progression[2]), 2, "Progression (exhaustive) difference 2 <- 3";
  }
  is $solution-count, 5, "Exhastive search yeilds correct number of results.";
}
done-testing
