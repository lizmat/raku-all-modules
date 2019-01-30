#!perl6

use v6;

use Test;

use Audio::Hydrogen::Drumkit;

my $data-dir = $*PROGRAM.parent.child('data');

my $xml = $data-dir.child('drumkit.xml').slurp;

my $obj;
lives-ok {
    $obj = Audio::Hydrogen::Drumkit.from-xml($xml);
}, "from-xml";

isa-ok $obj, Audio::Hydrogen::Drumkit, "got the right thing back";
is $obj.instruments.elems, 32, "and have the expected 32 instruments";

for $obj.instruments -> $instrument {
    isa-ok $instrument, Audio::Hydrogen::Instrument, "and the instrument is the right thing";
    ok $instrument.name.defined, "name is defined '{ $instrument.name }'";
    ok $instrument.id.defined, "id is defined";
}





done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
