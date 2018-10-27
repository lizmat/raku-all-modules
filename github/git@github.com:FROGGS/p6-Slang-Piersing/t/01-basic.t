use v6;
use lib 'lib';
use Test;
use Slang::Piersing;

plan 3;

sub foo?($a, $b) { $a * $b };
sub foo!($a, $b) { $a + $b };

is( (foo? 3, 5), 15, 'foo? 3, 5');
is foo?(3, 5),   15, 'foo?(3, 5)';
is foo!(3, 5),    8, 'foo!(3, 5)';
