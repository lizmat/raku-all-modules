use v6;
use Serialise::Map;

class ScaleVec::Chord::System::Foundation does Serialise::Map {
  use ScaleVec::Chord::System::Foundation::Element;
  use Result;
  use Result::Imports;

  has ScaleVec::Chord::System::Foundation::Element @.chord-system;

  method to-map( --> Map) {
    %(
      chord-system => @!chord-system.map( *.to-map )
    )
  }

  method from-map(Map $m --> ScaleVec::Chord::System::Foundation) {
    self.new(
      chord-system => $m<chord-system>.map( { ScaleVec::Chord::System::Foundation::Element.from-map: $_ } )
    )
  }

  method build-system( --> Result) {
    return Error "Empty attribute \@.chord-system, unable to build ScaleVec::Chord::System." unless @!chord-system;

    reduce {
      my ($l, $r) = ($^a, $^b);
      return $l if $r ~~ Result::Err;

      given $r.build-system {
        when Result::Err {
          return $_
        }
        default {
          $l.value.merge-systems($_.value)
        }
      }
    }, @!chord-system[0].build-system, |@!chord-system[1..*];
  }

}
