#!perl6

use v6;

use Test;

use Audio::Hydrogen::Song;

my $data-dir = $*PROGRAM.parent.child('data');

my $xml = $data-dir.child('Lifetime.h2song').slurp;

my $obj;
lives-ok {
    $obj = Audio::Hydrogen::Song.from-xml($xml);
}, "from-xml";

isa-ok $obj, Audio::Hydrogen::Song, "got the right thing back";
isa-ok $obj.version, Version, "got a version";



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
