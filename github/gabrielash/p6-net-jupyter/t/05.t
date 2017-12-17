#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say 'testing Executer -  Advanced'; 
use Net::Jupyter::Executer;


sub fy(*@args) { return @args.join("\n") ~ "\n"};

sub test-result($exec, $v, $o, $e) {
  if $exec.value.defined && $exec.value.starts-with('sub') {
    ok 'sub' eq $v, "return value sub { $v.gist } ";
  }else {
    ok $exec.value  === $v.gist, "return value { $v.gist}<=>{$exec.value}";
  }
  ok $exec.out  eq $o, "output -->" ~ $o.chomp ~ '::' ~ $exec.out.chomp ~ "<--";
  if $e.defined  {
    ok $exec.err.index($e).defined, "$e:{ $exec.err }";
  } else {
    ok $exec.err  === Str, "No error test";
  }
}

my @code = [ []
    ,[ '%% timeout 1 %%', 'sleep 10' ]
    ,[ '%% timeout 10 %%', 'sleep 1;','say 7;' ]
    ,[ '%% class A %%', '{ method a {say "A is Here" }}','A.a;' ]       #3    
    ,[ 'class A ', '{ method a {say "A is Here" }}','A.a;;' ]            #4
];

sub get-exec($i) { my $c=fy(|@code[$i]); say $c;return  Executer.new(:code($c));}

my Executer $exec;
my $t = 0;


if 0 {
  my $*so = $*OUT;
  my $timeout = 4;
  ok run-with-timeout(  { say "RUNNING WITH TIMEOUT " } , :$timeout);
  $timeout = 1;
  dies-ok {run-with-timeout(  { say "SLEEPING WITH TIMEOUT ";sleep 3;1 } , :$timeout)};

  lives-ok { test-result(get-exec(1), Any, '', 'timed out') }, "test {++$t} lives";
  lives-ok { test-result(get-exec(2), True, "7\n", Any) }, "test {++$t} lives";
}

lives-ok { test-result(get-exec(3), True, "A is Here\n", Any) }, "test {++$t} lives" for 0,1,2;
lives-ok { test-result(get-exec(4), True, "A is Here\n", Any) }, "test {++$t} lives WRONG WHY?";
#lives-ok { test-result(get-exec(4), Any, '', 'Redeclaration') }, "test {++$t} lives";



done-testing;
