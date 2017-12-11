#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say 'testing EvalError'; 

use MONKEY-SEE-NO-EVAL;
use Net::Jupyter::EvalError;

sub test-ex($code) {
  my $rval = Nil;
  try {
    $rval = EVAL($code);
    CATCH {
      default { # .say
        return EvalError.new( :exception($_));
      }
    }
  }
  return $rval;
}
sub check-error-fields(%e , $ex, Str $type, Str $name, Bool $met, Str $gist , Str $ctx, Str $trace='') {
    ok %e<type> eq $type, "type ok";
    ok %e<ename> eq $name, "ename ok";
    ok %e<dependencies-error> === $met, "DEP ok";
    ok %e<gist>.index( $gist ).defined, "msg ok";
    ok (%e<context>.index( $ctx) || ($ctx eq '' && %e<context> eq '')) , "context ok";
    ok ((%e<traceback> eq $trace eq '' )|| %e<traceback>.index($trace).defined  ) , "trace ok";
    ok %e<perl>.index('.new(').defined, "perl ok";
    ok %e<status> eq 'error', "status ok";
    ok %e<evalue>.index( %e<gist> ).defined, "evalue ok";
    ok %e<evalue> eq $ex.format(:short), 'short error message ok';
    ok $ex.format(:long).index(%e<ename>).defined, 'long error message ok';
    ok $ex.format(:full).index(%e<perl>).defined, 'full error message ok';
}



my $code = 'my $x = 7';
my $rval = test-ex($code);
my %error;
my $short;
my $long;
my $full;
ok ! $rval.isa(  EvalError ), " '$code' => $rval";

$code = '$x = 7';
$rval = test-ex($code);
ok $rval.isa(  EvalError ), " '$code' => Error Found ";
ok (%error = $rval.extract), "extraction passed";

check-error-fields(%error, $rval, 'Compilation Error', 'X::Undeclared'
                    , False, 'not declared', '--->', '');

$code = 'say 7/0';
$rval = test-ex($code);
ok $rval.isa(  EvalError ), " '$code' => Error Found ";
ok (%error = $rval.extract), "extraction passed";
check-error-fields(%error, $rval, 'Runtime Error', 'X::Numeric::DivideByZero'
                    , False, 'by zero', '', 'in method');

$code = 'use NO::SUCH::MODULE;';
$rval = test-ex($code);
ok $rval.isa(  EvalError ), " '$code' => Error Found ";
ok (%error = $rval.extract), "extraction passed";
check-error-fields(%error, $rval, 'Runtime Error', 'X::CompUnit::UnsatisfiedDependency'
                    , True, 'not find NO::', '', 'load_module');

try {
    say 7/0;
 CATCH {
  default {
          my $err = EvalError.new( :exception($_)).format(:short);
          ok $err.index('by zero').defined, "short Format Chaining OK: $err"; 
          }
  }
}


pass "...";

done-testing;
