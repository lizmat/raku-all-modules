use v6;
use lib 'lib';
use Test;
use Digest::xxHash;

plan(1);

my Str:D $file = $*PROGRAM-NAME.IO.dirname ~ '/digest-from-file';
$file.IO.e && $file.IO.f
    or die("File '$file' does not exist.");

# should return equal values in both 32 and 64-bit OSs
subtest('test 32-bit routines', {
    is(
        xxHash32(''),
        0x2CC5D05,
        'digest from empty string is correct'
    );
    is(
        xxHash32('dupa'),
        0x1A47C09D,
        "digest from string 'dupa' is correct"
    );
    is(
        xxHash32('dupa', :enc('ISO-8859-1')),
        0x1A47C09D,
        "digest from string 'dupa' encoded ISO-8859-1 is correct"
    );
    is(
        xxHash32(:$file),
        0x1A47C09D,
        'digest from file content is correct'
    );
    is(
        xxHash32($file.IO),
        0x1A47C09D,
        'digest from file content is correct'
    );
    is(
        xxHash32(Buf[uint8].new(0x64, 0x75, 0x70, 0x61)),
        0x1A47C09D,
        'digest from uint8 buffer is correct'
    );
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
