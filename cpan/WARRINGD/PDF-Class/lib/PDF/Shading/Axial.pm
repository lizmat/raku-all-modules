use v6;

use PDF::COS::Dict;
use PDF::Shading;

#| /ShadingType 2 - Axial

class PDF::Shading::Axial
    is PDF::COS::Dict
    does PDF::Shading {

    # see [PDF 1.7 TABLE 4.30 Additional entries specific to a type 2 shading dictionary]
    use PDF::COS::Tie;

    has Numeric @.Coords is entry(:required,:len(4)); #| (Required) An array of four numbers [ x0 y0 x1 y1 ] specifying the starting and ending coordinates of the axis, expressed in the shading’s target coordinate space.
    has Numeric @.Domain is entry(:len(2));            #| (Optional) An array of two numbers [ t0 t1 ] specifying the limiting values of a parametric variable t. The variable is considered to vary linearly between these two values as the color gradient varies between the starting and ending points of the axis
    has $.Function is entry(:required);     #| (Required) A 1-in, n-out function or an array of n 1-in, 1-out functions (where nis the number of color components in the shading dictionary’s color space)
    has Bool @.Extend is entry(:len(2));            #| (Optional) An array of two boolean values specifying whether to extend the shading beyond the starting and ending points of the axis, respectively
}
