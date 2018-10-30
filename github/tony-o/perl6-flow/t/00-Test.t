#!/usr/bin/env perl6

use Test;
use lib 'lib';
plan 1;

my @expected = 
  'ok - true',
  'not ok - false',
  'not ok - Int.new',
  'not ok - Hash.new', 
  'not ok - Failure',
  'not ok - %()',
  'ok - A.new',
  'not ok - A',
  'not ok - true',
  'ok - false',
  'ok - Int.new',
  'ok - Hash.new', 
  'ok - Failure',
  'ok - %()',
  'not ok - A.new',
  'ok - A',
;

class A { };

my Int $index = 0;
my @output;

{
  use Flow::Test;# :DEFAULT;

  ok True, "true";
  ok False, "false";
  ok Int.new, 'Int.new';
  ok Hash.new, 'Hash.new';
  ok Failure, 'Failure';
  ok %(), '%()';
  ok A.new, 'A.new';
  ok A, 'A';
  nok True, "true";
  nok False, "false";
  nok Int.new, 'Int.new';
  nok Hash.new, 'Hash.new';
  nok Failure, 'Failure';
  nok %(), '%()';
  nok A.new, 'A.new';
  nok A, 'A';

  @output.append(|@(debug-test-data<output><_>));
}

my $passing = True;
my $pass = 0;
my $fail = 0;
for @expected -> $e {
  my $passt = $e eq @output[$index];
  $pass++ if     $passt;
  $fail++ unless $passt;
  $index++;
}

$passing = $pass == +@expected;


ok $passing, 'Tests passed';
