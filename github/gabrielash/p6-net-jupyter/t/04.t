#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say 'testing Magic grammer'; 

use Net::Jupyter::Magic;

sub fy(*@args) { return @args.join("\n") ~ "\n"};

multi sub test-magic(@code, :$o , :$f  --> Magic ) {
  my $code = fy(@code); 
  my $valid = $f ?? 'invalid' !! 'valid';
  my Magic $m = Magic.parse($code);
  my $perl-code = $m.perl-code;
  say "CODE:\n$code\n---" if $o;

  CATCH { when X::Jupyter::MalformedMagic { 
      ok $f, "$valid code test " ~ $code.substr(0,16) ~ " :$_";
      return $m }}

  say "PERL:\n$perl-code\n---" if $o;
  say "--perl6 -c -e '$perl-code'--" if $o;

  ok  ($f ^^ shell "perl6 -c -e '$perl-code' " 
                    ~ ($o ?? '' !! ' 2>/dev/null') ), "testing $valid code";
  $m;
}

my @code-good = [  [],
    [''],           #1
    [' '],          #2    
    [';'] ,         #3    
    ['use v6;'      #4
    , 'my $z=3;'
    ],
    [
    '%% timeout 7 %%',  #5
    'my $y=7+(11/1);'
    ],
   [
    '%% class MyClass %%',           #6
    '%%   class  MyClass2 %%',
    '{ method a {say "I am method a" } };'
    ],
  [
    '%% class  MyClass begin  %%',    #7
    '%% class  MyClass end  %%',
    '%% class  MyClass cont  %%',
    '%% class  MyClass continue  %%',
    'my $y=7+(11/1);'
    ],

  ];


my @code-bad = [ [],
   [
    '%%  timeout 9   %%',           #1
    'my $y=7+(11/1);',
    '%% timeout 3 %%',
    'my $y=7+(11/1);',
    ],
    [
    '%% timeout %%',                #2
    'my $y=7+(11/1);'
    ],
    [
    '%% timeout 10 seconds %%',     #3
    'my $y=7+(11/1);'       
    ],
    [
    '%% timeout 1 %',               #4
    'my $y=7+(11/1);'
    ],
    [
    '%% timeout 1 %%',               #5
    '% timeout 2 %%',                
    'my $y=7+(11/1);'
    ],
  ];

say 'syntax magic tests' ;

test-magic( @code-good[1] );
test-magic( @code-good[2] );
test-magic( @code-good[3] );
test-magic( @code-good[4] );
test-magic( @code-good[5] );
test-magic( @code-good[6] );
#test-magic( @code-good[7] );  not implemented yet

test-magic( @code-bad[1], :f);
test-magic( @code-bad[2], :f);
test-magic( @code-bad[3], :f);
test-magic( @code-bad[4], :f);
test-magic( @code-bad[5], :f);

say 'runtime magic tests' ;

done-testing;
