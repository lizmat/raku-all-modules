use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Indexed
    is PDF::ColorSpace {

    use PDF::DAO::Tie;
    use PDF::DAO::Name;
    use PDF::DAO::Stream;
    use PDF::DAO::ByteString;
    # see [PDF 1.7 Section 4.5.5 Special Color Spaces]
    subset ArrayOrName where Array | PDF::DAO::Name;
    has ArrayOrName $.Base is index(1);
    has UInt $.Hival is index(2);
    my subset StreamOrByteString where PDF::DAO::Stream | PDF::DAO::ByteString;
    has StreamOrByteString $.Lookup is index(3);

}
