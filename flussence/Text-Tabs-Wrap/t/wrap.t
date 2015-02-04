#!/usr/bin/env perl6
use v6;
use Test;
use lib '.';
use Test::Corpus;
use Text::Wrap;

run-tests(
    sub ($in, $out, $filename) {
        my @in = $in.lines;
        my @out = $out.lines;

        is  wrap(q{ } x 3, q{ }, @in.join("\n"), word-break => rx{\s}),
            @out.join("\n"),
            "$filename - wrap.t";
    }
);
