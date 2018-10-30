unit module Compress::Snappy;
use v6;

use NativeCall;

my constant libsnappy = 'snappy';
constant SNAPPY_OK = 0;
constant SNAPPY_INVALID_INPUT = 1;
constant SNAPPY_BUFFER_TOO_SMALL = 2;

sub snappy_max_compressed_length(size_t) returns size_t is native(libsnappy) {...}
sub snappy_compress(Blob, size_t, CArray[uint8], size_t is rw) returns int32 is native(libsnappy) {...}

sub snappy_uncompressed_length(Blob, size_t, size_t is rw) returns int32 is native(libsnappy) {...}
sub snappy_uncompress(Blob, size_t, CArray[uint8], size_t is rw) returns int32 is native(libsnappy) {...}

sub snappy_validate_compressed_buffer(Blob, size_t) returns int32 is native(libsnappy) {...}

# helper function to hide translations between Perl and C representations
sub _zero_array(Int $count) {
	my $array = CArray[uint8].new();
        $array[$count-1] = 0;
	return $array;
}

our sub validate(Blob $blob) returns Bool {
        snappy_validate_compressed_buffer($blob, $blob.bytes) == 0;
}

our proto compress($, |) {*};
multi compress(Blob $blob) returns Buf {
	my size_t $max-size = snappy_max_compressed_length($blob.bytes);

	# Allocate an int pointer to store the length
	my $output = _zero_array($max-size);

	my $status = snappy_compress($blob, $blob.bytes, $output, $max-size);
	if $status {
		die "snappy_compress internal error: $status";
	}

	# Copy everything into a Buf
        Buf.new($output[^$max-size]);
}

multi compress(Str $str, Str $encoding = 'utf-8') returns Buf {
	return compress($str.encode($encoding));
}

our sub decompress(Blob $blob, Str $encoding?) {
	# Allocate an int pointer to store the length
	my size_t $uncompressed-length;

	my $status1 = snappy_uncompressed_length($blob, $blob.bytes, $uncompressed-length);
	if $status1 {
		die "snappy_uncompress internal error: $status1";
	}

	my $uncompressed = _zero_array($uncompressed-length);
	my $status2 = snappy_uncompress($blob, $blob.bytes, $uncompressed, $uncompressed-length);
	if $status2 {
		die "snappy_uncompress internal error: $status2";
	}

        my $buf = Buf.new($uncompressed[^$uncompressed-length]);

        return $encoding.defined ?? $buf.decode($encoding) !! $buf;
}
