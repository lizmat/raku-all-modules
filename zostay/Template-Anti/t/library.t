#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti;

class TestTemplates {
    method people-one(
        $at,
        :$title,
        :$motto,
        :@sith-lords,
    ) is anti-template(:source<basic.html>) {
        $at('title, h1')».content($title);
        $at('h1')».attr(title => $motto);
        $at('ul.people li:not(:first-child)')».remove;
        $at('ul.people li:first-child', :one)\
            .duplicate(@sith-lords, -> $item, %sith-lord {
                my $a = $item.at('a');
                $a.content(%sith-lord<name>);
                $a.attr(href => %sith-lord<url>);
            });
    }

    method people-two(|) is anti-template(:source<basic-embed.html>) { ... }
}

my $lib = Template::Anti::Library.new(
    path  => 't/view',
    views => { :testing(TestTemplates.new) },
);

{
    my $output = $lib.process('testing.people-one',
        title => 'Sith Lords',
        motto => 'The Force shall free me.',
        sith-lords => [
            { name => 'Vader',   url => 'http://example.com/vader' },
            { name => 'Sidious', url => 'http://example.com/sidious' },
        ],
    );

    is "$output\n", "t/basic.out".IO.slurp, 'output is as expected';
}

{
    my $output = $lib.process('testing.people-two',
        title => 'Sith Lords',
        motto => 'The Force shall free me.',
        sith-lords => [
            { name => 'Vader',   url => 'http://example.com/vader' },
            { name => 'Sidious', url => 'http://example.com/sidious' },
        ],
    );

    is "$output\n", "t/basic.out".IO.slurp, 'output is as expected';
}

throws-like {
    $lib.process("testing.not-a-method");
}, Exception, qq[no view method named "not-a-method"];

throws-like {
    $lib.process("not-a-view.not-a-method");
}, Exception, qq[no view named "not-a-view"];

done-testing;
