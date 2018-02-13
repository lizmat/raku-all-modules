use v6;

unit class Music::Engine::CounterPoint;

use Music::Engine::Generator::CurveMD;
use ScaleVec;
use ScaleVec::Scale::Fence;
use ScaleVec::Scale::Stack;

has ScaleVec $.chromatic = ScaleVec.new( :vector(0..12) );
has Numeric $.max-range = 15;
has Callable $.on-phrase-start;

# lazy
has ScaleVec::Scale::Fence $!class-space;
method class-space( --> ScaleVec::Scale::Fence ) {
  return $!class-space if $!class-space.defined;
  $!class-space .= new(
    :repeat-interval($!chromatic.repeat-interval)
    :lower-limit(0)
    :upper-limit($!chromatic.repeat-interval)
  );
}

has ScaleVec $.tonal-space = ScaleVec.new( :vector(0, 2, 4, 5, 7, 9, 11, 12) );

method update-tonal-space(ScaleVec:D $new-space) {
  $!tonal-space = $new-space;
  #clear $!pitch-space so it can be rebuilt
  $!pitch-space = ScaleVec::Scale::Stack;
}

# lazy
has ScaleVec::Scale::Stack $!pitch-space;
method pitch-space( --> ScaleVec::Scale::Stack ) {
  return $!pitch-space if $!pitch-space.defined;
  $!pitch-space .= new( :scales($!tonal-space, $!chromatic) );
}

has Set $.perfect-consonants    = Set(0, 7, 12);
has Set $.imperfect-consonants  = Set(3, 4, 8, 9);
#my Set $disonants             .= new: 1, 2, 5, 6, 10, 11;

our enum IntervalQaulity<perfect-consonant imperfect-consonant disonant>;

has Music::Engine::Generator::CurveMD $!contour handles<reset-steps, steps> = Music::Engine::Generator::CurveMD.new(
  :curve-current(12, -12)
  :curve-target(8, -8)
  :steps(8)
);

method update-contour-target(Int $upper, Int $lower) {
  $!contour.update-target: ($upper, $lower)
}

method notes(Seq $curves, Int $length --> Seq) {
  for distribute-targets($curves.values, $length) -> ($target, $duration) {
    my $values = $target.values;
    $!contour.queue-target: $values, $duration;
    say "Added $values targets to queue";
  }
  say "Current curve queue: { $!contour.curve-queue.perl }";
  $!on-phrase-start(self, :contour($!contour)) if $!on-phrase-start.defined;

  say "Chromatic: { $!chromatic.vector.perl }";
  say "Tonal space: { $!tonal-space.vector.perl }";

  my $upper;
  my $lower;
  return gather for 0..$length -> $i {
    my $values = $!contour.next-step;
    my $start = now;
    say $values;
    my $upper-target = self.pitch-space.step: $values[0];
    my $lower-target = self.pitch-space.step: $values[1];
    say "Target: $upper-target, $lower-target";

    if $i == 0 {
      $lower = $lower-target unless $lower.defined;

      for 1,3,5,7 -> $r {
        put "Search scope $r";
        # say "searching range $r, options: { self.options($upper-target, $r) }";
        given self.select: $lower, $upper-target, self.options($upper-target, $r).Set, perfect-consonant -> $next {
          when $next.defined {
            $upper = $next;
            last;
          }
        }
      }
    }
    elsif $i + 1 == $length {
      $lower = self.select:
                  $lower-target,
                  $lower,
                  set(
                    $lower-target,
                    |$!perfect-consonants.keys.sort.map( * + $lower-target).grep( * != $lower-target).first,
                    |$!perfect-consonants.keys.sort.map( $lower-target - *).grep( * != $lower-target).first
                  ),
                  perfect-consonant;
      $lower = $lower-target if !$lower.defined;

      for 1,3,5,7 -> $r {
        put "Search scope $r";
        given self.select: $lower, $upper, set(|self.options($upper, $r), |($upper-target..$upper)), perfect-consonant -> $next {
          when $next.defined {
            $upper = $next;
            last;
          }
        }
      }

    }
    else {
      $upper = (|self.options($upper-target, 1), |($upper-target..$upper)).grep( -> $option { $option != $upper } ).pick;

      for 1,3,5,7 -> $r {
        put "Search scope $r";
        given self.select: $upper, $lower, set(|self.options($lower-target, $r), |($lower-target..$lower)), imperfect-consonant -> $next {
          when $next.defined {
            $lower = $next;
            last;
          }
        }
      }

      die "Failed to select a value! (upper = { $upper.perl }, lower = { $lower.perl })" unless all($upper, $lower).defined;
    }

    say "{ :$upper.perl }, { :$lower.perl }";

    #say "int({ sprintf "%3d -> %3d) = %3d -> CS = %2d", $upper, $lower, $_, self.class-space.step($_) } ({ self.classify-quality: $_ })" given self.pitch-space.interval: $upper, $lower;
    die "Unable to allocate upper voice" unless $upper.defined;
    die "Unable to allocate lower voice for upper voice $upper" unless $lower.defined;
    warn "Lower voice is higher than upper voice!" unless $upper >= $lower;
    put "Selection: { now - $start }";
    take $($upper, $lower)
  }
}

method classify-quality(Numeric $interval --> IntervalQaulity) {
  # Rat types do not match Int types of the same value in Sets
  given self.class-space.step($interval) {
    when * ~~ $!perfect-consonants.keys.any {
      perfect-consonant
    }
    when * ~~ $!imperfect-consonants.keys.any {
      imperfect-consonant
    }
    default {
      disonant
    }
  }
}

method options(Numeric $pitch, Numeric $range --> Seq) {
  # say '--- options() ---';
  # say "CS.root -> { $!chromatic.root }";
  # say "CS.repeat-interval -> { $!chromatic.repeat-interval }";
  # say "CS.step(0) -> { $!chromatic.step(0) }";
  # say "CS.step(12) -> { $!chromatic.step(12) }";
  # say "CS.step(24) -> { $!chromatic.step(24) }";
  # say "CS.interval(23, 24) -> { $!chromatic.interval(23, 24) }";
  # say "CS.reflexive($pitch) -> { $!chromatic.reflexive-step($pitch) }";

  given $!tonal-space.reflexive-step($!chromatic.reflexive-step($pitch)) -> $step {
    ( ($step - $range)..($step + $range) ).map( -> $n { self.pitch-space.step($n) } )
  }
}

method select(Numeric $known, Numeric $previous, Set $options, IntervalQaulity $quality --> Numeric:D) {
  # say "$previous → { $options.keys.map: -> $o { "$o ({ self.class-space.step(self.chromatic.interval($known, $o)) })" } } against $known";
  $options.keys.grep( -> $option {
    $option != $previous
      and abs($known - $option) < $!max-range
      and self.classify-quality(self.chromatic.interval($known, $option).Int) ~~ $quality
  } ).pick;
}
