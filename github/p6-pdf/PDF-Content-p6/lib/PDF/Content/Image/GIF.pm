use v6;
use PDF::Content::Image;

# adapted from Perl 5's PDF::API::Resource::XObject::Image::GIF

class PDF::Content::Image::GIF
    is PDF::Content::Image {

    use Native::Packing :Endian;

    class LogicalDescriptor does Native::Packing[Vax] {
        has uint16 $.width;
        has uint16 $.height;
        has uint8 $.flags;
        has uint8 $.bgColorIndex;
        has uint8 $.aspect;
    }
    has LogicalDescriptor $!descr;

    class ImageDescriptor does Native::Packing[Vax] {
        has uint16 $.left;
        has uint16 $.top;
        has uint16 $.width;
        has uint16 $.height;
        has uint8 $.flags;
    }
    has ImageDescriptor $!img;

    class GCDescriptor does Native::Packing[Vax] {
        has uint8 $.cFlags;
        has uint16 $.delay;
        has uint8 $.transIndex
    }
    has GCDescriptor $!gc;
    has buf8 $!color-table;
    has buf8 $!data;

    method !read-colorspace($fh, UInt $flags) {
        my $cols = 2 ** (($flags +& 0x7) + 1);
        $!color-table = $fh.read( 3 * $cols);
    }

    sub vec(buf8 \buf, UInt \off) {
        (buf[ off div 8] +> (off mod 8)) mod 2
    }

    method !decompress(UInt \ibits, buf8 \stream --> Buf) {
        my UInt \reset-code = 1 +< (ibits - 1);
        my UInt \end-code   = reset-code + 1;
        my UInt \maxptr = 8 * +stream;
        my int $next-code  = end-code + 1;
        my int $bits = ibits;
        my int $ptr = 0;
        my uint8 @out;
        my int $outptr = 0;

        my @d = (0 ..^ reset-code).map: {[$_, ]};

        while ($ptr + $bits) <= maxptr {
            my UInt \tag = [+] (0 ..^ $bits).map: { vec(stream, $ptr + $_) +< $_ };
            $ptr += $bits;
            $bits++
                if $next-code == 1 +< $bits and $bits < 12;

            if tag == reset-code {
                $bits = ibits;
                $next-code = end-code + 1;
            } elsif tag == end-code {
                last;
            } else {
                @d[$next-code] = [ @d[tag].list ];
                @d[$next-code].push: @d[tag + 1][0]
                    if tag > end-code;
                @out.append: @d[$next-code++].list;
            }
        }

        buf8.new(@out);
    }

    method !deinterlace returns buf8 {
        my uint $row;
        my buf8 $result = buf8.allocate($!data.bytes);
        my uint $idx = 0;
        my uint $width = self.width;
        my uint $height = self.height;

        for [ 0 => 8, 4 => 8, 2 => 4, 1 => 2] {
            my $row = .key;
            my \incr = .value;
            while $row < $height {
                $result.subbuf-rw($row*$width, $width) = $!data.subbuf( $idx*$width, $width);
                $row += incr;
                $idx++;
            }
        }

        $result;
    }

    method width { ($!img // $!descr).width; }
    method height { ($!img // $!descr).height; }

    method read($fh = $.source) {
        my Str $encoded = '';

        my $header = $fh.read(6).decode: 'latin-1';
        die X::PDF::Image::WrongHeader.new( :type<GIF>, :$header, :path($fh.path) )
            unless $header ~~ /^GIF <[0..9]>**2 [a|b]/;

        $!descr .= read: $fh;

        with $!descr.flags -> uint8 $flags {
            self!read-colorspace($fh, $flags)
                if $flags +& 0x80;
        }

        while !$fh.eof {
            my uint8 $sep = $fh.read(1)[0]; # tag.

            given $sep {
                when 0x2C {
                    my Bool $interlaced = False;
                    $!img .= read: $fh;

                    with $!img.flags -> uint8 $flags {
                        self!read-colorspace($fh, $flags)
                            if $flags +& 0x80; # local colormap

                        $interlaced = True  # need de-interlace
                            if $flags &+ 0x40;
                    }

                    my uint8 ($sep, $len) = $fh.read(2).list; # image-lzw-start (should be 9) + length.
                    my $stream = buf8.new;

                    while $len {
                        $stream.append: $fh.read($len).list;
                        $len = $fh.read(1)[0];
                    }

                    $!data = self!decompress($sep+1, $stream);
                    $!data = self!deinterlace if $interlaced;
                    last;
                }

                when 0x3b {
                    last;
                }

                when 0x21 {
                    # Graphic Control Extension
                    my uint8 ($tag, $len) = $fh.read(2).list;
                    die "unsupported graphic control extension ($tag)"
                        unless $tag == 0xF9;

                    my $stream = Buf.new;

                    while $len {
                        $stream.append: $fh.read($len).list;
                        $len = $fh.read(1)[0];
                    }

                    $!gc .= unpack($stream);
                }

                default {
                    # misc extension
                    my uint8 ($tag, $len) = $fh.read(2).list;

                    # skip ahead
                    while $len {
                        $fh.seek($len, SeekFromCurrent);
                        $len = $fh.read(1)[0];
                    }
                }
            }
        }
        $fh.close;
        self;
    }

    method to-dict(Bool :$trans = True) {
        need PDF::COS;
        my %dict = ( :Type( :name<XObject> ),
                     :Subtype( :name<Image> ),
                     :Width( self.width),
                     :Height( self.height),
                     :BitsPerComponent(8),
            );
        with $!color-table {
            my $cols = .elems div 3;
            my $encoded = $!color-table.decode("latin-1");
            my $color-data = $cols > 64
                ?? PDF::COS.coerce( :stream{ :$encoded } )
                !! :hex-string($encoded);

            %dict<ColorSpace> = [ :name<Indexed>, :name<DeviceRGB>,
                                  :int($cols - 1), $color-data ];
        }

        if $trans & $!gc.defined {
            with $!gc.cFlags -> uint8 $cFlags {
                my uint8 $transIndex = $!gc.transIndex;
                %dict<Mask> = [$transIndex, $transIndex]
                    if $cFlags +& 0x01;
            }
        }

        my Str $encoded = $!data.decode: 'latin-1';
        PDF::COS.coerce: :stream{ :%dict, :$encoded };
    }

    method open(PDF::Content::Image::IOish $fh) {
        self.load-image: :$fh, :image-type<GIF>, :class(self);
    }

}
