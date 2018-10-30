#!perl6

use v6;

use Test;

use XML::Class;

my Bool $DEBUG;

# round trip tests for complex type
# with simple content


class Container does XML::Class {
    class Simple {
        has Str $.lang;
        has Str $.name is xml-simple-content;
    }

    has Simple $.name;
}

my $obj = Container.new(name => Container::Simple.new(lang => 'en', name => 'Something'));
my $in;

lives-ok { $in = $obj.to-xml(:document);  }, "complex type with simple content and attribute"; 
is $in.root.name, 'Container', "got the right root";
is $in.root.nodes.elems, 1, "only got the one child";
is $in.root.nodes[0].name, 'Simple', "and this is what we expected";
is $in.root.nodes[0].attribs.keys.elems, 1, "and only one attribute";
is $in.root.nodes[0].attribs<lang>, $obj.name.lang, "and it's the right value";
isa-ok $in.root.nodes[0].firstChild, XML::Text, "and we got a text";
is $in.root.nodes[0].firstChild.text, $obj.name.name, "and the text is right too";

diag $in if $DEBUG;

my $out;

lives-ok { $out = Container.from-xml($in);  }, "from-xml with complext type with simple content and attribute";
isa-ok $out, Container, "got the right thing back";
isa-ok $out.name, Container::Simple, "and so is the inner class";
is $out.name.name, $obj.name.name, "and the 'name' is right";
is $out.name.lang, $obj.name.lang, "and so is the 'attribute'";

# This is a typical sort of file that has simple content and complex content

my $xml = $*PROGRAM.parent.child('data/country.xml').slurp;

class Country does XML::Class[xml-element => 'country', xml-namespace => "http://www.example.com/country"] {
    class Name does XML::Class[xml-element => 'name'] {
        has Str $.lang;
        has Str $.name is xml-simple-content;
    }
    class Population does XML::Class[xml-element => 'population'] {
        has Str $.date;
        has Int $.figure;
    }
    class Currency does XML::Class[xml-element => 'currency'] {
        has Str $.code;
        has Str $.name;

    }
    class City does XML::Class[xml-element => 'city'] {
        has Str $.code;
        has Str $.name is xml-element;
    }
    has Str        $.code;
    has Name       $.name;
    has Population $.population;
    has Currency   $.currency;
    has City       @.cities;
}


lives-ok { $in = Country.from-xml($xml) }, "from-xml with multiple embedded complex-types";
is $in.code, "FR", "code is right";
is $in.name.lang, 'en', 'name/@lang is right';
is $in.name.name, 'France', 'name is right';
is $in.population.date, "2000-01-01", 'population/@date is right';
is $in.population.figure, 60000000, 'population/@figure is right';
is $in.currency.code, 'EUR', 'currency/@code';
is $in.currency.name, 'Euro', 'currency/@name';

is $in.cities.elems, 5, "and we have five cities";

for $in.cities -> $city {
    isa-ok $city, Country::City, "city is the right thing";
    ok $city.code.defined, "city.code defined { $city.code }";
    ok $city.name.defined, "city.name defined { $city.name }";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
