use v6;
use Test;
use PDF::Class::Util :to-roman, :from-roman, :alpha-number, :decimal-number;

for [1, 'I'], [2, 'II'], [3, 'III'], [4, 'IV'], [5, 'V'], [6, 'VI'], [10, 'X'], [11, 'XI'] {
    my (UInt $n, Str $r) = .list;
    is to-roman($n), $r, "to-roman($n)";
    is from-roman($r), $n, "from-roman({$r.perl})";
}

for [1, 'A'], [2, 'B'], [26, 'Z'], [27, 'AA'] {
    my (UInt $n, Str $a) = .list;
    is alpha-number($n), $a, "alpha-number($n)";
}

is decimal-number(5), '5', 'decimal-number';

done-testing;



