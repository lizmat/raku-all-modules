use v6;

class ScaleVec::Chord::Map {
  use ScaleVec;
  use ScaleVec::Chord::Graph;
  use Result;
  use Result::Imports;

  has ScaleVec      %!symbol-to-sv{Str};
  has Str               %!sv-to-symbol{ScaleVec};
  has ScaleVec::Chord::Graph::PV  %!sv-to-pv{ScaleVec};
  has ScaleVec      %!pv-to-sv{ScaleVec::Chord::Graph::PV};

  method relate(Str $symbol, ScaleVec $sv, ScaleVec::Chord::Graph::PV $pv --> Result) {
    # Check for collisions
    return Error "\%symbol<$symbol> already exists." if %!symbol-to-sv{$symbol}:exists;
    return Error "ScaleVec to \%symbol<$symbol> already exists as { %!sv-to-symbol{$sv} }."
      if %!sv-to-symbol{$sv}:exists;
    return Error "ScaleVec to PitchVector already exists realted to \%symbol<$symbol>."
      if %!sv-to-pv{$sv}:exists;
    return Error "PitchVector to ScaleVec already exists related to \%symbol<$symbol>."
      if %!pv-to-sv{$pv}:exists;

    # Add relationship
    %!symbol-to-sv{$symbol} = $sv;
    %!sv-to-symbol{$sv} = $symbol;
    %!sv-to-pv{$sv} = $pv;
    %!pv-to-sv{$pv} = $sv;
    OK True;
  }

  method merge(ScaleVec::Chord::Map $other --> ScaleVec::Chord::Map) {
    my ScaleVec::Chord::Map $merged .= new;
    for |self.tuples, |$other.tuples -> ($symbol, $sv, $pv) {
      $merged.relate($symbol, $sv, $pv).ok("Unable to merge ScaleVec::Chord::Maps.")
    }
    $merged
  }

  method tuples(--> Seq) {
    gather for %!symbol-to-sv.kv -> $symbol, $sv {
      take ($symbol, $sv, %!sv-to-pv{$sv})
    }
  }

  # * --> ScaleVec
  multi method sv(Str $symbol --> ScaleVec) {
    %!symbol-to-sv{$symbol}
  }
  multi method sv(ScaleVec::Chord::Graph::PV $pv --> ScaleVec) {
    %!pv-to-sv{$pv}
  }

  # * --> ScaleVec::Chord::Graph::PV
  multi method pv(Str $symbol --> ScaleVec::Chord::Graph::PV) {
    %!sv-to-pv{ %!symbol-to-sv{$symbol} }
  }
  multi method pv(ScaleVec $sv --> ScaleVec::Chord::Graph::PV) {
    %!sv-to-pv{$sv}
  }

  # * --> Str
  multi method sym(ScaleVec::Chord::Graph::PV $pv --> Str) {
    %!sv-to-symbol{ %!pv-to-sv{$pv} }
  }
  multi method sym(ScaleVec $sv --> Str) {
    %!sv-to-symbol{$sv}
  }

}
