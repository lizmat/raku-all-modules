use v6;
use PDF::Content::Image;

# adapted from Perl 5's PDF::API::Resource::XObject::Image::JPEG

class PDF::Content::Image::JPEG
    is PDF::Content::Image {
    use Native::Packing :Endian;
    class Atts does Native::Packing[Network] {
        has uint8 $.bit-depth;
        has uint16 ($.height, $.width);
        has uint8 $.color-channels
    }
    class BlockHeader does Native::Packing[Network] {
        has uint8 ($.ff, $.mark);
        has uint16 $.len
    }
    # work-around for Rakudo RT #131122 - sign handling
    has Atts $!atts;
    has Bool $!is-dct;
    has Str $!encoded;

    # work-around for Rakudo RT #131122 - sign handling
    sub u8(uint8 $v) { $v }

    method read($fh = $.source) {
        $fh.seek(0, SeekFromBeginning);
        my Str $header = $fh.read(2).decode: 'latin-1';
        die X::PDF::Image::WrongHeader.new( :type<JPEG>, :$header, :path($fh.path) )
            unless $header ~~ "\xFF\xD8";

        loop {
            my BlockHeader $hdr .= read: $fh;
            last if u8($hdr.ff) != 0xFF;
            last if u8($hdr.mark) == 0xDA | 0xD9;  # SOS/EOI
            last if $hdr.len < 2;
            last if $fh.eof;

            my $buf = $fh.read: $hdr.len - 2;
            with $hdr.mark -> uint8 $mark {
                if 0xC0 <= $mark <= 0xCF
                && $mark != 0xC4 | 0xC8 | 0xCC {
                    $!is-dct = ?( $mark == 0xC0 | 0xC2);
                    $!atts .= unpack($buf);
                    last;
                }
            }
        }

        $fh.seek(0, SeekFromBeginning);
        $!encoded = $fh.slurp-rest;
        $fh.close;
        self;
    }

    method to-dict {
        my %dict = :Type( :name<XObject> ), :Subtype( :name<Image> );
        with $!atts {
            my Str \color-space = do given .color-channels {
                when 1 {'DeviceGray'}
                when 3 {'DeviceRGB'}
                when 4 {'DeviceCMYK'}
                default {warn "JPEG has unknown color-space: $_";
                         'DeviceGray'}
            }

            %dict<ColorSpace> = :name(color-space);
            %dict<Width> = .width;
            %dict<Height> = .height;
            %dict<BitsPerComponent> = .bit-depth;
        }
        else {
            die "unable to read JPEG attributes";
        }
        %dict<Filter> = :name<DCTDecode>
            if $!is-dct;

        need PDF::DAO;
        PDF::DAO.coerce: :stream{ :%dict, :$!encoded };
    }

    method open(PDF::Content::Image::IOish $fh) {
        self.load-image: :$fh, :image-type<JPEG>, :class(self);
    }
}

