#BEGIN { @*INC.unshift( 'lib' ) }

use v6;
use Test;
use BSON;
use BSON::ObjectId;

plan( 7 );

my %samples = (

    'ObjectId minimum' => {
        'str' => '000000000000000000000000',
        'buf' => [ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ],
    },

    'ObjectId maximum' => {
        'str' => 'ffffffffffffffffffffffff',
        'buf' => [ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ],
    }
);

for %samples {
    is-deeply
        BSON::ObjectId.new( .value{ 'str' } ).perl,
        BSON::ObjectId.new( Buf.new( .value{ 'buf' }.list ) ).perl,
        .key;
}

dies-ok
    { BSON::ObjectId.new( 'ZZZZZZZZZZZZZZZZZZZZZZZZ' )},
    'ObjectId die on not hex values';

dies-ok
    { BSON::ObjectId.new( '00' )},
    'ObjectId die on too short hex values';

dies-ok
    { BSON::ObjectId.new( Buf.new( 0x00 ) ) },
    'ObjectId die on too short buf';


# Test cases borrowed from
# https://github.com/mongodb/mongo-python-driver/blob/master/test/test_bson.py

my $oid = BSON::ObjectId.new(
    Buf.new( 0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
             0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B
           )
);

my BSON::Bson $bson .= new;
is-deeply
    $bson.encode( { "oid" => $oid } ).list,
    [ 0x16, 0x00, 0x00, 0x00,
      0x07,
      0x6F, 0x69, 0x64, 0x00,
      0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
      0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
      0x00
    ],
    'encode ObjectId';

$bson._init_index;
is-deeply
    $bson.decode(
      Buf.new( 0x16, 0x00, 0x00, 0x00,                  # Length
               0x07,                                    # object id code
               0x6F, 0x69, 0x64, 0x00,                  # 'oid' + 0
               0x00, 0x01, 0x02, 0x03, 0x04, 0x05,      # object id
               0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
               0x00                                     # end doc
             )
    ).{'oid'}.Buf.list,
    [ 0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
      0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B
    ],
    'decode ObjectId';
