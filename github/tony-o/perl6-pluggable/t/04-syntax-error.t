#!/usr/bin/env perl6

use lib 't/lib';
use Pluggable;
use Test;

plan 1;

our $*DEBUG-PLUGINS = 1;
my @expected = [ ];

my @plugins = plugins('CaseC');
ok @plugins.map({ .WHAT.perl }).sort eqv @expected.sort;

