#!/usr/bin/env perl6

use lib 't/lib';
use Pluggable;
use Test;

plan 4;

# simple case, load two plugins with defaults
class CaseA does Pluggable {
    has @.expected = [
            'CaseA::Plugins::Class1',
            'CaseA::Plugins::Class2',
        ];

    method test() {
        my @plugins = @( $.plugins );
        ok @plugins.map({ .WHAT.perl }).sort eqv @.expected.sort;
        for @plugins -> $p {
            ok $p.new.gimme-five eq 'five';
        }
    }
};
CaseA.new.test;

# use custom plugin namespace and a matcher
class CaseB does Pluggable {
    has @.expected = [
            'CaseB::Extensions::TestPlugin',
        ];

    method test() {
        my @plugins = @( $.plugins(:plugins-namespace('Extensions'), :name-matcher(/Plugin$/)) );
        ok @plugins.map({ .WHAT.perl }).sort eqv @.expected.sort;
    }
};
CaseB.new.test;

