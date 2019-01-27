use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

# /Type /MCR - Marked Content Reference
class PDF::MCR
    is PDF::COS::Dict
    does PDF::Class::Type {

    # see [PDF 32000 Table 324 - Entries in a marked-content reference dictionary]
    ## use ISO_32000::Marked_content_reference;
    ## also does ISO_32000::Marked_content_reference;

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;
    use PDF::Page;

    has PDF::COS::Name $.Type is entry(:required, :alias<type>) where 'MCR';

    has PDF::Page $.Pg is entry(:indirect, :alias<page>); # (Optional; shall be an indirect reference) The page object representing the page on which the graphics objects in the marked-content sequence shall be rendered. This entry overrides any Pg entry in the structure element containing the marked-content reference; it shall be required if the structure element has no such entry.

    has PDF::COS::Stream $.Stm is entry;    # (Optional; shall be an indirect reference) The content stream containing the marked-content sequence. This entry should be present only if the marked-content sequence resides in a content stream other than the content stream for the page. If this entry is absent, the marked-content sequence shall be contained in the content stream of the page identified by Pg (either in the marked-content reference dictionary or in the parent structure element).

    has $.StmOwn is entry;                  # (Optional; shall be an indirect reference) The PDF object owning the stream identified by Stems annotation to which an appearance stream belongs.

    has UInt $.MCID is entry(:required);    # (Required) The marked-content identifier sequence within its content stream.
}
