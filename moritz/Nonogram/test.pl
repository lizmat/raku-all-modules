use v6;
use lib 'lib';

use Nonogram;

my $n = Nonogram.new(
    colspec => ([], [9], [9], [2, 2], [2, 2], [4], [4], []),
    rowspec => ([], [4], [6], [2, 2], [2, 2], [6], [4], [2], [2], [2], []),
);

$n.solve-zero();
$n.solve-one();
say $n;
$n.solve-shift();
say $n;
$n.solve-gen();
say $n;
