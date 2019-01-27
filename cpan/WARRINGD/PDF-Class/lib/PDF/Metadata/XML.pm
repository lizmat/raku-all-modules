use v6;

use PDF::COS::Stream;
use PDF::Class::Type;

class PDF::Metadata::XML
    is PDF::COS::Stream
    does PDF::Class::Type::Subtyped {

    # See [PDF 32000 Table 315 - Additional entries in a metadata stream dictionary]
    ## use ISO_32000::Metadata_stream_additional;
    ## also does ISO_32000::Metadata_stream_additional;

    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry(:required, :alias<type>) where 'Metadata';
    has PDF::COS::Name $.Subtype is entry(:required, :alias<subtype>) where 'XML';
    has PDF::Metadata::XML $.Metadata is entry; # (Optional; PDF 1.4) A metadata stream containing metadata for the component.
}
