use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Indexed
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;
    use PDF::COS::ByteString;

    # see [PDF 32000 Section 8.6.6.3 Indexed Color Spaces]

    my subset NameOrColorSpace where PDF::COS::Name|PDF::ColorSpace;
    has NameOrColorSpace $.Base is index(1);

    has UInt $.Hival is index(2);

    my subset StreamOrByteString where PDF::COS::Stream|PDF::COS::ByteString;
    has StreamOrByteString $.Lookup is index(3);

}
