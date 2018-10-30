#!perl6

use v6;
use lib 'lib';

use Test;

use JSON::Name;

class TestName {
    has $.test-attribute is json-name('666weirdname');
}

ok my $attr = TestName.^attributes[0], "get the attribute";

does-ok $attr, JSON::Name::NamedAttribute, "it does the attribute role";
is $attr.json-name, '666weirdname', "got our name";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
