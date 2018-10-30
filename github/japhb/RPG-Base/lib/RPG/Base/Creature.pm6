use RPG::Base::Thing;
use RPG::Base::ThingContainer;
use RPG::Base::StatsBearer;


#| A creature which has stats and may be able to carry things
class RPG::Base::Creature is RPG::Base::Thing
 does RPG::Base::ThingContainer
 does RPG::Base::StatsBearer {
    has Bool $.archetype is rw = True;

    method gist() {
        "$.name ({ self.^name }"
            ~ (" in $.container.^name() '$.container'" if $.container)
            ~ (" carrying @.contents.join(', ')" if @.contents)
            ~ ")"
    }

    method instance(*%twiddles) {
        my \clone = self.clone(|%twiddles);
        clone.instantiate-contents;
        clone.archetype = False;
        clone
    }
}
