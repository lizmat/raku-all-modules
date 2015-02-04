use v6;
use Encode;

use Test;

plan 2;

is Encode::decode('iso-8859-2', buf8.new(0xa3)), 'Ł', 'decode latin2 1/2';
is Encode::decode('iso-8859-2', buf8.new(76)), 'L', 'decode latin2 2/2';
