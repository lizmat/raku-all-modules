use Test;
use BSON;

#-------------------------------------------------------------------------------
# Test complete document encoding
#
my $bson = BSON.new;

my %test = 
    %( decoded => { b => Buf.new(^5) },
       encoded => [ 0x12, 0x00, 0x00, 0x00,             # Total size
                    0x05,                               # Type
                    0x62, 0x00,                         # 'b' + 0
                    0x05, 0x00, 0x00, 0x00,             # Size of buf
                    0x00,                               # Generic binary type
                    0x00, 0x01, 0x02, 0x03, 0x04,       # Buf.new(^5)
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
