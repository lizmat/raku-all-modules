use v6;
use lib 'lib';
use Test;
use Digest::xxHash;

$*KERNEL.bits == 64
    ?? plan(1)
    !! plan(:skip-all('Not a 64 bit OS, skip 64 bit tests'));

my Str:D $file = $*PROGRAM-NAME.IO.dirname ~ '/digest-from-file';
$file.IO.e && $file.IO.f
    or die("File '$file' does not exist.");

subtest('test 64-bit routines', {
    is(
        xxHash64(''),
        -0x10B924C8AE271667,
        'digest from empty string is correct'
    );
    is(
        xxHash64('dupa'),
        -0x513854E896BED82,
        "digest from string 'dupa' is correct"
    );
    is(
        xxHash64('dupa', :enc('ISO-8859-1')),
        -0x513854E896BED82,
        "digest from string 'dupa' encoded ISO-8859-1 is correct"
    );
    is(
        xxHash64(:$file),
        -0x513854E896BED82,
        'digest from file content is correct'
    );
    is(
        xxHash64($file.IO),
        -0x513854E896BED82,
        'digest from file content is correct'
    );
    is(
        xxHash64(Buf[uint8].new(0x64, 0x75, 0x70, 0x61)),
        -0x513854E896BED82,
        'digest from uint8 buffer is correct'
    );
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
