#!/usr/bin/env perl6

use lib 't/lib';
use Pluggable;
use Test;

plan 1;

my @expected = [
        'CaseA::Plugins::Class1',
        'CaseA::Plugins::Class2',
    ];

my @plugins = plugins('CaseA');
ok @plugins.map({ .WHAT.perl }).sort eqv @expected.sort;

