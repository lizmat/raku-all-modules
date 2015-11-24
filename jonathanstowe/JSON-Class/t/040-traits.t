#!perl6
use v6;
use Test;
use JSON::Class;

# These are needed for the traits

import JSON::Unmarshal;
import JSON::Marshal;

class TraitTest does JSON::Class {
    has Version $.version is marshalled-by('Str') is unmarshalled-by('new');
}

my $obj-orig;

lives-ok { $obj-orig = TraitTest.new(version => Version.new("0.0.1")) }, "create new object to test";

my $json;

lives-ok { $json = $obj-orig.to-json }, "to-json with traits";

is from-json($json)<version>, "0.0.1", "serialised JSON about right";

my $obj-new;

lives-ok { $obj-new = TraitTest.from-json($json) }, "from-json with traits";

isa-ok $obj-new.version, Version, "version is a Version";
is $obj-new.version.Str, "0.0.1", "and it stringies how we want";
is $obj-new.version, $obj-orig.version, "and the two compare the same";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
