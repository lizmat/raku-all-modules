#!perl6

use v6;

use Test;

use META6;

my $meta;

lives-ok { $meta = META6.new(version => Version.new(0), perl => $*PERL.version) }, "create a META6";

isa-ok $meta, META6, "and it's the right thing";

my $json;

lives-ok { $json = $meta.to-json; }, "to-json";

lives-ok { $meta = META6.new(json => $json) }, "round-trip";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
