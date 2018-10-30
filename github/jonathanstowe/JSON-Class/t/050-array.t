#!perl6

use v6.c;

use Test;
use JSON::Class;

class TestObject does JSON::Class {
    has Str $.string;
}

constant TestObjects = (Array[TestObject] but JSON::Class);

my $json = '[{ "string" : "one" }, { "string" : "two" }]';

my $obj;

lives-ok { $obj = TestObjects.from-json($json) }, "from-json with array data";

does-ok $obj, JSON::Class, "and the return does the role";

isa-ok $obj[0], TestObject, "and the items are the right type";

my $json2;

lives-ok { $json2 = $obj.to-json() }, "to-json on the array typed thing";


my $obj2;

lives-ok { $obj2 = TestObjects.from-json($json2) }, "back from-json again";

is $obj2[0].string, $obj[0].string, "got the first item back correctly";
is $obj2[1].string, $obj[1].string, "got the second item back correctly";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
