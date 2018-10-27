#!/usr/bin/env perl6

use Test;
use HexDump::Tiny;

my ($result) = hexdump("foo");

#00000000:  666f 6f                                   foo

ok $result.starts-with('00000000:'), 'starts at the beginning';
ok $result ~~ /666/, 'the number of the beast';
ok $result ~~ /666f\s+6f/, 'space every 2 chars';
ok $result ~~ /foo$/, 'ends with foo';

done-testing;
