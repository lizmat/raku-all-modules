use v6;

use PDF::COS::Stream;
use PDF::Shading;

#| /ShadingType 4 - FreeForm

class PDF::Shading::FreeForm
    is PDF::COS::Stream
    does PDF::Shading {
    # see [PDF 1.7 TABLE 4.32 Additional entries specific to a type 4 shading dictionary]
    use PDF::COS::Tie;

    has UInt $.BitsPerCoordinate is entry(:required); #| (Required) The number of bits used to represent each vertex coordinate. Valid values are 1, 2, 4, 8, 12, 16, 24, and 32.
    has UInt $.BitsPerComponent is entry(:required);  #| (Required) The number of bits used to represent each color component. Valid values are 1, 2, 4, 8, 12, and 16.
    has UInt $.BitsPerFlag is entry(:required);       #| (Required) The number of bits used to represent the edge flag for each vertex (see below). Valid values of BitsPerFlag are 2, 4, and 8, but only the least significant 2 bits in each flag value are used
    has Numeric @.Decode is entry(:required);         #| (Required) An array of numbers specifying how to map vertex coordinates and color components into the appropriate ranges of values
    has $.Function is entry;                          #| (Optional) A 1-in, n-out function or an array of n 1-in, 1-out functions (where n is the number of color components in the shading dictionary’s color space).
}
