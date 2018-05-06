use v6;

use PDF::COS::Tie::Hash;
use PDF::Class::Type;

#| /Type /Encoding
#| see [PDF 1.7 Section 5.5.5 Character Encoding]
role PDF::Encoding
    does PDF::COS::Tie::Hash
    does PDF::Class::Type {

    # see [PDF 1.7 TABLE 5.11 Entries in an encoding dictionary]
    use PDF::COS::Tie;
    use PDF::COS::Name;
    has PDF::COS::Name $.Type is entry where 'Encoding';
    has PDF::COS::Name $.BaseEncoding is entry; #| (Optional) The base encoding—that is, the encoding from which the Differences entry (if present) describes differences.
    has @.Differences is entry;                 #| (Optional; not recommended with TrueType fonts) An array describing the differences from the encoding specified by BaseEncoding or, if BaseEncoding is absent, from an implicit base encoding.

}
