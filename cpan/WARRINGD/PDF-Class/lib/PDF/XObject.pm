use v6;

use PDF::COS::Stream;
use PDF::Class::Type;

#| /Type /XObject - describes an abstract XObject. See also
#| PDF::XObject::Form, PDF::XObject::Image

class PDF::XObject
    is PDF::COS::Stream
    does PDF::Class::Type::Subtyped {

    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry(:alias<type>) where 'XObject';
    my subset XObjectSubtype of  PDF::COS::Name where 'Form'|'Image'|'PS';
    has XObjectSubtype $.Subtype is entry(:required, :alias<subtype>);

}
