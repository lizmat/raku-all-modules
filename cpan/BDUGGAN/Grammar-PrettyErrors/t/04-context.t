#!perl6

use Test;
use Grammar::PrettyErrors;

plan 4;

grammar G does Grammar::PrettyErrors {
  rule TOP { <inner> }
  rule inner {
    'a'+ % [ \s+ ]
    'b'
  }
}

my $g = G.new(:quiet);

$g.parse(q:to/X/);
a
a
a
a
a
a
a a a c
X

ok my $e = $g.error, 'got an error';
is $e.line, 7, 'line is ok';
is $e.column, 8, 'column is ok';
is $e.lastrule, 'inner', 'last rule';

#vim: set syntax perl6
