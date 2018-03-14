use v6;

use PDF::COS::Stream;
use PDF::Class::Type;

class PDF::Metadata::XML
    is PDF::COS::Stream
    does PDF::Class::Type {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    # See [PDF 1.7 TABLE 10.3 Additional entries in a metadata stream dictionary]
    my subset Name-Metadata of PDF::COS::Name where 'Metadata';
    my subset Name-XML of PDF::COS::Name where 'XML';

    has Name-Metadata $.Type is entry(:required);
    has Name-XML $.Subtype is entry(:required);
}
