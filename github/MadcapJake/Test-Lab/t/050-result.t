use v6;
use Test;
use lib 'lib';

use Test::Lab::Experiment;
use Test::Lab::Observation;
use Test::Lab::Result;

sub it($behavior, &block) {
  my Test::Lab::Experiment $*ex .= new(:name<experiment>);
  subtest &block, $behavior;
}

it 'is immutable', {
  my Test::Lab::Observation $control .= new
    :name('control')
    :experiment($*ex)
    :block(-> { });
  my Test::Lab::Observation $candidate .= new
    :name('candidate')
    :experiment($*ex)
    :block(-> { });
  my Test::Lab::Result $result .= new
    :experiment($*ex)
    :observations([$control, $candidate])
    :$control;
  is $result.control, $control;
  dies-ok { $result.control = 'butterfly' };
}

it 'evaluates its observations', {
  my Test::Lab::Observation $a .= new :name<a> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $b .= new :name<b> :experiment($*ex) :block({ 1 });

  ok $a.equiv-to($b);

  my Test::Lab::Result $res1 .= new
    :experiment($*ex)
    :observations([$a, $b])
    :control($a);

  ok $res1.is-matched;
  nok $res1.any-mismatched;
  is [], $res1.mismatched;

  my Test::Lab::Observation $x .= new :name<x> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $y .= new :name<y> :experiment($*ex) :block({ 2 });
  my Test::Lab::Observation $z .= new :name<z> :experiment($*ex) :block({ 3 });

  my Test::Lab::Result $res2 .= new
    :experiment($*ex)
    :observations([$x, $y, $z])
    :control($x);

  nok $res2.is-matched;
  ok $res2.any-mismatched;
  is-deeply  [$y, $z], $res2.mismatched;
}

it 'has no mismatches if there is only a control observation', {
  my Test::Lab::Observation $a .=
    new :name<a> :experiment($*ex) :block({ 1 });
  my Test::Lab::Result $r .=
    new :experiment($*ex) :observations([$a]) :control($a);
  ok $r.is-matched;
}

it 'evaluates observations using the experiment\'s comparator block', {
  my Test::Lab::Observation $a .= new
    :name<a> :experiment($*ex) :block({ '1' });
  my Test::Lab::Observation $b .= new
    :name<b> :experiment($*ex) :block({  1  });

  $*ex.comparator = &infix:<~~>;

  my Test::Lab::Result $r .= new
    :experiment($*ex) :observations([$a, $b]) :control($a);

  ok $r.is-matched, $r.mismatched;
}

it 'does not ignore any mismatches when nothing\'s ignored', {
  my Test::Lab::Observation $x .= new
    :name<x> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $y .= new
    :name<y> :experiment($*ex) :block({ 2 });
  my Test::Lab::Result $r .= new
    :experiment($*ex) :observations([$x, $y]) :control($x);
  ok $r.any-mismatched;
  nok $r.any-ignored;
}

it 'uses the experiment\'s ignore block to ignore mismatched observations', {
  my Test::Lab::Observation $x .= new
    :name<x> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $y .= new
    :name<y> :experiment($*ex) :block({ 2 });
  my $called = False;
  $*ex.ignore: -> $x, $y { $called = True };
  my Test::Lab::Result $r .= new
    :experiment($*ex) :observations([$x, $y]) :control($x);

  nok $r.any-mismatched;
  nok $r.is-matched;
  ok  $r.any-ignored;
  is $r.mismatched, [];
  is $r.ignored, [$y];
  ok $called;
}

it 'partitions observations into mismatched and ignored when applicable', {
  my Test::Lab::Observation $x .= new
    :name<x> :experiment($*ex) :block({ 'x' });
  my Test::Lab::Observation $y .= new
    :name<y> :experiment($*ex) :block({ 'y' });
  my Test::Lab::Observation $z .= new
    :name<z> :experiment($*ex) :block({ 'z' });
  $*ex.ignore: -> $control, $candidate { $candidate eq 'y' };
  my Test::Lab::Result $r .= new
    :experiment($*ex) :observations([$x, $y, $z]) :control($x);

  ok $r.any-mismatched;
  ok $r.any-ignored;
  is $r.ignored, [$y];
  is $r.mismatched, [$z];
}

it 'knows the experiment\'s name', {
  my Test::Lab::Observation $a .= new
    :name<a> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $b .= new
    :name<b> :experiment($*ex) :block({ 1 });
  my Test::Lab::Result $r .= new
    :experiment($*ex) :observations([$a, $b]) :control($a);

  is $r.experiment-name, $*ex.name;
}

it 'has the context from an experiment', {
  $*ex.context: :foo<bar>;
  my Test::Lab::Observation $a .= new
    :name<a> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $b .= new
    :name<b> :experiment($*ex) :block({ 1 });
  my Test::Lab::Result $r .= new
    :experiment($*ex) :observations([$a, $b]) :control($a);

  is $r.context, { foo => 'bar' };
}

done-testing;
