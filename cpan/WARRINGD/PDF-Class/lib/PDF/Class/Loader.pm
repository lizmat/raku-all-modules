use v6;

use PDF::DAO::Loader;

PDF::DAO.loader = class PDF::Class::Loader
    is PDF::DAO::Loader {

    use PDF::DAO::Util :from-ast;
    use PDF::DAO::Name;

    method class-paths {<PDF PDF::DAO::Type>}

    method find-delegate( Str $type!, $subtype?, :$fallback) is default {

	my Str $subclass = $type;
	$subclass ~= '::' ~ $subtype if $subtype;

	return self.handler{$subclass}
	    if self.handler{$subclass}:exists;

        my $handler-class = $fallback;
        my Bool $resolved;

	for self.class-paths -> $class-path {
            my $class-name = $class-path ~ '::' ~ $subclass;
            $handler-class = PDF::DAO.required($class-name);
            if $handler-class ~~ Failure {
                warn "failed to load: $class-name: {$handler-class.exception.message}";
            }
            else {
                $resolved = True;
                last;
            }
            CATCH {
                when X::CompUnit::UnsatisfiedDependency {
		    # try loading just the parent class
		    $handler-class = $.find-delegate($type, :$fallback)
			if $subtype;
		}
            }
	}

	note "No Doc handler class [{self.class-paths}]::{$subclass}"
	    unless $resolved;

        self.install-delegate( $subclass, $handler-class );
    }

    multi method load-delegate(Hash :$dict! where {.<FunctionType>:exists}) {
	$.find-delegate('Function').delegate-function( :$dict );
    }

    multi method load-delegate(Hash :$dict! where {.<PatternType>:exists}) {
	$.find-delegate('Pattern').delegate-pattern( :$dict );
    }

    multi method load-delegate(Hash :$dict! where {.<ShadingType>:exists}) {
	$.find-delegate('Shading').delegate-shading( :$dict );
    }

    multi method load-delegate(Hash :$dict! where {(.<Registry>:exists) && (.<Ordering>:exists)}) {
	$.find-delegate('CIDSystemInfo');
    }

    multi method load-delegate( Hash :$dict! where {.<Type>:exists}, :$fallback) {
        my $type = from-ast($dict<Type>);
        my $subtype = from-ast($dict<Subtype> // $dict<S>)
	    unless $type eq 'Border';

        $.find-delegate( $type, $subtype, :$fallback );
    }

    #| Reverse lookup for classes when /Subtype is required but /Type is optional
    multi method load-delegate(Hash :$dict! where {.<Subtype>:exists }, :$fallback) {
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

	if $type {
	    $.find-delegate($type, $subtype);
	}
	else {
	    note "unhandled subtype: PDF::*::{$subtype}";
	    $fallback;
	}
    }

    #| Reverse lookup for classes when /Subtype is required but /Type is optional
    multi method load-delegate(Hash :$dict where {from-ast($_) ~~ 'GTS_PDFX' given .<S>},) {
	    $.find-delegate('OutputIntent', 'GTS_PDFX');
    }

    subset ColorSpace-Array of List where {
        my $elems = .elems;
        my $t = from-ast .[0]
            if 2 <= $elems <= 5;
	(
         #| PDF Spec 1.7 Section 4.5.4 CIE-Based Color Spaces
         $elems == 2
         && $t ~~ PDF::DAO::Name
         && $t eq 'CalGray'|'CalRGB'|'Lab'|'ICCBased';
        )
        || ( 
            #| PDF Spec 1.7 Section 4.5.5 Special Color Spaces
            3 <= $elems <= 5
            && $t ~~ PDF::DAO::Name
            && $t eq 'Indexed'|'Separation'|'DeviceN';
        )
    }

    multi method load-delegate(ColorSpace-Array :$array!) {
	my $color-type = from-ast $array[0];
	$.find-delegate('ColorSpace', $color-type);
    }

    multi method load-delegate(:$fallback!) is default {
	$fallback;
    }

}
