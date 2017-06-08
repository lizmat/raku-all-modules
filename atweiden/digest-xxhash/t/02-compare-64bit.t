use v6;
use Test;
use Digest::xxHash;

if $*KERNEL.bits == 64
{
    plan 6;
}
else
{
    plan :skip-all('Not a 64 bit OS, skip 64 bit tests');
}

my Str $file-for-tests = $*PROGRAM-NAME.IO.dirname ~ "/digest-from-file";

unless $file-for-tests.IO ~~ :f
{
    die ">>> File: '"
        ~ $file-for-tests
        ~ "' doesn't exist (it should be distributed along with this
           Digest::xxHash archive)!"
}

# Test the 64 bit routines.
{
    is xxHash64(""), -0x10B924C8AE271667, "digest from empty string is correct";
}

{
    is xxHash64("dupa"), -0x513854E896BED82, "digest from string 'dupa' is correct";
}

{
    is xxHash64("dupa", :enc('ISO-8859-1')), -0x513854E896BED82,
      "digest from string 'dupa' encoded ISO-8859-1 is correct";
}

{
    is xxHash64(file => $file-for-tests), -0x513854E896BED82,
        "digest from file content is correct";
}

{
    is xxHash64( $file-for-tests.IO ), -0x513854E896BED82,
        "digest from file content is correct";
}

{
    is xxHash64(Buf[uint8].new(0x64, 0x75, 0x70, 0x61)), -0x513854E896BED82,
        "digest from uint8 buffer is correct";
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
