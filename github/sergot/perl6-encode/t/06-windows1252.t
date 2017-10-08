use v6;
use Encode;

use Test;

plan 2;

is Encode::decode('windows-1252', buf8.new(0x8a)), 'Š', 'decode windows-1252 1/2';
is Encode::decode('windows-1252', buf8.new(76)), 'L', 'decode windows-1252 2/2';
