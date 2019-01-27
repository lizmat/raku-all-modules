use v6;

use PDF::COS::Tie::Hash;
use PDF::Class::Type;

role PDF::Field
    does PDF::COS::Tie::Hash
    does PDF::Class::Type::Subtyped {

    use PDF::COS::Tie;
    use PDF::COS::TextString;
    use PDF::COS::Dict;
    use PDF::COS::Name;

    my role vanilla does PDF::Field {
        # see [PDF 32000 Table 220 - Entries common to all field dictionaries]
        ## use ISO_32000::Field_common;
        ## also does ISO_32000::Field_common;

        ## type specific - see individual field definitions
        has Any $.V is entry(:inherit);           # (Optional; inheritable) The field’s value, whose format varies depending on the field type

        has Any $.DV is entry(:inherit);          # (Optional; inheritable) The default value to which the field reverts when a reset-form action is executed. The format of this value is the same as that of V.
    }

    my subset FieldTypeName of PDF::COS::Name
	where ( 'Btn' # Button
	      | 'Tx'  # Text
              | 'Ch'  # Choice
	      | 'Sig' # Signature
	      );

    method field-delegate( PDF::COS::Dict $dict) {
        my $field-role = do with $dict<FT> {
	    when 'Btn' {'Button'}
            when 'Tx'  {'Text'}
            when 'Ch'  {'Choice'}
            when 'Sig' {'Signature'}
            default { warn "ignoring Field /FT entry: $_"; Nil }
        }
        else {
            warn "terminal Field lacks /FT entry"
                unless $dict<Kids>:exists
        }

        with $field-role {
            PDF::COS.loader.find-delegate( 'Field', $field-role, :base-class(PDF::Field) );
        }
        else {
            PDF::Field
        }
    }

    my subset AnnotLike of Hash where .<Type> ~~ 'Annot';
    my subset FieldLike is export(:FieldLike) of Hash where { (.<FT>:exists) || (.<Kids>:exists) }

    proto sub coerce( $, $ ) is export(:coerce) {*}
    multi sub coerce( PDF::COS::Dict $dict, PDF::Field $field ) {
	# refuse to coerce an annotation as a field
	PDF::COS.coerce( $dict, $field.field-delegate( $dict ) );
    }

    method type { 'Field' }
    has FieldTypeName $.FT is entry(:inherit, :alias<subtype>);  # Required for terminal fields; inheritable) The type of field that this dictionary describes
    has PDF::Field $.Parent is entry(:indirect);      # (Required if this field is the child of another in the field hierarchy; absent otherwise) The field that is the immediate parent of this one (the field, if any, whose Kids array includes this field). A field can have at most one parent; that is, it can be included in the Kids array of at most one other field.

    my subset AnnotOrField of Hash where AnnotLike|PDF::Field;
    multi sub coerce( FieldLike $dict, AnnotOrField) {
	PDF::COS.coerce( $dict, PDF::Field.field-delegate( $dict ) )
    }
    multi sub coerce( $_, AnnotOrField) is default {
        fail "unable to coerce {.perl} to an Annotation or Field";
    }

    has AnnotOrField @.Kids is entry(:indirect, :&coerce); # (Sometimes required, as described below) An array of indirect references to the immediate children of this field.
                                                # In a non-terminal field, the Kids array is required to refer to field dictionaries that are immediate descendants of this field. In a terminal field, the Kids array ordinarily must refer to one or more separate widget annotations that are associated with this field. However, if there is only one associated widget annotation, and its contents have been merged into the field dictionary, Kids must be omitted.

    method is-terminal returns Bool {
	with $.Kids {
            ! .keys.first: -> $k {.[$k] ~~ FieldLike }
        }
        else {
            True;
        }
    }

    #| return ourself, if terminal, any children otherwise
    method fields {
	my @fields;
	if self.is-terminal {
	    @fields.push: self
	}
	else {
	    for self.Kids.keys {
		my $kid = self.Kids[$_];
		@fields.append: $kid.fields
		    if $kid ~~ FieldLike;
	    }
	}
	flat @fields;
    }

    #| return immediate annotations only. return ourself, if we're an annotation,
    #| otherwise return any annots from out immediate kids
    method annots {
	my @annots;
	if self ~~ AnnotLike {
	    @annots.push: self
	}
	elsif  self.Kids.defined {
	    for self.Kids.keys {
		my $kid = self.Kids[$_];
		@annots.append: $kid.fields
		    if $kid ~~ AnnotLike && $kid !~~ FieldLike;
	    }
	}
	flat @annots;
    }

    has PDF::COS::TextString $.T is entry(:alias<key>);      # Optional) The partial field name

    has PDF::COS::TextString $.TU is entry(:alias<label>);     # (Optional; PDF 1.3) An alternate field name to be used in place of the actual field name wherever the field must be identified in the user interface (such as in error or status messages referring to the field). This text is also useful when extracting the document’s contents in support of accessibility to users with disabilities or for other purposes

    has PDF::COS::TextString $.TM is entry(:alias<tag>);     # (Optional; PDF 1.3) The mapping name to be used when exporting interactive form field data from the document.

    has UInt $.Ff is entry(:inherit, :alias<flags>);           # Optional; inheritable) A set of flags specifying various characteristics of the field

    has Hash $.AA is entry(:alias<additional-actions>);                     # (Optional; PDF 1.2) An additional-actions dictionary defining the field’s behavior in response to various trigger events. This entry has exactly the same meaning as the AA entry in an annotation dictionary

    # see [PDF 1.7 TABLE 8.71 Additional entries common to all fields containing variable text]

    has Str $.DA is entry(:inherit, :alias<default-appearance>);            # (Required; inheritable) The default appearance string containing a sequence of valid page-content graphics or text state operators that define such properties as the field’s text size and color.

    my subset QuaddingFlags of UInt where 0..3;
    has QuaddingFlags $.Q is entry(:inherit, :alias<quadding>);   # (Optional; inheritable) A code specifying the form of quadding (justification) to be used in displaying the text:
                                                # 0: Left-justified
                                                # 1: 1Centered
                                                # 2: Right-justified

    has PDF::COS::TextString $.DS is entry(:alias<default-style>);     # Optional; PDF 1.5) A default style string

    use PDF::COS::Stream;
    my subset TextOrStream where PDF::COS::TextString | PDF::COS::Stream;
    multi sub coerce(Str $value is rw, TextOrStream) {
	$value = PDF::COS.coerce( $value, PDF::COS::TextString );
    }
    has TextOrStream $.RV is entry( :&coerce, :alias<rich-text> );  # (Optional; PDF 1.5) A rich text string

    method cb-check {
        die "Fields should have an /FT or /Kids entry"
            unless self ~~ FieldLike;
    }
}
