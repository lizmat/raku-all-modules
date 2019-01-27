use v6;

use PDF::COS::Dict;
use PDF::Content::Font;
use PDF::Class::Type;

#| /Type /Font - Describes a font

class PDF::Font
    is PDF::COS::Dict
    does PDF::Content::Font
    does PDF::Class::Type::Subtyped {

    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry(:required, :alias<type>) where 'Font';
    has PDF::COS::Name $.Subtype is entry(:required, :alias<subtype>);

}
