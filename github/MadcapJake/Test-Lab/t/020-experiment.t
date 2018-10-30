use v6;
use Test;
use lib 'lib';

use Test::Lab::Experiment;
use Test::Lab::Result;
use Test::Lab::Errors;

class Fake is Test::Lab::Experiment {
  has $.published-result;
  has @!exceptions;
  method exceptions { @!exceptions }
  method died($operation, Exception $exception) {
    @!exceptions.push: ($operation, $exception);
  }
  method is-enabled { True }
  method publish(Test::Lab::Result $result) { $!published-result = $result }
}

subtest {
  subtest {
    my $ex = Test::Lab::Experiment.new(:name<hello>);
    isa-ok $ex, Test::Lab::Experiment, 'uses builtin defaults';
    is $ex.name, "hello", "default name properly set";
  }, 'has a default implementation';

  is Fake.new.name, "experiment", "properly defaults to 'experiment'";

  subtest {
    plan 2;
    my $ex = Fake.new();
    try {
      $ex.run;
      CATCH {
        when X::BehaviorMissing {
          pass 'properly throws BehaviorMissing exception';
          is 'control', $_.name, 'the missing behavior is the control';
        }
      }
    }
  }, "can't be run without a control behavior";

  {
    my $ex = Fake.new();
    $ex.use: { 'control' }

    is 'control', $ex.run, 'is a straight pass-through with only a control behavior'
  }

  {
    my $ex = Fake.new();
    $ex.use: { 'control' }
    $ex.try: { 'candidate' }

    is 'control', $ex.run, 'runs other behaviors but alwas returns the control';
  }

  subtest {
    plan 3;

    my $ex = Fake.new();
    $ex.use: { 'control' }

    try {
      CATCH {
        when X::BehaviorNotUnique {
          pass 'caught duplicate control block';
          is $ex, $_.experiment, 'exception has the experiment';
          is 'control', $_.name, 'exception has the name';
        }
        default { flunk 'did not return correct Exception' }
      }
      $ex.use: { 'control-again' }
      flunk 'Did not throw error on duplicate control block';
    }

  }, 'complains about duplicate behavior names';

  {
    my $ex = Fake.new;
    $ex.use: { 'control' }
    $ex.try: { die 'candidate' }

    is 'control', $ex.run, 'swallows exceptions thrown by candidate behaviors';
  }

  {
    my $ex = Fake.new;
    $ex.use: { die 'control' }
    $ex.try: { 'candidate' }

    try {
      $ex.run;
      CATCH {
        default {
          is 'control', $_.message,
             'passes through exceptions thrown by the control behavior' }
      }
    }
  }

  =begin TakesLong
  subtest {
    plan 1;

    my $ex = Fake.new;
    my ($last, @runs);

    $ex.use: { $last = 'control' }
    $ex.try: { $last = 'candidate' }

    for ^1000 { $ex.run; @runs.push: $last }
    ok @runs.unique.elems > 1;
  }, 'shuffles behaviors before running';
  =end TakesLong

  subtest {
    plan 3;

    my $ex = Test::Lab::Experiment.new(:name<hello>);
    isa-ok $ex, Test::Lab::Experiment;
    my role Boom { method publish($result) { die 'boomtown' } }
    $ex = $ex but Boom;

    $ex.use: { 'control' }
    $ex.try: { 'candidate' }

    try {
      $ex.run;
      CATCH {
        when X::AdHoc {
          pass 'adhoc error thrown';
          is 'boomtown', $_.message
        }
      }
      flunk 'never threw boomtown error';
    }

  }, 're-throws exceptions thrown during publish by default';

  subtest {
    plan 3;

    my $ex = Fake.new;
    my role Boom { method publish($result) { die 'boomtown' } }
    $ex = $ex but Boom;

    $ex.use: { 'control' }
    $ex.try: { 'candidate' }

    is 'control', $ex.run;

    my (\op, \exception) = $ex.exceptions.pop;

    is 'publish', op;
    is 'boomtown', exception.message;
  }, 'reports publishing errors';

  subtest {
    plan 2;

    my $ex = Fake.new;
    $ex.use: { 1 }
    $ex.try: { 1 }

    is 1, $ex.run;
    ok $ex.published-result.defined;
  }, 'publishes results';

  subtest {
    plan 2;

    my $ex = Fake.new;
    $ex.use: { 1 }

    is 1, $ex.run;
    nok $ex.published-result;
  }, 'does not publish results when there is only a control value';

  subtest {
    plan 2;

    my Fake $ex .= new;
    $ex.comparator = -> $a, $b { $a ~~ $b }
    $ex.use: { '1' }
    $ex.try: {  1  }

    is '1', $ex.run;
    ok $ex.published-result.is-matched;
  }, 'compares results with a comparator block if provided';

  subtest {
    plan 2;

    my Fake $experiment .= new;
    my Test::Lab::Observation $a .= new :name('a') :$experiment :block({ 1 });
    my Test::Lab::Observation $b .= new :name('b') :$experiment :block({ 2 });

    ok  $experiment.obs-are-equiv($a, $a);
    nok $experiment.obs-are-equiv($a, $b);
  }, 'knows how to compare two experiments';

  {
    my Fake $experiment .= new;
    my Test::Lab::Observation $a .= new :name('a') :$experiment :block({ '1' });
    my Test::Lab::Observation $b .= new :name('b') :$experiment :block({  1  });
    $experiment.comparator = -> $a, $b { $a ~~ $b };

    ok $experiment.obs-are-equiv($a, $b),
      'uses a compare block to determine if observations are equivalent';
  }

  subtest {
    plan 3;

    my Fake $experiment .= new;
    $experiment.comparator = -> $a, $b { die 'boomtown' }
    $experiment.use: { 'control' }
    $experiment.try: { 'candidate' }

    is 'control', $experiment.run;

    my (\op, \ex) = $experiment.exceptions.pop;

    is 'compare', op;
    is 'boomtown', ex.message;
  }, 'reports errors in a compare block';

  subtest {
    plan 3;

    my Fake $experiment .= new;
    my role EnabledError { method is-enabled { die 'kaboom' } };
    $experiment = $experiment but EnabledError;
    $experiment.use: { 'control' }
    $experiment.try: { 'candidate' }

    is 'control', $experiment.run;

    my (\op, \ex) = $experiment.exceptions.pop;

    is 'enabled', op;
    is 'kaboom', ex.message;
  }, 'reports errors in the is-enabled method';

  subtest {
    plan 3;

    my Fake $experiment .= new;
    $experiment.run-if = { die 'kaboom' }
    $experiment.use: { 'control' }
    $experiment.try: { 'candidate' }

    is 'control', $experiment.run;

    my (\op, \ex) = $experiment.exceptions.pop;

    is 'run-if', op;
    is 'kaboom', ex.message;
  }, 'reports errors in a run-if block';

  {
    my Fake $experiment .= new;

    is $experiment.clean-value(10), 10, 'returns the given value when no clean block is configured';
  }

  {
    my Fake $experiment .= new;
    $experiment.cleaner = { .uc }

    is $experiment.clean-value('test'), 'TEST',
      'calls the configured clean routine with a value when configured';
  }

  subtest {
    plan 4;

    my Fake $experiment .= new;
    $experiment.cleaner = -> $value { die 'kaboom' }
    $experiment.use: { 'control' }
    $experiment.try: { 'candidate' }

    is $experiment.run, 'control';
    is $experiment.published-result.control.cleaned-value, 'control';

    my (\op, \ex) = $experiment.exceptions.pop;

    is op, 'clean';
    is ex.message, 'kaboom';
  }, 'reports an error and returns the original vlaue when an' ~
     'error is raised in a clean block';

}, 'Test::Lab::Experiment';

subtest {
  {
    my ($candidate-ran, $run-check-ran) = False xx 2;
    my Fake $experiment .= new;
    $experiment.use: { 1 }
    $experiment.try: { $candidate-ran = True; 1 }
    $experiment.run-if = { $run-check-ran = True; False }

    $experiment.run;

    ok  $run-check-ran, 'run-if is properly called';
    nok $candidate-ran, 'does not run the experiment if run-if returns false';
  }

  {
    my ($candidate-ran, $run-check-ran) = False xx 2;
    my Fake $experiment .= new;
    $experiment.use: { True }
    $experiment.try: { $candidate-ran = True }
    $experiment.run-if = { $run-check-ran = True }

    $experiment.run;

    ok $run-check-ran, 'run-if is properly called';
    ok $candidate-ran, 'runs the experiment if the given block returns true';
  }
}, 'Test::Lab::Experiment.run-if';

subtest {
  sub prep {
    my Fake $experiment .= new;
    ($experiment,
     Test::Lab::Observation.new :name<a> :$experiment :block({ 1 }),
     Test::Lab::Observation.new :name<b> :$experiment :block({ 2 }))
  }
  sub it($behavior, &block) {
    my ($*ex, $*a, $*b) = prep();
    subtest &block, $behavior;
  }

  it 'does not ignore an observation if no ignores are configured', {
    nok $*ex.ignore-mismatched-obs($*a, $*b);
  }

  it 'calls a configured ignore block with the given observed values', {
    my $c = False;
    $*ex.ignore: -> $a, $b {
      is $*a.value, $a;
      is $*b.value, $b;
      $c = True;
    }
    ok $*ex.ignore-mismatched-obs($*a, $*b);
    ok $c;
  }

  it 'calls multiple ignore blocks to see if any match', {
    my ($called-one, $called-two, $called-three) = False xx 3;
    $*ex.ignore: -> $a, $b { $called-one   = True; False }
    $*ex.ignore: -> $a, $b { $called-two   = True; False }
    $*ex.ignore: -> $a, $b { $called-three = True; False }
    nok $*ex.ignore-mismatched-obs($*a, $*b);
    ok $called-one;
    ok $called-two;
    ok $called-three;
  }

  it "only calls ignore blocks until one matches", {
    my ($called-one, $called-two, $called-three) = False xx 3;
    $*ex.ignore: -> $a, $b { $called-one   = True; False }
    $*ex.ignore: -> $a, $b { $called-two   = True; True  }
    $*ex.ignore: -> $a, $b { $called-three = True; False }
    ok $*ex.ignore-mismatched-obs: $*a, $*b;
    ok $called-one;
    ok $called-two;
    nok $called-three;
  }

  it 'reports exceptions raised in an ignore block and returns false', {
    $*ex.ignore: -> $a, $b { die 'kaboom' }
    nok $*ex.ignore-mismatched-obs($*a, $*b);
    my (\op, \exception) = $*ex.exceptions.pop;
    is op, 'ignore';
    is exception.message, 'kaboom';
  }

  it 'skips ignore blocks that throw and tests any remaining ' ~
     'blocks if an exception is swalloed', {
    $*ex.ignore: -> $a, $b { die 'kaboom' }
    $*ex.ignore: -> $a, $b { True }
    ok $*ex.ignore-mismatched-obs($*a, $*b);
    is $*ex.exceptions.elems, 1;
  }

}, 'Test::Lab::Experiment.ignore-mismatched-obs';

subtest {
  sub it($behavior, &block) {
    my role Dier { has $!throw-on-mismatches }
    my Fake $ex .= new;
    my $*ex = $ex but Dier;
    subtest &block, $behavior;
  }

  it 'throws when there is a mismatch if throw-on-mismatches ' ~
     'is enabled', {
    $*ex.throw-on-mismatches: True;
    $*ex.use: { 'fine' }
    $*ex.try: { 'not fine' }
    throws-like { $*ex.run }, X::Test::Lab::Mismatch;
  }

  it 'doesn\'t throw when there is a mismatch if ' ~
     'throw-on-mismatches is disabled', {
    plan 2;
    $*ex.throw-on-mismatches: False;
    $*ex.use: { 'fine' }
    $*ex.try: { 'not fine' }
    lives-ok { is $*ex.run, 'fine' };
  }

  it 'throws a Mismatch error if the control raises ' ~
     'and candidate doesn\'t', {
    plan 1;
    $*ex.throw-on-mismatches: True;
    $*ex.use: { die 'control' }
    $*ex.try: { 'candidate' }
    throws-like { $*ex.run }, X::Test::Lab::Mismatch;
  }

  it 'throws a Mismatch error if the candidate raises ' ~
     'and control doesn\'t', {
    plan 1;
    $*ex.throw-on-mismatches: True;
    $*ex.use: { 'control' }
    $*ex.try: { die 'candidate' }
    throws-like { $*ex.run }, X::Test::Lab::Mismatch;
  }

  subtest {

    it 'throws when there is a mismatch if the experiment ' ~
       'instance\'s throw-on-mismatches is enabled', {
      Fake.throw-on-mismatches: False;
      $*ex.throw-on-mismatches: True;
      $*ex.use: { 'fine' }
      $*ex.try: { 'not fine' }
      throws-like { $*ex.run }, X::Test::Lab::Mismatch;
    }

    it 'doesn\'t throw when there is a mismatch if the ' ~
       'experiment instance\'s throw-on-mismatches is disabled', {
      Fake.throw-on-mismatches: True;
      $*ex.throw-on-mismatches: False;
      $*ex.use: { 'fine' }
      $*ex.try: { 'not fine' }
      is $*ex.run, 'fine';
    }

    it 'respects the throw-on-mismatches class variable by default', {
      Fake.throw-on-mismatches: False;
      $*ex.use: { 'fine' }
      $*ex.try: { 'not fine' }
      is $*ex.run, 'fine';
      Fake.throw-on-mismatches: True;
      throws-like { $*ex.run }, X::Test::Lab::Mismatch;
    }

  }, 'method throw-on-mismatches';

  subtest {

    sub it($behavior, &block) {
      Fake.throw-on-mismatches: True;
      my $*ex = Fake.new;
      $*ex.use: { 'foo' }
      $*ex.try: { 'bar' }
      my $*err;
      try {
        CATCH { default { $*err = $_; subtest &block, $behavior } }
        $*ex.run;
      }
    }

    it 'has the name of the experiment', {
      is $*err.name, $*ex.name;
    }

    it 'includes the experiments\' results', {
      is $*err.result, $*ex.published-result;
    }

    it 'formats nicely as a string', {
      is $*err.Str, q:to/ERROR/;
      experiment experiment observations mismatched:
      control:
        "foo"
      candidate:
        "bar"
      ERROR
    }

    it 'includes the backtrace when an observation throws', {
      my $mismatch;
      my Fake $experiment .= new;
      $experiment.use: { 'value' }
      $experiment.try: { die 'error' }
      try {
        CATCH {
          when X::Test::Lab::Mismatch {
            pass 'X::Test::Lab::Mismatch thrown';
            $mismatch = $_;
          }
          default { flunk 'wrong error thrown' }
        }
        $experiment.run;
        flunk 'no error thrown';
      }
      my $lines = $mismatch.Str.lines;
      is $lines[1], 'control:';
      is $lines[2], '  "value"';
      is $lines[3], 'candidate:';
      is $lines[4], '  X::AdHoc.new(payload => "error")';
      like $lines[5], /\s+in\s.+\sat\s.+\sline\s\d+/;
    }

  }, 'X::Test::Lab::Mismatch';

}, 'throwing on mismatches';

subtest {

  subtest {
    my Fake $ex .= new;
    my ($cont-ok, $cand-ok, $before) = False xx 2;
    $ex.before = { $before = True }
    $ex.use: { $cont-ok = $before }
    $ex.try: { $cand-ok = $before }

    $ex.run;

    ok $before,  '«before» should have run';
    ok $cont-ok, 'control should have run after «before»';
    ok $cand-ok, 'candidate should have run after «before»';
  }, 'runs when an experiment is enabled';

  subtest {
    my $before = False;
    my Fake $f .= new;
    my role FalseEnabled { method is-enabled { False } }
    my $ex = $f but FalseEnabled;
    $ex.before = { $before = True }
    $ex.use: { 'value' }
    $ex.try: { 'value' }
    $ex.run;

    nok $before, '«before» should not have run';
  }

}, '«before» block';


done-testing;
