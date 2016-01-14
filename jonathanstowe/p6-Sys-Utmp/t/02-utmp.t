#!perl6

use v6;
use Test;

use Sys::Utmp;

ok(my $obj = Sys::Utmp.new, "get a Sys::Utmp");
isa-ok($obj, Sys::Utmp);

lives-ok {
   for $obj.list -> $ut {
      ok $ut.defined, "got a defined onject";
      isa-ok $ut, Sys::Utmp::Utent;
      isa-ok $ut.timestamp, DateTime, "timestamp is a datetime object";
   }
}, "list works okay";

done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
