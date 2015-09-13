#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti::NodeSet;
use XML;

my $xml = from-xml(q:to/END_OF_XML/);
<root>
    <one></one>
    <two></two>
    <three></three>
</root>
END_OF_XML

{
    my $ns = Template::Anti::NodeSet.new(
        nodes => $xml.root.cloneNode,
    );
    $ns.text("Vader");
    is $ns.nodes[0].Str, '<root>Vader</root>', 'text works';
}

{
    my $root = $xml.root.cloneNode;
    my $ns = Template::Anti::NodeSet.new(
        nodes => $root.elements,
    );
    $ns.attrib(motto => 'The Force shall free me.');

    is $ns.nodes[0].Str, '<one motto="The Force shall free me."/>', 'attrib one works';
    is $ns.nodes[1].Str, '<two motto="The Force shall free me."/>', 'attrib two works';
    is $ns.nodes[2].Str, '<three motto="The Force shall free me."/>', 'attrib three works';
}

{
    my $ns = Template::Anti::NodeSet.new(
        nodes => $xml.root.cloneNode,
    );
    $ns.truncate(1);

    is $ns.nodes[0].Str, '<root><one/></root>';

    $ns.find('one').apply([
        { name => 'Vader',   url => 'http://example.com/vader' },
        { name => 'Sidious', url => 'http://example.com/sidious' },
    ]).via: -> $item, $sith-lord {
        $item.text($sith-lord<name>);
        $item.attrib(href => $sith-lord<url>);
    };

    is $ns.nodes[0].Str, '<root><one href="http://example.com/vader">Vader</one><one href="http://example.com/sidious">Sidious</one></root>';
}

{
    my $ns = Template::Anti::NodeSet.new(
        nodes => $xml.root,
    );
    $ns.text("Vader");
    is $xml.root.Str, '<root>Vader</root>', 'modifies original';
}

done-testing;

