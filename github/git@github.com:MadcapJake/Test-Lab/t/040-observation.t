use v6;
use Test;
use lib 'lib';

use Test::Lab::Experiment;

sub it($behavior, &block) {
  my Test::Lab::Experiment $*ex .= new(:name<test>);
  subtest &block, $behavior;
}

it 'observes and records the execution of a block', {
  plan 3;
  my Test::Lab::Observation $ob .= new
    :name<test>
    :experiment($*ex)
    :block({ sleep 0.1; 'ret' });
  is $ob.value, 'ret', 'value is «ret»';
  nok $ob.did-die, '«did-die» returns False';
  is-approx $ob.duration, 0.1, 0.05,'«duration» "is-approx" 0.1 seconds';
  # ok ($ob.duration - 0.1) ~~ 0..0.05, '«duration» "is-approx" 0.1 seconds';
}

it 'stashes exceptions', {
  plan 3;
  my Test::Lab::Observation $ob .= new
    :name<test>
    :experiment($*ex)
    :block({ die 'exceptional' });
  ok $ob.did-die;
  is $ob.exception.message, 'exceptional';
  nok $ob.value.defined;
}

it 'compares values', {
  plan 2;

  my Test::Lab::Observation $a .= new :name<test> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $b .= new :name<test> :experiment($*ex) :block({ 1 });

  ok $a.equiv-to($b);

  my Test::Lab::Observation $x .= new :name<test> :experiment($*ex) :block({ 1 });
  my Test::Lab::Observation $y .= new :name<test> :experiment($*ex) :block({ 2 });

  nok $x.equiv-to($y);
}

it 'compares exception messages', {
  plan 2;

  my Test::Lab::Observation $a .= new
    :name<test>
    :experiment($*ex)
    :block({ die 'error' });
  my Test::Lab::Observation $b .= new
    :name<test>
    :experiment($*ex)
    :block({ die 'error' });

  ok $a.equiv-to($b);

  my Test::Lab::Observation $x .= new
    :name<test>
    :experiment($*ex)
    :block({ die 'error' });
  my Test::Lab::Observation $y .= new
    :name<test>
    :experiment($*ex)
    :block({ die 'ERROR' });

  nok $x.equiv-to($y);
}

it 'compares exception classes', {
  plan 2;

  my class X::FirstError  is Exception { method message { 'error' } }
  my class X::SecondError is Exception { method message { 'error' } }

  my Test::Lab::Observation $x .= new
    :name<test>
    :experiment($*ex)
    :block({ X::FirstError.new.throw });
  my Test::Lab::Observation $y .= new
    :name<test>
    :experiment($*ex)
    :block({ X::SecondError.new.throw });
  my Test::Lab::Observation $z .= new
    :name<test>
    :experiment($*ex)
    :block({ X::FirstError.new.throw });

  ok $x.equiv-to($z);
  nok $x.equiv-to($y);
}

it 'compares values using a comparator block', {
  plan 3;

  my Test::Lab::Observation $a .= new :name<test> :experiment($*ex) :block({  1  });
  my Test::Lab::Observation $b .= new :name<test> :experiment($*ex) :block({ '1' });

  nok $a.equiv-to($b);
  ok $a.equiv-to($b, -> $x, $y { $x ~~ $y });

  my @yielded;
  $a.equiv-to($b, -> $x, $y {
    @yielded.push: $x;
    @yielded.push: $y;
    True
  });
  is-deeply [$a.value, $b.value], @yielded;
}

subtest {

  it 'returns the observation\'s value by default', {
    my Test::Lab::Observation $a .= new :name<test> :experiment($*ex) :block({ 1 });
    is $a.cleaned-value, 1;
  }

  it 'uses the experiment\'s clean block to clean a value when configured', {
    $*ex.cleaner = -> $val { $val.uc }
    my Test::Lab::Observation $a .= new :name<test> :experiment($*ex) :block({ 'test' });
    is $a.cleaned-value, 'TEST';
  }

}, '.cleaned-value';

done-testing;
