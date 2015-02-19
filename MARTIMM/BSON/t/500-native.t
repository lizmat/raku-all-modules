#BEGIN { @*INC.unshift( 'lib' ) }

use Test;
use BSON;

# Test mapping between native Perl 6 types and BSON representation.

# Test cases borrowed from
# https://github.com/mongodb/mongo-python-driver/blob/master/test/test_bson.py

my BSON $b .= new();
my Str $script = 'function(x){return x;}';
my Hash $scope = { n => 10 };

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

# '0x06 Undefined - deprecated' => { },

#`'0x07 ObjectId' => { Tested in t/600-extended.t },

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

    '0x09 Datetime' => {
        decoded => { t => DateTime.new('2015-02-18T11:08:00+0100') },
        encoded => [ 0x10, 0x00, 0x00, 0x00,            # 16 bytes
                     0x09,                              # datetime
                     0x74, 0x00,                        # 't' + 0
                     0x80, 0x64, 0xe4, 0x54, 0x00, 0x00, 0x00, 0x00,
                                                        # 1424128080 seconds
                     0x00                               # + 0
                   ]
    },

    '0x0A Null value' => {
        'decoded' => { "test" => Any },
        'encoded' => [ 0x0B, 0x00, 0x00, 0x00,          # 11 bytes
                       0x0A,                            # null value
                       0x74, 0x65, 0x73, 0x74, 0x00,    # 'test' + 0
                       0x00                             # + 0
                     ],
    },

    '0x0B Regex' => {
        'decoded' => { "t" => BSON::Regex.new( :regex('abc'), :options('i')) },
        'encoded' => [ 0x0E, 0x00, 0x00, 0x00,          # 11 bytes
                       0x0B,                            # regex
                       0x74, 0x00,                      # 't' + 0
                       0x61, 0x62, 0x63, 0x00,          # /abc/
                       0x69, 0x00,                      # i
                       0x00                             # + 0
                     ],
    },

# '0x0C DBPointer - deprecated' => { },

    '0x0D Javascript' => {
        'decoded' => { "t" => BSON::Javascript.new( :javascript($script)) },
        'encoded' => [ 0x23, 0x00, 0x00, 0x00,          # 35 bytes
                       0x0D,                            # javascript
                       0x74, 0x00,                      # 't' + 0
                       0x17, 0x00, 0x00, 0x00,          # 23 bytes js code + 1
                       0x66, 0x75, 0x6e, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x28,
                       0x78, 0x29, 0x7b, 0x72, 0x65, 0x74, 0x75, 0x72, 0x6e,
                       0x20, 0x78, 0x3b, 0x7d, 0x00,    # UTF8 encoded Javascript
                       0x00                             # + 0
                     ],
    },

# '0x0E ? - deprecated' => { },

    '0x0F Javascript with scope' => {
        'decoded' => { "t" => BSON::Javascript.new( :javascript($script)
                                                    :scope($scope)
                                                  )
                     },
        'encoded' => [ 0x33, 0x00, 0x00, 0x00,          # 51 bytes
                       0x0F,                            # javascript
                       0x74, 0x00,                      # 't' + 0
                       
                       0x27, 0x00, 0x00, 0x00,          # 39 bytes size js + doc
                       
                       0x17, 0x00, 0x00, 0x00,          # 23 bytes js code + 1
                       0x66, 0x75, 0x6e, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x28,
                       0x78, 0x29, 0x7b, 0x72, 0x65, 0x74, 0x75, 0x72, 0x6e,
                       0x20, 0x78, 0x3b, 0x7d, 0x00,    # UTF8 encoded Javascript
                       
                       0x0C, 0x00, 0x00, 0x00,          # 12 bytes embedded
                       0x10,                            # int32
                       0x6e, 0x00,                      # 'n' + 0
                       0x0A, 0x00, 0x00, 0x00,          # 10
                       0x00,                            # end emedded doc
                       
                       0x00                             # + 0
                     ],
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
};

for $samples.keys -> $key {
    my $value = $samples{$key};
    my @enc = $b.encode( $value<decoded> ).list;
    is_deeply @enc, $value<encoded>, 'encode ' ~ $key;

    given $key {
    
        when '0x09 Datetime' {
            my Hash $dec = $b.decode( Buf.new( $value<encoded> ));

            my @dec_kv = $dec.kv;
            my @enc_kv = $value<decoded>.kv;
            is @dec_kv[0], @enc_kv[0], [~] 'decode ', $key, ' Keys equal';

            # Must compare seconds because the dates will not compare right
            #
            # Failed test 'Values equal'
            # at t/500-native.t line 163
            # expected: '2015-02-18T11:08:00+0100'
            #      got: '2015-02-18T10:08:00Z'
            #
            is @dec_kv[1].posix, @enc_kv[1].posix, [~] 'decode ', $key, ' Values equal';
        }
    
        when '0x0B Regex' {
            my Hash $dec = $b.decode( Buf.new( $value<encoded> ));

            my @dec_kv = $dec.kv;
            my @enc_kv = $value<decoded>.kv;
            is @dec_kv[0], @enc_kv[0], [~] 'decode ', $key, ' Keys equal';

            # Must compare content because addresses are not same
            #
            # Failed test 'decode 0x0B Regex'
            # at t/500-native.t line 188
            # expected: {"t" => BSON::Regex.new(regex => "abc", options => "i")}
            #      got: {"t" => BSON::Regex.new(regex => "abc", options => "i")}
            #
            is @dec_kv[1].regex, @enc_kv[1].regex, [~] 'decode ', $key, ' Regex equal';
            is @dec_kv[1].options, @enc_kv[1].options, [~] 'decode ', $key, ' Options equal';
        }

        when '0x0D Javascript' {
            my Hash $dec = $b.decode( Buf.new( $value<encoded> ));

            my @dec_kv = $dec.kv;
            my @enc_kv = $value<decoded>.kv;
            is @dec_kv[0], @enc_kv[0], [~] 'decode ', $key, ' Keys equal';

            # Must compare content because addresses are not same
            #
            is @dec_kv[1].javascript, @enc_kv[1].javascript, [~] 'decode ', $key, ' Javascript equal';
        }

        when '0x0F Javascript with scope' {
            my Hash $dec = $b.decode( Buf.new( $value<encoded> ));

            my @dec_kv = $dec.kv;
            my @enc_kv = $value<decoded>.kv;
            is @dec_kv[0], @enc_kv[0], [~] 'decode ', $key, ' Keys equal';

            # Must compare content because addresses are not same
            #
            is @dec_kv[1].javascript, @enc_kv[1].javascript, [~] 'decode ', $key, ' Javascript equal';
            is_deeply @dec_kv[1].scope, @enc_kv[1].scope, [~] 'decode ', $key, ' scope equal';
        }

        default {
            is_deeply
                $b.decode( Buf.new( $value<encoded>.list ) ),
                $value<decoded>,
                'decode ' ~ $key;
        }
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
