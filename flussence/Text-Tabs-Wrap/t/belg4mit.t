#!/usr/bin/env perl6
use v6;
use Test;
use Text::Wrap;

# Test that columns=1 works correctly and doesn't go into infinite loop

plan 1;

lives_ok {
    wrap('', '', :columns(1),
    'H4sICNoBwDoAA3NpZwA9jbsNwDAIRHumuC4NklvXTOD0KSJEnwU8fHz4Q8M9i3sGzkS7BBrm
    OkCTwsycb4S3DloZuMIYeXpLFqw5LaMhXC2ymhreVXNWMw9YGuAYdfmAbwomoPSyFJuFn2x8
    Opr8bBBidccAAAA');
}, 'columns=1 should not cause infinite loop';
