#BEGIN { @*INC.unshift( 'lib' ) }

use Test;
use BSON;

# Test mapping between native Perl 6 types and BSON representation.

# Test cases borrowed from
# https://github.com/mongodb/mongo-python-driver/blob/master/test/test_bson.py

my $b = BSON.new( );

my Hash $samples = {

    '0x00 Empty object' => {
        'decoded' => { },
        'encoded' => [ 0x05, 0x00, 0x00, 0x00,          # Total size
                       0x00                             # + 0
                     ],
    },

    '0x01 Double float' => {
         decoded => { b => Num.new(0.3333333333333333)},
         encoded => [ 0x10, 0x00, 0x00, 0x00,           # Total size
                      0x01,                             # Double
                      0x62, 0x00,                       # 'b' + 0
                      0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0xD5, 0x3F,
                                                        # 8 byte double
                      0x00                              # + 0
                    ],
     },

    '0x02 UTF-8 string' => {
        'decoded' => { "test" => "hello world" },
        'encoded' => [ 0x1B, 0x00, 0x00, 0x00,          # 27 bytes
                       0x02,                            # string
                       0x74, 0x65, 0x73, 0x74, 0x00,    # 'test' + 0
                       0x0C, 0x00, 0x00, 0x00,
                       0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x00,
                                                        # 'hello world' + 0  
                       0x00                             # + 0
                     ],
    },

    '0x03 Embedded document' => {
        'decoded' => { "none" => { } },
        'encoded' => [ 0x10, 0x00, 0x00, 0x00,          # 16 bytes
                       0x03,                            # document
                       0x6E, 0x6F, 0x6E, 0x65, 0x00,    # 'none' + 0
                       0x05, 0x00, 0x00, 0x00,          # doc size 4 + 1
                       0x00,                            # end of doc
                       0x00                             # + 0
                     ],
    },

    '0x04 Array' => {
        'decoded' => { "empty" => [ ] },
        'encoded' => [ 0x11, 0x00, 0x00, 0x00,          # 17 bytes
                       0x04,                            # Array
                       0x65, 0x6D, 0x70, 0x74, 0x79, 0x00,
                                                        # 'empty' + 0
                       0x05, 0x00, 0x00, 0x00,          # array size 4 + 1
                       0x00,                            # end of array
                       0x00                             # + 0
                     ],
    },

    '0x05 Binary' => {
        'decoded' => { b => Buf.new(0..4) },
        'encoded' => [ 0x12, 0x00, 0x00, 0x00,          # Total size
                       0x05,                            # Binary
                       0x62, 0x00,                      # 'b' + 0
                       0x05, 0x00, 0x00, 0x00,          # Size of buf
                       0x00,                            # Generic binary type
                       0x00, 0x01, 0x02, 0x03, 0x04,    # Binary data
                       0x00                             # + 0
                     ],
    },

#`{{
    '0x06 Undefined - deprecated' => {
        decoded => { b => Mu.new(0x00) },
        encoded => [ 0x09, 0x00, 0x00, 0x00,            # Total size
                     0x06,                              # Undefined
                     0x62, 0x00,                        # 'b' + 0
                     0x00,                              # undef
                     0x00                               # + 0
                   ]
    },
}}

#`{{
    '0x07 ObjectId' => {
        # Tested in t/600-extended.t
    }
}}

    '0x08 Boolean "true"' => {
        'decoded' => { "true" => True },
        'encoded' => [ 0x0C, 0x00, 0x00, 0x00,          # 12 bytes
                       0x08,                            # Boolean
                       0x74, 0x72, 0x75, 0x65, 0x00,    # 'true' + 0
                       0x01,                            # true
                       0x00                             # + 0
                     ],
    },

    '0x08 Boolean "false"' => {
        'decoded' => { "false" => False },
        'encoded' => [ 0x0D, 0x00, 0x00, 0x00,          # 13 bytes
                       0x08,                            # Boolean
                       0x66, 0x61, 0x6C, 0x73, 0x65, 0x00,
                                                        # 'false' + 0
                       0x00,                            # false
                       0x00                             # + 0
                     ],
    },

#`{{}}
    '0x09 Date time' => {
        decoded => { t => DateTime.new('2015-02-18T11:08:00+0100') },
        encoded => [ 0x10, 0x00, 0x00, 0x00,            # 16 bytes
                     0x09,                              # datetime
                     0x74, 0x00,                        # 't' + 0
                     0x80, 0x64, 0xe4, 0x54, 0x00, 0x00, 0x00, 0x00,
                                                        # 1424128080 seconds
                     0x00                               # + 0
                   ]
    },


    '0x10 32-bit Integer' => {
        'decoded' => { "mike" => 100 },
        'encoded' => [ 0x0F, 0x00, 0x00, 0x00,          # 16 bytes
                       0x10,                            # 32 bits integer
                       0x6D, 0x69, 0x6B, 0x65, 0x00,    # 'mike' + 0
                       0x64, 0x00, 0x00, 0x00,          # 100
                       0x00                             # + 0
                     ],
    },

    '0xA0 Null value' => {
        'decoded' => { "test" => Any },
        'encoded' => [ 0x0B, 0x00, 0x00, 0x00,          # 11 bytes
                       0x0A,                            # null value
                       0x74, 0x65, 0x73, 0x74, 0x00,    # 'test' + 0
                       0x00                             # + 0
                     ],
    },
};

for $samples.keys -> $key {
    my $value = $samples{$key};

    if $key eq '0x09 Date time' {
      my @enc = $b.encode( $value<decoded> ).list;
      my Hash $dec = $b.decode( Buf.new( $value<encoded> ));

      is_deeply @enc, $value<encoded>, 'encode ' ~ $key;
      my @dec_kv = $dec.kv;
      my @enc_kv = $value<decoded>.kv;
      is @dec_kv[0], @enc_kv[0], 'Keys equal';

      # Must compare seconds because the dates will not compare right
      #
      # Failed test 'Values equal'
      # at t/500-native.t line 163
      # expected: '2015-02-18T11:08:00+0100'
      #      got: '2015-02-18T10:08:00Z'
      #
      is @dec_kv[1].posix, @enc_kv[1].posix, 'Values equal';
    }
    
    else {
      is_deeply
          $b.encode( $value<decoded> ).list,
          $value<encoded>,
          'encode ' ~ $key;

      is_deeply
          $b.decode( Buf.new( $value<encoded>.list ) ),
          $value<decoded>,
          'decode ' ~ $key;
    }
}


# check flattening aspects of Perl6

my %flattening = (
	'Array of Embedded documents' => { "ahh" => [ { }, { "not" => "empty" } ] },
	'Array of Arrays' => { "aaa" => [ [ ], [ "not", "empty" ] ] },
);

for %flattening {
    is_deeply
		$b.decode( $b.encode( .value ) ),
		.value,
		.key;
}


#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
