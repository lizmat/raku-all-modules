#!perl6
use v6;
use Test;
use JSON::Unmarshal;

class AnyAttributeClass {
    has $.any-attr;
}

my @tests = (
 { json => '{ "any-attr" : 42 }', value => 42, type => Int },
 { json => '{ "any-attr" : 4.2 }', value => 4.2, type => Rat },
 { json => '{ "any-attr" : "42" }', value => '42', type => Str },
 { json => '{ "any-attr" : true }', value => True, type => Bool },
);

for @tests -> $test {
    my $ret;
    lives-ok { $ret = unmarshal($test<json>, AnyAttributeClass) }, "unmarshal { $test<type>.^name }";
    isa-ok $ret, AnyAttributeClass, "returns the right object";
    is $ret.any-attr, $test<value>, "attribute has the correct value";
    isa-ok $ret.any-attr, $test<type>, "and it is the right type";
}
done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
