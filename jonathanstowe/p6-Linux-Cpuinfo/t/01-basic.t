#!perl6

use v6;

use Test;
use lib 'lib';

use-ok('Linux::Cpuinfo', 'Linux::Cpuinfo can be used');
use-ok('Linux::Cpuinfo::Cpu', 'Linux::Cpuinfo::Cpu can be used');

done();
# vim: expandtab shiftwidth=4 ft=perl6
