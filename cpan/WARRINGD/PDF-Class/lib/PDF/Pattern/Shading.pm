use v6;

use PDF::DAO::Dict;
use PDF::Pattern;

#| /ShadingType 2 - Axial

class PDF::Pattern::Shading
    is PDF::DAO::Dict
    does PDF::Pattern {

    use PDF::DAO::Tie;
    use PDF::DAO::Name;

    # see [PDF 1.7 TABLE 4.26 Entries in a type 2 pattern dictionary]
    use PDF::Shading;
    has PDF::Shading $.Shading is entry(:required); #| (Required) A shading object (see below) defining the shading pattern’s gradient fill.
    has Hash $.ExtGState is entry;          #| (Optional) A graphics state parameter dictionary
}
