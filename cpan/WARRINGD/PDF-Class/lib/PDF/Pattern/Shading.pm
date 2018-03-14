use v6;

use PDF::COS::Dict;
use PDF::Pattern;

#| /ShadingType 2 - Axial

class PDF::Pattern::Shading
    is PDF::COS::Dict
    does PDF::Pattern {

    use PDF::COS::Tie;
    use PDF::COS::Name;

    # see [PDF 1.7 TABLE 4.26 Entries in a type 2 pattern dictionary]
    use PDF::Shading;
    has PDF::Shading $.Shading is entry(:required); #| (Required) A shading object (see below) defining the shading pattern’s gradient fill.
    use PDF::ExtGState;
    has PDF::ExtGState $.ExtGState is entry;          #| (Optional) A graphics state parameter dictionary
}
