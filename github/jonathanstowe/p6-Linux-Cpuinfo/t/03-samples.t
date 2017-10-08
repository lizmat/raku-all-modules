#!perl6

use v6.c;

use Test;
plan 332;

use Linux::Cpuinfo;

if $*KERNEL.name eq 'linux' {
    for 't/proc'.IO.dir.grep({ .f }) -> $file {
        $file.Str ~~ / \.$<arch>=\w+$ /;

        ok(my $ci = Linux::Cpuinfo.new(filename => $file.Str, arch => ~$<arch>), "get object for a $<arch>");
        isa-ok($ci, Linux::Cpuinfo, "and it's the right kind of thing");
        is($ci.arch, $<arch>, "check we set arch right");

        ok($ci.num-cpus > 0, "got some CPUs");

        my $count_cpus = 0;
        for $ci.cpus -> $cpu {
            $count_cpus++;
            isa-ok($cpu, Linux::Cpuinfo::Cpu, "the CPU is the right type of object");
            is($cpu.^name, 'Linux::Cpuinfo::Cpu::' ~ $ci.arch.tc, "and the right sub-type");
            for $cpu.fields.keys -> $field {
                ok($cpu.can($field), "and the object has a $field method");
            }
        }

        is($ci.num-cpus, $count_cpus, "and we saw as many cpus as we expected");
    }
}
else {
    skip-rest "Not Linux won't test";
}


done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
