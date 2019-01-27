use PDF::COS::Tie;
use PDF::COS::Tie::Hash;

#| Target of PDF::FontDescriptor FontFile or FontFile 2 Attribute;
role PDF::FontStream
    does PDF::COS::Tie::Hash {

    use PDF::Metadata::XML;
    use PDF::COS::Name;

    has UInt $.Length1 is entry; # (Required for Type 1 and TrueType fonts) The length in bytes of the clear-text portion of the Type 1 font program, or the entire TrueType font program, after it has been decoded using the filters specified by the stream’s Filter entry, if any.
    has UInt $.Length2 is entry; # (Required for Type 1 fonts) The length in bytes of the encrypted portion of the Type 1 font program after it has been decoded using the filters specified by the stream’s Filter entry.
    has UInt $.Length3 is entry; # (Required for Type 1 fonts) The length in bytes of the fixed-content portion of the Type 1 font program after it has been decoded using the filters specified by the stream’s Filter entry. If Length3 is 0, it indicates that the 512 zeros and cleartomark have not been included in the FontFile font program and shall be added by the conforming reader.

    has PDF::Metadata::XML $.Metadata is entry; # (Optional; PDF 1.4) A metadata stream containing metadata for the embedded font program.
}

