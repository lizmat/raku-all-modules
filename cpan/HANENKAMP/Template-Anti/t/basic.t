#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti :one-off;

my &people = anti-template :source("t/view/basic.html".IO.slurp), -> $at, :$title, :$motto, :@sith-lords {
    $at('title, h1')».content($title);
    $at('h1')».attr(title => $motto);
    $at('ul.people li:not(:first-child)')».remove;
    $at('ul.people li:first-child', :one)\
        .duplicate(@sith-lords, -> $item, %sith-lord {
            my $a = $item.at('a');
            $a.content(%sith-lord<name>);
            $a.attr(href => %sith-lord<url>);
        });
};

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
