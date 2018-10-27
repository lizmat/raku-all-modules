use v6;

class X::Data::MessagePack::Packer is Exception {
  has $.reason;
  method message()
  {
    "Error : $.reason";
  }
}

module Data::MessagePack::Packer {

    our sub pack( $params ) {
        _pack( $params );
    }

    my multi _pack( Any:U $object ) {
        Blob.new(0xc0);
    }
    my multi _pack( Bool:D $b ) {
        $b??Blob.new(0xc3)!!Blob.new(0xc2);
    }

    my multi _pack( Int:D $i ) {
        given $i {
            when * < -2**63 {
                X::Data::MessagePack::Packer.new(reason => "Number to big to be converted").throw;
            }
            when * < -2**31 {
                return Blob.new(0xd3, $i +> 31 +> 25 +& 0xff,  # Rakudo bug, can't shift 32 or more
                                      $i +> 31 +> 17 +& 0xff,
                                      $i +> 31 +> 9  +& 0xff,
                                      $i +> 31 +> 1  +& 0xff,
                                      $i +> 24       +& 0xff,
                                      $i +> 16       +& 0xff,
                                      $i +> 8        +& 0xff,
                                      $i             +& 0xff);
            }
            when * < -2**15 {
                return Blob.new(0xd2, $i +> 24 +& 0xff,
                                      $i +> 16 +& 0xff,
                                      $i +> 8  +& 0xff,
                                      $i       +& 0xff);

            }
            when * < -2**7 { return Blob.new( 0xd1, $i +> 8 +& 0xff, $i +& 0xff )}
            when * < -32 { return Blob.new( 0xd0, $i ) }
            when * < 0 { return Blob.new( $i +& 255 ) }
            when * < 128 { return Blob.new( $i ) }
            when * < 2**8 { return Blob.new( 0xcc, $i ) }
            when * < 2**16 { return Blob.new(0xcd, $i +> 8 +& 0xff, $i +& 0xff); }
            when * < 2**32 {
                return Blob.new(0xce, $i +> 24 +& 0xff,
                                      $i +> 16 +& 0xff,
                                      $i +> 8  +& 0xff,
                                      $i       +& 0xff);
            }
            when * < 2**64 {
                return Blob.new(0xcf, $i +> 31 +> 25 +& 0xff,  # Rakudo bug, can't shift 32 or more
                                      $i +> 31 +> 17 +& 0xff,
                                      $i +> 31 +> 9  +& 0xff,
                                      $i +> 31 +> 1  +& 0xff,
                                      $i +> 24       +& 0xff,
                                      $i +> 16       +& 0xff,
                                      $i +> 8        +& 0xff,
                                      $i             +& 0xff);
            }
            default {
                X::Data::MessagePack::Packer.new(reason => "Number to big to be converted").throw;
            }
        }
    }

    my multi _pack( Str:D $s ) {
        my @stringdata = $s.encode.list;
        my $length = @stringdata.elems;
        my @header;

        given $length {
            when $length < 32 { @header.push( 0xa0 + $length ) }
            when $length < 2**8 { @header.push( 0xd9, $length ) }
            when $length < 2**16 { @header.push( 0xda, $length +> 8 +& 0xff, $length +& 0xff ) }
            when $length < 2**32 { @header.push( 0xdb, $length +> 24 +& 0xff, $length +> 16 +& 0xff, $length +> 8 +& 0xff, $length +& 0xff ) }
            default { X::Data::MessagePack::Packer.new(reason => "String is too long").throw; }
        }
        return Blob.new(@header, $s.encode.list );
    }

    my multi _pack( Blob:D $b ) {
        my $length = $b.elems;

        my @header;
        given $length {
            when $length < 2**8 { @header.push( 0xc4, $length ) }
            when $length < 2**16 { @header.push( 0xc5, $length +> 8 +& 0xff, $length +& 0xff ) }
            when $length < 2**32 { @header.push( 0xc6, $length +> 24 +& 0xff, $length +> 16 +& 0xff, $length +> 8 +& 0xff, $length +& 0xff ) }
            default { fail 'String is too long' }
        }
        return Blob.new(@header, $b.list );
    }

    my multi _pack( Numeric:D $f ) {
        if $f.Int == $f {
            return _pack( $f.Int );
        }
        #only double for now
        my $sign = $f>0??0!!1;
        my $abs = $f.abs;
        my $exp = ($abs.log / 2.log).Int;
        my $mantissa = $abs / 2**$exp;
        my $frac = $mantissa - 1;
        #adjuext exponenet
        $exp += 1023;

        #rouding done with the 3 followind Number
        #0xx and 100 for even mantissa, do nothing
        #100 and odd or 101, 110, 111 add one to mantissa
        #if overflow, add one to exponent, if exponent overflow + infinity
        my $frac-shifted = $frac * 2**52;

        my $grs = (($frac-shifted - $frac-shifted.Int) * 2**3).base(2).Int;
        $grs = ($frac-shifted * 2**3) +& 0x7;

        my $to_add = 0;
        if $grs +& 0b100  {
            #GRS -> 1xx
            if $grs +& 0b011 {
                #GRS -> 1xx with xx !+= 00
                $to_add = 1;
            } else {
                #GRS -> 1xx with xx == 00, up id mantissa is odd in binary, last bit is one
                if $frac-shifted +& 0b1 {
                    $to_add = 1;
                }
            }
        }

        if $to_add {
            #add and check overflow, hence 52 last bit are 0
            $frac-shifted += $to_add;

            if $frac-shifted +& 0xFFFFFFFFFFFFF == 0 {
                $exp += 1;
            }
        }

        my $binary = $sign +< 63 +| ( $exp +& 0x7FF ) +< 52 +| ( $frac-shifted +& 0xFFFFFFFFFFFFF );

        return Blob.new( 0xcb, (56, 48 ... 0).map( $binary +> * +& 0xff) );
    }

    my multi _pack( List:D $l where $l.elems < 2**4 ) {
        return Blob.new( 0x90 + $l.elems, $l.map( { _pack( $_).list } ) );
    }

    my multi _pack( List:D $l where 2**4 <= $l.elems < 2**16 ) {
        return Blob.new( 0xdc, (8,0).map( $l.elems +> * +& 0xff ), $l.map( { _pack( $_).list } ) );
    }

    my multi _pack( List:D $l where 2**16 <= $l.elems < 2**32 ) {
        return Blob.new( 0xdd, (24,16,8,0).map( $l.elems +> * +& 0xff ), $l.map( { _pack( $_).list } ) );
    }

    my multi _pack( Hash:D $h where $h.elems < 2**4 ) {
        return Blob.new( 0x80 + $h.elems, $h.kv.map( { _pack( $_).list } ) );
    }

    my multi _pack( Hash:D $h where 2**4 <= $h.elems < 2**16 ) {
        return Blob.new( 0xde, (8,0).map( $h.elems +> * +& 0xff ), $h.kv.map( { _pack( $_).list } ) );
    }

    my multi _pack( Hash:D $h where 2**16 <= $h.elems < 2**32 ) {
        return Blob.new( 0xdf, (24,16,8,0).map( $h.elems +> * +& 0xff ), $h.kv.map( { _pack( $_).list } ) );
    }
}
# vim: ft=perl6
