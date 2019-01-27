use v6;

use PDF::Font;
class PDF::Font::CIDFont
    is PDF::Font {

    use PDF::COS::Tie;
    use PDF::COS::Stream;
    use PDF::COS::Name;
    use PDF::FontDescriptor::CID;

    # see [PDF 32000 Table 117 - Entries in a CIDFont dictionary]
    ## use ISO_32000::CIDFont;
    ## also does ISO_32000::CIDFont;
    use PDF::CIDSystemInfo;
    use PDF::FontDescriptor::CID;

    has PDF::COS::Name $.BaseFont is entry(:required);        # (Required) The PostScript name of the CIDFont. For Type 0 CIDFonts, this is usually the value of the CIDFontName entry in the CIDFont program. For Type 2 CIDFonts, it is derived the same way as for a simple TrueType font
    has PDF::CIDSystemInfo $.CIDSystemInfo is entry(:required);             # (Required) A dictionary containing entries that define the character collection of the CIDFont.
    has PDF::FontDescriptor::CID $.FontDescriptor is entry(:required, :indirect); # (Required; must be an indirect reference) A font descriptor describing the CIDFont’s default metrics other than its glyph widths
    has UInt $.DW is entry(:alias<default-width>);                                   # (Optional) The default width for glyphs in the CIDFont
    has @.W is entry(:alias<widths>);                                         # (Optional) A description of the widths for the glyphs in the CIDFont. The array’s elements have a variable format that can specify individual widths for consecutive CIDs or one width for a range of CIDs
    has Numeric @.DW2 is entry(:len(2), :alias<default-width-and-height>);                               # (Optional; applies only to CIDFonts used for vertical writing) An array of two numbers specifying the default metrics for vertical writing
    has Numeric @.W2 is entry(:alias<heights>);                                # (Optional; applies only to CIDFonts used for vertical writing) A description of the metrics for vertical writing for the glyphs in the CIDFont
    my subset Identity of PDF::COS::Name where 'Identity';
    my subset StreamOrIdentity where PDF::COS::Stream | Identity;
    has StreamOrIdentity $.CIDToGIDMap is entry;              # to glyph indices. If the value is a stream, the bytes in the stream contain the mapping from CIDs to glyph indices: the glyph index for a particular CID value c is a 2-byte value stored in bytes 2 × c and 2 × c + 1, where the first byte is the high-order byte. If the value of CIDToGIDMap is a name, it must be Identity, indicating that the mapping between CIDs and glyph indices is the identity mapping

}
