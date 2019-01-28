use v6.c;
use Test;
use P5pack;

# This code contains no conditionals for endianness or word length.
# Perl 6 is fully 64 bit even when the underlying architecture is not.
# The code in P5pack always generates code for items like "i" as
# though it were running on a big-endian processor.

my $s1 = "string";
my @a1 = 123, 97, -126;
my @a2 = 123, 97, 130;
my $h1 = "3a6C";
my $h2 = "4142";
my $i1 = 0x1234567890123456;
my $i2 = -0x1234567890123456;
my uint $i3 = 0x9876543210987654; # not handled correctly by Rakudo

# Test packing individual elements

 is pack('a',    $s1),      Buf.new(0x73);
 is pack('a3',   $s1),      Buf.new(0x73, 0x74, 0x72);
 is pack('A',    $s1),      Buf.new(0x73);
 is pack('A9',   $s1),      Buf.new(115,116,114,105,110,103,32,32,32);
 is pack('A3',   $s1),      Buf.new(0x73, 0x74, 0x72);
 is pack('c',    @a1),      Buf.new(123);
 is pack('c5',   @a1),      Buf.new(123,97,130,0,0);
 is pack('c0',   @a1),      Buf.new();
 is pack('c3',   @a1),      Buf.new(123, 97, 130);
 is pack('c3',   @a2),      Buf.new(123, 97, 130);
 is pack('C',    @a1),      Buf.new(123);
 is pack('C3',   @a1),      Buf.new(123, 97, -126);
 is pack('C3',   @a2),      Buf.new(123, 97, -126);
 is pack('h',    $h1),      Buf.new(0x3a, 0x6c);
 is pack('h2',   $h1, $h2), Buf.new(0x3a, 0x6c, 0x41, 0x42);
 is pack('H',    $h1),      Buf.new(0xa3, 0xc6);
 is pack('H2',   $h1, $h2), Buf.new(0xa3, 0xc6, 0x14, 0x24);
 is pack('i',    $i1),      Buf.new(0x56, 0x34, 0x12, 0x90, 0x78, 0x56, 0x34, 0x12);
 is pack('i',    $i2),      Buf.new(0xaa, 0xcb, 0xed, 0x6f, 0x87, 0xa9, 0xcb, 0xed);
#is pack('i',    $i3),      Buf.new(?, ?, ?, ?, ?, ?, ?, ?);
 is pack('I',    $i1),      Buf.new(0x56, 0x34, 0x12, 0x90, 0x78, 0x56, 0x34, 0x12);
 is pack('I',    $i2),      Buf.new(0xAA, 0xCB, 0xED, 0x6F, 0x87, 0xA9, 0xCB, 0xED);
#is pack('I',    $i3),      Buf.new(?, ?, ?, ?, ?, ?, ?, ?);
 is pack('l',    $i1),      Buf.new(0x56, 0x34, 0x12, 0x90);
 is pack('l',    $i2),      Buf.new(0xAA, 0xCB, 0xED, 0x6F);
#is pack('l',    $i3),      Buf.new(?, ?, ?, ?);
 is pack('L',    $i1),      Buf.new(0x56, 0x34, 0x12, 0x90);
 is pack('L',    $i2),      Buf.new(0xAA, 0xCB, 0xED, 0x6F);
#is pack('L',    $i3),      Buf.new(?, ?, ?, ?);
 is pack('n',    $i1),      Buf.new(0x34, 0x56);
 is pack('n',    $i2),      Buf.new(0xCB, 0xAA);
#is pack('n',    $i3),      Buf.new(?, ?);
 is pack('N',    $i1),      Buf.new(0x90, 0x12, 0x34, 0x56);
 is pack('N',    $i2),      Buf.new(0x6f, 0xed, 0xcb, 0xaa);
#is pack('N',    $i3),      Buf.new(?, ?, ?, ?);
 is pack('q',    $i1),      Buf.new(0x56, 0x34, 0x12, 0x90, 0x78, 0x56, 0x34, 0x12);
 is pack('q',    $i2),      Buf.new(0xaa, 0xcb, 0xed, 0x6f, 0x87, 0xa9, 0xcb, 0xed);
#is pack('q',    $i3),      Buf.new(?, ?, ?, ?, ?, ?, ?, ?);
 is pack('Q',    $i1),      Buf.new(0x56, 0x34, 0x12, 0x90, 0x78, 0x56, 0x34, 0x12);
 is pack('Q',    $i2),      Buf.new(0xaa, 0xcb, 0xed, 0x6f, 0x87, 0xa9, 0xcb, 0xed);
#is pack('Q',    $i3),      Buf.new(?, ?, ?, ?, ?, ?, ?, ?);
 is pack('s',    $i1),      Buf.new(0x56, 0x34);
 is pack('s',    $i2),      Buf.new(0xaa, 0xcb);
#is pack('s',    $i3),      Buf.new(?, ?);
 is pack('S',    $i1),      Buf.new(0x56, 0x34);
 is pack('S',    $i2),      Buf.new(0xaa, 0xcb);
#is pack('S',    $i3),      Buf.new(?, ?);
#is pack('U',    $c1),      Buf.new(
 is pack('v',    $i1),      Buf.new(0x56, 0x34);
 is pack('v',    $i2),      Buf.new(0xaa, 0xcb);
#is pack('v',    $i3),      Buf.new(?, ?);
 is pack('V',    $i1),      Buf.new(0x56, 0x34, 0x12, 0x90);
 is pack('V',    $i2),      Buf.new(0xaa, 0xcb, 0xed, 0x6f);
#is pack('V',    $i3),      Buf.new(?, ?, ?, ?);
 is pack('w',    0x123456), Buf.new(0xc8, 0xe8, 0x56);
 is pack('x'),              Buf.new(0x00);
# X needs more complicated tests -- see 03-multi.t
#is pack('Z',    $s1),      Buf.new(0x73);
#is pack('Z3',   $s1),      Buf.new(0x73, 0x74, 0x72);
#is pack('Z[3]', $s1),      Buf.new(0x73, 0x74, 0x72);

done-testing;
