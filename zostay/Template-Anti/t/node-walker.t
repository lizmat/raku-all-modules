#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti::Selector;

use XML;

plan *;

my $xml = from-xml-file("t/basic.html");

my $helper = Template::Anti::Selector::NodeWalker.new(:origin($xml));

my @expected = <
    html head title
    body h1
    ul
    li a
    li a
    li a
>;

for @expected -> $expected {
    my $node = $helper.next-node;
    flunk("did not get something when $expected") unless $node;
    isa-ok $node, XML::Element;
    is $node.name, $expected, "expecting $expected";
}

nok $helper.next-node, "the end";

done;
