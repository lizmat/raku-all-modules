# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use TinyCC::NC;

sub zero(Mu:U $type) {
    given ~$type.REPR {
        when 'P6int' { 0 }
        when 'P6num' { 0e0 }
        when 'CPointer' { $type }
        default { die "Zero initializer for type '$type' not known" }
    }
}

proto rv($) is export {*}

multi rv($ptr where $ptr.?of.REPR ne 'CPointer') {
    nc.cast($ptr.of, $ptr);
}

multi rv($ptr where $ptr.?of.REPR eq 'CPointer') {
    nc.deref-ptr-of-ptr($ptr);
}

sub lv($ptr) is rw is export {
    nc.cast-ptr-to-array($ptr).AT-POS(0);
}

proto cvar(|) is rw is export {*}

multi cvar(Mu:U $type, :$value) is rw {
    nc.array($type, $value // zero($type)).AT-POS(0);
}

multi cvar(Mu:U $type, $ptr is rw, :$value) is rw {
    my $carray := nc.array($type, $value // zero($type));
    $ptr = nc.cast-to-ptr-of($type, $carray);
    $carray.AT-POS(0);
}

multi cval(Mu:U $type, $value?) is export {
    nc.cast-to-ptr-of($type, nc.array($type, $value // zero($type)));
}

my constant TYPEMAP = {
    Mu => 'void',
    Bool => '_Bool',
    # => 'char',
    int8 => 'signed char',
    uint8 => 'unsigned char',
    int16 => 'short',
    uint16 => 'unsigned short',
    int32 => 'int',
    uint32 => 'uint',
    int => 'long',
    uint => 'unsigned long',
    longlong => 'long long',
    Int => 'long long',
    int64 => 'long long',
    ulonglong => 'unisgned long long',
    UInt => 'unsigned long long',
    uint64 => 'unisgned long long',
    num32 => 'float',
    num => 'double',
    Num => 'double',
    num64 => 'double',
}

my constant REPRMAP = {
    CPointer => 'void*',
}

sub ctype(Mu:U $type) is export {
    TYPEMAP{$type.^name} // REPRMAP{$type.REPR} //
        die "Mapping of type '$type' to C equivalent not known";
}

sub cparams(@params) is export {
    return 'void' unless @params;
    @params.map: {
        when .positional {
            my $ctype := ctype(.type);
            my $name := .name;
            defined($name) ?? "$ctype $name" !! $ctype;
        }
        default {
            die "Only positional parameters can be passed on to C, \
                but parameter '{ .name }' isn't";
        }
    }
}

sub cargs(@args) is export {
    use nqp;
    @args.map: {
        when Numeric { ~.Numeric }
        when .REPR eq 'CPointer' { "(void*){ nqp::unbox_i($_ // 0) }" }
        default {
            die "Mapping of argument { .gist } not known";
        }
    }
}
