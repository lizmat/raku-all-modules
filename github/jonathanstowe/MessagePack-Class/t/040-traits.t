#!perl6
use v6.c;
use Test;

use MessagePack::Class;

subtest {
    class TraitTestName does MessagePack::Class {
        has Version $.version is packed-by('Str') is unpacked-by('new');
    }

    my $obj-orig;

    lives-ok { $obj-orig = TraitTestName.new(version => Version.new("0.0.1")) }, "create new object to test";

    my $pack;

    lives-ok { $pack = $obj-orig.to-messagepack }, "to-pack with traits";

    my $obj-new;

    lives-ok { $obj-new = TraitTestName.from-messagepack($pack) }, "from-pack with traits";

    isa-ok $obj-new.version, Version, "version is a Version";
    is $obj-new.version.Str, "0.0.1", "and it stringies how we want";
    is $obj-new.version, $obj-orig.version, "and the two compare the same";
}, "with named methods";
subtest {
    class TraitTestCode does MessagePack::Class {
        has Version $.version is packed-by(-> $v { $v.Str }) is unpacked-by(-> Str $v { Version.new($v) });
    }

    my $obj-orig;

    lives-ok { $obj-orig = TraitTestCode.new(version => Version.new("0.0.1")) }, "create new object to test";

    my $pack;

    lives-ok { $pack = $obj-orig.to-messagepack }, "to-pack with traits";

    my $obj-new;

    lives-ok { $obj-new = TraitTestCode.from-messagepack($pack) }, "from-pack with traits";

    isa-ok $obj-new.version, Version, "version is a Version";
    is $obj-new.version.Str, "0.0.1", "and it stringies how we want";
    is $obj-new.version, $obj-orig.version, "and the two compare the same";
}, "with subroutines";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
