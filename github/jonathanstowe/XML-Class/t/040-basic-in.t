#!perl6

use v6;

use Test;

use XML::Class;

my Bool $DEBUG;

class SimpleClass does XML::Class {
    has Int $.version;
    has Str $.something is xml-attribute('other-name');
    has Str $.thing is xml-element;
    has Rat $.named is xml-element('some-element');
    has Str @.strings;
    has Int @.ints is xml-container is xml-element('int');
    has Str %.hash is xml-element;

}

my $obj = SimpleClass.new(version => 0, thing => 'boom', named => 78/3, something => 'else', strings => <a b c d>, ints => (^5), hash => <A B C D>.map( { $_ => $_.lc}).hash);

my $xml =  $obj.to-xml;

diag $xml if $DEBUG;

my $out;

lives-ok { $out = SimpleClass.from-xml($xml);  }, "from-xml(Str)";

isa-ok $out, SimpleClass, "got back the class we expected";

is $out.version, $obj.version, "got the version we expected";
is $out.thing, $obj.thing, "and the element attribute";
is $out.named, $obj.named, "and a Rat with name over-ride";
is $out.something, $obj.something, "and an attribute attribute with name over-ride";
is-deeply $out.strings.sort, $obj.strings.sort, "and the basic array is good";
is-deeply $out.ints.sort, $obj.ints.sort, "and a contained array too";
is-deeply $out.hash, $obj.hash, "and the contained hash";

class Foo does XML::Class {
    class Bar {
        has Str $.thing is xml-element;
    }

    has Bar $.bar;
}

$obj = Foo.new(bar => Foo::Bar.new(thing => 'boom'));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = Foo.from-xml($xml);  }, "from-xml(Str) class with inner class";
isa-ok $out, Foo, "and the class is correct";
isa-ok $out.bar, Foo::Bar, "and the attribute is the right class";
is $out.bar.thing, $obj.bar.thing, "and its right attribute in it";

class Fob does XML::Class {
    class Bar {
        has Str $.thing is xml-element;
    }

    has Bar $.bar is xml-element('Body');
}

$obj = Fob.new(bar => Fob::Bar.new(thing => 'boom'));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = Fob.from-xml($xml);  }, "from-xml(Str) class with inner class";
isa-ok $out, Fob, "and the class is correct";
isa-ok $out.bar, Fob::Bar, "and the attribute is the right class";
is $out.bar.thing, $obj.bar.thing, "and its right attribute in it";

class Foz does XML::Class {
    class Bar {
        has Str $.thing is xml-element;
    }

    has Bar @.bar;
}

$obj = Foz.new(bar => (Foz::Bar.new(thing => 'boom'), Foz::Bar.new(thing => 'poom')));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = Foz.from-xml($xml); }, "from-xml(Str) class with a positional of inner class";
isa-ok $out, Foz, "and the class is correct";
isa-ok $out.bar[0], Foz::Bar, "and the attribute is the right class";
is $out.bar[0].thing, $obj.bar[0].thing, "and its right attribute in it";

class Fog does XML::Class {
    class Bar {
        has Str $.thing is xml-element;
    }

    has Bar @.bar is xml-element('Stuff');
}

$obj = Fog.new(bar => (Fog::Bar.new(thing => 'boom'), Fog::Bar.new(thing => 'poom')));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = Fog.from-xml($xml); }, "from-xml(Str) class with a positional of inner class with xml-element wrapper";
isa-ok $out, Fog, "and the class is correct";
isa-ok $out.bar[0], Fog::Bar, "and the attribute is the right class";
isa-ok $out.bar[1], Fog::Bar, "and the attribute is the right class";
is $out.bar[0].thing, $obj.bar[0].thing, "and its right attribute in it";
is $out.bar[1].thing, $obj.bar[1].thing, "and its right attribute in it";

class Fod does XML::Class {
    class Bar {
        has Str $.thing is xml-element;
    }

    has Bar @.bar is xml-element('Stuff') is xml-container('Bars');
}

$obj = Fod.new(bar => (Fod::Bar.new(thing => 'boom'), Fod::Bar.new(thing => 'poom')));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = Fod.from-xml($xml); }, "from-xml(Str) class with a positional of inner class with xml-element wrapper and container";
isa-ok $out, Fod, "and the class is correct";
isa-ok $out.bar[0], Fod::Bar, "and the attribute is the right class";
isa-ok $out.bar[1], Fod::Bar, "and the attribute is the right class";
is $out.bar[0].thing, $obj.bar[0].thing, "and its right attribute in it";
is $out.bar[1].thing, $obj.bar[1].thing, "and its right attribute in it";

class Fom does XML::Class {
    class Bar {
        has Str $.thing is xml-element;
    }

    has Bar @.bar is xml-container('Bars');
}

$obj = Fom.new(bar => (Fom::Bar.new(thing => 'boom'), Fom::Bar.new(thing => 'poom')));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = Fom.from-xml($xml); }, "from-xml(Str) class with a positional of inner class with container only";
isa-ok $out, Fom, "and the class is correct";
isa-ok $out.bar[0], Fom::Bar, "and the attribute is the right class";
isa-ok $out.bar[1], Fom::Bar, "and the attribute is the right class";
is $out.bar[0].thing, $obj.bar[0].thing, "and its right attribute in it";
is $out.bar[1].thing, $obj.bar[1].thing, "and its right attribute in it";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
