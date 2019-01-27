use v6.d;
use NativeCall;
unit class Crypt::CAST5:ver<0.1.0>:auth<github:Kaiepi> is repr('CPointer');

sub LIB(--> Str) { state $ = %?RESOURCES<libraries/cast5>.absolute }

sub cast5_init(Blob, size_t --> Crypt::CAST5)    is native(LIB) {*}
sub cast5_encode(Crypt::CAST5, Blob, Blob is rw) is native(LIB) {*}
sub cast5_decode(Crypt::CAST5, Blob, Blob is rw) is native(LIB) {*}
sub cast5_free(Crypt::CAST5)                     is native(LIB) {*}

method new(Blob $key!) {
    die 'The CAST5 key must be between 5 and 16 characters long.' if $key.elems < 5 || $key.elems > 16;
    cast5_init($key, $key.elems)
}

method encode(Blob $plaintext --> Blob) {
    Blob.new: $plaintext.rotor(8, :partial).map({
        my Blob $in  .= new: $_;;
        my Blob $out .= allocate: 8;
        cast5_encode(self, $in, $out);
        $out.contents
    }).flat[0..^$plaintext.elems]
}

method decode(Blob $ciphertext --> Blob) {
    Blob.new: $ciphertext.rotor(8, :partial).map({
        my Blob $in  .= new: $_;;
        my Blob $out .= allocate: 8;
        cast5_decode(self, $in, $out);
        $out.contents
    }).flat[0..^$ciphertext.elems]
}

submethod DESTROY() { cast5_free(self) }

=begin pod

=head1 NAME

Crypt::CAST5 - CAST5 encryption library

=head1 SYNOPSIS

  use Crypt::CAST5;

  my Crypt::CAST5 $cast5   .= new: 'ayy lmao'.encode;
  my Str          $in       = 'sup my dudes';
  my Blob         $encoded  = $cast5.encode: $in.encode;
  my Blob         $decoded  = $cast5.decode: $encoded;
  my Str          $out      = $decoded.decode;

  say $out; # OUTPUT: sup my dudes

=head1 DESCRIPTION

Crypt::CAST5 is a library that handles encryption and decryption using the
CAST5 algorithm. Currently, only the ECB block cipher mode is supported.

=head1 METHODS

=item B<new>(Blob I<$key>)

Constructs a new instance of Crypt::CAST5 using the given block cipher mode and
key. The key must be 5-16 bytes in length.

=item B<encode>(Blob I<$plaintext> --> Blob)

Encodes C<$plaintext> using CAST5 encryption.

=item B<decode>(Blob I<$ciphertext> --> Blob)

Decodes C<$ciphertext> using CAST5 encryption.

=head1 AUTHOR

Ben Davies (Kaiepi)

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
