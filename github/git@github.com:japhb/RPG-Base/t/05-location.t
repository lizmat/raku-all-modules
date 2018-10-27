use Test;
use RPG::Base::Container;
use RPG::Base::Location;


plan 44;

# XXXX: Need to test starting with pre-defined exits or contents
# XXXX: Need to test setting invalid exits or contents

{
    # Anonymous location
    my $location = RPG::Base::Location.new;
    isa-ok $location, RPG::Base::Location;
    is $location.name,   'Unknown', "anon location got default name";
    is $location.desc,   '',        "anon location got empty description";
    is $location.contents.elems, 0, "anon location starts with no contents";
    is $location.exits   .elems, 0, "anon location starts with no exits";

    # Set description
    $location.desc =   'Mind-bending';
    is $location.desc, 'Mind-bending', "Able to set description for anon location";
}

{
    # Named location
    my $location = RPG::Base::Location.new(:name('Mars'));
    isa-ok $location, RPG::Base::Location;
    is $location.name,   'Mars',    "named location remembers its name";
    is $location.desc,   '',        "named location got empty description";
    is $location.contents.elems, 0, "named location starts with no contents";
    is $location.exits   .elems, 0, "named location starts with no exits";

    # Set description
    $location.desc =   'Trying to kill you';
    is $location.desc, 'Trying to kill you', "Able to set description for named location";

    # add-exit, longhand form
    my $l3 = RPG::Base::Location.new(:name('Earth'));
    $location.add-exit(:direction('inward'), :location($l3));
    is $location.exits<inward>, $l3, "inward exit set";
    $l3.add-exit(:direction('outward'), :$location);
    is $l3.exits<outward>, $location, "outward exit set";

    my $l2 = RPG::Base::Location.new(:name('Venus'));
    throws-like { $location.add-exit(:direction('inward'), :location($l2)) },
                X::RPG::Base::Location::ExitAlreadyExists;

    is $location.exits.elems, 1, "still only one exit set on original location";

    # add-exit, shorthand form
    my $l5 = RPG::Base::Location.new(:name('Asteroid Belt'));
    $location.add-exit('outward' => $l5);
    is $location.exits<outward>, $l5, "outward exit set";

    my $l6 = RPG::Base::Location.new(:name('Jupiter'));
    throws-like { $location.add-exit('outward' => $l6) },
                X::RPG::Base::Location::ExitAlreadyExists;

    is $location.exits.elems, 2, "still only two exits set on original location";

    # add-thing
    my $container = RPG::Base::Container.new(:name('knapsack'));
    $location.add-thing($container);
    ok $container ∈ $location.contents, "first thing is in location's contents";
    is $container.container, $location, "first thing knows its location";
    is $location.contents.elems, 1, "only one thing in location's contents";

    throws-like { $location.add-thing($container) },
                X::RPG::Base::ThingContainer::AlreadyContained;

    throws-like { $l2.add-thing($container) },
                X::RPG::Base::ThingContainer::AlreadyHasContainer;

    # remove-thing
    my $c2 = RPG::Base::Container.new(:name('pouch'));
    throws-like { $location.remove-thing($c2) },
                X::RPG::Base::ThingContainer::NotContained;
    throws-like { $l2.remove-thing($container) },
                X::RPG::Base::ThingContainer::NotContained;

    $location.add-thing($c2);
    ok $c2 ∈ $location.contents, "second thing is in location's contents";
    is $c2.container, $location, "second thing knows its location";
    is $location.contents.elems, 2, "two things in location's contents";

    $location.remove-thing($c2);
    nok $c2 ∈ $location.contents, "second thing gone from location's contents";
    nok $c2.container, "second thing has no thing";
    is $location.contents.elems, 1, "back to one thing in location's contents";

    # move-thing, longhand form
    throws-like { $location.move-thing(:direction('up'), :thing($container)) },
                X::RPG::Base::Location::ExitDoesNotExist;

    throws-like { $location.move-thing(:direction('inward'), :thing($c2)) },
                X::RPG::Base::ThingContainer::NotContained;

    $location.move-thing(:direction('inward'), :thing($container));
    is $container.container, $l3, "thing knows its new location";
    is $location.contents.elems, 0, "starting location now empty";
    is $l3.contents.elems, 1, "ending location has one thing";
    ok $container ∈ $l3.contents, "correct thing in ending location";

    # move-thing, shorthand form
    throws-like { $l3.move-thing('up' => $container) },
                X::RPG::Base::Location::ExitDoesNotExist;

    throws-like { $l3.move-thing('outward' => $c2) },
                X::RPG::Base::ThingContainer::NotContained;

    $l3.move-thing('outward' => $container);
    is $container.container, $location, "thing knows its new location";
    is $l3.contents.elems, 0, "starting location now empty";
    is $location.contents.elems, 1, "ending location has one thing";
    ok $container ∈ $location.contents, "correct thing in ending location";
}

done-testing;
