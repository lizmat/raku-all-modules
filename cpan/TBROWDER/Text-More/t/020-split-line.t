use v6;
use Test;

use Text::More :ALL;

plan 2;

my $s1 = 'sub foo($song, $tool, @long-array, :$good) is export { say pwd }';

my ($line1, $line2) = split-line($s1, '(');
is $line1, 'sub foo(';
is $line2, '$song, $tool, @long-array, :$good) is export { say pwd }';
