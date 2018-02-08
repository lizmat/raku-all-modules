use v6;
use Serialise::Map;

class ScaleVec::Chord::System::Foundation::Element does Serialise::Map {
  use ScaleVec;
  use ScaleVec::Chord::Set;
  use Result;
  use Result::Imports;

  has ScaleVec  %.pitch-spaces;
  has ScaleVec::Chord::Set    $.chord-set;

  method to-map( --> Map) {
    %(
      pitch-spaces => %(
        %!pitch-spaces.kv.map( -> $k, $v { $k => $v.to-map } )
      ),
      chord-set => $!chord-set.to-map,
    )
  }

  method from-map(Map $m --> ScaleVec::Chord::System::Foundation::Element) {
    self.new(
      pitch-spaces  => $m<pitch-spaces>.kv.map( -> $k, $v { $k => ScaleVec.from-map($v) } ),
      chord-set    => ScaleVec::Chord::Set.from-map($m<chord-set>)
    )
  }

  method build-system( --> Result) {
    given $!chord-set.build-system(%!pitch-spaces) {
      when Result::Err {
        return Error qq:to/ERR/.chomp
        { .error }
        Unable to build chord system for pitch-spaces: { %!pitch-spaces.keys.join: ', ' }.
        ERR
      }
      default {
        #Pass along the Result::OK
        $_
      }
    }
  }

}
