#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti :one-off;

my &people = anti-template :source("t/view/basic-embed.html".IO.slurp);
my $output = people(
    title => 'Sith Lords',
    motto => 'The Force shall free me.',
    sith-lords => [
        { name => 'Vader',   url => 'http://example.com/vader' },
        { name => 'Sidious', url => 'http://example.com/sidious' },
    ],
);

is "$output\n", "t/basic.out".IO.slurp, 'output is as expected';

done-testing;
