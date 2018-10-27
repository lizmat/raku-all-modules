use v6;

my @lookup-table =
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a,
    0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15,
    0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20,
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b,
    0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36,
    0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41,
    0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c,
    0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,
    0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62,
    0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d,
    0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
    0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f,
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x0) },     # 0x80
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x1) },     # 0x81
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x2) },     # 0x82
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x3) },     # 0x83
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x4) },     # 0x84
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x5) },     # 0x85
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x6) },     # 0x86
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x7) },     # 0x87
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x8) },     # 0x88
    sub ($b, $position is rw) { _unpack-map($b, $position, 0x9) },     # 0x89
    sub ($b, $position is rw) { _unpack-map($b, $position, 0xa) },     # 0x8a
    sub ($b, $position is rw) { _unpack-map($b, $position, 0xb) },     # 0x8b
    sub ($b, $position is rw) { _unpack-map($b, $position, 0xc) },     # 0x8c
    sub ($b, $position is rw) { _unpack-map($b, $position, 0xd) },     # 0x8d
    sub ($b, $position is rw) { _unpack-map($b, $position, 0xe) },     # 0x8e
    sub ($b, $position is rw) { _unpack-map($b, $position, 0xf) },     # 0x8f
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x0) },   # 0x90
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x1) },   # 0x91
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x2) },   # 0x92
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x3) },   # 0x93
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x4) },   # 0x94
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x5) },   # 0x95
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x6) },   # 0x96
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x7) },   # 0x97
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x8) },   # 0x98
    sub ($b, $position is rw) { _unpack-array($b, $position, 0x9) },   # 0x99
    sub ($b, $position is rw) { _unpack-array($b, $position, 0xa) },   # 0x9a
    sub ($b, $position is rw) { _unpack-array($b, $position, 0xb) },   # 0x9b
    sub ($b, $position is rw) { _unpack-array($b, $position, 0xc) },   # 0x9c
    sub ($b, $position is rw) { _unpack-array($b, $position, 0xd) },   # 0x9d
    sub ($b, $position is rw) { _unpack-array($b, $position, 0xe) },   # 0x9e
    sub ($b, $position is rw) { _unpack-array($b, $position, 0xf) },   # 0x9f
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x00) }, # 0xa0
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x01) }, # 0xa1
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x02) }, # 0xa2
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x03) }, # 0xa3
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x04) }, # 0xa4
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x05) }, # 0xa5
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x06) }, # 0xa6
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x07) }, # 0xa7
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x08) }, # 0xa8
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x09) }, # 0xa9
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x0a) }, # 0xaa
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x0b) }, # 0xab
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x0c) }, # 0xac
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x0d) }, # 0xad
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x0e) }, # 0xae
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x0f) }, # 0xaf
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x10) }, # 0xb0
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x11) }, # 0xb1
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x12) }, # 0xb2
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x13) }, # 0xb3
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x14) }, # 0xb4
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x15) }, # 0xb5
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x16) }, # 0xb6
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x17) }, # 0xb7
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x18) }, # 0xb8
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x19) }, # 0xb9
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x1a) }, # 0xba
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x1b) }, # 0xbb
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x1c) }, # 0xbc
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x1d) }, # 0xbd
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x1e) }, # 0xbe
    sub ($b, $position is rw) { _unpack-string($b, $position, 0x1f) }, # 0xbf
    Any,     # 0xc0
    Failure, # 0xc1
    False,   # 0xc2
    True,    # 0xc3
    sub ($b, $position is rw) { _unpack-bin($b, $position, _unpack-uint( $b, $position, 1 )) },
    sub ($b, $position is rw) { _unpack-bin($b, $position, _unpack-uint( $b, $position, 2 )) },
    sub ($b, $position is rw) { _unpack-bin($b, $position, _unpack-uint( $b, $position, 4 )) },
    Failure,  # 0xc7
    Failure,  # 0xc8
    Failure,  # 0xc9
    &_unpack-float,  # 0xca
    &_unpack-double, # 0xcb
    sub ($b, $position is rw) { _unpack-uint($b, $position, 1) }, # 0xcc
    sub ($b, $position is rw) { _unpack-uint($b, $position, 2) }, # 0xcd
    sub ($b, $position is rw) { _unpack-uint($b, $position, 4) }, # 0xce
    sub ($b, $position is rw) { _unpack-uint($b, $position, 8) }, # 0xcf
    sub ($b, $position is rw) { _unpack-uint($b, $position, 1 ) -^ 0xff - 1 },
    sub ($b, $position is rw) { _unpack-uint($b, $position, 2 ) -^ 0xffff - 1 },
    sub ($b, $position is rw) { _unpack-uint($b, $position, 4 ) -^ 0xffffffff - 1 },
    sub ($b, $position is rw) { _unpack-uint($b, $position, 8 ) -^ 0xffffffffffffffff - 1 },
    Failure, # 0xd4
    Failure, # 0xd5
    Failure, # 0xd6
    Failure, # 0xd7
    Failure, # 0xd8
    sub ($b, $position is rw) { _unpack-string($b, $position, _unpack-uint($b, $position, 1) ) },
    sub ($b, $position is rw) { _unpack-string($b, $position, _unpack-uint($b, $position, 2) ) },
    sub ($b, $position is rw) { _unpack-string($b, $position, _unpack-uint($b, $position, 4) ) },
    sub ($b, $position is rw) { _unpack-array($b, $position, _unpack-uint($b, $position, 2) ) },
    sub ($b, $position is rw) { _unpack-array($b, $position, _unpack-uint($b, $position, 4) ) },
    sub ($b, $position is rw) { _unpack-map($b, $position, _unpack-uint($b, $position, 2) ) },
    sub ($b, $position is rw) { _unpack-map($b, $position, _unpack-uint($b, $position, 4) ) },
    -0x20, -0x1f, -0x1e, -0x1d, -0x1c, -0x1b, -0x1a, -0x19, -0x18,
    -0x17, -0x16, -0x15, -0x14, -0x13, -0x12, -0x11, -0x10, -0x0f,
    -0x0e, -0x0d, -0x0c, -0x0b, -0x0a, -0x09, -0x08, -0x07, -0x06,
    -0x05, -0x04, -0x03, -0x02, -0x01
;


module Data::MessagePack::Unpacker {

    our sub unpack( Blob $b ) {
        my $position = 0;
        _unpack( $b, $position );
    }

}

    sub _unpack( Blob $b, Int $position is rw ) {
        my $next = @lookup-table[$b[$position++]];
        $next ~~ Callable ?? $next($b, $position) !! $next;
    }

    sub _unpack-array( Blob $b, Int $position is rw, Int $elems ) {
        my @array = ();
        for ^$elems {
            @array.push(
                _unpack($b, $position)
            );
        }

        @array;
    }

    sub _unpack-map( Blob $b, Int $position is rw, Int $elems ) {
        my %map = ();
        for ^$elems {
            %map{ _unpack($b, $position) } = _unpack($b, $position);
        }

        %map;
    }


sub _unpack-uint( Blob $b, Int $position is rw, Int $byte-count ) {
    my Int $res = 0;
    for ^$byte-count {
        $res +<= 8;
        $res += $b[$position++];
    }

    $res;
}

sub _unpack-bin( Blob $b, Int $position is rw, Int $length ) {
    my $blob = $b.subbuf($position, $length);
    $position += $length;

    $blob;
}



sub _unpack-string( Blob $b, Int $position is rw, Int $length ) {
    my $str = $b.subbuf($position, $length).decode;
    $position += $length;

    $str;
}

sub _unpack-float( Blob $b, Int $position is rw ) {
    my $raw = 0;
    for ^4 {
        $raw +<= 8;
        $raw += $b[$position++];
    }

    return 0.0 if $raw == 0;
    my $s = $raw +& 0x80000000 ?? -1 !! 1;
    my $exp = ( $raw +> 23 ) +& 0xff;
    $exp -= 127;
    my $mantissa = $raw +& 0x7FFFFF;
    $mantissa = 1 + ( $mantissa / 2**23 );

    $s * $mantissa * 2**$exp;
}
sub _unpack-double( Blob $b, Int $position is rw ) {
    my $raw = 0;
    for ^8 {
        $raw +<= 8;
        $raw += $b[$position++];
    }

    return 0.0 if $raw == 0;
    my $s = $raw +& 0x8000000000000000 ?? -1 !! 1;
    my $exp = ( $raw +> 52 ) +& 0x7ff;
    $exp -= 1023;
    my $mantissa = $raw +& 0x0FFFFFFFFFFFFF;
    $mantissa = 1 + ( $mantissa / 2**52 );

    $s * $mantissa * 2**$exp;
}
# vim: ft=perl6
