use v6;

=begin pod

=begin NAME

Linux::Cpuinfo::Cpu - per cpu core information.

=end NAME

=begin DESCRIPTION

An array of sub-classes of this type will be returned by Linux::Cpuinfo.cpus

It provides an interface to the information provided by the kernel with generated
accessor methods for each of the fields.

=end DESCRIPTION

=begin METHODS

The below is a list of fields that I found when I fist documented the Perl 5
version of this module, the actual methods present will be generated at run-time
from the field names found in the /proc/cpuinfo so will almost certainly differ.

The full list can be discovered by calling C<.fields.keys> on the object.


=item processor   

This is the index of the processor this information is for, it will be zero
for a the first CPU (which is the only one on single-proccessor systems), one
for the second and so on.

=item vendor_id   

This is a vendor defined string for X86 CPUs such as 'GenuineIntel' or
'AuthenticAMD'. 12 bytes long, since it is returned via three 32 byte long
registers.

=item cpu_family  

This should return an integer that will indicate the 'family' of the 
processor - This is for instance '6' for a Pentium III. Might be undefined for
non-X86 CPUs.

=item model or cpu_model

An integer that is probably vendor dependent that indicates their version 
of the above cpu_family

=item model_name  

A string such as 'Pentium III (Coppermine)'.

=item stepping 

I'm lead to believe this is a version increment used by intel.

=item cpu_mhz

I guess this is self explanatory - it might however be different to what
it says on the box. The Mhz is measured at boot time by the kernel and
represents the true Mhz at that time.

=item bus_mhz

The MHz of the bus system.

=item cache_size  

The cache size for this processor - it might well have the units appended
( such as 'KB' )

=item fdiv_bug 

True if this bug is present in the processor.

=item hlt_bug     

True if this bug is present in the processor.

=item sep_bug     

True if this bug is present in the processor.

=item f00f_bug 

True if this bug is present in the processor.

=item coma_bug 

True if this bug is present in the processor.

=item fpu      

True if the CPU has a floating point unit.

=item fpu_exception  

True if the floating point unit can throw an exception.

=item cpuid_level

The C<cpuid> assembler instruction is only present on X86 CPUs. This attribute
represents the level of the instruction that is supported by the CPU. The first
CPUs had only level 1, newer chips have more levels and can thus return more
information.

=item wp

No idea what this is on X86 CPUs.

=item flags

This is the set of flags that the CPU supports - this is returned as an
array

=item byte_order

The byte order of the CPU, might be little endian or big endian, or undefined
for unknown.

=item bogomips 

A system constant calculated when the kernel is booted - it is a (rather poor)
measure of the CPU's performance.


=end METHODS

=end pod

class Linux::Cpuinfo::Cpu {

    #|  a hash keyed on the names of the fields found in the record
    has %.fields;
    multi method new(Str $cpu ) {
        my %fields;

        for $cpu.lines -> $line {
            my ($key, $value) =  $line.split(/\s*\:\s*/);
            $key.=subst(/\s+/,'_', :g);

            if  $value.defined {
                if $value ~~ /^yes|no$/ {
                    $value = so $/ eq 'yes';
                }
                elsif $value ~~ /^<:Nd>+\.?<:Nd>?$/ {
                    $value = $value + 0;
                }
            }
            given $key {
                when 'flags' {
                    my @flags = $value.split(/\s+/);
                    $value = @flags;
                }
            }

            %fields{$key.lc} = $value;

        }
        self.new(:%fields);
    }

    # This needs to be separate as the object itself is needed.
    submethod BUILD(:%!fields ) {
        for %!fields.keys -> $field {
            if not self.can($field) {
                self.^add_method($field, { %!fields{$field} } );
            }
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
