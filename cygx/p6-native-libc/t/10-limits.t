#!/usr/bin/env perl6

use v6;

use Test;
use Native::LibC <malloc fopen puts>;

plan 5;

my @keys = <
    CHAR_BIT SCHAR_MIN SCHAR_MAX UCHAR_MAX CHAR_MIN CHAR_MAX
    MB_LEN_MAX
    SHRT_MIN SHRT_MAX USHRT_MAX
    INT_MIN INT_MAX UINT_MAX
    LONG_MIN LONG_MAX ULONG_MAX
    LLONG_MIN LLONG_MAX ULLONG_MAX
>;

ok ?all(libc::limits{@keys}:exists),
    'limits exist';

is libc::CHAR_BIT, 8,
    'chars are octets';

is libc::UCHAR_MAX, 2**libc::CHAR_BIT - 1,
    'unsigned char has no padding';

ok libc::SCHAR_MIN == -128 && libc::SCHAR_MAX == 127,
    'signed char uses two\'s complement';

my $char-is-schar = libc::CHAR_MIN == libc::SCHAR_MIN &&
    libc::CHAR_MAX == libc::SCHAR_MAX;
my $char-is-uchar = libc::CHAR_MIN == 0 && libc::CHAR_MAX == libc::UCHAR_MAX;
my $char-type = do {
    when $char-is-schar { 'signed' }
    when $char-is-uchar { 'unsigned' }
    default { 'neither' }
}

ok $char-is-schar || $char-is-uchar,
    "char is either signed char or unsigned char [$char-type]";
