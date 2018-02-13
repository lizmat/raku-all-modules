use v6;

sub distribute-targets(Positional $targets, Int $length --> Seq) is export {
  my $elems = $targets.elems;
  gather for $targets.kv -> $elem, $value {
    # when $value % 2 == 0 {
    #   take ($value, ceiling($elem / $length).Int)
    # }
    # default {
    #   take ($value, floor($elem / $length).Int)
    # }
    default {
      take ( $value, ($length / $elems).Int )
    }
  }
}

unit class Music::Engine::Generator::CurveMD;
use Math::Curves;

has Numeric   @.curve-current is required;
has Int       @.curve-target  is required;
has List      @.curve-queue;
has Int       $.steps is rw   is required;
has Callable  $.on-steps-finished;
has Iterator  $!curve = ().Seq.iterator;

method !curve-generator( --> Seq) {
  my @origin = @!curve-current;
  gather for 0..$!steps -> $step {
    @!curve-current = gather for 0..@!curve-current.end -> $k {
      take bézier($step.Rat / $!steps, @origin[$k], @!curve-current[$k], @!curve-target[$k])
    }
    take @!curve-current.map( *.round.Int );
  }
}

method reset-steps()
#= reset the current curve step position to 0 (within the context of the curve transition t = step/steps)
{
  $!curve = Seq().iterator;
}

method update-target(List:D $vec)
#= Update the curve generator target vector.
#= Dies if the dimensions of the old target vector does not match the new target vector.
{
  if @!curve-target.elems == $vec.elems {
    @!curve-target = |$vec
  }
  else {
    die "New target list only has { $vec.elems }, expected { @!curve-target.elems }!";
  }
}

method queue-target(Positional $target, Int $steps) {
  @!curve-queue.push: $($target, $steps);
}

method next-step( --> List)
#= Calculate the next vector of our curve.
#= If a step progression is completed, the on-steps-finished callback will be triggered and following execution the new curve segment will be started and its first step returned.
{
  given $!curve.pull-one -> $tuple {
    # HACKS!
    when $tuple.gist ~~ "IterationEnd" {
      # Clear curve and call again to begin the curve again
      $!curve  = self!curve-generator.iterator;
      given @!curve-queue.head -> ($target, $steps) {
        when $target and $steps {
          self.update-target($target);
          $!steps = $steps;
          self.reset-steps;
        }
        default {
          $!on-steps-finished(self) if defined $!on-steps-finished;
        }
      }
      return self.next-step
    }
    default {
       $tuple.values;
    }
  }
}
