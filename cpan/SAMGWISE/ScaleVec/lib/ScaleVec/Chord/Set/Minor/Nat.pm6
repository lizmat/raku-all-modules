use v6;
use ScaleVec::Chord::Set;

class ScaleVec::Chord::Set::Minor::Nat does ScaleVec::Chord::Set {
use ScaleVec;

  submethod BUILD(:%chords) {
    %!chords = %(
      <i ii° III iv v VI VII>.kv.map( -> $n, $symbol {
        $symbol => ScaleVec.new( :vector( (0, 2, 4, 7).map(* + $n) ) )
      })
    );

    %!chords{%chords.keys} = %chords.values;
  }
}
