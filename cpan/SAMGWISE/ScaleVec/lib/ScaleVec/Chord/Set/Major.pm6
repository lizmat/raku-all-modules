use v6;
use ScaleVec::Chord::Set;

class ScaleVec::Chord::Set::Major does ScaleVec::Chord::Set {
use ScaleVec;

  submethod BUILD(:%chords) {
    %!chords = %(
      <I ii iii IV V vi vii°>.kv.map( -> $n, $symbol {
        $symbol => ScaleVec.new( :vector( (0, 2, 4, 7).map(* + $n) ) )
      })
    );

    %!chords{%chords.keys} = %chords.values;
  }
}
