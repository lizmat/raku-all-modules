use v6;
use Test;
use Operator::defined-alternation;

plan 4;

my $falsish = 2 but False;
is ( $falsish ?// 2 !! 4 ), '2', 'defined but False';

$falsish = Any;
is ( $falsish ?// 2 !! 4 ), '4', 'undefined but False';

my $truish = 2 but True;
is ( $truish ?// 2 !! 4 ), '2', 'defined but True';

$truish = Any but True;
is ( $truish ?// 2 !! 4 ), '4', 'undefined but True';
