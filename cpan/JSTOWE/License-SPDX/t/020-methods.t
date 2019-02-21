#!/usr/bin/env perl6

use v6;

use Test;

use License::SPDX;

my License::SPDX $lic;

lives-ok { $lic = License::SPDX.new }, "new from data";

for $lic.license-ids -> $id {
    ok my $l = $lic.get-license($id), "Licence '$id' exists";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
