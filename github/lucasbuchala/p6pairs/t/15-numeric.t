
use v6;
use Test;
use Duo;

my \d = Duo.new(1, 2);

is-deeply d.Rat,     1/2,  '.Rat';
is-deeply d.Complex, 1+2i, '.Complex';

done-testing;

# vim: ft=perl6
