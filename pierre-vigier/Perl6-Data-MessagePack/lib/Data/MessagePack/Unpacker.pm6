use v6;

module Data::MessagePack::Unpacker {

    our sub unpack( Blob $b ) {
        my $position = 0;
        _unpack( Buf.new( $b ), $position );
    }

    sub _unpack-array( Buf $b, Int $position is rw, Int $elems ) {
        my @array = ();
        for ^$elems {
            @array.push(
                _unpack($b, $position)
            );
        }
        return @array;
    }

    sub _unpack-map( Buf $b, Int $position is rw, Int $elems ) {
        my %map = ();
        for ^$elems {
            %map{ _unpack($b, $position) } = _unpack($b, $position);
        }
        return %map;
    }

    sub _unpack( Buf $b, Int $position is rw ) {
        given $b[$position++] {
            when 0xc0 { Any }
            when 0xc2 { False }
            when 0xc3 { True }
            #bin
            when 0xc4 { _unpack-bin($b, $position, _unpack-uint( $b, $position, 1 )) }
            when 0xc5 { _unpack-bin($b, $position, _unpack-uint( $b, $position, 2 )) }
            when 0xc6 { _unpack-bin($b, $position, _unpack-uint( $b, $position, 4 )) }
            # extension
            when 0xc7 { ... }
            when 0xc8 { ... }
            when 0xc9 { ... }
            #floats
            when 0xca { _unpack-float($b, $position) }
            when 0xcb { _unpack-double($b, $position) }
            #uint
            when 0xcc { _unpack-uint( $b, $position, 1 ) }
            when 0xcd { _unpack-uint( $b, $position, 2 ) }
            when 0xce { _unpack-uint( $b, $position, 4 ) }
            when 0xcf { _unpack-uint( $b, $position, 8 ) }
            #int
            when 0xd0 { _unpack-uint( $b, $position, 1 ) -^ 0xff - 1 }
            when 0xd1 { _unpack-uint( $b, $position, 2 ) -^ 0xffff - 1 }
            when 0xd2 { _unpack-uint( $b, $position, 4 ) -^ 0xffffffff - 1 }
            when 0xd3 { _unpack-uint( $b, $position, 8 ) -^ 0xffffffffffffffff - 1 }
            #fixext
            when 0xd4 { ... }
            when 0xd5 { ... }
            when 0xd6 { ... }
            when 0xd7 { ... }
            when 0xd8 { ... }
            #strings
            when 0xd9 { _unpack-string($b, $position, _unpack-uint( $b, $position, 1 )) }
            when 0xda { _unpack-string($b, $position, _unpack-uint( $b, $position, 2 )) }
            when 0xdb { _unpack-string($b, $position, _unpack-uint( $b, $position, 4 )) }
            #array
            when 0xdc { _unpack-array($b, $position, _unpack-uint( $b, $position, 2) ) }
            when 0xdd { _unpack-array($b, $position, _unpack-uint( $b, $position, 4) ) }
            #map
            when 0xde { _unpack-map($b, $position, _unpack-uint( $b, $position, 2) ) }
            when 0xdf { _unpack-map($b, $position, _unpack-uint( $b, $position, 4) ) }
            #positive fixint 0xxxxxxx	0x00 - 0x7f
            when * +& 0b10000000 == 0 { $_ }
            #fixmap          1000xxxx	0x80 - 0x8f
            when * +& 0b11110000 == 0b10000000 { _unpack-map($b, $position, $_ +& 0x0f ) }
            #fixarray        1001xxxx	0x90 - 0x9f
            when * +& 0b11110000 == 0b10010000 { _unpack-array($b, $position, $_ +& 0x0f ) }
            #fixstr          101xxxxx	0xa0 - 0xbf
            when * +& 0b11100000 == 0b10100000 { _unpack-string($b, $position, $_ +& 0x1f ) }
            #negative fixint 111xxxxx	0xe0 - 0xff
            when * +& 0b11100000 == 0b11100000 { $_ +& 0x1f -^ 0x1f - 1 }
        }
    }

}

sub _unpack-uint( Buf $b, Int $position is rw, Int $byte-count ) {
    my Int $res = 0;
    for ^$byte-count {
        $res +<= 8;
        $res += $b[$position++];
    }
    return $res;
}

sub _unpack-bin( Buf $b, Int $position is rw, Int $length ) {
    my $blob = Blob.new( $b[$position .. ($position + $length - 1)] );
    $position += $length;
    return $blob;
}



sub _unpack-string( Buf $b, Int $position is rw, Int $length ) {
    my $str = Blob.new( $b[$position .. ($position + $length - 1)] ).decode;
    $position += $length;
    return $str;
}

sub _unpack-float( Buf $b, Int $position is rw ) {
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
    return $s * $mantissa * 2**$exp;
}
sub _unpack-double( Buf $b, Int $position is rw ) {
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
    return $s * $mantissa * 2**$exp;
}
# vim: ft=perl6
