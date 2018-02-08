use v6;
use ScaleVec::Scale;
use Serialise::Map;

unit class ScaleVec::Scale::Fence does ScaleVec::Scale does Serialise::Map;

has Numeric:D $.upper-limit is required;
has Numeric:D $.lower-limit is required;
has Numeric:D $.repeat-interval is required;

method step(Numeric $step) returns Numeric {
  given $step {
    when * >= $!upper-limit {
      #$!upper-limit - $!repeat-interval
      # - (($!repeat-interval - 1) * floor( ($step - $!upper-limit) / $!repeat-interval ))
      # + $step - $!upper-limit
      $!upper-limit - ($!repeat-interval - (($step - $!upper-limit) % $!repeat-interval))
    }
    when * < $!lower-limit {
      $!lower-limit + $step % $!repeat-interval
    }
    default {
      $step;
    }
  }
}

method upper-offset() {
  $!repeat-interval - ($!upper-limit % $!repeat-interval)
}

#
# Serialise::Map methods
#

method to-map( --> Map) {
  %(
    :$!upper-limit,
    :$!lower-limit,
    :$!repeat-interval
  )
}

method from-map(Map $m --> ScaleVec::Scale::Fence) {
  self.new(|$m)
}
