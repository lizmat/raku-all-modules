#!perl6

use v6;

use Test;
plan 2;

use-ok('Linux::Cpuinfo', 'Linux::Cpuinfo can be used');
use-ok('Linux::Cpuinfo::Cpu', 'Linux::Cpuinfo::Cpu can be used');

done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
