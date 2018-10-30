# p6-MIME-QuotedPrint #

Module for quoted-printable encoding/decoding

## Example Usage ##

    use MIME::QuotedPrint;

    my $encoded = MIME::QuotedPrint.encode-str("xyzzy‽");
    my $decoded = MIME::QuotedPrint.decode-str($encoded);

## Methods ##

### `encode-str(Str $data, :$mime-header --> Str)`

Encodes `$data` into quoted-printable format, assuming you want utf8 encoding.
(internally just calls `.encode($data.encode('utf8'))` )

If `:$mime-header` is set, will encode using the rules for an email header.
(_ for space, must encode '?', etc.)

### `encode(Blob $data, :$mime-header --> Str)`

Encodes the binary data in `$data` into quoted-printable format.

If `:$mime-header` is set, will encode using the rules for an email header.
(_ for space, must encode '?', etc.)

### `decode-str(Str $encoded, :$mime-header --> Str)`

Decodes a quoted-printable encoded string to a utf8 string.
(internally just calls `.decode($encoded).decode('utf8')` )

If `:$mime-header` is set, will decode using the rules for an email header.
(_ for space, must encode '?', etc.)

### `decode(Str $encoded, :$mime-header --> Buf)`

Decodes a quoted-printable encoded string to a buffer of binary data.

If `:$mime-header` is set, will decode using the rules for an email header.
(_ for space, must encode '?', etc.)
