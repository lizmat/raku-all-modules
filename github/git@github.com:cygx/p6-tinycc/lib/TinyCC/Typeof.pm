# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use nqp;

proto typeof(Mu $) is export {*}

multi typeof(Mu $_ where .REPR eq 'P6int') {
    my $size = .^nativesize;
    my $unsigned = .^unsigned;
    given $size {
        when  8 { $unsigned ?? 'unsigned char' !! 'signed char' }
        when 16 { $unsigned ?? 'unsigned short' !! 'short' }
        when 32 { $unsigned ?? 'unsigned' !! 'int' }
        when 64 { $unsigned ?? 'unsigned long long' !! 'long long' }
        default { !!! }
    }
}

multi typeof(Mu $_ where .REPR eq 'P6num') {
    my $size = .^nativesize;
    given $size {
        when 32 { 'float' }
        when 64 { 'double' }
        default { !!! }
    }
}

multi typeof(Mu $ where .REPR eq 'Uninstantiable') { 'void' }
multi typeof(Mu $ where nqp::decont($_) =:= Mu) { 'void' }
multi typeof(Mu $) { !!! }
