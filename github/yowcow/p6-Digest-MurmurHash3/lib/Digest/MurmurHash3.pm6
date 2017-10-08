use v6;
use LibraryMake;
use NativeCall;

unit class Digest::MurmurHash3;

constant UINT32_MAX = 4294967295;

sub library {
    state $so;
    $so = get-vars('')<SO> if not $so;
    ~(%?RESOURCES{"libmurmurhash3$so"});
}

sub MurmurHash3_x86_32_i(Str, int32, uint32 --> uint32)
    is native(&library) { * }

sub MurmurHash3_x86_128(Str, int32, uint32, CArray[uint32])
    is native(&library) { * }

our sub fix-sign-bit(Int:D $v --> Int) {
    # Negative value comes out even though type is CArray[uint32].
    # To correctly manage bits, flag left most bit if sign is negative.
    $v.sign == -1
        ?? $v + 1 + UINT32_MAX
        !! $v;
}

sub to-buf(*@hash --> Buf) {
    my Int @blocks;
    @hash.map({
        my $h = $_;
        for ^4 {
            @blocks.push: $h +& 255;
            $h = $h +> 8;
        }
    });
    Buf.new(|@blocks);
}

our sub murmurhash3_32(Str:D $key, Int:D $seed --> Int) is export {
    MurmurHash3_x86_32_i($key, $key.chars, $seed);
}

our sub murmurhash3_32_hex(Str:D $key, Int:D $seed --> Buf) is export {
    to-buf(murmurhash3_32($key, $seed));
}

our sub murmurhash3_128(Str:D $key, Int:D $seed --> Array[Int]) is export {
    my @hash := CArray[uint32].new;
    @hash[$_] = 0 for ^4;

    MurmurHash3_x86_128($key, $key.chars, $seed, @hash);

    Array[Int].new((fix-sign-bit(@hash[$_]) for ^4));
}

our sub murmurhash3_128_hex(Str:D $key, Int:D $seed --> Buf) is export {
    to-buf(murmurhash3_128($key, $seed));
}

=begin pod

=head1 NAME

Digest::MurmurHash3 - MurmurHash3 implementation for Perl 6

=head1 SYNOPSIS

  use Digest::MurmurHash3;

  my Int $uint32 = murmurhash3_32($key, $seed);

  my Buf $hex8   = murmurhash3_32_hex($key, $seed);

  my Int @uint32 = murmurhash3_128($key, $seed);

  my Buf $hex32  = murmurhash3_128_hex($key, $seed);

=head1 DESCRIPTION

Digest::MurmurHash3 is a L<MurmurHash3|https://github.com/aappleby/smhasher> hashing algorithm implementation.

=head1 METHODS

=head2 murmurhash3_32(Str $key, uint32 $seed) returns Int

Calculates 32-bit hash, and returns as Int.

=head2 murmurhash3_32_hex(Str $key, uint32 $seed) returns Buf

Calculates 32-bit hash, and returns as Buf.
A hex string can be obtained with `.unpack("H4")`.

=head2 murmurhash3_128(Str $key, uint32 $seed) returns Array[Int]

Calculates 128-bit hash, and returns as Array[Int] with length of 4.

=head2 murmurhash3_128_hex(Str $key, uint32 $seed) returns Buf

Calculates 128-bit hash, and returns as Buf.
A hex string can be obtained with `.unpack("H16")`.

=head1 AUTHOR

yowcow <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

MurmurHash3 was written by L<Austin Appleby|https://github.com/aappleby>, and is released under MIT license.

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
