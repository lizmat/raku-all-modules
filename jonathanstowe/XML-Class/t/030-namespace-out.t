#!perl6

use v6;

use Test;

use XML::Class;

my $DEBUG = False;

class NSClass does XML::Class[xml-namespace => 'urn:example.com', xml-namespace-prefix => 'nsc'] {
    has Str $.thing is xml-element = "boom";
}

my $xml;
my $obj = NSClass.new;

lives-ok { $xml = $obj.to-xml(:document) }, "to-xml with xml-namespace-prefix";
ok $xml.root.attribs<xmlns:nsc>:exists, "and the namespace declaration has the prefix";
is $xml.root.name, 'nsc:NSClass', 'and the element does have the prefix';
is $xml.root[0].name, 'nsc:thing', "and so does the child element";

diag $xml if $DEBUG;

class NSClass2 does XML::Class[xml-namespace => 'urn:example.com', xml-namespace-prefix => 'nsc'] {
    has Str $.thing is xml-element is xml-namespace('urn:thing.com', 'th') = "boom";
}

$obj = NSClass2.new;

lives-ok { $xml = $obj.to-xml(:document) }, "to-xml with xml-namespace-prefix and xml-namespace trait on child";
ok $xml.root.attribs<xmlns:nsc>:exists, "and the namespace declaration has the prefix";
is $xml.root.name, 'nsc:NSClass2', 'and the element does have the prefix';
is $xml.root[0].name, 'th:thing', "and the child element has the specified prefix";
is $xml.root[0].attribs<xmlns:th>, 'urn:thing.com', "and the namespace declaration";

diag $xml if $DEBUG;

class Zub does XML::Class[xml-namespace => 'urn:zub', xml-namespace-prefix => 'z'] {
        has Str @.things;
}

$obj = Zub.new(things => <a b c d>);

lives-ok { $xml = $obj.to-xml(:document);  }, "to-xml(:document) -class has positional attribute no over-rides";

is $xml.root.nodes.elems, 4, "should have four child elements";
for $xml.root.nodes -> $el {
    isa-ok $el, XML::Element, "and elements";
    is $el.name, 'z:things', "and the right name";
}
#is $xml.Str, '<?xml version="1.0"?><Zub><things>d</things><things>c</things><things>b</things><things>a</things></Zub>', 'looks good';
diag $xml if $DEBUG;

class Zug does XML::Class[xml-namespace => 'urn:zub', xml-namespace-prefix => 'z'] {
        has Str @.things is xml-element('thing');
}

$obj = Zug.new(things => <a b c d>);

lives-ok { $xml = $obj.to-xml(:document);  }, "to-xml(:document) -class has positional attribute no over-rides";

is $xml.root.nodes.elems, 4, "should have four child elements";
for $xml.root.nodes -> $el {
    isa-ok $el, XML::Element, "and elements";
    is $el.name, 'z:thing', "and the right name";
}
#is $xml.Str, '<?xml version="1.0"?><Zub><things>d</things><things>c</things><things>b</things><things>a</things></Zub>', 'looks good';
diag $xml if $DEBUG;

class Zuv does XML::Class[xml-namespace => 'urn:zub', xml-namespace-prefix => 'z'] {
        has Str @.things is xml-element('thing') is xml-namespace('urn:thing', 'th');
}

$obj = Zuv.new(things => <a b c d>);

lives-ok { $xml = $obj.to-xml(:document);  }, "to-xml(:document) -class has positional attribute no over-rides";

is $xml.root.nodes.elems, 4, "should have four child elements";
for $xml.root.nodes -> $el {
    isa-ok $el, XML::Element, "and elements";
    is $el.name, 'th:thing', "and the right name";
    is $el.attribs<xmlns:th>, 'urn:thing', "and  each one has the namespace";
}
#is $xml.Str, '<?xml version="1.0"?><Zub><things>d</things><things>c</things><things>b</things><things>a</things></Zub>', 'looks good';
diag $xml if $DEBUG;
class Zuz does XML::Class[xml-namespace => 'urn:zub', xml-namespace-prefix => 'z'] {
        has Str @.things is xml-element('thing') is xml-container;
}

$obj = Zuz.new(things => <a b c d>);

lives-ok { $xml = $obj.to-xml(:document);  }, "to-xml(:document) -class has positional attribute no over-rides";

is $xml.root.nodes.elems, 1, "should have one child elements";
is $xml.root.nodes[0].name, 'z:things', "and the container has the prefix";
for $xml.root[0].nodes -> $el {
    isa-ok $el, XML::Element, "and elements";
    is $el.name, 'z:thing', "and the right name";
}
#is $xml.Str, '<?xml version="1.0"?><Zub><things>d</things><things>c</things><things>b</things><things>a</things></Zub>', 'looks good';
diag $xml if $DEBUG;

class Zuy does XML::Class[xml-namespace => 'urn:zub', xml-namespace-prefix => 'z'] {
        has Str @.things is xml-element('thing') is xml-container is xml-namespace('urn:thing', 'th');
}

$obj = Zuy.new(things => <a b c d>);

lives-ok { $xml = $obj.to-xml(:document);  }, "to-xml(:document) -class has positional attribute no over-rides";

is $xml.root.nodes.elems, 1, "should have one child elements";
is $xml.root.nodes[0].name, 'th:things', "and the container has the prefix";
is $xml.root.nodes[0].attribs<xmlns:th>, 'urn:thing', "and got the namespace declaration";
for $xml.root[0].nodes -> $el {
    isa-ok $el, XML::Element, "and elements";
    is $el.name, 'th:thing', "and the right name";
    nok $el.attribs<xmlns:th>:exists, "and we didn't copy the ns declaration";
}
#is $xml.Str, '<?xml version="1.0"?><Zub><things>d</things><things>c</things><things>b</things><things>a</things></Zub>', 'looks good';
diag $xml if $DEBUG;

class Foo does XML::Class[xml-namespace => 'urn:foo', xml-namespace-prefix => 'fo'] {
    class Bar {
        has Str $.thing is xml-element;
    }
    has @.things;
}

$obj = Foo.new(things => (Foo::Bar.new(thing => 'zub')));
lives-ok { $xml = $obj.to-xml(:document); }, "to-xml(:document) with namespace and an Any array of object";
is $xml.root.nodes.elems, 1, "have one child element";
is $xml.root.nodes[0].name, 'fo:Bar', "and the class got the namespace prefix";
is $xml.root.nodes[0][0].name, 'fo:thing', "and so did its child element";

diag $xml if $DEBUG;

class Baz does XML::Class[xml-namespace => 'urn:baz', xml-namespace-prefix => 'ba'] {
    has Str $.thing is xml-element;
}

$obj = Foo.new(things => (Baz.new(thing => 'zub')));
lives-ok { $xml = $obj.to-xml(:document); }, "to-xml(:document) with namespace and an Any array of object and object of XML::Class";
is $xml.root.nodes.elems, 1, "have one child element";
is $xml.root.nodes[0].name, 'ba:Baz', "and the class got the namespace prefix";
is $xml.root.nodes[0][0].name, 'ba:thing', "and so did its child element";

diag $xml if $DEBUG;

class Fob does XML::Class[xml-namespace => 'urn:foo', xml-namespace-prefix => 'fo'] {

    has @.things is xml-container('Body');
}

$obj = Fob.new(things => (Baz.new(thing => 'zub')));
lives-ok { $xml = $obj.to-xml(:document); }, "to-xml(:document) with namespace and an Any array of object and object of XML::Class with container";
is $xml.root.nodes.elems, 1, "have one child element";
is $xml.root.nodes[0].name, 'fo:Body', "and the container got the namespace prefix from the root";
is $xml.root.nodes[0][0].name, 'ba:Baz', "The inserted object got its choice of namespace";
is $xml.root.nodes[0][0][0].name, 'ba:thing', "and so did its child element";

diag $xml if $DEBUG;

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
