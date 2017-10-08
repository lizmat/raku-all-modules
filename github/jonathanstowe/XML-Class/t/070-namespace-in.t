#!perl6

use v6;

use Test;

my Bool $DEBUG;

use XML::Class;

class Inner does XML::Class[xml-namespace => 'http://example.com/inner', xml-namespace-prefix => 'in'] {
    has Str $.string is xml-element;
}

class Named does XML::Class[xml-namespace => 'http://example.com/named', xml-namespace-prefix => 'nx'] {
    has Inner $.inner;
    has Str   $.string is xml-element;
}

my $obj = Named.new(string => 'thing', inner => Inner.new(string => 'inner-thing'));
my $in;
lives-ok { $in = $obj.to-xml(:document); }, "to-xml() with namespace and inner class with namespace";

diag $in if $DEBUG;

my $out;

lives-ok { $out = Named.from-xml($in);  }, "from-xml with prefixed namespaces";

isa-ok $out, Named, "got the right thing";
isa-ok $out.inner, Inner, "and the inner class";
is $out.string, $obj.string, "outer string is right";
is $out.inner.string, $obj.inner.string, "inner string is right";

class NamedWithPositional does XML::Class[xml-namespace => 'http://example.com/named', xml-namespace-prefix => 'nx'] {
    has Inner @.inners is xml-container('Body');
    has Str   $.string is xml-element;
}

$obj = NamedWithPositional.new(string => 'thing', inners => (Inner.new(string => 'inner-thing'), Inner.new(string => 'other-thing')));
lives-ok { $in = $obj.to-xml(); }, "to-xml() with namespace and array of inner class with namespace";

diag $in if $DEBUG;


lives-ok {
$out = NamedWithPositional.from-xml($in);   }, "from-xml with prefixed namespaces and array inner class with namespace";

isa-ok $out, NamedWithPositional, "got the right thing";
is $out.string, $obj.string, "outer string is right";

ok $out.inners.elems, "got the inner items";
for ^$out.inners.elems -> $i {
    isa-ok $out.inners[$i], Inner, "and the inner class";
    is $out.inners[$i].string, $obj.inners[$i].string, "inner string is right";
}

class NamedWithPositionalBody does XML::Class[xml-namespace => 'http://example.com/named', xml-namespace-prefix => 'nx'] {
    has Inner @.inners is xml-container('Body') is xml-namespace('http://example.com/body', 'body');
    has Str   $.string is xml-element;
}

$obj = NamedWithPositionalBody.new(string => 'thing', inners => (Inner.new(string => 'inner-thing'), Inner.new(string => 'other-thing')));
lives-ok { $in = $obj.to-xml(); }, "to-xml() with namespace and array of inner class with namespace";

diag $in if $DEBUG;


lives-ok {
$out = NamedWithPositionalBody.from-xml($in);
}, "from-xml with prefixed namespaces and array inner class with namespace (different container)";

isa-ok $out, NamedWithPositionalBody, "got the right thing";
is $out.string, $obj.string, "outer string is right";

ok $out.inners.elems, "got the inner items";
for ^$out.inners.elems -> $i {
    isa-ok $out.inners[$i], Inner, "and the inner class";
    is $out.inners[$i].string, $obj.inners[$i].string, "inner string is right";
}

class NamedWithLocal does XML::Class[xml-namespace => 'http://example.com/local'] {
    class Inner {
        has Str $.string is xml-element is xml-namespace('http://example.com/string');
        has Int $.int    is xml-element('Int');
    }
    has Inner $.inner;
    has Str   $.string is xml-element is xml-namespace('http://example.com/string', 'st');
}

$obj = NamedWithLocal.new(string => 'outer-string', inner => NamedWithLocal::Inner.new(string => 'inner-string', int => 10));
lives-ok {
$in = $obj.to-xml();
}, "to-xml with default namespace, inner class with namespace on attribute";
diag $in if $DEBUG;
lives-ok {
    $out = NamedWithLocal.from-xml($in);
}, "from-xml with un-namespaced inner class with attribute with different namespace";

is $out.string, $obj.string, "got the right attribute for the outer";
is $out.inner.string, $obj.inner.string, "got the right attribute for the inner";
is $out.inner.int, $obj.inner.int, "for the right attribute for the inner int";


class Zuy does XML::Class[xml-namespace => 'urn:zub', xml-namespace-prefix => 'z'] {
            has Str @.things is xml-element('thing') is xml-container is xml-namespace('urn:thing', 'th');
}

$obj = Zuy.new(things => <a b c d>);

lives-ok {
$in = $obj.to-xml();
}, "to-xml namespaced with namespaced contained positional";



diag $in if $DEBUG;

lives-ok {
    $out = Zuy.from-xml($in);
},"from-xml namespaced with namespaced contained positional";

ok $out.things.elems, "got the elements";

for ^$out.things.elems -> $i {
    is $out.things[$i], $obj.things[$i], "got the right element";
}

class Zuz does XML::Class[xml-namespace => 'urn:zub', xml-namespace-prefix => 'z'] {
            has Str @.things is xml-element('thing') is xml-namespace('urn:thing', 'th');
}

$obj = Zuz.new(things => <a b c d>);

lives-ok {
$in = $obj.to-xml();
}, "to-xml namespaced with namespaced non-contained positional";



diag $in if $DEBUG;

lives-ok {
    $out = Zuz.from-xml($in);
},"from-xml namespaced with namespaced non-contained positional";

ok $out.things.elems, "got the elements";

for ^$out.things.elems -> $i {
    is $out.things[$i], $obj.things[$i], "got the right element";
}


done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
