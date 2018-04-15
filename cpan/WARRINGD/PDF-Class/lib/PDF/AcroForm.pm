use v6;

use PDF::COS::Tie::Hash;

#| AcroForm role - see PDF::Catalog - /AcroForm entry
role PDF::AcroForm
    does PDF::COS::Tie::Hash {

    # see [PDF 1.7 TABLE 8.67 Entries in the interactive form dictionary]
    use PDF::COS::Tie;
    use PDF::Field :coerce;

    has PDF::Field @.Fields is entry(:required, :&coerce);    #| (Required) An array of references to the document’s root fields (those with no ancestors in the field hierarchy).
    #| returns an inorder array of all descendant fields
    method fields returns Array {
	my PDF::Field @fields;
        my $flds = $.Fields;
	for $flds.keys {
	    @fields.append( $flds[$_].fields )
	}
	@fields;
    }
    #| return fields mapped to a hash. Default keys are $.T and $.TU field entries
        method fields-hash( Array $fields-arr = self.fields,
                            :$key where 'T'|'TU'|'TR' = 'T'
			--> Hash) {
	my %fields;

	for $fields-arr.list -> $field {
            %fields{ $_ } = $field
                with $field{$key};
	}

	%fields;
    }

    has Bool $.NeedAppearances is entry;       #| (Optional) A flag specifying whether to construct appearance streams and appearance dictionaries for all widget annotations in the document

    my subset SigFlagsInt of UInt where 0..3;
    my enum SigFlags is export(:SigFlags) «
        :SignaturesExist(1) #| If set, the document contains at least one signature field
        :AppendOnly(2)      #| If set, the document contains signatures that may be invalidated if the file is saved (written) in a way that alters its previous contents, as opposed to an incremental update.
    »;
    has SigFlagsInt $.SigFlags is entry;       #| (Optional; PDF 1.3) A set of flags specifying various document-level characteristics related to signature fields

    has Hash @.CO is entry(:indirect, :alias<calculation-order>);         #| (Required if any fields in the document have additional-actions dictionaries containing a C entry; PDF 1.3) An array of indirect references to field dictionaries with calculation actions, defining the calculation order in which their values will be recalculated when the value of any field changes

    has Hash $.DR is entry(:alias<default-resources>);                    #| (Optional) A resource dictionary containing default resources (such as fonts, patterns, or color spaces) to be used by form field appearance streams. At a minimum, this dictionary must contain a Font entry specifying the resource name and font dictionary of the default font for displaying text.

    has Str $.DA is entry(:alias<default-appearance>);                     #| (Optional) A document-wide default value for the DA attribute of variable text fields

    has UInt $.Q is entry(:alias<quadding>);                     #| (Optional) A document-wide default value for the Q attribute of variable text fields

    use PDF::COS::Stream;
    my subset StreamOrArray where PDF::COS::Stream | Array;
    has StreamOrArray $.XFA is entry;          #| (Optional; PDF 1.5) A stream or array containing an XFA resource, whose format is described by the Data Package (XDP) Specification. (see the Bibliography).
                                               #| The value of this entry must be either a stream representing the entire contents of the XML Data Package or an array of text string and stream pairs representing the individual packets comprising the XML Data Package

}
