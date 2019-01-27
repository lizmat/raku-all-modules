use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::ICCBased
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::ICCProfile;

    # see [PDF 32000 Table 66 - Additional Entries Specific to an ICC Profile Stream Dictionary]
    has PDF::ICCProfile $.dict is index(1);
    method props is rw handles <N Alternate Range Metadata> { $.dict }
}
