use v6;
use Test;
use BSON;
use BSON::Double;

#-------------------------------------------------------------------------------
# Double precision floating point tests. See also the wikipedia at
# http://en.wikipedia.org/wiki/Double-precision_floating-point_format
# All binary arrays are little endian.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 
my BSON::Bson $bson .= new;
my Buf $b;
my Buf $br;
my Num $v;

#-------------------------------------------------------------------------------
# Test special cases
#
# 0x0000 0000 0000 0000 = 0
#

$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
my Int $index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);
is $v, 0, 'Result is 0';

$br = BSON::Double.encode-double($v);
is-deeply $br, $b, "special case $v after encode";


# 0x8000 0000 0000 0000 = -0            Will become 0.
#
$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);

is $v, Num.new(-0), 'Result is -0';
$br = BSON::Double.encode-double($v);
is-deeply $br,
          Buf.new( 0x00 xx 8),
          "special case -0 not recognizable and becomes 0";


# 0x7FF0 0000 0000 0000 = Inf
#
$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);

is $v, Inf, 'Result is Infinite';
$br = BSON::Double.encode-double($v);
is-deeply $br, $b, "special case $v after encode";


# 0xFFF0 0000 0000 0000 = -Inf
#
$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);

is $v, -Inf, 'Result is minus Infinite';
$br = BSON::Double.encode-double($v);
is-deeply $br, $b, "special case $v after encode";


# 0x 7ff0 0000 0000 0001 <= nan <= 0x 7ff7 ffff ffff ffff signalling NaN
# 0x fff0 0000 0000 0001 <= nan <= 0x fff7 ffff ffff ffff
# 0x 7ff8 0000 0000 0000 <= nan <= 0x 7fff ffff ffff ffff quiet NaN
# 0x fff8 0000 0000 0000 <= nan <= 0x ffff ffff ffff ffff
#
$b = Buf.new( 0x01, 0x03, 0x00, 0x00, 0x00, 0x00, 0xf0, 0x7f);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);

is $v, NaN, 'Result is not a number';
$br = BSON::Double.encode-double($v);
is-deeply $br, Buf.new( 0 xx 6, 0xF8, 0x7F), "special case $v after encode";

$b = Buf.new( 0x01, 0x03, 0x00, 0x00, 0xff, 0x00, 0xf8, 0xff);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);

is $v, NaN, 'Result is not a number';
$br = BSON::Double.encode-double($v);
is-deeply $br, Buf.new( 0 xx 6, 0xF8, 0x7F), "special case $v after encode";


#-------------------------------------------------------------------------------
# Other numbers
#
# Number 1/3, 0x3FD5 5555 5555 5555
#
$b = Buf.new( 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xD5, 0x3F);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);
is $v, 0.333333333333333, "Result $v = 0.333333333333333";

$br = BSON::Double.encode-double(Num.new(1/3));
#say "Br: ", $br;
is-deeply $br, $b, "Compare bufs {$br.perl}";


# Number -1.34277290539414e+242, Big and negative
#
$b = Buf.new( 0x40, 0x47, 0x5A, 0xAC, 0x34, 0x23, 0x34, 0xF2);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);
is $v, -1.34277290539414e+242, "Result $v = -1.34277290539414e+242";

$br = BSON::Double.encode-double($v);
#say "BR: ", $br;
is-deeply $br, $b, "Compare bufs {$br.perl}";


# Number 40, Small and positive
#
$b = Buf.new( 0x00 xx 6, 0x44, 0x40);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);
is $v, 40, "Result $v = 40";

$br = BSON::Double.encode-double($v);
#say "BR: ", $br;
is-deeply $br, $b, "Compare bufs {$br.perl}";


# Number -203.345, Small and negative
#
$b = Buf.new( 0xd7, 0xa3, 0x70, 0x3d, 0x0a, 0x6b, 0x69, 0xc0);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);
is $v, -203.345, "Result $v = -203.345";

$br = BSON::Double.encode-double($v);
#say "BR: ", $br;
is-deeply $br, $b, "Compare bufs {$br.perl}";


# Number 3e-100, Very small and positive
#
$b = Buf.new( 0xE4, 0x83, 0x6A, 0x2B, 0x63, 0xFF, 0x44, 0x2B);
$index = 0;
$v = BSON::Double.decode-double( $b.Array, $index);
is $v, 3E-100, "Result $v = 3e-100";

$br = BSON::Double.encode-double($v);
#say "BR: ", $br;
is-deeply $br, $b, "Compare bufs {$br.perl}";


#-------------------------------------------------------------------------------
# Cleanup
#
done-testing();
exit(0);
