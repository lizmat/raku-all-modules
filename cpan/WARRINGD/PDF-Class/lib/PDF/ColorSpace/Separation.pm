use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Separation
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Function;
    # see [PDF 1.7 Section 4.5.5 Special Color Spaces]
    has PDF::COS::Name $.Name is index(1);
    subset ArrayOrName where Array | PDF::COS::Name;
    has ArrayOrName $.AlternateSpace is index(2);
    has PDF::Function $.TintTransform is index(3);

}
