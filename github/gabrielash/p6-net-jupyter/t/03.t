#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say 'testing Executer -  Basic'; 
use Net::Jupyter::Executer;

my $*so = $*OUT;
my $timeout = 4;
ok run-with-timeout(  { say "RUNNING WITH TIMEOUT " } , :$timeout);
$timeout = 1;
dies-ok {run-with-timeout(  { say "SLEEPING WITH TIMEOUT ";sleep 3;1 } , :$timeout)};

sub fy(*@args) { return @args.join("\n") ~ "\n"};

sub test-result($exec, $v, $o, $e) {
  if $exec.value.defined && $exec.value.starts-with('sub') {
    ok 'sub' eq $v, "return value sub { $v.gist } ";
  }else {
    ok $exec.value  === $v.gist, "return value {$exec.value}<=>{ $v.gist }";
  }
  ok $exec.out  eq $o, "output -->" ~ $exec.out.chomp ~ "::" ~ $o.chomp ~ "<--";
  if $e  {
    ok $exec.err.index($e).defined, "err $e";  #":{ $exec.err }";
  } else {
    ok $exec.err  === Str, "No error test";
  }
}

my @code = [
    [''],
    ['use v6;'
    , 'my $z=3;'
    ],
   [
    'my $y=7+(11/1);'
      , 'my  $x = 4 * 8 + $z;'
      , 'say q/YES/;'
      , 'say $x/1;'
    ],
    [ 'sub xx($d) {', 
      '  return $d*2;',
      '}'      
    ], 
    [  'xx($m)'
    ],
    [
      'say xx(10);'
    ],
    [
      'say 10/0;'
    ],
    [
      'use NO::SUCH::MODULE;'
    ],
    [ '{'  ],
    [ '15/0' ],
    [ '%% timeout 1 %%', 'sleep 10' ],
    [ '%% timeout 10 %%', 'sleep 1;','say 7;' ]


];

sub get-exec($i) { my $c=fy(|@code[$i]); say $c;return  Executer.new(:code($c));}

my Executer $exec;
my $t = 0;

if 1 {
lives-ok { test-result(get-exec(0), Any, '', Any) }, "test {++$t} lives";
lives-ok { test-result(get-exec(1), 3, '', Any) }, "test {++$t} lives";
lives-ok { test-result(get-exec(2), True, "YES\n35\n", Any) }, "test {++$t} lives";
lives-ok { test-result(get-exec(3), 'sub', '', Any) }, "test {++$t} lives";
lives-ok { test-result(get-exec(4), Any, '', 'not declared') }, "test {++$t} lives";
lives-ok { test-result(get-exec(5), True, "20\n", Any) }, "test {++$t} lives";
lives-ok { test-result(get-exec(6), Any, '', 'by zero') }, "test {++$t} lives";
lives-ok { test-result(get-exec(7), Any, '', 'find NO::SUCH::MODULE') }, "test {++$t} lives";
lives-ok { get-exec(0).reset }, 'reset' ; 
lives-ok { test-result(get-exec(2), Any, '', 'not declared') }, "test {++$t} lives";
lives-ok { test-result(get-exec(8), Any, '', 'Missing block') }, "test {++$t} lives";

lives-ok { get-exec(9) }, "15/0 exec";
lives-ok { test-result(get-exec(9), Any, '', 'by zero') }, "test {++$t} lives";
}
lives-ok { test-result(get-exec(10), Any, '', 'timed out') }, "test {++$t} lives";
lives-ok { test-result(get-exec(11), True, "7\n", Any) }, "test {++$t} lives";
pass "...";

done-testing;
