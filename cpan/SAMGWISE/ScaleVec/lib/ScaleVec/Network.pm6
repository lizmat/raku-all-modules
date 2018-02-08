use v6;
use ScaleVec;

role ScaleVec::Serialise::Map { ... }
class ScaleVec::Goal does ScaleVec::Serialise::Map { ... }
class ScaleVec::Space does ScaleVec::Serialise::Map { ... }

role ScaleVec::Serialise::Map {
  method to-map( --> Map) { ... }
  method from-map(%attributes, ScaleVec::Serialise::Map :$parent) { ... }
}

class ScaleVec::Goal {
  has ScaleVec::Space $.parent;
  has Numeric         $.delta = 0;
  has                 %.values;

  method to-map( --> Map) {
    {
      delta   => $!delta,
      values  => %!values,
    }
  }

  method from-map(%attributes, ScaleVec::Serialise::Map :$parent) {
    ScaleVec::Goal.new: |%attributes, |($parent.defined ?? :$parent !! |() );
  }
}

class ScaleVec::Space {
  has ScaleVec::Space $.parent is rw;
  has ScaleVec        $.pitch  is rw;
  has ScaleVec        $.rhythm is rw;
  has ScaleVec::Space @.nested;
  has ScaleVec::Goal  @.goals;

  method collect-goals( --> Seq) {
    gather {
      for @!goals -> $goal {
        take $goal;
      }
      for @!nested -> $sub-space {
        for $sub-space.collect-goals -> $goal {
          take $goal;
        }
      }
    }
  }

  method collect-pitch-vecs( --> Seq) {
    gather {
      take $!pitch if $!pitch.defined;
      last unless $!parent.defined;
      for $!parent.collect-pitch-vecs -> $pitch-vec {
        take $pitch-vec;
      }
    }
  }

  method collect-rhythm-vecs( --> Seq) {
    gather {
      take $!rhythm if $!rhythm.defined;
      last unless $!parent.defined;
      for $!parent.collect-rhythm-vecs -> $rhythm-vec {
        take $rhythm-vec;
      }
    }
  }

  # ScaleVec::Scale methods
  method pitch-step(Numeric $step --> Numeric) {
    reduce { $^b.step: $^a }, $step, |self.collect-pitch-vecs;
  }

  method rhythm-step(Numeric $step --> Numeric) {
    reduce { $^b.step: $^a }, $step, |self.collect-rhythm-vecs;
  }

  method pitch-reflexive-step(Numeric $step --> Numeric) {
    reduce { $^b.reflexive-step: $^a }, $step, |self.collect-pitch-vecs.reverse;
  }

  method rhythm-reflexive-step(Numeric $step --> Numeric) {
    reduce { $^b.reflexive-step: $^a }, $step, |self.collect-rhythm-vecs.reverse;
  }

  # Serialise::Map methods
  method to-map( --> Map) {
    {
      # delegate to array elements
      nested => @!nested.map( { .to-map } ),
      goals  => @!goals.map( { .to-map } ),
      # if defined include pitch
      (
        $!pitch.so
        ?? pitch => {
          vector          => $!pitch.vector,
          repeat-interval => $!pitch.repeat-interval,
        }
        !! |()
      ),
      # if defined include rhythm
      (
        $!rhythm.so
        ?? rhythm => {
          vector          => $!rhythm.vector,
          repeat-interval => $!rhythm.repeat-interval,
        }
        !! |()
      ),
    }
  }

  method from-map(%attributes, ScaleVec::Serialise::Map :$parent) {
    my ScaleVec::Space $space;
    $space .= new(
      |($parent.defined            ?? :$parent                                     !! |() ),
      |(%attributes<pitch>:exists  ?? pitch  => ScaleVec.new(|%attributes<pitch>)  !! |() ),
      |(%attributes<rhythm>:exists ?? rhythm => ScaleVec.new(|%attributes<rhythm>) !! |() ),
    );

    for |(%attributes<nested>:exists ?? %attributes<nested> !! |()) -> $nested-space {
      $space.nested.push: ScaleVec::Space.from-map($nested-space, :parent($space))
    }

    for |(%attributes<goals>:exists ?? %attributes<goals> !! |()) -> $goal {
      $space.goals.push: ScaleVec::Goal.from-map($goal, :parent($space))
    }

    $space
  }

}

sub EXPORT {
  {
   '&network-from-map'  => sub (%attributes) { ScaleVec::Space.from-map: %attributes },
   'ScaleVec::Space'    => ScaleVec::Space,
   'ScaleVec::Goal'     => ScaleVec::Goal,
   'ScaleVec::Serialise::Map' => ScaleVec::Serialise::Map,
  }
}
