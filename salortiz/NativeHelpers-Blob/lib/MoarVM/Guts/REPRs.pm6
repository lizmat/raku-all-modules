use v6;

# This is ia module for access the guts of MoarVM's REPRs
# Right now lives here because it is incomplete, undocumented and is mainly a prof of concept
#
# When grow I'll move it to an independent module.

unit module MoarVM::Guts::REPRs;
use NativeCall;

constant Offset = do {
    my Pointer \p = Pointer.new(0xdeadbeaf); # A type with a trivial REPR
    my CArray[uint64] \ar = nativecast(CArray[uint64], Pointer.new(p.WHERE));
    my $i = 0;
    repeat { last if ar[$i] == p; } while ++$i < 10;
    die "Can't determine actual Offset" if $i == 10;
    $i * nativesizeof(uint64);
};

constant PPsize = nativesizeof(Pointer);

# The body of the 'VMArray' REPR
my class MVMArrayB is repr('CStruct') {
    has uint64 $.elems;
    has uint64 $.start;
    has uint64 $.ssize;
    has Pointer $.any;

    method realstart(::?CLASS:D:) {
	+$!start ?? Pointer.new(+$!any + +$!start * PPsize) !! $!any;
    }
}

# The body of the 'CArray' REPR
my class CArrayB is repr('CStruct') {
    has Pointer $.storage;
    has Pointer[Pointer] $.child;
    has int32 $.managed;
    has int32 $.allocated;
    has int32 $.elems;
}

my %known-bodies = (
    VMArray => MVMArrayB,
    CArray => CArrayB
);

sub OBJECT_BODY(Mu \any) is export {
    Pointer.new(any.WHERE + Offset);
}

sub BODY_OF(Mu \any) is export {
    my \type = %known-bodies{any.REPR};
    die "Can only handle " ~ %known-bodies.keys if type ~~ Nil;
    nativecast(Pointer[type], OBJECT_BODY(any)).deref;
}
# vim: ft=perl6:st=4:sw=4
