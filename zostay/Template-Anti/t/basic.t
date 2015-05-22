#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti;

my $at = Template::Anti.load("t/basic.html".IO);

$at('title, h1').text('Sith Lords');
$at('h1').attrib(title => 'The Force shall free me.');
$at('ul.people').truncate(1).find('li').apply([
    { name => 'Vader',   url => 'http://example.com/vader' },
    { name => 'Sidious', url => 'http://example.com/sidious' },
]).via: -> $item, $sith-lord {
    my $a = $item.find('a');
    $a.text($sith-lord<name>);
    $a.attrib(href => $sith-lord<url>);
};

my $output = $at.render.subst(/\>\s+\</, "><", :g);

is "$output\n", "t/basic.out".IO.slurp, 'output is as expected';

done;
