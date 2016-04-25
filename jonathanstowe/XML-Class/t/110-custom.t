#!perl6

use v6;

use Test;
use XML::Class;

my Bool $DEBUG;

class CustomThing does XML::Class {
    sub version-out(Version $v) returns Str {
        $v.Str;
    }
    sub version-in(Str $v) returns Version {
        Version.new($v);
    }

    sub complex-out(Complex $v) returns Str {
        "{$v.re},{$v.im}";
    }
    sub complex-in(Str $v) returns Complex {
        my ( $re, $im) = $v.split(',');
        Complex.new(Int($re // 0), Int($im // 0));
    }

    sub instr-in(Str $v) returns Int {
        %(one => 1, two => 2, three => 3, four => 4){$v};
    }

    sub instr-out(Int $v) returns Str {
        %(1 => 'one', 2 => 'two', 3 => 'three', 4 => 'four'){$v};
    }

    has Version $.version-attribute is xml-serialise(&version-out) is xml-deserialise(&version-in);
    has Version $.version-element is xml-serialise(&version-out) is xml-deserialise(&version-in) is xml-element;
    has Complex $.complex-attribute is xml-serialise(&complex-out) is xml-deserialise(&complex-in);
    has Complex $.complex-element is xml-serialise(&complex-out) is xml-deserialise(&complex-in) is xml-element;
    has Int $.integer-string is xml-serialise(&instr-out) is xml-deserialise(&instr-in) is xml-element;
}

my $obj = CustomThing.new(version-attribute => v0.1.2, version-element => v0.1.3, complex-attribute => (10 + 5 * i), complex-element => (5 + 10 *i), integer-string => 2);

my $xml;

lives-ok {
    $xml = $obj.to-xml;
}, "to-xml with custom serialise/deserialise";

diag $xml if $DEBUG;

my $in;

lives-ok {
    $in = CustomThing.from-xml($xml);
}, "from-xml with custom deserialise";

is $in.version-attribute, $obj.version-attribute, "attribute one is good";
is $in.version-element, $obj.version-element, "element is also good";
is $in.complex-attribute, $obj.complex-attribute, "complex attribute too";
is $in.complex-element, $obj.complex-element, "complex element too";
is $in.integer-string, $obj.integer-string, "integer element";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
