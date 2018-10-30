use v6;
use Test;
use lib 'lib';

use Test::Lab;

use-ok 'Test::Lab';

{
  my $r = lab 'test', -> $e {
    $e.use: { 'control'   }
    $e.try: { 'candidate' }
  }
  is $r, 'control', 'provides a helper to instantiate and run experiments';
}

is-deeply Hash.new, Test::Lab::<%context>, "provides an empty default context";

{
  Test::Lab::<%context>.push: (:default);

  my $experiment;
  lab 'test', -> $e {
    $experiment := $e;
    $e.context :inline;
    $e.use: -> { }
  }

  ok $experiment.defined, "experiment can be bound out of a lab procedure";
  ok $experiment.context<default>, 'pre-procedure context is kept';
  ok $experiment.context<inline>, 'intra-procedure context is kept';
}

{
  my $experiment;
  my $result = lab 'test', -> $e {
    $experiment := $e;

    $e.try: -> { True  }, :name<first-way>;
    $e.try: -> { False }, :name<secnd-way>;
  }, :run<first-way>;

  ok $result, 'Runs the named test instead of the control';
}

{
  my $experiment;
  my $result = lab 'test', -> $e {
    $experiment := $e;

    $e.use: -> { True  };
    $e.try: -> { False }, :name<second-way>;
  }, :run(Nil);

  ok $result, 'Runs control when there is a Nil named test';
}

{
  class NewDefault is Test::Lab::Experiment {
    method is-enabled { False }
    method publish($result) { }
  }
  Test::Lab::<$experiment-class> = NewDefault;
  lab 'test', -> $e {
    $e.use: -> { True  };
    $e.try: -> { False };
    isa-ok $e, NewDefault, 'Lets you override what the lab sub uses for a class';
    nok $e.is-enabled, 'uses new overriden classes methods';
  }
}

done-testing;
