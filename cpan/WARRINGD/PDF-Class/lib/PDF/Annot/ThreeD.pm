use v6;

use PDF::Annot;
use PDF::Class::ThreeD;

class PDF::Annot::ThreeD
    is PDF::Annot
    does PDF::Class::ThreeD {

    # See [PDF 32000 Table 298 – Additional entries specific to a 3D annotation]
    ## use ISO_32000::Three-D_annotation;
    ## also does ISO_32000::Three-D_annotation;
    use PDF::COS::Tie;

    has Numeric @.view-box  is entry(:key<3DB>, :len(4)); # rectangle (Optional) The 3D view box, which is the rectangular area in which the 3D artwork shall be drawn. It shall be within the rectangle specified by the annotation’s Rect entry and shall be expressed in the annotation’s target coordinate system (see discussion following this Table).
    # Default value: the annotation’s Rect entry, expressed in the target
    # coordinate system. This value is [ -w/2 -h/2 w/2 h/2 ], where w and h are the width and height, respectively, of Rect.

    has Hash $.artwork is entry(:key<3DD>);      # A 3D stream or 3D reference dictionary that specifies the 3D artwork to be shown.

    has Bool $.interactive is entry(:key<3DI>, :default);  # (Optional) A flag indicating the primary use of the 3D annotation. If true, it is intended to be interactive; if false, it is intended to be manipulated programmatically, as with a JavaScript animation. Conforming readers may present different user interface controls for interactive 3D annotations (for example, to rotate, pan, or zoom the artwork) than for those managed by a script or other mechanism. Default value: true.
}
