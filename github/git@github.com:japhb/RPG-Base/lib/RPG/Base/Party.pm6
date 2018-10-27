use RPG::Base::Creature;
use RPG::Base::Grouping;


#| A (non-exclusive) group of Creatures working together
class RPG::Base::Party
 does RPG::Base::Grouping[RPG::Base::Creature] {

    method gist() {
        "{+$.members} member party"
        ~ (': ' ~ $.members.keys».name.join(', ') if $.members)
    }
}
