use v6;

use PDF::COS::Dict;
use PDF::Content::Font;
use PDF::Class::Type;

#| /Type /Font - Describes a font

class PDF::Font
    is PDF::COS::Dict
    does PDF::Content::Font
    does PDF::Class::Type {

    use PDF::COS::Tie;
    use PDF::COS::Name;

    my subset Name-Font of PDF::COS::Name where 'Font';
    has Name-Font $.Type is entry(:required);
    has PDF::COS::Name $.Subtype is entry(:required);

}
