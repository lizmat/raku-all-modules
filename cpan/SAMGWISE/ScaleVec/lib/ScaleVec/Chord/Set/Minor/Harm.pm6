use v6;
use ScaleVec::Chord::Set;

class ScaleVec::Chord::Set::Minor::Harm does ScaleVec::Chord::Set {
use ScaleVec;

  submethod BUILD(:%chords) {
    %!chords = %(
      <i ii° III iv v VI VII>.kv.map( -> $n, $symbol {
        $symbol => ScaleVec.new( :vector( (0, 2, 4, 7).map(* + $n) ) )
      })
    );

    %!chords<III v VII>:delete;
    %!chords<III+ V vii°> = .new( :vector(2, 4, 6.5) ), .new( :vector(4, 6.5, 8) ), .new( :vector(6.5, 8, 10) ) given ScaleVec;
    %!chords{%chords.keys} = %chords.values;
  }
}
