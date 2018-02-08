use v6;
use Serialise::Map;

role ScaleVec::Chord::Set does Serialise::Map {
  use ScaleVec;
  use ScaleVec::Chord::Graph;
  use ScaleVec::Chord::Map;
  use ScaleVec::Chord::System;
  use ScaleVec::Scale::Fence;
  use Result;
  use Result::Imports;

  has ScaleVec::Scale::Fence $.pc-space = ScaleVec::Scale::Fence.new(
    :lower-limit(0)
    :upper-limit(12)
    :repeat-interval(12)
  );

  has ScaleVec %.chords;

  method build-system(ScaleVec %pitch-spaces --> Result) {
    my ScaleVec::Chord::Graph %chord-graphs;
    my ScaleVec::Chord::Map $chord-map .= new;
    for %pitch-spaces.kv -> $label-space, $space {
      my ScaleVec::Chord::Graph $chord-graph .= new();
      for %!chords.kv -> $label-chord, $chord {
        # Add SV to graph, transpose structure according to pitch space and place into pitch class space
        with $chord-graph.add-pv($chord.scale-pv.map( -> $e { $!pc-space.step($space.step($e)) } )) -> $pv {
          # Add graph element to system map and map the chord onto the space
          given $chord-map.relate("$label-space:$label-chord", $chord.map-onto($space), $pv) {
            when Result::Err {
              return Error qq:to/ERR/.chomp
              { .error }
              Unable to add relation for '$label-space:$label-chord' as it will overwrite elements of an existing relationship.
              ERR
            }
          }
        }
        else {
          return Error "Failed when adding '$label-space: $label-chord' to graph.";
        }
      }
      %chord-graphs{$label-space} = $chord-graph;
    }
    OK ScaleVec::Chord::System.new( :graph(%chord-graphs), :map($chord-map) );
  }

  #
  # Serialise::Map methods
  #
  method to-map( --> Map) {
    %(
      pc-space    => $!pc-space.to-map,
      chords      => %(
        %!chords.kv.map( -> $k, $v { $k => $v.to-map } )
      ),
    )
  }

  method from-map(Map $m --> ScaleVec::Chord::Set) {
    my ScaleVec %chords;
    for $m<chords>.kv -> $k, $v {
      %chords{$k} = ScaleVec.from-map($v)
    }

    self.new(
      :pc-space(ScaleVec::Scale::Fence.from-map: $m<pc-space>)
      :%chords
    )
  }
}
