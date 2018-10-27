#| The immutable result of running an experiment
unit class Test::Lab::Result;

#| An array of candidate Observations.
has @.candidates is readonly;

#| The control Observation to which the rest are compared.
has $.control is readonly;

#| An Experiment.
has $!experiment;

#| An array of observations which didn't match the control,
#| but where ignored.
has @.ignored is readonly;

#| An array of observations which didn't make the control.
has @.mismatched is readonly;

#| An array of observations in execution order.
has @!observations;

submethod BUILD(:$!experiment, :@!observations, :$!control) {
  @!candidates = gather {
    @!observations.map({ if $_ !=== $!control { take $_ } })
  }
  self.evaluate-candidates;
}

#| The experiment's context
method context { $!experiment.context }

#| The name of the experiment
method experiment-name { $!experiment.name }

#| Was the result a match between all behaviors?
method is-matched { @!mismatched.elems == 0 and not self.any-ignored }

#| Were there mismatches in the behaviors?
method any-mismatched { @!mismatched.any.so }

#| Where there any ignored mismatches?
method any-ignored { @!ignored.any.so }

#| Evaluate the candidates to find mismatched and
#| ignored resuls.
#|
#| Sets @!ignored and @!mismatched with the ignored
#| and mismatched candidates.
method evaluate-candidates {
  my @all-mismatches = gather {
    for @!candidates {
      take $_ unless $!experiment.obs-are-equiv($!control, $_);
    }
  }
  for @all-mismatches {
    if $!experiment.ignore-mismatched-obs($!control, $_)
    { @!ignored.push($_) } else { @!mismatched.push: $_ }
  }
}
