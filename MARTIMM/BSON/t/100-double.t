use Test;
use BSON;

#-------------------------------------------------------------------------------
# 
#
my $bson = BSON.new;

# Wikipedia: http://en.wikipedia.org/wiki/Double-precision_floating-point_format#Endianness
#
# 0x3FD5 5555 5555 5555
# 0.333333333333333314829616256247390992939472198486328125
# ~ 1/3
#
# Array filled as little endian.
#
my Buf $b = Buf.new( 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xD5, 0x3F);
#say "Reversed for reading: ", $b.reverse.list.fmt('%02X');

# It comes back at a smaller precision but maybe alright
# 0.333333333333333
#
my Num $v = Num.new($bson._double64($b.list));
is $v.fmt('%6.4f'), '0.3333', 'Result is about 0.3333';


$b = $bson._double64($v);
#say "Reversed for reading: ", $b.reverse.list.fmt('%02X');

$b = $bson._double64(Num.new(0.333333333333333314829616256247390992939472198486328125));
#say "Reversed for reading: ", $b.reverse.list.fmt('%02X');

#say '-' x 80;

#-------------------------------------------------------------------------------
# Test special cases
#
# 0x0000 0000 0000 0000 = 0
# 0x8000 0000 0000 0000 = -0
# 0x7FF0 0000 0000 0000 = Inf
# 0xFFF0 0000 0000 0000 = -Inf
#
$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
#say "Reversed for reading: ", $b.reverse.list.fmt('%02X');

$v = Num.new($bson._double64($b.list));
is $v.fmt('%6.4f'), '0.0000', 'Result is about 0.0000';

#say '-' x 80;


$b = Buf.new( 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
#say "Reversed for reading: ", $b.reverse.list.fmt('%02X');

$v = Num.new($bson._double64($b.list));
is $v.fmt('%6.4f'), '0.0000', 'Result is about 0.0000';

#say '-' x 80;


$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F);
#say "Reversed for reading: ", $b.reverse.list.fmt('%02X');

$v = Num.new($bson._double64($b.list));
is $v, Inf, 'Result is Infinite';

#say '-' x 80;


$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF);
#say "Reversed for reading: ", $b.reverse.list.fmt('%02X');

$v = Num.new($bson._double64($b.list));
is $v, Inf, 'Result is Infinite';







#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
