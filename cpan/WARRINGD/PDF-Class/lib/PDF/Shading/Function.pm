use v6;

use PDF::COS::Dict;
use PDF::Shading;

#| /ShadingType 1 - Functional
class PDF::Shading::Function
    is PDF::COS::Dict
    does PDF::Shading {

     # see [PDF 32000 Table 79 - Additional Entries Specific to a Type 1 Shading Dictionary]
    ## use ISO_32000::Type_1_Shading;
    ## also does ISO_32000::Type_1_Shading;
    use PDF::COS::Tie;
    use PDF::Function;

    has Numeric @.Domain is entry(:len(4));  # (Optional) An array of four numbers [ xmin xmax ymin ymax ] specifying the rectangular domain of coordinates over which the color function(s) are defined.
    has Numeric @.Matrix is entry(:len(4));  # (Optional) An array of six numbers specifying a transformation matrix mapping the coordinate space specified by the Domain entry into the shading’s target coordinate space.
    has PDF::Function @.Function is entry(:required, :array-or-item)       # (Required) A 2-in, n-out function or an array of n 2-in, 1-out functions (where nis the number of color components in the shading dictionary’s color space)
}
