#!/usr/bin/env perl6
use v6;
use Test;
use Text::Wrap;

# This test re-wraps a short string repeatedly with different settings for $word-break - the output
# should be the same each time
# FIXME: Is this from RT#37000? There's an external link there that seems to be dead, but other than
# that I can't find any mention of this there

my Str $input = "(1) Category\t(2 or greater) New Category\n\n";
my Str $output = "(1) Category\t(2 or greater) New Category\n";
my @steps = (
    rx{\s},
    rx{\d},
    rx{a},
);

plan +@steps;

my Str $current = $input;

for @steps.kv -> $number, $word-break {
    $current = wrap('', '', :$word-break, $current);

    todo 'Known failure';
    is  $current,
        $output,
        "Short line \$word-break test ({1+$number} of {+@steps})";
}
