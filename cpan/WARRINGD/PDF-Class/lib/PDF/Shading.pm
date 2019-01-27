use v6;

use PDF::COS::Tie::Hash;

#| /ShadingType 1..7 - the Shading dictionary delegates

role PDF::Shading
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;
    use PDF::COS::Array;
    use PDF::COS::Name;
    use PDF::COS::Dict;
    use PDF::ColorSpace;

    my subset ShadingTypeInt of Int where 1..7;
    has ShadingTypeInt $.ShadingType is entry(:required);

    # see [PDF 32000 Table 78 - Entries Common to All Shading Dictionaries]
    ## use ISO_32000::Shading_common;
    ## also does ISO_32000::Shading_common;

    my subset NameOrColorSpace of PDF::COS where PDF::COS::Name | PDF::ColorSpace;
    has NameOrColorSpace $.ColorSpace is entry(:required); # (Required) The color space in which color values are expressed.
    has @.Background is entry;                        # (Optional) An array of color components appropriate to the color space, specifying a single background color value.
    has Numeric @.BBox is entry(:len(4));             # (Optional) An array of four numbers giving the left, bottom, right, and top coordinates, respectively, of the shading’s bounding box
    has Bool $.AntiAlias is entry;                    # (Optional) A flag indicating whether to filter the shading function to prevent aliasing artifacts.

    # from PDF Spec 1.7 table 4.28
    my constant ShadingTypes = <Function Axial Radial FreeForm Lattice Coons Tensor>;
    my constant ShadingNames = %( ShadingTypes.pairs.invert );
    method type {'Shading'}
    method subtype { ShadingTypes[ $.ShadingType - 1] }

    #| see also PDF::Class::Loader
    method delegate-shading(Hash :$dict!, |c) {

	use PDF::COS::Util :from-ast;
	my UInt $type-int = from-ast $dict<ShadingType>;

	unless $type-int ~~ ShadingTypeInt {
	    note "unknown /ShadingType $dict<ShadingType> - supported range is 1..7";
	    return self.WHAT;
	}

	my $subtype = ShadingTypes[$type-int - 1];
	PDF::COS.loader.find-delegate( 'Shading', $subtype, :base-class(PDF::COS::Dict));
    }

    method cb-init {
        for self.^mro {
            my Str $class-name = .^name;

            if $class-name ~~ /^ 'PDF::' (\w+) ['::' (\w+)]? $/ {
		my Str $type = ~$0;
		my Str $shading-type = ~$1
		    if $1;

		die "invalid shading class: $class-name"
		    unless $type eq $.type
		    && $shading-type
		    && (ShadingNames{ $shading-type }:exists);

		my ShadingTypeInt $shading-type-int = ShadingNames{ $shading-type } + 1;

		self<ShadingType> //= $shading-type-int;

		die "conflict between class-name $class-name /ShadingType. Expected $shading-type-int, got  self<ShadingType>"
		    unless self<ShadingType> == $shading-type-int;

                last;
            }
        }

    }
}
