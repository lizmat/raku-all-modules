#-------------------------------------------------------------------------------
# Double precision floating point tests. See also the wikipedia at
# http://en.wikipedia.org/wiki/Double-precision_floating-point_format
# All binary arrays are little endian.
#-------------------------------------------------------------------------------

use v6;
use Test;
use BSON;
use BSON::Double;

#-------------------------------------------------------------------------------
# 
my BSON::Bson $bson .= new;
my Buf $be;
my Buf $b;
my Buf $br;
my Num $v;

#-------------------------------------------------------------------------------
# Test special cases
#
# 0x0000 0000 0000 0000 = 0
#

$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
my Int $index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;
is $v, 0, 'Result is 0';

$br = BSON::Double.encode-double: (abc => $v);
is-deeply $br, $be, "special case $v after encode";


# 0x8000 0000 0000 0000 = -0            Will become 0.
#
$b = Buf.new( 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ Buf.new(0 xx 8);
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;

is $v, Num.new(-0), 'Result is -0';
$br = BSON::Double.encode-double: (abc => $v);
is-deeply $br, $be, "special case -0 not recognizable and becomes 0";


# 0x7FF0 0000 0000 0000 = Inf
#
$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;

is $v, Inf, 'Result is Infinite';
$br = BSON::Double.encode-double: (abc => $v);
is-deeply $br, $be, "special case $v after encode";


# 0xFFF0 0000 0000 0000 = -Inf
#
$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;

is $v, -Inf, 'Result is minus Infinite';
$br = BSON::Double.encode-double: (abc => $v);
is-deeply $br, $be, "special case $v after encode";


#-------------------------------------------------------------------------------
# Other numbers
#
# Number 1/3, 0x3FD5 5555 5555 5555
#
$b = Buf.new( 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xD5, 0x3F);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;
is $v, 0.333333333333333, "Result $v = 0.333333333333333";

$br = BSON::Double.encode-double: (abc => Num.new(1/3));
#say "Br: ", $br;
is-deeply $br, $be, "Compare bufs {$br.perl}";


# Number -1.34277290539414e+242, Big and negative
#
$b = Buf.new( 0x40, 0x47, 0x5A, 0xAC, 0x34, 0x23, 0x34, 0xF2);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;
is $v, -1.34277290539414e+242, "Result $v = -1.34277290539414e+242";

$br = BSON::Double.encode-double: (abc => $v);
#say "BR: ", $br;
is-deeply $br, $be, "Compare bufs {$br.perl}";


# Number 40, Small and positive
#
$b = Buf.new( 0x00 xx 6, 0x44, 0x40);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;
is $v, 40, "Result $v = 40";

$br = BSON::Double.encode-double: (abc => $v);
#say "BR: ", $br;
is-deeply $br, $be, "Compare bufs {$br.perl}";


# Number -203.345, Small and negative
#
$b = Buf.new( 0xd7, 0xa3, 0x70, 0x3d, 0x0a, 0x6b, 0x69, 0xc0);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;
is $v, -203.345, "Result $v = -203.345";

$br = BSON::Double.encode-double: (abc => $v);
#say "BR: ", $br;
is-deeply $br, $be, "Compare bufs {$br.perl}";


# Number 3e-100, Very small and positive
#
$b = Buf.new( 0xE4, 0x83, 0x6A, 0x2B, 0x63, 0xFF, 0x44, 0x2B);
$be = Buf.new(0x01) ~ 'abc'.encode() ~ Buf.new(0x00) ~ $b;
$index = 0;
$v = BSON::Double.decode-double( $be.Array, $index).value;
is $v, 3E-100, "Result $v = 3e-100";

$br = BSON::Double.encode-double: (abc => $v);
#say "BR: ", $br;
is-deeply $br, $be, "Compare bufs {$br.perl}";


#-------------------------------------------------------------------------------
# Cleanup
#
done-testing();
exit(0);
