use v6;

use PDF::COS::Stream;
use PDF::Shading;

#| /ShadingType 6 - Coons
class PDF::Shading::Coons
    is PDF::COS::Stream
    does PDF::Shading {
    ## use ISO_32000::Type_6_Shading;
    ## also does ISO_32000::Type_6_Shading;
    # see [PDF 32000 Table 84 - Additional Entries Specific to a Type 6 Shading Dictionary]
    use PDF::COS::Tie;
    use PDF::Function;

    has UInt $.BitsPerCoordinate is entry(:required); # (Required) The number of bits used to represent each vertex coordinate. Valid values are 1, 2, 4, 8, 12, 16, 24, and 32.
    has UInt $.BitsPerComponent is entry(:required);  # (Required) The number of bits used to represent each color component. Valid values are 1, 2, 4, 8, 12, and 16.
    has UInt $.BitsPerFlag is entry(:required);       # (Required) The number of bits used to represent the edge flag for each vertex (see below). Valid values of BitsPerFlag are 2, 4, and 8, but only the least significant 2 bits in each flag value are used
    has Numeric @.Decode is entry(:required);         # (Required) An array of numbers specifying how to map vertex coordinates and color components into the appropriate ranges of values
    has PDF::Function @.Function is entry(:array-or-item);  # (Optional) A 1-in, n-out function or an array of n 1-in, 1-out functions (where n is the number of color components in the shading dictionary’s color space).
}
