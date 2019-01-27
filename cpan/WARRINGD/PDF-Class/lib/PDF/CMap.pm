use v6;

use PDF::COS::Stream;
use PDF::Class::Type;

#| /Type /CMap
class PDF::CMap
    is PDF::COS::Stream
    does PDF::Class::Type {

    # see [PDF 32000 Table 120 - Additional entries in a CMap dictionary]
    ## use ISO_32000::CMap_stream;
    ## also does ISO_32000::CMap_stream;

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::CIDSystemInfo;

    has PDF::COS::Name $.Type is entry(:required, :alias<type>) where 'CMap';
    has PDF::COS::Name $.CMapName is entry(:required); # (Required) The PostScript name of the CMap. It should be the same as the value of CMapName in the CMap file.
    has PDF::CIDSystemInfo $.CIDSystemInfo is entry(:required);         # (Required) A dictionary containing entries that define the character collection for the CIDFont or CIDFonts associated with the CMap
    my subset ZeroOrOne of UInt where 0|1;
    has ZeroOrOne $.WMode is entry;                       # (Optional) A code that determines the writing mode for any CIDFont with which this CMap is combined. The possible values are 0 for horizontal and 1 for vertical
    my subset NameOrCMap where PDF::COS::Name | PDF::COS::Stream;
    has NameOrCMap $.UseCMap is entry;                  # (Optional) The name of a predefined CMap, or a stream containing a CMap, that is to be used as the base for this CMap
}
