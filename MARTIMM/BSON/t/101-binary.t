use Test;
use BSON;
use BSON::Binary;

#-------------------------------------------------------------------------------
# Binary object
#
my BSON $bson .= new;

my BSON::Binary $bin-obj .= new;
my Buf $raw-bin = Buf.new(0x55 xx 3);
$bin-obj.raw($raw-bin);
is_deeply( $bin-obj.Buf, $raw-bin, 'compare data');

my Array $bin-test = [ 0x03, 0x00, 0x00, 0x00,          # Size of buf
                       0x00,                            # Generic binary type
                       0x55 xx 3,                       # Raw Buf
                     ];
my Buf $enc-bin = $bin-obj._enc_binary($bson);
is_deeply( $enc-bin.list, $bin-test, 'encode test');

$bin-obj .= new;
$bin-obj._dec_binary( $bson, $enc-bin.list);
is_deeply( $bin-obj.Buf, $raw-bin, 'compare data after decoding');

#-------------------------------------------------------------------------------
# Test complete document encoding
#
#$bin-obj.raw(Buf.new(^5));

my %test = 
    %( decoded => { b => BSON::Binary.new().raw(Buf.new(^5)) },
       encoded => [ 0x12, 0x00, 0x00, 0x00,             # Total size
                    0x05,                               # Type
                    0x62, 0x00,                         # 'b' + 0
                    0x05, 0x00, 0x00, 0x00,             # Size of buf
                    0x00,                               # Generic binary type
                    0x00, 0x01, 0x02, 0x03, 0x04,       # Buf.new(^5)
                    0x00                                # + 0
                  ],
       type => 'Binary';
     );

is_deeply
    $bson.encode(%test<decoded>).list,
    %test<encoded>,
    "encode type {%test<type>}";

is_deeply
    $bson.decode(Buf.new(%test<encoded>))<b>.Buf,
    %test<decoded><b>.Buf,
    "decode type {%test<type>}";

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
