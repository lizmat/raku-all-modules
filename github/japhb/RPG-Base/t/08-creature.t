use Test;
use RPG::Base::Container;
use RPG::Base::Creature;


plan 50;


sub check-basics($creature) {
    isa-ok  $creature, RPG::Base::Creature;
    isa-ok  $creature, RPG::Base::Thing;
    does-ok $creature, RPG::Base::ThingContainer;
    does-ok $creature, RPG::Base::StatsBearer;
    does-ok $creature, RPG::Base::Named;

    ok $creature.gist.contains($creature.name),  "creature mentions its name in .gist";
    ok $creature.gist.contains($creature.^name), "creature mentions its type in .gist";
}

{
    # Anonymous creature
    my $creature = RPG::Base::Creature.new;
    check-basics($creature);
    is $creature.name, 'unnamed', "anon creature got default name";
    ok $creature.archetype, "anon creature defaults to being an archetype";
}

{
    # Named creature
    my $creature = RPG::Base::Creature.new(:name('Zuul'));
    check-basics($creature);
    is $creature.name, 'Zuul', "named creature knows its name";
    ok $creature.archetype, "named creature defaults to being an archetype";

    # Instancing
    my $instance1 = $creature.instance;
    check-basics($instance1);
    is $instance1.name, 'Zuul', "untwiddled instance defaults to same name";
    nok $instance1.archetype, "untwiddled instance is not an archetype";

    my $instance2 = $creature.instance(:name('Clone'));
    check-basics($instance2);
    is $instance2.name, 'Clone', "twiddled instance gets new name";
    nok $instance2.archetype, "twiddled instance is not an archetype";

    # Containment
    my $house = RPG::Base::Container.new(:name('House'));
    $house.add-thing($instance1);
    ok $instance1.gist.contains($house.name),  "creature mentions its container's name in .gist";
    ok $instance1.gist.contains($house.^name), "creature mentions its container's type in .gist";

    # Carrying
    my $briefcase = RPG::Base::Thing.new(:name('Briefcase'));
    $instance1.add-thing($briefcase);
    ok $instance1.gist.contains($briefcase.name), "creature mentions name of thing it carries in .gist";

    # Re-instancing
    my $instance3 = $instance1.instance(:name('Bill'));
    check-basics($instance3);
    is $instance3.name, 'Bill', "twiddled re-instance gets new name";
    nok $instance3.archetype, "twiddled re-instance is still not an archetype";
    ok $instance3.gist.contains($briefcase.name), "re-instance carries same thing as base instance";
    nok $instance3.contents[0] === $briefcase, "re-instance's carried thing is separate from original";
}

done-testing;
