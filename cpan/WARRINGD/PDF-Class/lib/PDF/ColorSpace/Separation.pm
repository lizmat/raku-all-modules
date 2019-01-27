use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Separation
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Function;

    # see [PDF 32000 Section 8.6.6.4 Separation Color Spaces]

    has PDF::COS::Name $.Name is index(1);

    my subset NameOrColorSpace where PDF::COS::Name|PDF::ColorSpace;
    has NameOrColorSpace $.AlternateSpace is index(2);

    has PDF::Function $.TintTransform is index(3);

}
