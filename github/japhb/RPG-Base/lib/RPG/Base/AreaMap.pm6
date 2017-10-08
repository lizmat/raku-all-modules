use RPG::Base::Named;
use RPG::Base::Location;


#| An abstract map containing Locations that know their outgoing exits and thus form a directed graph
class RPG::Base::AreaMap
 does RPG::Base::Named {
    has RPG::Base::Location @.locations;

    method gist() {
        "$.name (locations: @.locations.elems())"
    }
}
