use v6;
use Test;
use String::CRC32;
use newline :lf;

plan 6;

my $string1 = "This is the test string";

is(
    String::CRC32::crc32($string1), 1835534707,
    "Test the CRC of a string variable"
);

is(
    String::CRC32::crc32("This is another test string"), 2154698217,
    "Test the CRC of another string variable"
);

is(
    String::CRC32::crc32("Perl6 rocks"), 1413143404,
    "Test the CRC of an awesome string",
);

# Test type Buf
my $buf1 = $string1.encode("UTF-8");
is(
    String::CRC32::crc32($buf1), 1835534707,
    "Test the CRC of a Buf variable",
);

# Test CRC of a filehandle
my $fh = open("t/testfile", :bin, :r);
my $crc = String::CRC32::crc32($fh);
is($crc, 1925609391, "Test the CRC of a file handle");
if $crc == 443916274 {
    diag("CRC value of $crc indicates a possibly incorrect handling of EOL");
}

# Test a Buf made of invalid UTF8
my $buf2 = Buf.new(0xff);
is(
    String::CRC32::crc32($buf2), 4278190080,
    "Test the CRC of a Buf containing invalid utf8"
);

