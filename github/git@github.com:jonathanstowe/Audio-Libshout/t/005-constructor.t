#!perl6

use v6;
use Test;

use lib 'lib';
use Audio::Libshout;

my $obj;

lives-ok { $obj = Audio::Libshout.new() }, "constructor";
isa-ok( $obj, Audio::Libshout, "and it is the right kind of object");

my $ver;

lives-ok { $ver = $obj.libshout-version }, "get libshout version";
isa-ok($ver, Version, "and it is a Version");
diag "testing against $ver";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
