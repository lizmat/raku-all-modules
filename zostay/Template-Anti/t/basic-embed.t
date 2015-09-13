#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti;

my $at = Template::Anti.load("t/basic-embed.html".IO);

$at.process-scripts;

my $output = $at.render.subst(/\>\s+\</, "><", :g);

is "$output\n", "t/basic.out".IO.slurp, 'output is as expected';

done-testing;
