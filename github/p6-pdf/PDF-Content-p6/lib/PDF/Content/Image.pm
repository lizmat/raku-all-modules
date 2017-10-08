use v6;

class X::PDF::Image::WrongHeader is Exception {
    has Str $.type is required;
    has Str $.header is required;
    has $.path is required;
    method message {
        "{$!path} image doesn't have a {$!type} header: {$.header.perl}"
    }
}

class X::PDF::Image::UnknownType is Exception {
    has $.path is required;
    method message {
        die "unable to open image: $!path";
    }
}

class PDF::Content::Image {
    use PDF::DAO;
    use PDF::Content::XObject;
    use PDF::IO;

    method !image-type($_, :$path!) {
        when m:i/^ jpe?g $/    { 'JPEG' }
        when m:i/^ gif $/      { 'GIF' }
        when m:i/^ png $/      { 'PNG' }
        when m:i/^ pdf|json $/ { 'PDF' }
        default {
            die X::PDF::Image::UnknownType.new( :$path );
        }
    }

    multi method open(Str $data-uri where /^('data:' [<t=.ident> '/' <s=.ident>]? $<b64>=";base64"? $<start>=",") /) {
        my $path = ~ $0;
        my Str \mime-type = ( $0<t> // '(missing)').lc;
        my Str \mime-subtype = ( $0<s> // '').lc;
        my Bool \base64 = ? $0<b64>;
        my Numeric \start = $0<start>.to;

        die "expected mime-type 'image/*' or 'application/pdf', got '{mime-type}': $path"
            unless mime-type eq (mime-subtype eq 'pdf' ?? 'application' !! 'image');
        my $image-type = self!image-type(mime-subtype, :$path);
        my $data = substr($data-uri, start);
	if base64 {
	    use Base64::Native;
	    $data = base64-decode($data).decode("latin-1");
	}

        my $fh = PDF::IO.coerce($data, :$path);
        self!open($image-type, $fh, :$data-uri);
    }

    multi method open(Str $path! ) {
        self.open( $path.IO );
    }

    multi method open(IO::Path $io-path) {
        self.open( $io-path.open( :r, :enc<latin-1>) );
    }

    multi method open(IO::Handle $fh!) {
        my $path = $fh.path;
        my Str $type = self!image-type($path.extension, :$path);
        self!open($type, $fh);
    }

    method !open(Str $image-type, $fh, |c) {
        my Hash $image-dict = (require ::('PDF::Content::Image')::($image-type)).open($fh);
        $image-dict does PDF::Content::XObject[$image-dict<Subtype>]
            unless $image-dict ~~ PDF::Content::XObject;

        $image-dict.?set-source(:source($fh), :$image-type, |c);
        $image-dict;
    }

    method inline-to-xobject(Hash $inline-dict, Bool :$invert) {

        my constant %Abbreviations = %(
            # [PDF 1.7 TABLE 4.43 Entries in an inline image object]
            :BPC<BitsPerComponent>,
            :CS<ColorSpace>,
            :D<Decode>,
            :DP<DecodeParms>,
            :F<Filter>,
            :H<Height>,
            :IM<ImageMask>,
            :I<Interpolate>,
            :W<Width>,
            # [PDF 1.7 TABLE 4.44 Additional abbreviations in an inline image object]
            :G<DeviceGray>,
            :RGB<DeviceRGB>,
            :CMYK<DeviceCMYK>,
            # Notes:
            # 1. ambiguous 'Indexed' entry seems to be a typo in the spec
            # 2. filter abbreviations are handled in PDF::IO::Filter
            );
        my constant %Expansions = %( %Abbreviations.invert );

        my $alias = $invert ?? %Expansions !! %Abbreviations;

        my %xobject-dict = $inline-dict.pairs.map: {
            ($alias{.key} // .key) => .value
        }

        %xobject-dict;
    }

    method inline-content {

        # for serialization to content stream ops: BI dict ID data EI
        use PDF::Content::Ops :OpCode;
        use PDF::DAO::Util :ast-coerce;
        # serialize to content ops
        my %dict = ast-coerce(self).value.list;
        %dict<Type Subtype Length>:delete;
        %dict = self.inline-to-xobject( %dict, :invert );

        [ (BeginImage) => [ :%dict ],
          (ImageData)  => [ :$.encoded ],
          (EndImage)   => [],
        ]
    }
}
