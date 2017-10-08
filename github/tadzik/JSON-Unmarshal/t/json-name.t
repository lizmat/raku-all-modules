#!perl6

use v6;
use lib 'lib';

use Test;

use JSON::Unmarshal;
use JSON::Name;

class TestClass {
    has $.nice-name is rw is json-name('666.evil.name');
}

my $json = '{ "666.evil.name" : "some value we want" }';

my $obj;
lives-ok { $obj = unmarshal($json, TestClass) }, "Unmarshal object with a json-name attribute";


is $obj.nice-name,"some value we want", "and we got the key back with the json name";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
