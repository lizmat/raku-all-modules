#!perl6

use v6.c;

use Test;

use Linux::Cpuinfo;

if $*KERNEL.name eq 'linux' {
    ok(my $ci = Linux::Cpuinfo.new, "new Linux::Cpuinfo - no args");
    isa-ok($ci, Linux::Cpuinfo, "and it is the right sort of object");
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
else {
    # Of course we don't actualy know how many tests we will have
    plan 228;
    skip-rest "not Linux won't test";
}

done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
