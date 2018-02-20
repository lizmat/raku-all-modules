use v6;

role PDF::Content::XObject['Form'] {
    has Numeric $.width;
    has Numeric $.height;
    method width  { with $!width  { $_ } else { self!size()[0] } }
    method height { with $!height { $_ } else { self!size()[1] } }
    method !size {
        my $bbox = self<BBox>;
        $!width  = $bbox[2] - $bbox[0];
        $!height = $bbox[3] - $bbox[1];
        ($!width, $!height);
    }
}

role PDF::Content::XObject['Image'] {
    has Numeric $.width;
    has Numeric $.height;
    method width  { $!width //= self<Width> }
    method height { $!height //= self<Height> }
    has $.image-obj is rw handles <data-uri source image-type>;
    method Str { with $!image-obj  {.data-uri} else {nextsame} }

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
        if $invert {
            %xobject-dict<Type Subtype Length>:delete;
        }
        else {
            %xobject-dict<Type> = :name<XObject>;
            %xobject-dict<Subtype> = :name<Image>;
        }

        %xobject-dict;
    }

    method inline-content {

        # for serialization to content stream ops: BI dict ID data EI
        use PDF::Content::Ops :OpCode;
        use PDF::DAO::Util :ast-coerce;
        # serialize to content ops
        my %dict = ast-coerce(self).value.list;
        %dict = self.inline-to-xobject( %dict, :invert );

        [ (BeginImage) => [ :%dict ],
          (ImageData)  => [ :$.encoded ],
          (EndImage)   => [],
        ]
    }
}

role PDF::Content::XObject['PS'] {
    # stub
}
