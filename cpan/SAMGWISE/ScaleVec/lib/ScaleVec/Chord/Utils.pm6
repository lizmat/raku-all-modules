use v6;

unit module ScaleVec::Chord::Utils;
use JSON::Pretty;
use ScaleVec::Chord::System::Foundation;

sub load-chord-system(Str $file --> ScaleVec::Chord::System::Foundation) is export {
  ScaleVec::Chord::System::Foundation.from-map: $file.IO.slurp.&from-json
}

sub save-chord-system(Str $file, ScaleVec::Chord::System::Foundation $csf) is export {
  $file.IO.spurt: $csf.to-map.&to-json
}

sub generate-from-file(Str $file, ScaleVec::Chord::System $sys --> Seq) is export {
  gather for $file.IO.slurp.&from-json.values -> $definition {
    my $config = $definition<config>;
    return "Missing config: " ~ $config<start diffs end>.perl unless $config<start diffs end>.all ~~ *.so;
    take '-' x 78;
    take $definition<name>;
    take $sys
      .merge-graphs
      .progression-eager($sys.pv($config<start>), $config<diffs>, $sys.pv($config<end>))
      .map( { with $_ { $sys.sym($_) } else { "NA" } } )
      .fmt("% 6s")
      for 1..10;
  }
}

sub build-gen-config(Str $start, Positional $diffs, Str $end --> Map) is export {
  %(
    do for $diffs.values {
      %(
        :name($_.perl),
        config => %(
          :start($start),
          :diffs($_),
          :end($end)
        )
      )
    }
  )
}

sub collect-permutations(Positional $vec --> Seq) is export {
  gather rec-permutations($vec, ())
}

sub rec-permutations(Positional $vec, Positional $mutation) {
  if $vec.elems {
    for ^($vec.head) {
      rec-permutations($vec[1..*], ($_ + 1, $mutation.Slip))
    }
  }
  else {
    take $mutation
  }
}
