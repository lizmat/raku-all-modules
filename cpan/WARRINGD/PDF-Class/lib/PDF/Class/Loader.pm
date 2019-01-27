use v6;

use PDF::COS::Loader;

PDF::COS.loader = class PDF::Class::Loader
    is PDF::COS::Loader {

    use PDF::COS::Util :from-ast;
    use PDF::COS::Name;
    use PDF::COS::Dict;

    method class-paths {<PDF PDF::COS::Type>}
    method warn {True}

    multi method load-delegate(Hash :$dict! where {.<FunctionType>:exists}) {
	$.find-delegate('Function', :base-class(PDF::COS::Dict)).delegate-function( :$dict );
    }

    multi method load-delegate(Hash :$dict! where {.<PatternType>:exists}) {
        my UInt $pt = from-ast $dict<PatternType>;
        my $sub-type = [Mu, 'Tiling', 'Shading'][$pt];
        note "Unknown /PatternType $pt" without $sub-type;
	$.find-delegate('Pattern', :base-class(PDF::COS::Dict), $sub-type);
    }

    multi method load-delegate(Hash :$dict! where {.<ShadingType>:exists}) {
	$.find-delegate('Shading', :base-class(PDF::COS::Dict)).delegate-shading( :$dict );
   }

    multi method load-delegate( Hash :$dict! where {.<Type>:exists}, :$base-class!) {
        my $type = from-ast($dict<Type>);
        my $subtype = from-ast($_)
            with $dict<Subtype> // $dict<S>;
        with $subtype {
            when '3D'   { $_ = 'ThreeD' }
            when .chars <= 2
            || $type ~~ 'OutputIntent'|'StructElem' # no specific subclasses
                        { $_ = Nil }
        }
        $type ~~
            'Ind'|'Ttl'|'Org'  # handled by PDF::OCG
            |'Sig'             # handled by PDF::Signature
            |'PageLabel'       # handled by PDF::Catalog
            |'EmbeddedFile'    # handled by PDF::Filespec
            ?? $base-class
            !! $.find-delegate( $type, $subtype, :$base-class );
    }

    #| Reverse lookup for classes when /Subtype is required but optional /Type is absent
    multi method load-delegate(Hash :$dict! where {.<Subtype>:exists }, :$base-class!) {
	my $subtype = from-ast $dict<Subtype>;

	my $type = do given $subtype {
	    # See [PDF 32000 Table 169 - Annotation types]
	    when 'Text'|'Link'|'FreeText'|'Line'|'Square'|'Circle'
		|'Polygon'|'PolyLine'|'Highlight'|'Underline'|'Squiggly'
		|'StrikeOut'|'Stamp'|'Caret'|'Ink'|'Popup'|'FileAttachment'
		|'Sound'|'Movie'|'Widget'|'Screen'|'PrinterMark'|'TrapNet'
		|'Watermark'    { 'Annot' }
            when 'Markup3D' { 'ExData' }
            when '3D' { $subtype = 'ThreeD'; 'Annot' }
	    when 'PS'|'Image'|'Form' { 'XObject' }
            when 'Type1C'|'CIDFontType0C'|'OpenType' {
                $subtype = Nil; # not currently subclassed
                'FontFile'
            }
	    default { Nil }
	};

	with $type {
	    $.find-delegate($_, $subtype, :$base-class);
	}
	else {
	    $base-class;
	}
    }

    #| Reverse lookup for classes when /S (subtype) is required, but /Type is optional
    multi method load-delegate(Hash :$dict! where {.<S>:exists }, :$base-class!) {
	my $subtype = from-ast $dict<S>;

	my $type = do given $subtype {
            when 'Alpha'|'Luminosity' { 'Mask' }
            when 'GTS_PDFX'|'GTS_PDFA1'|'ISO_PDFE1' {
                    $subtype = Nil; # not subclassed
                    'OutputIntent';
                 }
            when 'GoTo'|'GoToR'|'GoToE'|'Launch'|'Thread'|'URI'|'Sound'|'Movie'
                |'Hide'|'Named'|'SubmitForm'|'ResetForm'|'ImportData'|'JavaScript'
                |'SetOCGState'|'Rendition'|'Trans'|'GoTo3DView' { 'Action' }
            default { Nil }
	};

	with $type {
	    $.find-delegate($_, $subtype, :$base-class);
	}
        else {
            $base-class;
        }
    }

    subset ColorSpace-Array of List where {
        my $elems := .elems;

        2 <= $elems <= 5
            && ((my $t = from-ast .[0]) ~~ PDF::COS::Name)
            && ($elems == 2
                ?? $t ~~ 'CalGray'|'CalRGB'|'Lab'|'ICCBased'|'Pattern' #| PDF Spec 1.7 Section 4.5.4 CIE-Based Color Spaces
                !! $t ~~ 'Indexed'|'Separation'|'DeviceN'); #| PDF Spec 1.7 Section 4.5.5 Special Color Spaces
    }

    multi method load-delegate(ColorSpace-Array :$array!, :$base-class!) {
	my $color-type = from-ast $array[0];
	$.find-delegate('ColorSpace', $color-type, :$base-class);
    }

    multi method load-delegate(:$base-class!) is default {
	$base-class;
    }

}
