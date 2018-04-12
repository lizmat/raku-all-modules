use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Pattern
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    # see [PDF 1.7 Section 4.5.5 Special Color Spaces]
    has PDF::COS::Name $.Colorspace is index(1);
}
