use v6;

unit module NativeHelpers::Blob:ver<0.1.1>;
use NativeCall;
use MoarVM::Guts::REPRs;
use nqp;

our $debug = False;


my sub memcpy(Pointer $dest, Pointer $src, size_t $size)
    returns Pointer is native() { * };

multi sub Pointer(Blob:D \b, :$typed) is export {
    my \t = b.^array_type;
    my $bb = BODY_OF(b);
    note "From ", $bb.perl if $debug;
    my \sp = $bb.realstart;
    $typed ?? nativecast(Pointer[t], sp) !! sp;
}

our sub carray-from-blob(Blob:D \b, :$managed) is export {
    my \t = b.^array_type;
    my $bb = BODY_OF(b);
    note "From ", $bb.perl if $debug;
    if $managed {
	my \array = CArray[t].new;
	array[$bb.elems - 1] = 0; # Force allocation
	my $cb = BODY_OF(array);
	note "To ", $cb.perl if $debug;
	memcpy($cb.storage, $bb.realstart, $bb.elems * nativesizeof(t));
	array;
    } else {
	nativecast(CArray[t], $bb.realstart);
    }
}

our sub carray-is-managed(CArray:D \array) is export {
    so BODY_OF(array).managed;
}

our sub blob-new(Mu \type = uint8, :$elems) is export {
    my \b = Blob[type].new;
    nqp::setelems(b, nqp::unbox_i($elems.Int)) if $elems;
    b;
}

our sub blob-from-pointer(Pointer:D \ptr, Int :$elems!, Mu :$type = uint8) is export {
    my sub memcpy(Blob:D $dest, Pointer $src, size_t $size)
	returns Pointer is native() { * };
    my \t = ptr.of ~~ void ?? $type !! ptr.of;
    if  nativesizeof(t) != nativesizeof($type) {
	fail "Pointer type don't match Buf type";
    }
    my $b = (t === uint8) ?? Buf !! Buf.^parameterize($type);
    with ptr {
	$b .= allocate($elems);
	memcpy($b, ptr, $elems * nativesizeof(t));
    }
    $b;
}

our sub blob-from-carray(CArray:D \array, Int :$size) is export {
    my \t = array.^array_type;
    my $cb = BODY_OF(array);
    die "Need :size for unmanaged CArray" unless $cb.managed || $size;
    my $elems = $cb.elems || +$size;
    blob-from-pointer($cb.storage, :$elems, :type(t));
}

# vim: ft=perl6:st=4:sw=4
