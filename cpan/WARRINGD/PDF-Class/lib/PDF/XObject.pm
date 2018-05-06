use v6;

use PDF::COS::Stream;
use PDF::Class::Type;

#| /Type /XObject - describes an abstract XObject. See also
#| PDF::XObject::Form, PDF::XObject::Image

class PDF::XObject
    is PDF::COS::Stream
    does PDF::Class::Type {

	use PDF::COS::Tie;
        use PDF::COS::Name;
	has PDF::COS::Name $.Type is entry where 'XObject';
	has PDF::COS::Name $.Subtype is entry;

}
