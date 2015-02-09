use Test;
use BSON;

#-------------------------------------------------------------------------------
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
#say "B: ", $b;
my Num $v = $bson._dec_double($b.list);
is $v, 0.333333333333333, 'Result is 0.333333333333333';
my Buf $br = $bson._enc_double($v);
#say "BR: ", $br;
is_deeply $br, $b, "encoded $v";


$b = Buf.new( 0x34, 0x47, 0x5A, 0xAC, 0x34, 0x23, 0x34, 0xF2);
#say "B: ", $b;
$v = $bson._dec_double($b.list);
#say " -> $v";
$br = $bson._enc_double($v);
#say "BR: ", $br;
is_deeply $br, $b, "$v after encode";


$b = Buf.new( 0x00 xx 6, 0x44, 0x40);
#say "B: ", $b;
$v = $bson._dec_double($b.list);
#say " -> $v";
$br = $bson._enc_double($v);
#say "BR: ", $br;
is_deeply $br, $b, "$v after encode";

#-------------------------------------------------------------------------------
# Test special cases
#
# 0x0000 0000 0000 0000 = 0
# 0x8000 0000 0000 0000 = -0
# 0x7FF0 0000 0000 0000 = Inf
# 0xFFF0 0000 0000 0000 = -Inf
#
$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
$v = $bson._dec_double($b.list);
is $v, 0, 'Result is 0';
$br = $bson._enc_double($v);
is_deeply $br, $b, "$v after encode";

$b = Buf.new( 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
$v = $bson._dec_double($b.list);
is $v, Num.new(-0), 'Result is -0';
$br = $bson._enc_double($v);
is_deeply $br, Buf.new(0 xx 8), "-0 not recognizable and becomes 0";


$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F);
$v = $bson._dec_double($b.list);
is $v, Inf, 'Result is Infinite';
$br = $bson._enc_double($v);
is_deeply $br, $b, "$v after encode";

$b = Buf.new( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF);
$v = $bson._dec_double($b.list);
is $v, -Inf, 'Result is minus Infinite';
$br = $bson._enc_double($v);
is_deeply $br, $b, "$v after encode";

#-------------------------------------------------------------------------------
# Test complete document encoding
#
my %test = 
    %( decoded => { b => Num.new(0.3333333333333333)},
       encoded => [ 0x10, 0x00, 0x00, 0x00,             # Total size
                    0x01,                               # Type
                    0x62, 0x00,                         # 'b' + 0
                    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xD5, 0x3F,
                                                        # 8 byte double
                    0x00                                # + 0
                  ],
       type => 'Num';
     );

is_deeply
    $bson.encode(%test<decoded>).list,
    %test<encoded>,
    "encode type {%test<type>}";

is_deeply
    $bson.decode(Buf.new(%test<encoded>)),
    %test<decoded>,
    "decode type {%test<type>}";

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
