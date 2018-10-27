use v6;
use Encode;

use Test;

plan 1;

is Encode::decode('utf-8', buf8.new('Ł'.encode)), 'Ł', 'decode utf8 1/1';
