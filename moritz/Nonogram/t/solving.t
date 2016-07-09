use v6;
use Test;
plan *;

use lib 'lib';

use Nonogram;

my $n = Nonogram.new(
    colspec => ([], [9], [9], [2, 2], [2, 2], [4], [4], []),
    rowspec => ([], [4], [6], [2, 2], [2, 2], [6], [4], [2], [2], [2], []),
);

lives-ok { $n.solve() }, 'can run .solve';

my $solved = q[
11111111|
12222111|
12222221|
12211221|
12211221|
12222221|
12222111|
12211111|
12211111|
12211111|
11111111|];
for $solved.trim.split("\n").kv -> $j,  $line {
    my $i = 0;
    for $line.comb -> $c {
        if $c eq any <1 2> {
            is $n.field-rows[$j][$i], $c, "($j, $i) is '$c'";
        }
        $i++;
    }
}
done;
