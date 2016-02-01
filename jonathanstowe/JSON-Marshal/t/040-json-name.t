#!perl6

use v6;

use Test;

use JSON::Marshal;
use JSON::Name;

class TestClass {
    has $.nice-name is rw is json-name('666.evil.name');
}

my $obj;
lives-ok { $obj = TestClass.new(nice-name => "value for money") }, "create on object with a json-name attribute";

my $json;

lives-ok { $json = marshal($obj) }, "marshal that object";

my $back;

lives-ok { $back = from-json($json) }, "parse the JSON";

is $back<666.evil.name>, $obj.nice-name, "and we got the key back with the json name";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
