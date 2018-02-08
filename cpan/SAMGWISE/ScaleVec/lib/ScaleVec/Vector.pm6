use v6;
use ScaleVec::Vectorable;
use ScaleVec::Scale::Intervalic;

unit role ScaleVec::Vector does ScaleVec::Vectorable does ScaleVec::Scale::Intervalic;

use ScaleVec::Scale;

method ordered() returns ScaleVec::Vector {
  self.new(
    :vector(self.vector)
    :repeat-interval(self.repeat-interval)
    :ordered
  );
}

method default-repeat-interval() returns Numeric {
  self.interval-vector.sum;
}

method intervals() returns Seq {
  return Seq unless self.vector.elems > 1;
  given self.root -> $root {
    return self.vector[1..*].map: * - $root;
  }
}

method map-onto(ScaleVec::Scale $scale) returns ScaleVec::Vector {
  self.new(
    :vector( self.scale-pv.map( { $scale.step: $_ } ) )
  );
}

method inversion(Int $i) returns ScaleVec::Vector {
  given $i {
    when 0 {
      return self.new( :vector(self.vector), :repeat-interval(self.repeat-interval) :ordered );
    }
    when * > 0 {
      given $i mod (self.intervals.elems + 1) {
        return self.new(
          :vector(
            self.vector.kv.map( -> $k, $v { $k < $i ?? $v + self.repeat-interval !! $v } )
          )
          :repeat-interval(self.repeat-interval)
          :ordered
        );
      }
    }
    when * < 0 {
      return self.new(
        :vector(
          self.vector.reverse.kv.map( -> $k, $v { -$k > $i ?? $v - self.repeat-interval !! $v } ).reverse
        )
        :repeat-interval(self.repeat-interval)
        :ordered
      );
    }
  }
}

method mirror-inversion() returns ScaleVec::Vector {
  self.new(
    :vector( self.vector.map( -> $v { -$v } ) )
    :repeat-interval(self.repeat-interval)
  )
}

method transpose(Numeric $interval is required) returns ScaleVec::Vector {
  self.new(
    :vector( self.vector.map: -> $v { $v + $interval } )
    :repeat-interval(self.repeat-interval)
  )
}

method retrograde() returns ScaleVec::Vector {
  self.new( :vector(self.vector.reverse) :repeat-interval(self.repeat-interval) )
}

method iv-retrograde() returns ScaleVec::Vector {
  self.new( :vector( iv-to-pv(
      self.interval-vector.reverse,
      :root(self.root)
    ))
    :repeat-interval(self.repeat-interval)
  )
}

# Augment
multi method augment(Int $steps) returns ScaleVec::Vector {
  self.new( :vector(self.vector.map: * + $steps) :repeat-interval(self.repeat-interval) )
}
multi method augment(Rat $ratio) returns ScaleVec::Vector {
  self.new( :vector(self.vector.map: { $_ + ($_ * $ratio) }) :repeat-interval(self.repeat-interval) )
}

# Diminish
multi method diminish(Int $steps) returns ScaleVec::Vector {
  self.new( :vector(self.vector.map: * - $steps) :repeat-interval(self.repeat-interval) )
}
multi method diminish(Rat $ratio) returns ScaleVec::Vector {
  self.new( :vector(self.vector.map: { $_ - ($_ * $ratio) }) :repeat-interval(self.repeat-interval) )
}

method map-between(ScaleVec::Vector $set) returns Seq {
  gather for self.vector.kv -> $vec-key, $vec-val {
    for $set.vector.kv -> $set-key, $set-val {
      take $vec-key => $set-key if $vec-val % self.repeat-interval == $set-val % self.repeat-interval
    }
  }
}

method map-between-self() returns Seq {
  self.map-between(self.ordered)
}

method voice-leading-permutations(ScaleVec::Vector $other) returns Seq {
  gather for self.vector -> $v {
    take $other.vector.map: * - $v;
  }
}

method interval-vector-diff(ScaleVec::Vector $other) returns Seq {
  gather for self.interval-vector Z $other.interval-vector -> ($a, $b) {
    take $b - $a;
  }
}

method distance(ScaleVec::Vector $other) returns Numeric {
  (self.vector Z $other.vector).map( -> ($a, $b) { ($b - $a)**2 } ).sum.sqrt
}

method cycle(Int $step) returns Numeric {
  given self.vector -> $pv {
    return $pv[$step % $pv.elems];
  }
}

#
# Extension transforms
#
method append(Numeric $e --> ScaleVec::Vector) {
  self.new( :vector(|self.vector, $e) :repeat-interval(self.repeat-interval) )
}

method prepend(Numeric $e --> ScaleVec::Vector) {
  self.new( :vector($e, |self.vector) :repeat-interval(self.repeat-interval) )
}
