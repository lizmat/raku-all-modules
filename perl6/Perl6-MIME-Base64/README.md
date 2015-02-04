MIME::Base64
============

## Name ##

MIME::Base64 - Encoding and decoding Base64 ASCII strings. A Perl6 implementation of MIME::Base64

## Description ##

Implements encoding and decoding to and from base64.

## Status ##

Version 1.1 and later works on latest Rakudo based on nom. For earlier
versions of Rakudo based on ng, please use v1.0 (see tag v1.0-ng).

## Example Usage ##

    use MIME::Base64;

    my $encoded = MIME::Base64.encode-str("xyzzy‽");
    my $decoded = MIME::Base64.decode-str($encoded);

or

    use MIME::Base64;

    my $encoded     = MIME::Base64.encode($blob);
    my $decoded-buf = MIME::Base64.decode($encoded);

## Methods ##

### `new($backend?)`

Creates a new MIME::Base64 object that will use a specific backend, or the
current default backend if not specified.

Note that all of the below methods can be called on MIME::Base64 directly. `.new`
is only required if you want to encode using two different backends at the same
time.

### `set-backend($backend)`

When called on an object, sets the backend for that object only. Otherwise, sets
the default backend.

### `get-backend()`

When called on an object, returns the currently used backend. Otherwise, returns
the default backend.

### `encode(Blob $data, :$oneline --> Str)`

Encodeѕ binary data `$data` in base64 format.

By default, the output is wrapped every 76 characters. If `:$oneline` is set,
wrapping will be disabled.

### `decode(Str $encoded --> Buf)`

Decodes base64 encoded data into a binary buffer.

### `encode-str(Str $string, :$oneline --> Str)`

Encodes `$string` into base64, assuming utf8 encoding.

(Ιnternally calls `.encode($string.encode('utf8'))` )

### `decode-str(Str $encoded --> Str)`

Decodes `$encoded` into a string, assuming utf8 encoding.

(Internally calls `.decode($encoded).decode('utf8')` )

## Compatibility Methods ##

### `encode_base64(Str $string --> Str)`

Calls `.encode-str($string)`

### `decode_base64(Str $encoded --> Str)`

Calls `.decode-str($encoded)`

## Backends ##

### `MIME::Base64::PIR`

Calls out to parrot's base64 library to encode/decode. Selected by default when
running rakudo on top of parrot.

### `MIME::Base64::Perl`

Pure Perl 6 implementation of base64 encoding. Selected by default when no other
backends can be used.

## Known Issues ##

The previous precompilation issue has been fixed. The master branch should now be
usable for all backends.

## LICENSE and COPYRIGHT ##

Use these files at your risk and without warranty. This module may be used
under the terms of the Artistic License 2.0.

Written by Adrian White.
