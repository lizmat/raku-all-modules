use v6;
use Test;
use Digest::xxHash;

plan 4;

my Str $file-for-tests = $*PROGRAM-NAME.IO.dirname ~ "/digest-from-file";

unless $file-for-tests.IO ~~ :f
{
    die ">>> File: '"
        ~ $file-for-tests
        ~ "' doesn't exist (it should be distributed along with this
           Digest::xxHash archive)!"
}

{
    is xxHash32(""), 0x2CC5D05, "digest from empty string is correct";
}

{
    is xxHash32("dupa"), 0x1A47C09D, "digest from string 'dupa' is correct";
}

{
    is xxHash32(file => $file-for-tests), 0x1A47C09D,
        "digest from file content is correct";
}

{
    is xxHash32(buf-u8 => Buf[uint8].new(0x64, 0x75, 0x70, 0x61)), 0x1A47C09D,
        "digest from uint8 buffer is correct";
}

# vim: ft=perl6
