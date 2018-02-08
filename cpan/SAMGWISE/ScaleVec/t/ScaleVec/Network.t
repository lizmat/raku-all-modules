#! /usr/bin/env perl6
use v6;
use Test;
use JSON::Tiny;

constant MAP_FILE = 't/res/test-network.json';

use-ok 'ScaleVec::Network';
use ScaleVec::Network;

unless ok(MAP_FILE.IO.f) {
  die "{ MAP_FILE } does not exist. Unable to conitnue test.";
}

my $map;
lives-ok {
  $map = from-json( MAP_FILE.IO.slurp)
}, "Loaded map from { MAP_FILE }";

my $graph;
lives-ok {
   $graph = network-from-map($map)
}, "Built network with network-from-map";

# Check round trip conversion.
# The extra conversions ensure we have the same datatypes as the exported types include Seqs not present in the version from JSON.
is-deeply $graph.to-map, network-from-map($graph.to-map).to-map, "Exported map agrees with imported map";

is $graph.collect-goals.elems, 3, "Correct number of goal objects";
is $graph.collect-goals[0].parent.collect-pitch-vecs.elems, 2, "Correct number of pitch vectors from goal 0";
is $graph.collect-goals[0].parent.collect-rhythm-vecs.elems, 1, "Correct number of rhythm vectors from goal 0";

done-testing
