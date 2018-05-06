use v6;

use PDF::COS::Stream;
use PDF::Class::Type;

class PDF::Metadata::XML
    is PDF::COS::Stream
    does PDF::Class::Type {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    # See [PDF 1.7 TABLE 10.3 Additional entries in a metadata stream dictionary]
    has PDF::COS::Name $.Type is entry(:required) where 'Metadata';
    has PDF::COS::Name $.Subtype is entry(:required) where 'XML';
}
