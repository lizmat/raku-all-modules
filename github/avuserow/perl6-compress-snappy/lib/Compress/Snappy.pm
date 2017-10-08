unit module Compress::Snappy;
use v6;

use NativeCall;

my constant libsnappy = 'snappy';
constant SNAPPY_OK = 0;
constant SNAPPY_INVALID_INPUT = 1;
constant SNAPPY_BUFFER_TOO_SMALL = 2;

sub snappy_max_compressed_length(size_t) returns size_t is native(libsnappy) {...}
sub snappy_compress(CArray[uint8], size_t, CArray[uint8], size_t is rw) returns int32 is native(libsnappy) {...}

sub snappy_uncompressed_length(CArray[uint8], size_t, size_t is rw) returns int32 is native(libsnappy) {...}
sub snappy_uncompress(CArray[uint8], size_t, CArray[uint8], size_t is rw) returns int32 is native(libsnappy) {...}

sub snappy_validate_compressed_buffer(CArray[uint8], size_t) returns int32 is native(libsnappy) {...}

# helper functions to hide translations between Perl and C representations
sub _zero_array(Int $count) {
	my $array = CArray[uint8].new();
	$array[$_] = 0 for ^$count;
	return $array;
}

# these two can go away if/when NativeCall learns to translate Blobs to CArrays
sub _copy_blob_to_array(Blob $blob) {
	my $array = CArray[uint8].new();
	$array[$_] = $blob[$_] for ^$blob.bytes;
	return $array;
}

sub _int_pointer(Int $value = 0) {
	# Simulate an int pointer with a CArray
	my $intpointer = CArray[int].new();
	$intpointer[0] = $value;
	return $intpointer;
}

our sub validate(Blob $blob) returns Bool {
	my $compressed = _copy_blob_to_array($blob);
	my $status = snappy_validate_compressed_buffer($compressed, $blob.bytes);
	return $status == 0;
}

our proto compress($) {*};
multi compress(Blob $blob) returns Buf {
	my size_t $max-size = snappy_max_compressed_length($blob.bytes);

	# Allocate an int pointer to store the length
	my $output = _zero_array($max-size);
	my $input = _copy_blob_to_array($blob);
	my size_t $blob-size = $blob.bytes;

	my $status = snappy_compress($input, $blob-size, $output, $max-size);
	if $status {
		die "snappy_compress internal error: $status";
	}

	# Copy everything into a Buf
	return Buf.new: map {$output[$_]}, ^$max-size;
}

multi compress(Str $str) returns Buf {
	return compress($str.encode("utf8"));
}

our sub decompress(Blob $blob) returns Buf {
	# Allocate an int pointer to store the length
	my size_t $uncompressed-length;
	my $compressed = _copy_blob_to_array($blob);
	my size_t $blob-size = $blob.bytes;

	my $status1 = snappy_uncompressed_length($compressed, $blob-size, $uncompressed-length);
	if $status1 {
		die "snappy_uncompress internal error: $status1";
	}

	my $uncompressed = _zero_array($uncompressed-length);
	my $status2 = snappy_uncompress($compressed, $blob.bytes, $uncompressed, $uncompressed-length);
	if $status2 {
		die "snappy_uncompress internal error: $status2";
	}

	return Buf.new: map {$uncompressed[$_]}, ^$uncompressed-length;
}
