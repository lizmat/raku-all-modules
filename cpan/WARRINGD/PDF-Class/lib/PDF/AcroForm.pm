use v6;

use PDF::DAO::Tie::Hash;

# AcroForm role - see PDF::Catalog - /AcroForm entry

role PDF::AcroForm
    does PDF::DAO::Tie::Hash {

    # see [PDF 1.7 TABLE 8.67 Entries in the interactive form dictionary]
    use PDF::DAO::Tie;
    use PDF::Field :coerce;
    use PDF::DAO;

    has PDF::Field @.Fields is entry(:required, :&coerce);    #| (Required) An array of references to the document’s root fields (those with no ancestors in the field hierarchy).
    #| returns an inorder array of all descendant fields
    method fields returns Array {
	my PDF::Field @fields;
	for $.Fields.keys {
	    @fields.append( $.Fields[$_].fields )
	}
	@fields;
    }
    #| return fields mapped to a hash. Default keys are $.T and $.TU field entries
    method fields-hash( Array $fields-arr = self.fields,
			Bool :$T  = True,
			Bool :$TU = True,
			Bool :$TM = False
			--> Hash) {
	my @keys;
	push @keys: 'T' if $T;
	push @keys: 'TU' if $TU;
	push @keys: 'TM' if $TM;
	my %fields;

	for $fields-arr.list -> $field {
	    for @keys -> $key {
		%fields{ $field{$key} } = $field
		    if $field{$key}:exists;
	    }
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

    has Hash @.CO is entry(:indirect);         #| (Required if any fields in the document have additional-actions dictionaries containing a C entry; PDF 1.3) An array of indirect references to field dictionaries with calculation actions, defining the calculation order in which their values will be recalculated when the value of any field changes

    has Hash $.DR is entry;                    #| (Optional) A resource dictionary containing default resources (such as fonts, patterns, or color spaces) to be used by form field appearance streams. At a minimum, this dictionary must contain a Font entry specifying the resource name and font dictionary of the default font for displaying text.

    has Str $.DA is entry;                     #| (Optional) A document-wide default value for the DA attribute of variable text fields

    has UInt $.Q is entry;                     #| (Optional) A document-wide default value for the Q attribute of variable text fields

    use PDF::DAO::Stream;
    my subset StreamOrArray where PDF::DAO::Stream | Array;
    has StreamOrArray $.XFA is entry;          #| (Optional; PDF 1.5) A stream or array containing an XFA resource, whose format is described by the Data Package (XDP) Specification. (see the Bibliography).
                                               #| The value of this entry must be either a stream representing the entire contents of the XML Data Package or an array of text string and stream pairs representing the individual packets comprising the XML Data Package

}
