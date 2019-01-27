use v6;

use PDF::COS::Tie::Hash;

#| /Type /Encoding
role PDF::Encoding
    does PDF::COS::Tie::Hash {

    # see [PDF 32000 Table 114 - Entries in an encoding dictionary]
    ## use ISO_32000::Encoding;
    ## also does ISO_32000::Encoding;

    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry where 'Encoding';
    has PDF::COS::Name $.BaseEncoding is entry; # (Optional) The base encoding—that is, the encoding from which the Differences entry (if present) describes differences.
    has @.Differences is entry;                 # (Optional; not recommended with TrueType fonts) An array describing the differences from the encoding specified by BaseEncoding or, if BaseEncoding is absent, from an implicit base encoding.

}
