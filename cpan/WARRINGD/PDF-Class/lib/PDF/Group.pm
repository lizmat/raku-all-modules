use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

# /Type /Group - a node in the page tree
class PDF::Group
    is PDF::COS::Dict
    does PDF::Class::Type {

    # see [PDF 1.7 TABLE 10.12 Entries in an object reference dictionary]
    use PDF::COS::Tie;
    use PDF::COS::Name;
    has PDF::COS::Name $.Type is entry(:required) where 'Group';
}
