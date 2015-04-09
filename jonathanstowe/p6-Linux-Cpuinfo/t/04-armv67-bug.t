#!perl6

use v6;

use lib "lib";

use Test;
use Linux::Cpuinfo;

my @procs = (
               {
                  filename => 't/proc/cpuinfo.armv6hl_rpi',
                  arch     => 'armv6hl_rpi',
                  num_cpus => 1,
               },
               {
                  filename => 't/proc/cpuinfo.Marvel_PJ4Bv7',
                  arch     => 'Marvel_PJ4Bv7',
                  num_cpus => 1,
               },

            );

for @procs -> $proc {
   ok(my $ci = Linux::Cpuinfo.new(filename => $proc<filename>, arch => $proc<arch>), "get cpu for $proc<arch>");
   is($ci.num_cpus, $proc<num_cpus>, "and it has the number of cpus we expected");

   my $cpu = $ci.cpus[0];
   for $cpu.fields.keys -> $field {
      ok($cpu.can($field), "and the object has a $field method");
   }

}

done();
