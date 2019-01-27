use v6;

use PDF::Class::OutlineNode;
use PDF::COS::Tie::Hash;

#| /Type /Outlines - the Outlines dictionary
role PDF::Outlines
    does PDF::Class::OutlineNode
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Outline;

    # See [PDF 32000 Table 152 - Entries in the outline dictionary]
    ## use ISO_32000::Outline;
    ## also does ISO_32000::Outline;

    has PDF::COS::Name $.Type is entry where 'Outlines';  # (Optional) The type of PDF object that this dictionary describes; if present, shall be Outlines for an outline dictionary.

    # see TABLE 8.3 Entries in the outline dictionary
    has PDF::Outline $.First is entry(:indirect); # (Required if there are any open or closed outline entries; must be an indirect reference) An outline item dictionary representing the first top-level item in the outline.
    has PDF::Outline $.Last is entry(:indirect);  # (Required if there are any open or closed outline entries; must be an indirect reference) An outline item dictionary representing the last top-level item in the outline.
    has Int $.Count is entry;                    # (Required if the document has any open outline entries) The total number of open items at all levels of the outline. This entry should be omitted if there are no open outline items.
}

