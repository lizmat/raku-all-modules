use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

#| /Type /OBJR - a node in the page tree
class PDF::OBJR
    is PDF::COS::Dict
    does PDF::Class::Type {

    # see [PDF 1.7 TABLE 10.12 Entries in an object reference dictionary]
    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Page;

    has PDF::COS::Name $.Type is entry(:required) where 'OBJR';
    has PDF::Page $.Pg is entry(:indirect, :alias<page>);       #| (Optional; must be an indirect reference) The page object representing the page on which the object is rendered. This entry overrides any Pg entry in the structure element containing the object reference; it is required if the structure element has no such entry.
    has $.Obj is entry(:required,:indirect); #| (Required; must be an indirect reference) The referenced object.

}
