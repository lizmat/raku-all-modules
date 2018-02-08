use v6;

class ScaleVec::Chord::Graph::PC    { ... }
class ScaleVec::Chord::Graph::PV    { ... }
class ScaleVec::Chord::Graph::Link  { ... }

class ScaleVec::Chord::Graph::PC {
  has Numeric $.value;
  has ScaleVec::Chord::Graph::Link @.pitch-vectors;

  method collect-pitch-vectors( --> Seq) {
    gather for @!pitch-vectors.map( *.pv ) -> $pv {
      take $pv;
    }
  }
}

class ScaleVec::Chord::Graph::PV {
  has ScaleVec::Chord::Graph::Link @.pitch-classes;

  method vector( --> Seq) {
    gather for @!pitch-classes -> $l {
      take $l.pc.value;
    }
  }

  method collect-pitch-classes( --> Seq) {
    gather for @!pitch-classes.map( *.pc ) -> $pc {
      take $pc;
    }
  }

  method is-eqv(ScaleVec::Chord::Graph::PV $other --> Bool) {
    self.vector eqv $other.vector;
  }

  # commutative common tone difference score
  method difference(ScaleVec::Chord::Graph::PV $other --> Int) {
    my $vector = self.vector;
    if $vector.elems > $other.vector.elems {
      $vector.elems - $other.vector.map( -> $o { ($o == $vector.any) ?? 1 !! 0 } ).sum
    }
    else {
      $other.vector.elems - $vector.map( -> $v { ($v == $other.vector.any) ?? 1 !! 0 } ).sum
    }
  }

  method neighbours( --> Seq) {
    unique gather for self.collect-pitch-classes -> $pc {
      for $pc.collect-pitch-vectors -> $pv {
        take $pv unless $pv ~~ self
      }
    }
  }

  method Str( --> Str) {
    join ', ', self.vector;
  }

  method identity( --> ScaleVec::Chord::Graph::PV) {
    self;
  }
}

class ScaleVec::Chord::Graph::PV::Unioned is ScaleVec::Chord::Graph::PV {
  has ScaleVec::Chord::Graph::PV $.pre-union is required;

  method identity( --> ScaleVec::Chord::Graph::PV) {
    $!pre-union.identity;
  }
}

class ScaleVec::Chord::Graph::Link {
  has ScaleVec::Chord::Graph::PC $.pc;
  has ScaleVec::Chord::Graph::PV $.pv;
}

class ScaleVec::Chord::Graph {
  has ScaleVec::Chord::Graph::PC    @!pitch-classes;
  has ScaleVec::Chord::Graph::Link  @!links;
  has ScaleVec::Chord::Graph::PV    @!pitch-vectors;

  #
  # Access API
  #

  method add-pc(Positional $pitch-classes --> Seq) {
    for $pitch-classes.unique -> $pc {
      @!pitch-classes.push: ScaleVec::Chord::Graph::PC.new( :value($pc) ) unless $pc == @!pitch-classes.map( *.value ).any
    }
    @!pitch-classes .= sort( { $^a.value <=> $^b.value } );
    @!pitch-classes.values
  }

  method pitch-classes( --> Seq) {
    @!pitch-classes.map( *.value )
  }

  method pitches( --> Seq) {
    @!pitch-classes.values
  }

  method vectors( --> Seq) {
    @!pitch-vectors.values
  }

  method links( --> Seq) {
    @!links.values
  }

  method add-pv(Positional $pitch-vector --> ScaleVec::Chord::Graph::PV) {
    my ScaleVec::Chord::Graph::PV $pv .= new;
    for self.add-pc($pitch-vector).grep( *.value == $pitch-vector.any) -> $pc {
      my ScaleVec::Chord::Graph::Link $link .= new( :$pc, :$pv);
      $pv.pitch-classes.push: $link;
      $pc.pitch-vectors.push: $link;
      @!links.push: $link;
    }
    @!pitch-vectors.push: $pv;
    $pv
  }

  method link-pv(ScaleVec::Chord::Graph::PV $pv --> ScaleVec::Chord::Graph::PV::Unioned) {
    my ScaleVec::Chord::Graph::PV::Unioned $u-pv .= new: :pre-union($pv);
    for self.add-pc($pv.vector).grep( *.value == $pv.vector.any) -> $pc {
      my ScaleVec::Chord::Graph::Link $link .= new( :$pc, :$u-pv);
      $u-pv.pitch-classes.push: $link;
      $pc.pitch-vectors.push: $link;
      @!links.push: $link;
    }
    @!pitch-vectors.push: $u-pv;
    $u-pv
  }

  #
  # Search API
  #

  # A chord generator which sacrifices quality for laziness
  method progression-lazy(ScaleVec::Chord::Graph::PV:D $start, Positional $diffs, Int $steps, ScaleVec::Chord::Graph::PV $end --> Seq) {
    my $current-pv = $start;
    gather {
      take $start;
      for $diffs.kv -> $n, $diff {
        if $end.defined and $n >= ($steps - 1) {
          with @!pitch-vectors.grep( { $_.difference($current-pv) == $diffs.tail } ).grep( { $end.difference($_) == $diffs.tail } ).pick {
            take $_
          } else {
            take @!pitch-vectors.grep( { $end.difference($_) == $diffs.tail } ).pick
          }
        }
        else {
          $current-pv = @!pitch-vectors.grep( { $_.difference($current-pv) == $diff } ).pick;
          take $current-pv;
        }
      }
      take $end if $end.defined;
    }
  }

  # A chord generator which sacrifices laziness for quality
  method progression-eager(ScaleVec::Chord::Graph::PV:D $start, Positional $diffs, ScaleVec::Chord::Graph::PV:D $end --> Positional) {
    self!recursive-chord-search($start, $diffs, $end)
  }

  method !recursive-chord-search(ScaleVec::Chord::Graph::PV:D $node, Positional $diffs, ScaleVec::Chord::Graph::PV:D $target --> Positional) {
    # is it a terminal state?
    if $diffs.elems == 1 {
      if $target.difference($node) == $diffs[0] {
        # note 'finished';
        return ($node, $target);
      }
      else {
        # note 'no - options';
        return (ScaleVec::Chord::Graph::PV, )
      }
    }
    # else try to move towards a final state
    my ($current-diff, $remaining-diffs) = $diffs[0], $diffs[1..*];
    for @!pitch-vectors.grep( { .difference($node) == $current-diff } ).sort( { 100.rand <=> 100.rand } ) -> $chord-option {
      given self!recursive-chord-search($chord-option, $remaining-diffs, $target) -> $results {
        when $results.elems > 0 and $results.head.defined {
          # note "collected: { ($node, |$results).elems } nodes";
          return $node, |$results;
        }
      }
    }

    # note 'no - options';
    (ScaleVec::Chord::Graph::PV, )
  }

  #
  # Returns a Sequence of all solutions which match the given diffs.
  #
  method progression-exhaustive(ScaleVec::Chord::Graph::PV:D $start, Positional $diffs, ScaleVec::Chord::Graph::PV:D $end --> Seq) {
    my ScaleVec::Chord::Graph::PV @chords;
    my @options = [$start], ;
    gather for 1..(@!pitch-vectors.elems ** $diffs.elems) {
      # note "options: ({ @options.elems }):({ @options.map( *.elems ).join: ', ' }), chords: ({ @chords.elems })";

      # Complete answer
      when @chords.end == ($diffs.end + 1) {
        #note "Collecting answer.";
        take @chords.List; # collect
        # return to search level prior to beginning terminal state checking
        @chords.pop; #remove end
        @chords.pop; #remove previous chord
        @options.pop; # remove trailing option
      }

      # Try adding end
      when @chords.end == $diffs.end {
        # note "Checking end condition.";
        if $end.difference(@chords.tail) == $diffs.tail {
          #note "Adding end chord.";
          @chords.push: $end
        }
        else {
          # note "Unable to reach end condition.";
          @chords.pop; # remove failed option
          @options.pop; # remove trailing option
        }
      }

      # End search
      when !@options.so {
        # note "Search complete";
        last
      }

      # Step back up our search tree when no options left
      when !@options.tail.so {
        # note "Stepping search back.";
        @options.pop;
        @chords.pop;
      }

      # step down into search tree
      default {
        # note "Stepping search forward searching diff($_) => { $diffs[$_] }." given @chords.end + 1;
        @options.push: my $current = @options.pop;

        @chords.push: $current.pop;
        with @!pitch-vectors.grep( { .difference(@chords.tail) == $diffs[@chords.end] } ) {
          # note "Adding { .elems } options.";
          @options.push: .Array;
        }
        else {
          # note "No valid options from selected chord";
          @chords.pop; #remove invalid step
        }
      }
    }
  }

  #
  # Save load behaviour
  #

  method to-map( --> Map) {
    {
      pitch-vectors => [@!pitch-vectors.map( *.vector )],
      pitch-classes => [@!pitch-classes.map( *.value )],
    }
  }

  method from-map(Map $map) {
    my $new = self.new();
    for $map<pitch-vectors>.values -> $pv {
      $new.add-pv($pv)
    }
    $new.add-pc($map<pitch-classes>);
    $new
  }

  #
  # Graph to graph interactions
  #

  method graph-union(ScaleVec::Chord::Graph $other --> ScaleVec::Chord::Graph) {
    #my %union = (pitch-vectors => [], pitch-classes => []);
    my ScaleVec::Chord::Graph $union .= new;
    for |self.pitches, |$other.pitches -> $pc {
      $union.add-pc(($pc.value,));
    }
    for |self.vectors, |$other.vectors -> $pv {
      $union.link-pv($pv);
    }
    $union
  }
}

sub EXPORT {
  {
   #'&network-from-map'  => sub (%attributes) { ScaleVec::Space.from-map: %attributes },
   #'ScaleVec::Chord::Graph'         => ScaleVec::Chord::Graph,
   'ScaleVec::Chord::Graph::PC'     => ScaleVec::Chord::Graph::PC,
   'ScaleVec::Chord::Graph::PV'     => ScaleVec::Chord::Graph::PV,
   'ScaleVec::Chord::Graph::Link'   => ScaleVec::Chord::Graph::Link,
  }
}
