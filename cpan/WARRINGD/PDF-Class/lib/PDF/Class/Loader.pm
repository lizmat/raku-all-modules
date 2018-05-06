use v6;

use PDF::COS::Loader;

PDF::COS.loader = class PDF::Class::Loader
    is PDF::COS::Loader {

    use PDF::COS::Util :from-ast;
    use PDF::COS::Name;

    method class-paths {<PDF PDF::COS::Type>}

    method find-delegate( Str $type!, $subtype?, :$base-class) {

	my Str $subclass = $type;
	$subclass ~= '::' ~ $_
            with $subtype;

	return self.handler{$subclass}
	    if self.handler{$subclass}:exists;

        my $handler-class = $base-class;
        my Bool $resolved;

	for self.class-paths -> $class-path {
            my $class-name = $class-path ~ '::' ~ $subclass;
            $handler-class = PDF::COS.required($class-name);
            if $handler-class ~~ Failure {
                warn "failed to load: $class-name: {$handler-class.exception.message}";
            }
            else {
                $handler-class = $base-class.^mixin($handler-class)
                    unless $handler-class.isa($base-class);
                $resolved = True;
                last;
            }
            CATCH {
                when X::CompUnit::UnsatisfiedDependency {
		    # try loading just the parent class
		    $handler-class = $.find-delegate($type, :$base-class)
			if $subtype;
		}
            }
	}

	note "No PDF handler class [{self.class-paths}]::{$subclass}"
	    unless $resolved;

        self.install-delegate( $subclass, $handler-class );
    }

    multi method load-delegate(Hash :$dict! where {.<FunctionType>:exists}) {
	$.find-delegate('Function').delegate-function( :$dict );
    }

    multi method load-delegate(Hash :$dict! where {.<PatternType>:exists}) {
        my Int $pt = from-ast $dict<PatternType>;
        my $sub-type = [Mu, 'Tiling', 'Shading'][$pt];
        note "Unknown /PatternType $pt" without $sub-type;
	$.find-delegate('Pattern', $sub-type);
    }

    multi method load-delegate(Hash :$dict! where {.<ShadingType>:exists}) {
	$.find-delegate('Shading').delegate-shading( :$dict );
    }

    multi method load-delegate(Hash :$dict! where {(.<Registry>:exists) && (.<Ordering>:exists)}) {
	$.find-delegate('CIDSystemInfo');
    }

    multi method load-delegate( Hash :$dict! where {.<Type>:exists}, :$base-class) {
        my $type = from-ast($dict<Type>);
        my $subtype = from-ast($dict<Subtype> // $dict<S>);
        $type ~~
            'Border'|'Encoding' # classess with optional /type & unhandled subtype
            |'Ind'|'Ttl'|'Org'  # handled by PDF::OCG User attribute
            ?? $base-class
            !! $.find-delegate( $type, $subtype, :$base-class );
    }

    #| Reverse lookup for classes when /Subtype is required but optional /Type is absent
    multi method load-delegate(Hash :$dict! where {.<Subtype>:exists }, :$base-class) {
	my $subtype = from-ast $dict<Subtype>;

	my $type = do given $subtype {
	    # See [PDF 1.7 - TABLE 8.20 Annotation types]
	    when 'Text'|'Link'|'FreeText'|'Line'|'Square'|'Circle'
		|'Polygon'|'PolyLine'|'Highlight' |' Underline'|'Squiggly'
		|'StrikeOut'|'Stamp'|'Caret'|'Ink'|'Popup'|'FileAttachment'
		|'Sound'|'Movie'|'Widget'|'Screen'|'PrinterMark'|'TrapNet'
		|'Watermark'|'3D'    { 'Annot' }
	    when 'PS'|'Image'|'Form' { 'XObject' }
            when 'Type1C'|'CIDFontType0C'|'OpenType' {
                $subtype = Nil; # not currently subclassed
                'FontFile'
            }
	    default { Nil }
	};

	with $type {
	    $.find-delegate($_, $subtype);
	}
	else {
	    $base-class;
	}
    }

    #| Reverse lookup for classes when /S (subtype) is required, but optional /Type is absent
    multi method load-delegate(Hash :$dict! where {.<S>:exists }, :$base-class) {
	my $subtype = from-ast $dict<S>;

	my $type = do given $subtype {
            when 'Alpha'|'Luminosity' { 'Mask' }
            when 'GTS_PDFX' { 'OutputIntent' }
            default { Nil }
	};

	with $type {
	    $.find-delegate($_, $subtype);
	}
        else {
            $base-class;
        }
    }

    subset ColorSpace-Array of List where {
        my $elems = .elems;

        if 2 <= $elems <= 5
            && ((my $t = from-ast .[0]) ~~ PDF::COS::Name) {
            ;
            $elems == 2
                ?? $t ~~ 'CalGray'|'CalRGB'|'Lab'|'ICCBased'|'Pattern' #| PDF Spec 1.7 Section 4.5.4 CIE-Based Color Spaces
                !! $t ~~ 'Indexed'|'Separation'|'DeviceN'; #| PDF Spec 1.7 Section 4.5.5 Special Color Spaces
        }
        else {
            False
        }
    }

    multi method load-delegate(ColorSpace-Array :$array!) {
	my $color-type = from-ast $array[0];
	$.find-delegate('ColorSpace', $color-type);
    }

    multi method load-delegate(:$base-class!) is default {
	$base-class;
    }

}
