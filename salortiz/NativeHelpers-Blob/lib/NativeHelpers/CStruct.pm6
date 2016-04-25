use v6;

unit module NativeHelpers::CStruct:ver<0.1.0>;
use NativeCall;
use MoarVM::Guts::REPRs;
#use nqp;
constant stdlib = Rakudo::Internals.IS-WIN ?? 'msvcrt' !! Str;
our $debug = False;

role LinearArray[::T] does Positional[T] is export {
    die "Need a CStruct" unless T.REPR eq 'CStruct';
    my int $sol = nativesizeof(T);
    my \ty = T;

    has Pointer $!storage;
    has @!cache handles <AT-POS elems shape>;
    has Int $!size;

    submethod BUILD(:$!size!) {
	sub calloc(size_t, size_t --> Pointer) is native(stdlib) { * }
	@!cache := Array[ty].new(:shape($!size));
	with calloc($!size, $sol) -> $storage {
	    $!storage = $storage;
	    for ^$!size {
		my Pointer $p .= new(+$storage + $_ * $sol);
		@!cache[$_] = nativecast(T, $p);
	    }
	    self;
	} else {
	    fail "Can't allocate memory";
	}
    }

    method new(::?CLASS:U: Int $size) {
	self.bless(:$size);
    }

    method dispose(::?CLASS:D:) {
	sub free(Pointer) is native(stdlib) { * }
	with $!storage {
	    @!cache := ();
	    free($!storage);
	    $!storage = Pointer;
	    True;
	} else {
	    False;
	}
    }

    method nativesizeof() {
	$sol * $!size;
    }

    method bare-pointer() {
	$!storage;
    }

    method typed-pointer() {
	@!cache[0];
    }

    method _Pointer(Int $idx) {
	BODY_OF(@!cache[$idx]).cstruct;
    }

    method Pointer(::?CLASS:U: T:D $struct) {
	BODY_OF($struct).cstruct;
    }
}
