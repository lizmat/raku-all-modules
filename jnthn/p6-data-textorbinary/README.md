# Data::TextOrBinary

Implements a heuristic algorithm, very much like the one used by Git, to
decide if some data is most likely to be text or binary.

## Synopsis

    # Test a Buf/Blob
    say is-text('Vánoční stromek'.encode('utf-8'));         # True
    say is-text(Buf.new(0x02, 0xFF, 0x00, 0x38));           # False

    # Test a file
    say is-text('/bin/bash'.IO);                            # False
    say is-text('/usr/share/dict/words'.IO);                # True

## Subroutines

The module exports a single subroutine `is-text`, which has candidates for
`Blob` and `IO::Path`, enabling it to be used on data that has already been
read into memory as well as data in a file.

### On a Blob

    my $text = is-text($the-blob, test-bytes => 8192);

When called on a `Blob`, `is-text` will test the first `test-bytes` bytes of
it to decide if it contains text or binary data. The `test-bytes` named
parameter is optional, and its default value is 4096.

### On an IO::Path

    my $text = is-text($filename.IO, test-bytes => 8192);

When called on an `IO::Path`, `is-text` will read the first `test-bytes` bytes
from the file it points to. It will then test these to decide if the file is
text or binary. The `test-bytes` named parameter is optional, and its default
value is 4096.

## Algorithm

The algorithm will flag a file as binary if it encounters a NULL byte or a
lone carriage return (`\r`). Otherwise, it considers the ratio of printable
to ASCII-range control characters, with newline sequences excluded. If there
is less than one byte representing an unprintable ASCII character per 128
bytes representing printable ASCII characters, then the data is considered to
be text.

## Thread safety

The function exported by this module is safe to call from multiple threads at
the same time.
