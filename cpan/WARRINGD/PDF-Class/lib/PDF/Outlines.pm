use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

#| /Type /Outlines - the Outlines dictionary

class PDF::Outlines
    is PDF::COS::Dict
    does PDF::Class::Type {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    my subset Name-Outlines of PDF::COS::Name where 'Outlines';
    has Name-Outlines $.Type is entry;
    use PDF::OutlineItem;

    # see TABLE 8.3 Entries in the outline dictionary
    has PDF::OutlineItem $.First is entry(:indirect); #| (Required if there are any open or closed outline entries; must be an indirect reference) An outline item dictionary representing the first top-level item in the outline.
    has PDF::OutlineItem $.Last is entry(:indirect);  #| (Required if there are any open or closed outline entries; must be an indirect reference) An outline item dictionary representing the last top-level item in the outline.
    has UInt $.Count is entry;             #| (Required if the document has any open outline entries) The total number of open items at all levels of the outline. This entry should be omitted if there are no open outline items.

}

