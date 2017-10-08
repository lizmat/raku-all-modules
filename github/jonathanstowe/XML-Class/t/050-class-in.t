#!perl6

use v6;

use Test;

use XML::Class;

my Bool $DEBUG;

class A does XML::Class[xml-element => "a"] {
    class B does XML::Class[xml-element => 'b'] {
        has Str $.string;
    }

    has B $.bee;
}

my $obj = A.new(bee => A::B.new(string => 'boom'));
my $xml = $obj.to-xml;

diag $xml if $DEBUG;

my $out;

lives-ok { $out = A.from-xml($xml); }, "from-xml() simple inner XML::Class with element names";

isa-ok $out, A, "got the correct type back";
isa-ok $out.bee, A::B, "and the XML::Class attribute is the correct thing";
is $out.bee.string, $obj.bee.string, "the attribute match";

class B does XML::Class[xml-element => "a"] {
    class B does XML::Class[xml-element => 'b'] {
        has Str $.string;
    }

    has B $.bee is xml-element('Inner');
}

$obj = B.new(bee => B::B.new(string => 'boom'));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = B.from-xml($xml); }, "from-xml() simple inner XML::Class with element names inner xml-element";

isa-ok $out, B, "got the correct type back";
isa-ok $out.bee, B::B, "and the XML::Class attribute is the correct thing";
is $out.bee.string, $obj.bee.string, "the attribute match";

class C does XML::Class[xml-element => "a"] {
    class B does XML::Class {
        has Str $.string is xml-element;
    }

    has B $.bee is xml-element('Inner');
}

$obj = C.new(bee => C::B.new(string => 'boom'));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = C.from-xml($xml); }, "from-xml() simple inner XML::Class with element name on outer inner xml-element default inner name";

isa-ok $out, C, "got the correct type back";
isa-ok $out.bee, C::B, "and the XML::Class attribute is the correct thing";
is $out.bee.string, $obj.bee.string, "the attribute match";

class D does XML::Class[xml-element => "a"] {
    class B does XML::Class {
        has Str $.string is xml-element;
    }

    has B @.bee;
}

$obj = D.new(bee => (D::B.new(string => 'boom'), D::B.new(string => 'doom')));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = D.from-xml($xml); }, "from-xml() array of inner XML::Class with element name on outer inner xml-element default inner name";

isa-ok $out, D, "got the correct type back";
isa-ok $out.bee[0], D::B, "and the XML::Class attribute (first element) is the correct thing";
is $out.bee[0].string, $obj.bee[0].string, "the attribute match";
isa-ok $out.bee[1], D::B, "and the XML::Class attribute (second element) is the correct thing";
is $out.bee[1].string, $obj.bee[1].string, "the attribute match";

class F does XML::Class[xml-element => "a"] {
    class B does XML::Class[xml-element => 'bee'] {
        has Str $.string is xml-element;
    }

    has B @.bee;
}

$obj = F.new(bee => (F::B.new(string => 'boom'), F::B.new(string => 'doom')));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = F.from-xml($xml); }, "from-xml() array of inner XML::Class with element name on outer inner xml-element iner with name";


isa-ok $out, F, "got the correct type back";
isa-ok $out.bee[0], F::B, "and the XML::Class attribute (first element) is the correct thing";
is $out.bee[0].string, $obj.bee[0].string, "the attribute match";
isa-ok $out.bee[1], F::B, "and the XML::Class attribute (second element) is the correct thing";
is $out.bee[1].string, $obj.bee[1].string, "the attribute match";

class E does XML::Class[xml-element => "a"] {
    class B does XML::Class {
        has Str $.string is xml-element;
    }

    has B @.bee is xml-container('Bees');
}

$obj = E.new(bee => (E::B.new(string => 'boom'), E::B.new(string => 'doom')));
$xml = $obj.to-xml;

diag $xml if $DEBUG;

lives-ok { $out = E.from-xml($xml); }, "from-xml() array with container of inner XML::Class with element name on outer xml-element default inner name";

isa-ok $out, E, "got the correct type back";
isa-ok $out.bee[0], E::B, "and the XML::Class attribute (first element) is the correct thing";
is $out.bee[0].string, $obj.bee[0].string, "the attribute match";
isa-ok $out.bee[1], E::B, "and the XML::Class attribute (second element) is the correct thing";
is $out.bee[1].string, $obj.bee[1].string, "the attribute match";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
