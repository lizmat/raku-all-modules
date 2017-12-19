use v6;

use PDF::Shading::Axial;

#| /ShadingType 3 - Radial

class PDF::Shading::Radial
    is PDF::Shading::Axial {
    # see [PDF TABLE 4.31 Additional entries specific to a type 3 shading dictionary]
    # Radial and Axial have identical structure
}
