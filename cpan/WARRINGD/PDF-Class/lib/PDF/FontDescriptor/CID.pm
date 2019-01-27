use PDF::COS::Tie::Hash;
role PDF::FontDescriptor::CID
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;

    #| See [PDF 320000 Table 124 – Additional font descriptor entries for CIDFonts]
    ## use ISO_32000::CIDFont_descriptor_additional;
    ## also does ISO_32000::CIDFont_descriptor_additional;

    has Hash $.Style is entry;              # (Optional) A dictionary containing entries that describe the style of the glyphs in the font.
    has PDF::COS::Name $.Lang is entry;     # (Optional; PDF 1.5) A name specifying the language of the font, which may be used for encodings where the language is not implied by the encoding itself. The value shall be one of the codes defined by Internet RFC 3066, Tags for the Identification of Languages or (PDF 1.0) 2-character language codes defined by ISO 639. If this entry is absent, the language shall be considered to be unknown.
    has Hash %.FD is entry;                 # (Optional) A dictionary whose keys identify a class of glyphs in a CIDFont. Each value shall be a dictionary containing entries that shall override the corresponding values in the main font descriptor dictionary for that class of glyphs.
    has PDF::COS::Stream $.CIDSet is entry; # (Optional) A stream identifying which CIDs are present in the CIDFont file. If this entry is present, the CIDFont shall contain only a subset of the glyphs in the character collection defined by the CIDSystemInfo dictionary. If it is absent, the only indication of a CIDFont subset shall be the subset tag in the FontName entry. The stream’s data shall be organized as a table of bits indexed by CID. The bits shall be stored in bytes with the high-order bit first. Each bit shall correspond to a CID. The most significant bit of the first byte shall correspond to CID 0, the next bit to CID 1, and so on.
}
