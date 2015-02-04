use v6;

BEGIN { @*INC.push('t', 'lib') };
use Redis;
use Test;

plan 1;

dies_ok { Redis.new('127.0.0.1:0') }

# vim: ft=perl6
