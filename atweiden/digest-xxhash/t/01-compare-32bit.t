use v6;
use Test;
use Digest::xxHash;

plan 6;

my Str $file-for-tests = $*PROGRAM-NAME.IO.dirname ~ "/digest-from-file";

unless $file-for-tests.IO ~~ :f
{
    die ">>> File: '"
        ~ $file-for-tests
        ~ "' doesn't exist (it should be distributed along with this
           Digest::xxHash archive)!"
}

# Test the 32 bit routines. Should return same values in both 32 and 64 bit OSs
{
    is xxHash32(""), 0x2CC5D05, "digest from empty string is correct";
}

{
    is xxHash32("dupa"), 0x1A47C09D, "digest from string 'dupa' is correct";
}

{
    is xxHash32("dupa", :enc('ISO-8859-1')), 0x1A47C09D,
      "digest from string 'dupa' encoded ISO-8859-1 is correct";
}

{
    is xxHash32(file => $file-for-tests), 0x1A47C09D,
        "digest from file content is correct";
}

{
    is xxHash32( $file-for-tests.IO ), 0x1A47C09D,
        "digest from file content is correct";
}

{
    is xxHash32(Buf[uint8].new(0x64, 0x75, 0x70, 0x61)), 0x1A47C09D,
        "digest from uint8 buffer is correct";
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
