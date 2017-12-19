use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Separation
    is PDF::ColorSpace {

    use PDF::DAO::Tie;
    use PDF::DAO::Name;
    # see [PDF 1.7 Section 4.5.5 Special Color Spaces] 
    has PDF::DAO::Name $.Name is index(1);
    subset ArrayOrName where Array | PDF::DAO::Name;
    has ArrayOrName $.AlternateSpace is index(2);
    has $.TintTransform is index(3);

}
