use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Indexed
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;
    use PDF::COS::ByteString;
    # see [PDF 1.7 Section 4.5.5 Special Color Spaces]
    subset ArrayOrName where Array | PDF::COS::Name;
    has ArrayOrName $.Base is index(1);
    has UInt $.Hival is index(2);
    my subset StreamOrByteString where PDF::COS::Stream | PDF::COS::ByteString;
    has StreamOrByteString $.Lookup is index(3);

}
