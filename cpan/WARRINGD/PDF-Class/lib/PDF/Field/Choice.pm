use v6;

use PDF::Field;

role PDF::Field::Choice
    does PDF::Field {

    # [PDF 1.7 TABLE 8.76 Additional entry specific to check box and radio button fields]

    use PDF::COS::Tie;
    use PDF::COS::TextString;

    my subset ArrayOfTextStrings of Array where { [&&] .map( *.isa(PDF::COS::TextString) ) }
    my subset FieldOption where ArrayOfTextStrings | PDF::COS::TextString;
    multi sub coerce(Str $s is rw, FieldOption) {
	PDF::COS.coerce($s, PDF::COS::TextString)
    }
    multi sub coerce(Array $a is rw, FieldOption) {
	for $a.keys {
	    PDF::COS.coerce( $a[$_],  PDF::COS::TextString)
	}
    }

    has FieldOption $.V is entry(:&coerce, :inherit, :alias<value>);
    has FieldOption $.DV is entry(:&coerce, :inherit, :alias<default-value>);

    has FieldOption @.Opt is entry(:&coerce);    #| (Optional) An array of options to be presented to the user. Each element of the array is either a text string representing one of the available options or an array consisting of two text strings: the option’s export value and the text to be displayed as the name of the option

   has UInt $.TI is entry(:alias<top-index>);  #| Optional) For scrollable list boxes, the top index (the index in the Opt array of the first option visible in the list). Default value: 0.

   has UInt @.I is entry(:alias<indices>);   #| (Sometimes required, otherwise optional; PDF 1.4) For choice fields that allow multiple selection (MultiSelect flag set), an array of integers, sorted in ascending order, representing the zero-based indices in the Opt array of the currently selected option items. This entry is required when two or more elements in the Opt array have different names but the same export value or when the value of the choice field is an array. In other cases, the entry is permitted but not required. If the items identified by this entry differ from those in the V entry of the field dictionary (see below), the V entry takes precedence.

}
