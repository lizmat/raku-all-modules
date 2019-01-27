use v6;

use PDF::Shading::Coons;

#| /ShadingType 7 - Tensor
class PDF::Shading::Tensor
    is PDF::Shading::Coons {
    # See [PDF 32000 Section 8.7.4.5.8 - Type 7 Shadings (Tensor-Product Patch Meshes)]
    # Tensor and FreeForm shading types have identical structure
}
