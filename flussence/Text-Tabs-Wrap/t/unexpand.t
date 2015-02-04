#!/usr/bin/env perl6
use v6;
use Test;
use lib '.';
use Test::Corpus;
use Text::Tabs;

run-tests(sub ($in, $out, $filename) {
    is unexpand($in.slurp), $out.slurp, $filename;
});
