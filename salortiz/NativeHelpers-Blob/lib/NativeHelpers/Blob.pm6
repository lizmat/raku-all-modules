use v6;

unit module NativeHelpers::Blob:ver<0.1.3>;
use NativeCall;
use MoarVM::Guts::REPRs;
use nqp; # Needed by blob-allocate

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

our sub blob-allocate(Blob:U \blob, $elems) is export {
    my \b = blob.new;
    nqp::setelems(b, nqp::unbox_i($elems.Int));
    b;
}

our sub blob-from-pointer(Pointer:D \ptr, Int :$elems!, Blob:U :$type = Buf) is export {
    my sub memcpy(Blob:D $dest, Pointer $src, size_t $size)
	returns Pointer is native() { * };
    my \t = ptr.of ~~ void ?? $type.of !! ptr.of;
    if  nativesizeof(t) != nativesizeof($type.of) {
	fail "Pointer type don't match Blob type";
    }
    my $b = (t === uint8) ?? $type !! $type.^parameterize(t);
    with ptr {
	if $b.can('allocate') {
	    $b .= allocate($elems);
	} else {
	    $b = blob-allocate($b, $elems);
	}
	memcpy($b, ptr, $elems * nativesizeof(t));
    }
    $b;
}

our sub blob-from-carray(CArray:D \array, Int :$size) is export {
    my \t = array.^array_type;
    my $cb = BODY_OF(array);
    die "Need :size for unmanaged CArray" unless $cb.managed || $size;
    my $elems = $cb.elems || +$size;
    blob-from-pointer($cb.storage, :$elems, :type(Buf[t]));
}

# vim: ft=perl6:st=4:sw=4
