use v6;

use PDF::DAO::Tie::Hash;
use PDF::Class::Type;

role PDF::Field
    does PDF::DAO::Tie::Hash
    does PDF::Class::Type['FT'] {

    use PDF::DAO::Tie;
    use PDF::DAO::TextString;
    use PDF::DAO::Dict;

    # see [PDF 1.7 TABLE 8.69 Entries common to all field dictionaries]

    my subset FieldTypeName of PDF::DAO::Name
	where ( 'Btn' # Button
	      | 'Tx'  # Text
              | 'Ch'  # Choice
	      | 'Sig' # Signature
	      );

    multi method field-delegate( PDF::DAO::Dict $dict where { .<FT>:exists && .<FT> ~~ FieldTypeName }) {
	my $field-role = do given $dict<FT> {
	    when 'Btn' {'Button'}
            when 'Tx'  {'Text'}
            when 'Ch'  {'Choice'}
            when 'Sig' {'Signature'}
	};
	PDF::DAO.loader.find-delegate( 'Field', $field-role );
    }

    multi method field-delegate( PDF::DAO::Dict $dict)  {
	if $dict<FT> {
	    warn "ignoring Field /FT entry: $dict<FT>"
	}
	else {
	    warn "terminal Field lacks /FT entry"
		unless $dict<Kids>:exists
	}
	PDF::Field;
    }

    #| pure annotation or field/annotation union
    sub is-annot($dict) returns Bool {
	   ?( ($dict<Type>:exists)
	      && $dict<Type> eq 'Annot' );
    }

    #| pure annotation only
    sub is-annot-only($dict) returns Bool {
	?( is-annot($dict)
	   && !($dict<FT>:exists)
	   && !($dict<Kids>:exists))
    }

    proto sub coerce( $, $ ) is export(:coerce) {*}
    multi sub coerce( PDF::DAO::Dict $dict is rw, PDF::Field $field ) {
	# refuse to coerce an annotation as a field
	PDF::DAO.coerce( $dict, $field.field-delegate( $dict ) );
    }

    has FieldTypeName $.FT is entry(:inherit, :alias<field-type>);  #| Required for terminal fields; inheritable) The type of field that this dictionary describes
    has PDF::Field $.Parent is entry(:indirect);      #| (Required if this field is the child of another in the field hierarchy; absent otherwise) The field that is the immediate parent of this one (the field, if any, whose Kids array includes this field). A field can have at most one parent; that is, it can be included in the Kids array of at most one other field.

    my subset AnnotOrField of Hash where { is-annot-only($_) || $_ ~~ PDF::Field }
    multi sub coerce( PDF::DAO::Dict $dict is rw, AnnotOrField) {
	PDF::DAO.coerce( $dict, PDF::Field.field-delegate( $dict ) )
	    unless is-annot-only($dict)
    }
    has AnnotOrField @.Kids is entry(:indirect, :&coerce); #| (Sometimes required, as described below) An array of indirect references to the immediate children of this field.
                                                #| In a non-terminal field, the Kids array is required to refer to field dictionaries that are immediate descendants of this field. In a terminal field, the Kids array ordinarily must refer to one or more separate widget annotations that are associated with this field. However, if there is only one associated widget annotation, and its contents have been merged into the field dictionary, Kids must be omitted.

    method is-terminal returns Bool {
	! ($.Kids.defined
	   && $.Kids.keys.first: {! is-annot-only($.Kids[$_]) })
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
		    unless is-annot-only($kid)
	    }
	}
	flat @fields;
    }

    #| return immediate annotations only. return ourself, if we're an annotation,
    #| otherwise return any annots from out immediate kids
    method annots {
	my @annots;
	if is-annot(self) {
	    @annots.push: self
	}
	elsif  self.Kids.defined {
	    for self.Kids.keys {
		my $kid = self.Kids[$_];
		@annots.append: $kid.fields
		    if is-annot-only($kid)
	    }
	}
	flat @annots;
    }

    has PDF::DAO::TextString $.T is entry(:alias<key>);      #| Optional) The partial field name

    has PDF::DAO::TextString $.TU is entry(:alias<label>);     #| (Optional; PDF 1.3) An alternate field name to be used in place of the actual field name wherever the field must be identified in the user interface (such as in error or status messages referring to the field). This text is also useful when extracting the document’s contents in support of accessibility to users with disabilities or for other purposes

    has PDF::DAO::TextString $.TM is entry(:alias<tag>);     #| (Optional; PDF 1.3) The mapping name to be used when exporting interactive form field data from the document.

    has UInt $.Ff is entry(:inherit);           #| Optional; inheritable) A set of flags specifying various characteristics of the field

## type specific - see individual field definitions
##    has Any $.V is entry(:inherit);           #| (Optional; inheritable) The field’s value, whose format varies depending on the field type

##    has Any $.DV is entry(:inherit);          #| (Optional; inheritable) The default value to which the field reverts when a reset-form action is executed. The format of this value is the same as that of V.

    has Hash $.AA is entry;                     #| (Optional; PDF 1.2) An additional-actions dictionary defining the field’s behavior in response to various trigger events. This entry has exactly the same meaning as the AA entry in an annotation dictionary

    # see [PDF 1.7 TABLE 8.71 Additional entries common to all fields containing variable text]

    has Str $.DA is entry(:inherit);            #| (Required; inheritable) The default appearance string containing a sequence of valid page-content graphics or text state operators that define such properties as the field’s text size and color.

    my subset QuaddingFlags of UInt where 0..3;
    has QuaddingFlags $.Q is entry(:inherit);   #| (Optional; inheritable) A code specifying the form of quadding (justification) to be used in displaying the text:
                                                #| 0: Left-justified
                                                #| 1: 1Centered
                                                #| 2: Right-justified

    has PDF::DAO::TextString $.DS is entry;     #| Optional; PDF 1.5) A default style string

    use PDF::DAO::Stream;
    my subset TextOrStream where PDF::DAO::TextString | PDF::DAO::Stream;
    multi sub coerce(Str $value is rw, TextOrStream) {
	$value = PDF::DAO.coerce( $value, PDF::DAO::TextString );
    }
    has TextOrStream $.RV is entry( :&coerce );             #| (Optional; PDF 1.5) A rich text string
    
}
