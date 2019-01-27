use v6;

use PDF::COS::Stream;
use PDF::Shading;

#| /ShadingType 5 - Lattice
class PDF::Shading::Lattice
    is PDF::COS::Stream
    does PDF::Shading {

    use PDF::COS::Tie;
    use PDF::Function;

    # see [PDF 32000 Table 83 - Additional Entries Specific to a Type 5 Shading Dictionary]
    ## use ISO_32000::Type_5_Shading;
    ## also does ISO_32000::Type_5_Shading;

    has UInt $.BitsPerCoordinate is entry(:required);	# [integer] (Required) The number of bits used to represent each vertex coordinate. The value is 1, 2, 4, 8, 12, 16, 24, or 32.
    has UInt $.BitsPerComponent is entry(:required);  # (Required) The number of bits used to represent each color component. Valid values are 1, 2, 4, 8, 12, and 16.
    has UInt $.VerticesPerRow is entry(:required);    # (Required) The number of vertices in each row of the lattice; the value must be greater than or equal to 2.
    has Numeric @.Decode is entry(:required);         # (Required) An array of numbers specifying how to map vertex coordinates and color components into the appropriate ranges of values
    has PDF::Function @.Function is entry(:array-or-item);   # (Optional) A 1-in, n-out function or an array of n 1-in, 1-out functions (where n is the number of color components in the shading dictionary’s color space).
}
