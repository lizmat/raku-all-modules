#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say 'testing basic functionality of ContextREPL'; 

use Net::Jupyter::EvalError;
use Net::Jupyter::ContextREPL;

my ContextREPL $r = ContextREPL.get-repl;
ok $r.isa(ContextREPL), 'got REPL';


sub test-repl($code, %result, :$key, :$null) {
    %result<value error out> = (Nil,Nil,Nil); 
    say $code;
    my $out = $*OUT;
    my $capture ='';
    $*OUT = class { method print(*@args) {  $capture ~= @args.join; True }
                    method flush { True }}
    try {
      %result<value> = $r.eval($code, :no-context) if $null;
      %result<value> = $r.eval($code, $key) if ($key && ! $null);
      %result<value> = $r.eval($code) unless ($key || $null);
      CATCH {
        default {
          %result<error> = EvalError.new( :exception($_)).format(:short);
        }
      }
    }
    $*OUT = $out;
    %result<out> = $capture;
}
sub fy(*@args) { return @args.join("\n") ~ "\n"};

sub test-result(%r, $v, $o, $e) {
  %r<value> = %r<value>.perl if %r<value>.isa(Rat);
  ok %r<value>  === $v, "return value { %r<value>.gist }<=>{ $v.gist } ";
  ok %r<out>    === $o, "output -->" ~ %r<out> ~"<-- ";
  if $e.defined && %r<error>.defined {
    ok %r<error>.index($e).defined, ": " ~ %r<error>.substr(0,90);
  } else {
    ok %r<error>  === $e, "error is {%r<error>.gist }<=>{ $e.gist} ";
  }
}

my %result;
my @code = [
    [''],
    ['use v6;'
    , 'my $z=3;'],
   [
    'my $y=7+(11/1);'
      , 'my  $x = 4 * 8 + $z;'
      , 'say q/YES/;'
      , 'say $x/1;'
    ],
    [ 'sub xx($d) {', 
      '  return $d*2;',
      '}',
      'xx($z)'
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
    [ '{ say 10;'],
    [ '15/0'],
    [ 'grammar G { token TOP { <a>+ }','token a { "d-x" -  }}'  ]

];

my %e1 = %*ENV;
my $t = 0;
if 1 {
lives-ok {test-repl(fy(|@code[0]), %result)}, "test {++$t} lives";
ok %e1.perl eq %*ENV.perl, say 'ENV Invariant';

lives-ok {test-repl(fy(|@code[1]), %result)}, "test {++$t} lives";
test-result(%result, 3, '', Any );

lives-ok {test-repl(fy(|@code[2]), %result)}, "test {++$t} lives";
test-result(%result, True, "YES\n35\n", Any );

lives-ok {test-repl(fy(|@code[3]), %result)}, "test {++$t} lives";
test-result(%result, 6, "", Any );

lives-ok {test-repl(fy(|@code[3]), %result, :null)}, "test {++$t} lives";
test-result(%result, Any, "", 'not declared' );

lives-ok {test-repl(fy(|@code[3]), %result, :key('OTHER'))}, "test {++$t} lives";
test-result(%result, Any, "", 'not declared' );

lives-ok {test-repl(fy(|@code[1]), %result, :key('OTHER'))}, "test {++$t} lives";
test-result(%result, 3, "", Any );
lives-ok {test-repl(fy(|@code[3]), %result, :key('OTHER'))}, "test {++$t} lives";
test-result(%result, 6, "", Any );

lives-ok {test-repl(fy(|@code[1]), %result, :null)}, "test {++$t} lives";
test-result(%result, 3, "", Any );
lives-ok {test-repl(fy(|@code[3]), %result, :null)}, "test {++$t} lives";
test-result(%result, Any, "", 'not declared' );

lives-ok {test-repl(fy(|@code[4]), %result)}, "test {++$t} lives";
test-result(%result, True, "20\n", Any );

lives-ok {test-repl(fy(|@code[5]), %result)}, "test {++$t} lives";
test-result(%result, Any, "", 'by zero' );

lives-ok {test-repl(fy(|@code[6]), %result)}, "test {++$t} lives";
test-result(%result, Any, "", 'find NO::SUCH::MODULE' );

lives-ok { $r.reset('OTHER') }, 'reset OTHER' ; 
lives-ok {test-repl(fy(|@code[3]), %result, :key('OTHER'))}, "test {++$t} lives";
test-result(%result, Any, "", 'not declared'  );
lives-ok {test-repl(fy(|@code[3]), %result)}, "test {++$t} lives";
test-result(%result, 6, "", Any );

lives-ok {test-repl(fy(|@code[7]), %result)}, "test {++$t} lives";
test-result(%result, Any, "", 'Missing block' );

lives-ok {test-repl(fy(|@code[8]), %result)}, "test {++$t} lives";
test-result(%result, Any, "", 'by zero' );
}
lives-ok {test-repl(fy(|@code[9]), %result)}, "test {++$t} lives";
test-result(%result, Any, "", 'metacharacter' );

say %result;


pass "...";

done-testing;

