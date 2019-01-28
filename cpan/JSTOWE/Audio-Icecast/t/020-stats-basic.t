#!perl6

use v6;

use Test;
use Audio::Icecast;

my $data-dir = $*PROGRAM.parent.add('data');

my $xml = $data-dir.add('admin_stats.xml').slurp;

my $obj;

lives-ok { $obj = Audio::Icecast::Stats.from-xml($xml); }, "create Stats from xml";

is $obj.source.elems, 3, "we have three sources";

for $obj.source -> $source {
    isa-ok $source, 'Audio::Icecast::Source', "and the source ( { $source.mount } ) is the right thing";
    is $source.max-listeners, int.Range.max, "and we got back an int for 'unlimited'";
}





done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
