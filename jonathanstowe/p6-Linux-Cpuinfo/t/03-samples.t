#!perl6

use v6;

use lib 'lib';
use Test;

use Linux::Cpuinfo;

for 't/proc'.IO.dir.grep({ .f }) -> $file {
   $file.Str ~~ / \.$<arch>=\w+$ /;

   ok(my $ci = Linux::Cpuinfo.new(filename => $file.Str, arch => ~$<arch>), "get object for a $<arch>");
   isa-ok($ci, Linux::Cpuinfo, "and it's the right kind of thing");
   is($ci.arch, $<arch>, "check we set arch right");

   ok($ci.num_cpus > 0, "got some CPUs");

   my $count_cpus = 0;
   for $ci.cpus -> $cpu {
      $count_cpus++;
      isa-ok($cpu, Linux::Cpuinfo::Cpu, "the CPU is the right type of object");
      is($cpu.^name, 'Linux::Cpuinfo::Cpu::' ~ $ci.arch.tc, "and the right sub-type");

      for $cpu.fields.keys -> $field {
         ok($cpu.can($field), "and the object has a $field method");
      }
   }

   is($ci.num_cpus, $count_cpus, "and we saw as many cpus as we expected");

}


done();
# vim: expandtab shiftwidth=4 ft=perl6
