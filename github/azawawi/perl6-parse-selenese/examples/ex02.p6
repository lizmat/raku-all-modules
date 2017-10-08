#!/usr/bin/env perl6

use v6;

use lib 'lib';
use Parse::Selenese;

my $selenese = "examples/testsuite.html".IO.slurp;

my $parser = Parse::Selenese.new;
my $result = $parser.parse($selenese);
if $result {
  say "Matches with the following results: " ~ $result.ast.perl;
} else {
  say "Fails";
}