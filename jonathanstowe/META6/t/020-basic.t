#!perl6

use v6;
use lib 'lib';

use Test;

use META6;

my IO::Path $data-dir = $*PROGRAM.parent.child("data");

my IO::Path $meta-path = $data-dir.child('META.info');

my $obj;

lives-ok { $obj = META6.new(file => $meta-path) }, "default test";

is $obj.version, "0.0.1", "object get good version";
is $obj.name, "JSON::Marshal", "got right name";
is $obj.description, "Simple serialisation of objects to JSON", "and description";

my $json;

lives-ok { $json = $obj.to-json }, "call to-json";

my $h = from-json($json);

is $h<version>, "0.0.1", "version is right";
is $h<perl>, "6", "perl is right";

for $obj.^attributes -> $attr {
    if $attr.has-accessor {

        ok $attr.^does(META6::MetaAttribute), "attribute { $attr.name } has the trait";

    }
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
