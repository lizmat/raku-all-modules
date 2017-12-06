use v6;

# adapted from Perl 5's PDF::API2::Resource::XObject::Image::PNG
use PDF::Content::Image;

class PDF::Content::Image::PNG
    is PDF::Content::Image {

    use PDF::DAO;
    use PDF::DAO::Stream;
    use PDF::IO::Filter;
    use PDF::IO::Util :pack;
    use Native::Packing :Endian;

    enum PNG-CS is export(:PNG-CS) « :Gray(0) :RGB(2) :RGB-Palette(3) :Gray-Alpha(4) :RGB-Alpha(6) »;

    use NativeCall;
    need Compress::Zlib::Raw;

    class Header does Native::Packing[Network] {
        has uint32 $.width;
        has uint32 $.height;
        has uint8  $.bit-depth;
        has uint8  $.color-type is rw;
        has uint8  $.compression-type;
        has uint8  $.filter-type;
        has uint8  $.interlace-type;
    }
    class Quad does Native::Packing[Network] {
        has uint32 $.Numeric;
    }
    has Header $.hdr;
    has buf8 $.palette is rw;
    has buf8 $.trns is rw;
    has buf8 $.stream .= new;
    constant PNG-Header = [~] 0x89.chr, "PNG", 0xD.chr, 0xA.chr, 0x1A.chr, 0xA.chr;
    constant \NullPointer = nativecast(CArray,Pointer.new(0));

    method !crc($hdr, $buf) {
        my uint32 $crc = Compress::Zlib::Raw::crc32(0, NullPointer, 0);
        $crc = Compress::Zlib::Raw::crc32($crc, nativecast(CArray, $hdr), 4);
        $crc = Compress::Zlib::Raw::crc32($crc, nativecast(CArray, $buf), $buf.elems)
            if $buf.elems;
        $crc;
    }

    method read($fh = $.source) {

        my Str $header = $fh.read(8).decode('latin-1');

        die X::PDF::Image::WrongHeader.new( :type<PNG>, :$header, :path($fh.path) )
            unless $header eq PNG-Header;

        while !$fh.eof {
            my Quad $len .= read($fh);
            my buf8 $hdr = $fh.read(4);
            my buf8 $buf = $fh.read(+$len);
            my Quad $crc = Quad.read($fh);
            if +$len {
                my uint32 $crc-got = +$crc;
                my uint32 $crc-calc = self!crc($hdr,$buf);
                die "crc check failed: expected $crc-calc, got $crc-got"
                    unless $crc-calc == $crc-got;
            }

            given $hdr.decode('latin-1') {

                when 'IHDR' {
                    $!hdr = Header.unpack: $buf;
                    die "Unsupported Compression($!hdr.cm) Method" if $!hdr.compression-type;
                    die "Unsupported Filter($!hdr.fm) Method" if $!hdr.filter-type;
                    die "Unsupported Interlace($!hdr.im) Method" if $!hdr.interlace-type;
                }
                when 'PLTE' {
                    $!palette = $buf;
                }
                when 'IDAT' {
                    $!stream.append: $buf.list;
                }
                when 'tRNS' {
                    $!trns = $buf;
                }
                when 'IEND' {
                    last;
                }
            }
        }
        $fh.close;
        self;
    }

    method !add-chunk(buf8 $buf, Str $hdr, buf8:D $data) {
        my Quad $len .= new: :Numeric($data.bytes);
        $len.pack($buf);
        $buf.append: $hdr.encode.list;
        $buf.append: $data.list;
        my Quad $crc .= new: :Numeric(self!crc($hdr.encode, $data));
        $crc.pack($buf);
    }

    method Buf {
        my $buf = buf8.new: PNG-Header.encode: "latin-1";
        self!add-chunk($buf, 'IHDR', $!hdr.pack);
        self!add-chunk($buf, 'PLTE', $_) with $!palette;
        self!add-chunk($buf, 'tRNS', $_) with $!trns;
        self!add-chunk($buf, 'IDAT', $!stream);
        self!add-chunk($buf, 'IEND', buf8.new);
        $buf;
    }

    sub network-words(Buf $buf) {
        pack($buf, 16);
    }

    method to-dict(Bool :$alpha = True) {
        my %dict = :Type( :name<XObject> ), :Subtype( :name<Image> );
        %dict<Width>  = $!hdr.width;
        %dict<Height> = $!hdr.height;
        my $stream = $!stream;

        my %opts = :w($!hdr.width), :h($!hdr.height), :%dict, :$stream, :$alpha;
        %opts<trns> = $_ with $!trns;
        %opts<palette> = $_ with $!palette;
        png-to-stream(PNG-CS($!hdr.color-type), $!hdr.bit-depth, |%opts);
    }

    proto sub png-to-stream(uint $cs, uint $bpc, *%o --> PDF::DAO::Stream) {*}

    multi sub png-to-stream(PNG-CS::Gray,
                            $bpc where 1|2|4|8|16,
                            UInt :$w!,
                            UInt :$h!,
                            :%dict!,
                            Buf :$stream!,
                            Buf :$trns,
                            Bool :$alpha,
        ) {
        %dict<Filter> = :name<FlateDecode>;
        %dict<ColorSpace> = :name<DeviceGray>;
        %dict<BitsPerComponent> = $bpc;
        %dict<DecodeParms> = { :Predictor(15), :BitsPerComponent($bpc), :Colors(1), :Columns($w) };

        if $alpha && $trns && +$trns {
            my $vals = network-words($trns);
            %dict<Mask> = [ $vals.min, $vals.max ]
        }
        my $encoded = $stream.decode: 'latin-1';
        PDF::DAO.coerce: :stream{ :%dict, :$encoded };
    }
    
    multi sub png-to-stream(PNG-CS::RGB,
                            $bpc where 8|16,
                            UInt :$w!,
                            UInt :$h!,
                            :%dict!,
                            Buf :$stream!,
                            Buf :$trns,
                            Bool :$alpha,
        ) {
        %dict<Filter> = :name<FlateDecode>;
        %dict<ColorSpace> = :name<DeviceRGB>;
        %dict<BitsPerComponent> = $bpc;
        %dict<DecodeParms> = { :Predictor(15), :BitsPerComponent($bpc), :Colors(3), :Columns($w) };

        if $alpha && $trns && +$trns {
            my $vals = network-words($trns);
            %dict<Mask> = [ $vals.map: { (*.min, *.max) } ];
        }
        my $encoded = $stream.decode: 'latin-1';
        PDF::DAO.coerce: :stream{ :%dict, :$encoded };
    }
    
    multi sub png-to-stream(PNG-CS::RGB-Palette,
                            $bpc where 1|2|4|8,
                            UInt :$w!,
                            UInt :$h!,
                            :%dict!,
                            Buf :$stream!,
                            Buf :$trns,
                            Buf :$palette!,
                            Bool :$alpha,
        ) {
        %dict<Filter> = :name<FlateDecode>;
        %dict<BitsPerComponent> = $bpc;
        %dict<DecodeParms> = { :Predictor(15), :BitsPerComponent($bpc), :Colors(1), :Columns($w) };

        my $encoded = $palette.decode('latin-1');
        my $color-stream = PDF::DAO.coerce: :stream{ :$encoded };
        my $hival = +$palette div 3  -  1;
        %dict<ColorSpace> = [ :name<Indexed>, :name<DeviceRGB>, $hival, $color-stream, ];

        if defined $trns && $alpha {
            my $decoded = $trns;
            my uint $padding = $w * $h  -  +$decoded;
            $decoded.append( 0xFF xx $padding)
                if $padding;
		
            %dict<SMask> = PDF::DAO.coerce: :stream{
                :dict{:Type( :name<XObject> ),
		      :Subtype( :name<Image> ),
		      :Width($w),
		      :Height($h),
		      :ColorSpace( :name<DeviceGray> ),
		      :Filter( :name<FlateDecode> ),
		      :BitsPerComponent(8),
		},
		:$decoded,
	    };
	}
	$encoded = $stream.decode: 'latin-1';
	PDF::DAO.coerce: :stream{ :%dict, :$encoded };
    }
    
    multi sub png-to-stream(PNG-CS::Gray-Alpha,
			    $bpc where 8|16,
			    UInt :$w!,
			    UInt :$h!,
			    :%dict!,
			    :$stream! is copy,
			    Bool :$alpha,
	) {

	%dict<Filter> = PDF::DAO.coerce: :name<FlateDecode>;
	%dict<ColorSpace> = :name<DeviceGray>;
	%dict<DecodeParms> = { :Predictor(15), :Colors(2), :Columns($w), :BitsPerComponent($bpc) };
	%dict<BitsPerComponent> = $bpc;

	$stream = PDF::IO::Filter.decode( $stream, :%dict );

	# Extract alpha (transparency channel)
	%dict<DecodeParms><Colors>--;

	my uint $n = $bpc div 8;
	my uint $i = 0;

	my buf8 $gray-channel  .= new;
	my buf8 $alpha-channel .= new;
	while $i < +$stream {
	    $gray-channel.push( $stream[$i++] )  xx $n;
	    $alpha-channel.push( $stream[$i++] ) xx $n;
	}

	if $alpha {
	    my $decoded = $alpha-channel.decode: 'latin-1';
	    %dict<SMask> = PDF::DAO.coerce: :stream{
		:dict{:Type( :name<XObject> ),
		      :Subtype( :name<Image> ),
		      :Width($w),
		      :Height($h),
		      :ColorSpace( :name<DeviceGray> ),
		      :Filter( :name<FlateDecode> ),
		      :BitsPerComponent( $bpc ),
		},
		:$decoded,
	    };
	}

	my $decoded = $gray-channel.decode: 'latin-1';
	PDF::DAO.coerce: :stream{ :%dict, :$decoded };
    }
    
    multi sub png-to-stream(PNG-CS::RGB-Alpha,
			    $bpc where 8|16,
			    UInt :$w!,
			    UInt :$h!,
			    :%dict!,
			    :$stream! is copy,
			    Buf :$trns,
			    Bool :$alpha,
	) {
	%dict<Filter> = PDF::DAO.coerce: :name<FlateDecode>;
	%dict<ColorSpace> = :name<DeviceRGB>;
	%dict<BitsPerComponent> = $bpc;
	%dict<DecodeParms> = { :Predictor(15), :BitsPerComponent($bpc), :Colors(4), :Columns($w) };
	$stream = PDF::IO::Filter.decode( $stream, :%dict );
	# Strip alpha (transparency channel)
	%dict<DecodeParms><Colors>--;

	my uint $n = $bpc div 8;
	my uint $i = 0;
        my uint $stream-len = +$stream;

	my buf8 $rgb-channels  .= new;
	my buf8 $alpha-channel .= new;
	while $i < $stream-len {
	    $rgb-channels.push( $stream[$i++] ) xx ($n*3);
	    $alpha-channel.push( $stream[$i++] ) xx $n;
	}

	if $alpha {
	    my $decoded = $alpha-channel.decode: 'latin-1';
	    %dict<SMask> = PDF::DAO.coerce: :stream{
		:dict{:Type( :name<XObject> ),
		      :Subtype( :name<Image> ),
		      :Width($w),
		      :Height($h),
		      :ColorSpace( :name<DeviceGray> ),
		      :Filter( :name<FlateDecode> ),
		      :BitsPerComponent( $bpc ),
		},
		:$decoded
	    };
	}

	my $decoded = $rgb-channels.decode: 'latin-1';
	PDF::DAO.coerce: :stream{ :%dict, :$decoded };
    }

}

=begin rfc

RFC 2083
PNG: Portable Network Graphics
January 1997


4.1.3. IDAT Image data

    The IDAT chunk contains the actual image data.  To create this
    data:

     * Begin with image scanlines represented as described in
       Image layout (Section 2.3); the layout and total size of
       this raw data are determined by the fields of IHDR.
     * Filter the image data according to the filtering method
       specified by the IHDR chunk.  (Note that with filter
       method 0, the only one currently defined, this implies
       prepending a filter type byte to each scanline.)
     * Compress the filtered data using the compression method
       specified by the IHDR chunk.

    The IDAT chunk contains the output datastream of the compression
    algorithm.

    To read the image data, reverse this process.

    There can be multiple IDAT chunks; if so, they must appear
    consecutively with no other intervening chunks.  The compressed
    datastream is then the concatenation of the contents of all the
    IDAT chunks.  The encoder can divide the compressed datastream
    into IDAT chunks however it wishes.  (Multiple IDAT chunks are
    allowed so that encoders can work in a fixed amount of memory;
    typically the chunk size will correspond to the encoder's buffer
    size.) It is important to emphasize that IDAT chunk boundaries
    have no semantic significance and can occur at any point in the
    compressed datastream.  A PNG file in which each IDAT chunk
    contains only one data byte is legal, though remarkably wasteful
    of space.  (For that matter, zero-length IDAT chunks are legal,
    though even more wasteful.)


4.2.9. tRNS Transparency

    The tRNS chunk specifies that the image uses simple
    transparency: either alpha values associated with palette
    entries (for indexed-color images) or a single transparent
    color (for grayscale and truecolor images).  Although simple
    transparency is not as elegant as the full alpha channel, it
    requires less storage space and is sufficient for many common
    cases.

    For color type 3 (indexed color), the tRNS chunk contains a
    series of one-byte alpha values, corresponding to entries in
    the PLTE chunk:

        Alpha for palette index 0:  1 byte
        Alpha for palette index 1:  1 byte
        ... etc ...

    Each entry indicates that pixels of the corresponding palette
    index must be treated as having the specified alpha value.
    Alpha values have the same interpretation as in an 8-bit full
    alpha channel: 0 is fully transparent, 255 is fully opaque,
    regardless of image bit depth. The tRNS chunk must not contain
    more alpha values than there are palette entries, but tRNS can
    contain fewer values than there are palette entries.  In this
    case, the alpha value for all remaining palette entries is
    assumed to be 255.  In the common case in which only palette
    index 0 need be made transparent, only a one-byte tRNS chunk is
    needed.

    For color type 0 (grayscale), the tRNS chunk contains a single
    gray level value, stored in the format:

        Gray:  2 bytes, range 0 .. (2^bitdepth)-1

    (For consistency, 2 bytes are used regardless of the image bit
    depth.) Pixels of the specified gray level are to be treated as
    transparent (equivalent to alpha value 0); all other pixels are
    to be treated as fully opaque (alpha value (2^bitdepth)-1).

    For color type 2 (truecolor), the tRNS chunk contains a single
    RGB color value, stored in the format:

        Red:   2 bytes, range 0 .. (2^bitdepth)-1
        Green: 2 bytes, range 0 .. (2^bitdepth)-1
        Blue:  2 bytes, range 0 .. (2^bitdepth)-1

    (For consistency, 2 bytes per sample are used regardless of the
    image bit depth.) Pixels of the specified color value are to be
    treated as transparent (equivalent to alpha value 0); all other
    pixels are to be treated as fully opaque (alpha value
    2^bitdepth)-1).

    tRNS is prohibited for color types 4 and 6, since a full alpha
    channel is already present in those cases.

    Note: when dealing with 16-bit grayscale or truecolor data, it
    is important to compare both bytes of the sample values to
    determine whether a pixel is transparent.  Although decoders
    may drop the low-order byte of the samples for display, this
    must not occur until after the data has been tested for
    transparency.  For example, if the grayscale level 0x0001 is
    specified to be transparent, it would be incorrect to compare
    only the high-order byte and decide that 0x0002 is also
    transparent.

    When present, the tRNS chunk must precede the first IDAT chunk,
    and must follow the PLTE chunk, if any.

=end rfc
