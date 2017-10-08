#!perl6

use v6;

use Test;
use XML::Class;

my Bool $DEBUG;

class Payload does XML::Class[xml-namespace => 'urn:example.com/payload'] {
    has Str $.string is xml-element;

}

class Container does XML::Class {
    has $.head is xml-element('Head') is xml-any;
    has $.body is xml-element('Body') is xml-any;
}

my $obj = Container.new(body => Payload.new(string => 'something'));

my $out;

lives-ok {
    $out = $obj.to-xml;
    diag $out if $DEBUG;
}, "to-xml for scalar element with xml-any with object in it";

my %*NS-MAP = ('urn:example.com/payload' => Payload);
my $in;
lives-ok {
    $in = Container.from-xml($out);
}, "from-xml with xml-any";

ok $in.body.defined, "body is defined";
isa-ok $in.body, Payload, "and the right type";
is $in.body.string, $obj.body.string, "and the data is right";

class ArrayContainer does XML::Class {
    has $.head is xml-element('Head');
    has @.body is xml-container('Body') is xml-any;
}

$obj = ArrayContainer.new(body => (Payload.new(string => 'something'), Payload.new(string => 'else')));

lives-ok {
    $out = $obj.to-xml;
    diag $out if $DEBUG;
}, "to-xml for scalar element with xml-any with object in it";

lives-ok {
    $in = ArrayContainer.from-xml($out);
}, "from-xml with xml-any";

is $in.body.elems, 2, "and we have two elements in body";

for ^$in.body.elems -> $i {
    ok $in.body[$i].defined, "body is defined ($i)";
    isa-ok $in.body[$i], Payload, "and the right type ($i)";
    is $in.body[$i].string, $obj.body[$i].string, "and the data is right ($i)";
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
