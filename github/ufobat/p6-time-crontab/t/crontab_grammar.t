#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Test;
use Time::Crontab::Grammar;

plan 9;

my @positive-crontabs = (
    # any
    '* * * * *',
    # any-step
    '*/10 */10 */10 */10 */6',
    # range
    '10-20 10-20 10-20 5-10 2-5',
    # range-step
    '10-20/2 10-20/2 10-20/2 5-10/2 2-5/2',
    # single-value include
    '1 2 3 4 5',
    # single-value exclude
    '*,!5 *,!5 *,!5 *,!5 *,!5',

    # this should parse, but does not make sense.
    '5,!5 5,!5 5,!5 5,!5 5,!5',
    
);

my @negative-crontabs = (
    # wrong order, 20-10 is invalid
    '20-10 20-10 20-10 10-5 5-2',

    # */10 doesn't work for dow (last value) which must be between 0-6
    '*/10 */10 */10 */10 */10',

);

ok(Time::Crontab::Grammar.parse($_), $_ ~ " parses") for @positive-crontabs;
nok(Time::Crontab::Grammar.parse($_), $_~ " doesn't parse") for @negative-crontabs;





