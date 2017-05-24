use v6;

module Base64::Native {

    use LibraryMake;
    # Find our compiled library.
    sub libbase64 is export(:libbase64) {
        state $ = do {
            my $so = get-vars('')<SO>;
            ~(%?RESOURCES{"lib/libbase64$so"});
        }
    }

    use NativeCall;

    sub base64_encode(Blob, size_t, Blob, size_t)  is native(&libbase64) { * }
    sub base64_encode_uri(Blob, size_t, Blob, size_t)  is native(&libbase64) { * }
    sub base64_decode(Blob, size_t, Blob, size_t --> ssize_t)  is native(&libbase64) { * }

    sub enc-alloc(Blob $in) {
	my \out-blocks = ($in.bytes div 3) + ($in.bytes %% 3 ?? 0 !! 1);
	buf8.allocate: out-blocks * 4;
    }

    sub dec-alloc(Blob $in) {
	my \out-blocks = ($in.bytes + 3) div 4;
	buf8.allocate: out-blocks * 3;
    }

    our proto sub base64-encode($, $?, :$enc, :$str, :$uri)  is export { * }

    multi sub base64-encode(:$str! where .so, |c --> Str) {
	base64-encode(|c).decode;
    } 
    multi sub base64-encode(Blob $in, Blob $out = enc-alloc($in), :$uri --> Blob) {
	$uri
	    ?? base64_encode_uri($in, $in.bytes, $out, $out.bytes)
	    !! base64_encode($in, $in.bytes, $out, $out.bytes);
	$out;
    }
    multi sub base64-encode(Str $in, :$enc = 'utf8', |c --> Blob) {
	base64-encode($in.encode($enc), |c)
    }

    our proto sub base64-decode($, $?, :$enc)  is export { * }

    multi sub base64-decode(Str :$enc!, |c --> Str) {
	base64-decode(|c).decode($enc);
    }
    multi sub base64-decode(Str $in, :$enc = 'utf8', |c --> Blob) {
	base64-decode($in.encode($enc), |c)
    }
    multi sub base64-decode(Blob $in, Blob $out = dec-alloc($in) --> Blob) {
	my ssize_t $n = base64_decode($in, $in.bytes, $out, $out.bytes);
	die "unable to decode as base64. stopped at byte {-$n}: 0x{$in[-$n - 1].base(16)} {$in[-$n - 1].chr.perl}"
	    if $n < 0;
	$out.reallocate($n)
	    if $n <= $out.bytes;
	$out;
    }

}
