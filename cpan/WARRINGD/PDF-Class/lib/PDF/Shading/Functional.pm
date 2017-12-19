use v6;

use PDF::Shading;

#| /ShadingType 1 - Functional

class PDF::Shading::Functional
    is PDF::Shading {

     # see [PDF 1.7 TABLE 4.29 Additional entries specific to a type 1 shading dictionary]
     use PDF::DAO::Tie;
     has Numeric @.Domain is entry(:len(4));  #| (Optional) An array of four numbers [ xmin xmax ymin ymax ] specifying the rectangular domain of coordinates over which the color function(s) are defined.
     has Numeric @.Matrix is entry(:len(4));  #| (Optional) An array of six numbers specifying a transformation matrix mapping the coordinate space specified by the Domain entry into the shading’s target coordinate space.
     has $.Function is entry(:required)       #| (Required) A 2-in, n-out function or an array of n 2-in, 1-out functions (where nis the number of color components in the shading dictionary’s color space)
}
