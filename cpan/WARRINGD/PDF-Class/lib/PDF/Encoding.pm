use v6;

use PDF::DAO::Dict;
use PDF::Class::Type;

# /Type /Encoding - a node in the page tree
# see [PDF 1.7 Section 5.5.5 Character Encoding]
class PDF::Encoding
    is PDF::DAO::Dict
    does PDF::Class::Type {

    # see [PDF 1.7 TABLE 5.11 Entries in an encoding dictionary]
    use PDF::DAO::Tie;
    use PDF::DAO::Name;
    my subset Name-Encoding of PDF::DAO::Name where 'Encoding';
    has Name-Encoding $.Type is entry;
    has PDF::DAO::Name $.BaseEncoding is entry; #| (Optional) The base encoding—that is, the encoding from which the Differences entry (if present) describes differences.
    has @.Differences is entry;                 #| (Optional; not recommended with TrueType fonts) An array describing the differences from the encoding specified by BaseEncoding or, if BaseEncoding is absent, from an implicit base encoding.

}
