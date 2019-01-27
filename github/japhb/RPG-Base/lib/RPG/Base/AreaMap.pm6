use RPG::Base::Named;
use RPG::Base::Location;


class RPG::Base::AreaMap {...};


# Exceptions specific to this class
class X::RPG::Base::AreaMap::AlreadyKnown is Exception {
    has RPG::Base::Location $.location;
    has RPG::Base::AreaMap  $.map;

    method message() {
        "$.location.^name() '$.location.name()' is already in $.map.^name() '$.map.name'"
    }
}


#| An abstract map containing Locations that know their outgoing exits and thus form a directed graph
class RPG::Base::AreaMap
 does RPG::Base::Named {
    has RPG::Base::Location @.locations;
    has %!by-name;


    method gist() {
        "$.name (locations: @.locations.elems())"
    }


    # Invariant checkers
    method !throw-if-location-known($location) {
        X::RPG::Base::AreaMap::AlreadyKnown.new(:$location, :map(self)).throw
                if $location ∈ @!locations;
    }


    #| Add a location to this map
    method add-location(RPG::Base::Location:D $location) {
        self!throw-if-location-known($location);

        %!by-name{$location.name}.push($location);
        @!locations.push($location);
    }

    #| Find all locations with a given name in this map
    method locations-named(Str:D $name) {
        @(%!by-name{$name} // []);
    }
}
