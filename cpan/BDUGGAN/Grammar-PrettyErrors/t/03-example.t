#!perl6

use Test;
use Grammar::PrettyErrors;

plan 3;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    <subject>
    <verb>
    <prepositional-phrase>
  }
  rule subject {
    <article> [ <adjective>**2 % ' '] <noun>
  }
  token verb { jumped }
  rule prepositional-phrase {
    <preposition> <article> <adjective> <noun>
  }
  token article { the }
  token adjective {
    quick | brown | lazy
  }
  token noun { 'sheep dog' | fox }
  token preposition { over }
  token ws { <!ww> \s* }
}

my @got;
my $parsed = G.new.parse('the quick brown flox jumped over the lazy fox');
ok $parsed ~~ Failure, 'got a failure';
nok so $parsed, 'is false';
is $parsed.exception.message, ["--errors--\n\x[1B][1;33m" ~ qq:to/X/; ], 'got colorful errors';
  1 │▶the quick brown flox jumped over the lazy fox\x[1B][0m
                      ^

Uh oh, something went wrong around line 1.
Unable to parse subject.
X

#vim: set syntax perl6
