use v6;

use PDF::DAO::Stream;
use PDF::Class::Type;

# /Type /XObject - describes an abstract XObject. See also
# PDF::XObject::Form, PDF::XObject::Image

class PDF::XObject
    is PDF::DAO::Stream
    does PDF::Class::Type {

	use PDF::DAO::Tie;
	my subset Name-XObject of PDF::DAO::Name where 'XObject';
	has Name-XObject $.Type is entry;
	has PDF::DAO::Name  $.Subtype is entry;

}
