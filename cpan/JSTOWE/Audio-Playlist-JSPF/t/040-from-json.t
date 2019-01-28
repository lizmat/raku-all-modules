#!perl6

use v6;

use Test;

use Audio::Playlist::JSPF;


my $pl;

my $data-dir = $*PROGRAM.parent.child('data');

my $json = $data-dir.child('example.jspf').slurp;

lives-ok { $pl = Audio::Playlist::JSPF.from-json($json) }, "new from json";

isa-ok $pl, Audio::Playlist::JSPF, "and we got the right thing back";

is $pl.track.elems, 1, "got tracks";

lives-ok { $json = $pl.to-json; }, "round-trip back out to JSON";

lives-ok { $pl = Audio::Playlist::JSPF.from-json($json) }, "and back again";



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
