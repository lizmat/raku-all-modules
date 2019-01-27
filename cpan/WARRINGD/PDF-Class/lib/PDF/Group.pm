use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

# /Type /Group - group attributes dictionary
class PDF::Group
    is PDF::COS::Dict
    does PDF::Class::Type::Subtyped {

    # see [PDF 32000 Table 96 – Entries Common to all Group Attributes Dictionaries]
    ## use ISO_32000::Group_Attributes_common;
    ## also does ISO_32000::Group_Attributes_common;
    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry(:alias<type>) where 'Group';
    has PDF::COS::Name $.S is entry(:alias<subtype>);
}
