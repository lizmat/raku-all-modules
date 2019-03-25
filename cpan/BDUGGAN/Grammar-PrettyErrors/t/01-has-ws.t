#!perl6

use Grammar::PrettyErrors;

use Test;
plan 3;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    a b
  }
  token ws {
   <!ww> \s*
  }
}

my $g = G.new(:quiet, :!colors);

ok so $g.parse('a b'), 'parsed a valid string';
nok $g.parse('a c'), 'failed on an invalid string';
is $g.error.report, q:to/MSG/, "nice report";
    --errors--
      1 │▶a c
           ^

    Uh oh, something went wrong around line 1.
    MSG
