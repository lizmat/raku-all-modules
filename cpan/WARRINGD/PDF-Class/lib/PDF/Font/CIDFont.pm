use v6;

class PDF::Font::CIDFont {

    use PDF::COS::Tie;
    use PDF::COS::Stream;
    use PDF::COS::Name;

    # see [PDF 1.7 TABLE 5.14 Entries in a CIDFont dictionary]
    has PDF::COS::Name $.BaseFont is entry(:required);        #| (Required) The PostScript name of the CIDFont. For Type 0 CIDFonts, this is usually the value of the CIDFontName entry in the CIDFont program. For Type 2 CIDFonts, it is derived the same way as for a simple TrueType font
    has Hash $.CIDSystemInfo is entry(:required);             #| (Required) A dictionary containing entries that define the character collection of the CIDFont.
    use PDF::FontDescriptor;
    has PDF::FontDescriptor $.FontDescriptor is entry(:required, :indirect); #| (Required; must be an indirect reference) A font descriptor describing the CIDFont’s default metrics other than its glyph widths
    has UInt $.DW is entry;                                   #| (Optional) The default width for glyphs in the CIDFont
    has @.W is entry;                                         #| (Optional) A description of the widths for the glyphs in the CIDFont. The array’s elements have a variable format that can specify individual widths for consecutive CIDs or one width for a range of CIDs
    has Numeric @.DW2 is entry;                               #| (Optional; applies only to CIDFonts used for vertical writing) An array of two numbers specifying the default metrics for vertical writing
    has Numeric @.W2 is entry;                                #| (Optional; applies only to CIDFonts used for vertical writing) A description of the metrics for vertical writing for the glyphs in the CIDFont
    my subset Identity of PDF::COS::Name where 'Identity';
    my subset StreamOrIdentity where PDF::COS::Stream | Identity;
    has StreamOrIdentity $.CIDToGIDMap                        #| to glyph indices. If the value is a stream, the bytes in the stream contain the mapping from CIDs to glyph indices: the glyph index for a particular CID value c is a 2-byte value stored in bytes 2 × c and 2 × c + 1, where the first byte is the high-order byte. If the value of CIDToGIDMap is a name, it must be Identity, indicating that the mapping between CIDs and glyph indices is the identity mapping

}
