use v6;

class Data::MessagePack::StreamingUnpacker {
    has Supply    $.source;
    has Supplier  $!supplier;

    has           $!next = &get-next;

    submethod TWEAK ( :$!source ){
        $!supplier = Supplier::Preserving.new;
        $!source.tap(
            -> $v { self.process_input( $v ) },
            done => {
                $!supplier.done();
            },
            quit => {
                $!supplier.quit($_)
            }
        );
    }

    method Supply returns Supply {
        $!supplier.Supply;
    }

    multi method process_input( Blob $b ) {
        $b.map: { $.process_input( $_) };
    }

    multi method process_input( $byte ) {
        $!next = $!next.( $byte );

        if $!next !~~ Sub {
            $!supplier.emit( $!next );
            $!next = &get-next;
        }
    }

    sub get-next( $byte ) {
        #nothing in queue, start a new decode loop
        given $byte {
            when 0xc0 { Any }
            when 0xc2 { False }
            when 0xc3 { True }
            #bin
            when 0xc4 { process-bin( length-bytes => 1 ) }
            when 0xc5 { process-bin( length-bytes => 2 ) }
            when 0xc6 { process-bin( length-bytes => 4 ) }
            #string
            when 0xd9 { process-string( length-bytes => 1 ) }
            when 0xda { process-string( length-bytes => 2 ) }
            when 0xdb { process-string( length-bytes => 4 ) }
            #array
            when 0xdc { process-array( length-bytes => 2 ) }
            when 0xdd { process-array( length-bytes => 4 ) }
            #map
            when 0xde { process-hash( length-bytes => 2 ) }
            when 0xdf { process-hash( length-bytes => 4 ) }
            #floats
            when 0xca { process-float() }
            when 0xcb { process-double() }
            #uint
            when 0xcc { process-uint( length-bytes => 1 ) }
            when 0xcd { process-uint( length-bytes => 2 ) }
            when 0xce { process-uint( length-bytes => 4 ) }
            when 0xcf { process-uint( length-bytes => 8 ) }
            #int
            when 0xd0 { process-int( length-bytes => 1 ) }
            when 0xd1 { process-int( length-bytes => 2 ) }
            when 0xd2 { process-int( length-bytes => 4 ) }
            when 0xd3 { process-int( length-bytes => 8 ) }

            #positive fixint 0xxxxxxx	0x00 - 0x7f
            when * +& 0b10000000 == 0 { $byte }
            #fixmap          1000xxxx	0x80 - 0x8f
            when * +& 0b11110000 == 0b10000000 { process-hash( length => $byte +& 0x0f ) }
            #fixarray        1001xxxx	0x90 - 0x9f
            when * +& 0b11110000 == 0b10010000 { process-array( length => $byte +& 0x0f  ) }
            #negative fixint 111xxxxx	0xe0 - 0xff
            when * +& 0b11100000 == 0b11100000 { $byte +& 0x1f -^ 0x1f - 1 }
            #fixstr          101xxxxx	0xa0 - 0xbf
            when * +& 0b11100000 == 0b10100000 { process-string( length => $byte +& 0x1f ) }
        }
    }

    sub process-hash( :$length-bytes = 0, :$length = 0 ) {
        if $length-bytes == 0 and $length == 0 {
            return {};
        }
        my $remaining-bytes = $length-bytes;
        my $elems = $length;
        my $hash-next = &get-next;
        my @pairs = ();

        return sub ($byte) {
            if $remaining-bytes {
                $elems +<= 8; $elems += $byte;
                $remaining-bytes--;
                return &?BLOCK;
            } else {
                $hash-next = $hash-next.($byte);
                if $hash-next !~~ Sub {
                    @pairs.push( $hash-next );
                    $elems-- if @pairs.elems %% 2;
                    return @pairs.Hash unless $elems;
                    $hash-next = &get-next;
                }
                return &?BLOCK;
            }
        }
    }

    sub process-array( :$length-bytes = 0, :$length = 0 ) {
        if $length-bytes == 0 and $length == 0 {
            return [];
        }
        my @array;
        my $remaining-bytes = $length-bytes;
        my $elems = $length;
        my $array-next = &get-next;

        return sub ($byte) {
            if $remaining-bytes {
                $elems +<= 8; $elems += $byte;
                $remaining-bytes--;
                return &?BLOCK;
            } else {
                $array-next = $array-next.($byte);
                if $array-next !~~ Sub {
                    @array.push: $array-next;
                    return @array unless --$elems;
                    $array-next = &get-next;
                }
                return &?BLOCK;
            }
        }
    }

    sub process-uint( :$length-bytes ) {
        my $remaining-bytes = $length-bytes;
        my $value = 0;
        return sub ($byte) {
            $value +<= 8; $value += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                return $value ;
            }
        };
    }

    sub process-int( :$length-bytes ) {
        my $remaining-bytes = $length-bytes;
        my $value = 0;
        my $mask = :16("FF" x $length-bytes);
        return sub ($byte) {
            $value +<= 8; $value += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                return $value -^ $mask - 1 ;
            }
        };
    }

    sub process-float() {
        my $remaining-bytes = 4;
        my $raw = 0;

        return sub ( $byte ) {
            $raw +<= 8;
            $raw += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                if $raw == 0 {
                    return 0 ;
                } else {
                    my $s = $raw +& 0x80000000 ?? -1 !! 1;
                    my $exp = ( $raw +> 23 ) +& 0xff;
                    $exp -= 127;
                    my $mantissa = $raw +& 0x7FFFFF;
                    $mantissa = 1 + ( $mantissa / 2**23 );
                    return $s * $mantissa * 2**$exp ;
                }
            }
        }
    }

    sub process-double() {
        my $remaining-bytes = 8;
        my $raw = 0;

        return sub ( $byte ) {
            $raw +<= 8;
            $raw += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                if $raw == 0 {
                    return 0 ;
                } else {
                    my $s = $raw +& 0x8000000000000000 ?? -1 !! 1;
                    my $exp = ( $raw +> 52 ) +& 0x7ff;
                    $exp -= 1023;
                    my $mantissa = $raw +& 0x0FFFFFFFFFFFFF;
                    $mantissa = 1 + ( $mantissa / 2**52 );
                    return $s * $mantissa * 2**$exp ;
                }
            }
        }
    }

    sub process-string( :$length-bytes = 0, :$length = 0 ) {
        if $length-bytes == 0 and $length == 0 {
            return "";
        }
        my $remaining-bytes = $length-bytes;
        my $str-length = $length;
        my $buf = Buf.new;
        return sub ($byte) {
            if $remaining-bytes {
                $str-length +<= 8; $str-length += $byte;
                $remaining-bytes--;
                return &?BLOCK;
            } else {
                $buf.push( $byte );
                if --$str-length {
                    return &?BLOCK;
                } else {
                    return $buf.decode ;
                }
            }
        };
    }

    sub process-bin( :$length-bytes ) {
        my $remaining-bytes = $length-bytes;
        my $bin-length = 0;
        my @bytes = ();
        return sub ($byte) {
            if $remaining-bytes {
                $bin-length +<= 8; $bin-length += $byte;
                $remaining-bytes--;
                return &?BLOCK;
            } else {
                @bytes.push( $byte );
                if --$bin-length {
                    return &?BLOCK;
                } else {
                    return Blob.new(@bytes) ;
                }
            }
        };
    }
}
