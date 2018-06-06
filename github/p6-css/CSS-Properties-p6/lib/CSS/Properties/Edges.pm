use v6;

use CSS::Properties::Property;

#| A four-sided container property that contains top, left, bottom and right sub-properties
class CSS::Properties::Edges
    is CSS::Properties::Property {
    method box { True }

    has CSS::Properties::Property $.top;
    has CSS::Properties::Property $.left;
    has CSS::Properties::Property $.bottom;
    has CSS::Properties::Property $.right;
}
