use v6;

use lib <t lib>;
use Redis;
use Test;

plan 1;

dies-ok { Redis.new('127.0.0.1:0') }

# vim: ft=perl6
