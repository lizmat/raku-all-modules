use v6;

class MessagePack::Unpacker {
    has $!str;

    my %unpack-for-type = (
        0xc0 => { Any   },
        0xc2 => { False },
        0xc3 => { True  },
        0xc4 => { $_!unpack-raw(  bytes => $_!unpack-uint8) },
        0xc5 => { $_!unpack-raw(  bytes => $_!unpack-uint16) },
        0xc6 => { $_!unpack-raw(  bytes => $_!unpack-uint32) },
        0xca => { $_!unpack-float  },
        0xcb => { $_!unpack-double },
        0xcc => { $_!unpack-uint8  },
        0xcd => { $_!unpack-uint16 },
        0xce => { $_!unpack-uint32 },
        0xcf => { $_!unpack-uint64 },
        0xd0 => { $_!unpack-int8   },
        0xd1 => { $_!unpack-int16  },
        0xd2 => { $_!unpack-int32  },
        0xd3 => { $_!unpack-int64  },
        0xd9 => { $_!unpack-str(  bytes => $_!unpack-uint8) },
        0xda => { $_!unpack-str(  bytes => $_!unpack-uint16) },
        0xdb => { $_!unpack-str(  bytes => $_!unpack-uint32) },
        0xdc => { $_!unpack-array(elems => $_!unpack-uint16) },
        0xdd => { $_!unpack-array(elems => $_!unpack-uint32) },
        0xde => { $_!unpack-map(  pairs => $_!unpack-uint16) },
        0xdf => { $_!unpack-map(  pairs => $_!unpack-uint32) },
    );

    method new(Blob $str) {
        self.bless(str => Buf.new($str));
    }

    submethod BUILD(:$!str) { };

    # Class method
    method unpack($str) {
        my $unpacker = self.new($str);
        $unpacker!unpack;
    }

    method !unpack() {
        my $type = self!unpack-uint8;

        return (given $type {
            when ($type +& 0b1000_0000) == 0b0000_0000 {
                # positive fixnum
                $type;
            }
            when ($type +& 0b1110_0000) == 0b1110_0000 {
                # negative fixnum
                ($type +& 0b0001_1111) - 32;
            }
            when ($type +& 0b1110_0000) == 0b1010_0000 {
                # fixraw
                self!unpack-str(bytes => $type +& 0b1_1111);
            }
            when ($type +& 0b1111_0000) == 0b1001_0000 {
                # fixarray
                self!unpack-array(elems => $type +& 0b1111);
            }
            when ($type +& 0b1111_0000) == 0b1000_0000 {
                # fixmap
                self!unpack-map(pairs => $type +& 0b1111);
            }
            when %unpack-for-type{$type} :exists {
                %unpack-for-type{$type}(self);
            }
            default {
                fail sprintf("Unknown type 0x%02x", $type);
            }
        });
    }

    method !unpack-uint8() {
        my $v = $!str.unpack('C');
        $!str .= subbuf(1);
        return $v;
    }
    
    method !unpack-uint16() {
        my $v = $!str.unpack('n');
        $!str .= subbuf(2);
        return $v;
    }

    method !unpack-uint32() {
        my $v = $!str.unpack('N');
        $!str .= subbuf(4);
        return $v;
    }

    method !unpack-uint64() {
        # XXX Need uint64 unpack code
        my @bytes = $!str.subbuf(0, 8).list;
        $!str .= subbuf(8);
        (@bytes[0] +< 56) +|
        (@bytes[1] +< 48) +|
        (@bytes[2] +< 40) +|
        (@bytes[3] +< 32) +|
        (@bytes[4] +< 24) +|
        (@bytes[5] +< 16) +|
        (@bytes[6] +<  8) +|
        (@bytes[7]      );
    }

    method !unpack-int8() {
        my $uint8 = self!unpack-uint8;
        ($uint8 < (1 +< 7)) ?? $uint8 !! $uint8 - (1 +< 8);
    }

    method !unpack-int16() {
        my $uint16 = self!unpack-uint16;
        ($uint16 < (1 +< 15)) ?? $uint16 !! $uint16 - (1 +< 16);
    }

    method !unpack-int32() {
        my $uint32 = self!unpack-uint32;
        ($uint32 < (1 +< 31)) ?? $uint32 !! $uint32 - (1 +< 32);
    }

    method !unpack-int64() {
        my $uint64 = self!unpack-uint64;
        ($uint64 < (1 +< 63)) ?? $uint64 !! $uint64 - (1 +< 64);
    }

    method !unpack-float() {
        my $v = self!unpack-uint32;
        return 0.0 if $v == 0;

        my $sign = $v +> 31 ?? -1 !! 1;
        my $exp  = (($v +> 23) +& 0xff) - 127;
        my $frac = ($v +& 0x7f_ffff) +| 0x80_0000;
        $sign * ($frac * 2 ** ($exp - 23));
    }

    method !unpack-double() {
        my $hi = self!unpack-uint32;
        my $lo = self!unpack-uint32;
        return 0.0 if $hi == $lo == 0;

        my $sign  = $hi +> 31 ?? -1 !! 1;
        my $exp   = (($hi +> 20) +& 0x7ff) - 1023;
        my $hfrac = ($hi +& 0xf_ffff) +| 0x10_0000;
        $sign * (($hfrac * 2 ** ($exp - 20)) + 132 * ($lo * 2 ** ($exp - 52)));
    }

    method !unpack-str(:$bytes) {
        return self!unpack-raw(:$bytes).decode('UTF-8');
    }

    method !unpack-raw(:$bytes) {
        my $v = $!str.subbuf(0, $bytes);
        $!str .= subbuf($bytes);
        return $v;
    }

    method !unpack-array(:$elems) {
        list(gather for ^$elems { take self!unpack });
    }

    method !unpack-map(:$pairs) {
        hash(gather for ^$pairs { take self!unpack => self!unpack });
    }
}

# vim: ft=perl6
