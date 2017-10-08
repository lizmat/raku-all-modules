use v6;

use CSS::Declarations::Property;

#| A four-sided container property that contains top, left, bottom and right sub-properties
class CSS::Declarations::Edges
    is CSS::Declarations::Property {
    method box { True }

    has CSS::Declarations::Property $.top;
    has CSS::Declarations::Property $.left;
    has CSS::Declarations::Property $.bottom;
    has CSS::Declarations::Property $.right;
}
