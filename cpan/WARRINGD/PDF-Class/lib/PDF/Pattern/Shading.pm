use v6;

use PDF::COS::Dict;
use PDF::Pattern;

#| /ShadingType 2 - Axial

class PDF::Pattern::Shading
    is PDF::COS::Dict
    does PDF::Pattern {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Shading;
    use PDF::ExtGState;

    # see [PDF 32000 Table 76 - Entries in a type 2 pattern dictionary]
    ## use ISO_32000::Type_2_Pattern;
    ## also does ISO_32000::Type_2_Pattern;

    has PDF::Shading $.Shading is entry(:required);                 # (Required) A shading object (see below) defining the shading pattern’s gradient fill.
    has PDF::ExtGState $.ExtGState is entry;                        # (Optional) A graphics state parameter dictionary
}
