use v6;
use Test;
use BSON;
use BSON::Binary;

#-------------------------------------------------------------------------------
# Binary object
#
my BSON::Binary $bin-obj .= new;
my Buf $raw-bin = Buf.new(0x55 xx 3);
$bin-obj.raw($raw-bin);
is-deeply( $bin-obj.Buf, $raw-bin, 'compare data');

my Array $bin-test = [ 0x03, 0x00, 0x00, 0x00,          # Size of buf
                       0x00,                            # Generic binary type
                       0x55 xx 3,                       # Raw Buf
                     ];
my Buf $enc-bin = $bin-obj.enc_binary;
is-deeply( $enc-bin.list, $bin-test, 'encode test');

#say "EB: ", $enc-bin;
my $index = 0;
$bin-obj .= new;
$bin-obj.dec_binary( $enc-bin.list, $index);
is-deeply( $bin-obj.Buf, $raw-bin, 'compare data after decoding');
is( $index, $bin-test.elems, 'Index is shifted');

#-------------------------------------------------------------------------------
# Test complete document encoding
#
#$bin-obj.raw(Buf.new(^5));

my BSON::Bson $bson .= new;

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

is-deeply
    $bson.encode(%test<decoded>).list,
    %test<encoded>,
    "encode type {%test<type>}";

$bson._init_index;
is-deeply
    $bson.decode(Buf.new(%test<encoded>))<b>.Buf,
    %test<decoded><b>.Buf,
    "decode type {%test<type>}";

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
