use Test;
use RPG::Base::Container;
use RPG::Base::Location;


plan 81;

# XXXX: Need to test gist

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
    ok $location.exits<inward> === $l3, "inward exit set";
    $l3.add-exit(:direction('outward'), :$location);
    ok $l3.exits<outward> === $location, "outward exit set";

    my $l2 = RPG::Base::Location.new(:name('Venus'));
    throws-like { $location.add-exit(:direction('inward'), :location($l2)) },
                X::RPG::Base::Location::ExitAlreadyExists;

    my $ship = RPG::Base::Container.new(:name('Transport'));
    dies-ok { $location.add-exit(:direction('off'), :location($ship)) },
        "Can't set an exit to a non-Location/Code using long form";

    is $location.exits.elems, 1, "still only one exit set on original location";

    # add-exit, shorthand form
    my $l5 = RPG::Base::Location.new(:name('Asteroid Belt'));
    $location.add-exit('outward' => $l5);
    ok $location.exits<outward> === $l5, "outward exit set";

    my $l6 = RPG::Base::Location.new(:name('Jupiter'));
    throws-like { $location.add-exit('outward' => $l6) },
                X::RPG::Base::Location::ExitAlreadyExists;

    dies-ok { $location.add-exit('off' => $ship) },
        "Can't set an exit to a non-Location/Code using short form";

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

    dies-ok { $location.add-thing('Simple string') },
        "Can't add a non-Thing to a Location";

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

{
    # Pre-filled exits
    my $airlock = RPG::Base::Location.new(:name('Airlock'));
    my $engine  = RPG::Base::Location.new(:name('Engine Room'));
    my RPG::Base::Location %exits = up => $airlock, down => $engine;
    my $lab     = RPG::Base::Location.new(:name('Laboratory'), :%exits);

    isa-ok $lab, RPG::Base::Location;
    is $lab.name, 'Laboratory',
        "named location with pre-filled exits remembers its name";
    is $lab.desc, '',
        "named location with pre-filled exits got empty description";
    is $lab.contents.elems, 0,
        "named location with pre-filled exits starts with no contents";
    is $lab.exits   .elems, 2,
        "named location with pre-filled exits has correct number of them";

    ok $lab.exits<up>   === $airlock, "first exit is correct";
    ok $lab.exits<down> === $engine, "second exit is correct";

    my $habitat = RPG::Base::Location.new(:name('Habitat Ring'));
    $lab.add-exit('outward' => $habitat);
    is $lab.exits.elems, 3, "able to add exit to named location with pre-filled exits";
    ok $lab.exits<outward> === $habitat, "third exit is correct";

    my $suit = RPG::Base::Container.new(:name('Space Suit'));
    my %escape = in => $suit,;
    dies-ok { RPG::Base::Location.new(:exits(%escape)) },
        "Cannot add a non-Location/Code exit even as a prefilled exit";
}

{
    # Pre-filled contents
    my $cabinet = RPG::Base::Container.new(:name('Filing Cabinet'));
    my $desk    = RPG::Base::Container.new(:name('Desk'));
    my $lab     = RPG::Base::Location.new(:name('Laboratory'),
                                          :contents($cabinet, $desk));

    isa-ok $lab, RPG::Base::Location;
    is $lab.name, 'Laboratory',
        "named location with pre-filled contents remembers its name";
    is $lab.desc, '',
        "named location with pre-filled contents got empty description";
    is $lab.exits   .elems, 0,
        "named location with pre-filled contents starts with no exits";
    is $lab.contents.elems, 2,
        "named location with pre-filled contents has correct number of them";

    ok $cabinet ∈ $lab.contents, "first item in contents";
    ok $desk    ∈ $lab.contents, "second item in contents";

    my $office = RPG::Base::Location.new(:name('New Office'));
    $lab.add-exit('north' => $office);
    is $lab.exits.elems, 1,
        "able to add exit to named location with pre-filled contents";
    ok $lab.exits<north> === $office, "exit is correct";

    $lab.move-thing('north' => $desk);
    is $lab.contents.elems, 1,
        "able to move thing out of location with pre-filled contents";
    is $office.contents.elems, 1,
        "moved thing arrives at new location";
    ok $office.contents[0] === $desk, "moved thing is correct";
    ok $lab.contents[0] === $cabinet, "other thing remains in old location";

    my $centrifuge = RPG::Base::Container.new(:name('Centrifuge'));
    $lab.add-thing($centrifuge);
    is $lab.contents.elems, 2,
        "able to add thing to location with pre-filled contents";
    ok $cabinet ∈ $lab.contents, "original item in contents";
    ok $centrifuge ∈ $lab.contents, "new item in contents";
}

{
    # Programmatic and blocked exits
    my $near = RPG::Base::Location.new(:name('Near Bank'));
    my $far  = RPG::Base::Location.new(:name('Far Bank'));
    my $down = RPG::Base::Location.new(:name('Down River'));
    my $raft = RPG::Base::Container.new(:name('Small Raft'));

    enum RiverLevel < Low High Raging >;
    my   RiverLevel $level = Low;

    my sub exit-rule(:$location, :$direction, *%) {
        given $level {
            when Low    { $location === $near ?? $far !! $near  }
            when High   { $down }
            when Raging {
                X::RPG::Base::Location::Blocked
                    .new(:$direction, :$location,
                         :block('the raging flood waters')).throw
            }
        }
    }

    # add-exit, programmatic longhand form
    $near.add-exit(:direction('across'), :code(&exit-rule));
    $near.add-thing($raft);
    ok $near.exits<across> === &exit-rule, "set a programmatic exit longhand";

    throws-like { $near.move-thing('upstream' => $raft) },
        X::RPG::Base::Location::ExitDoesNotExist;

    $near.move-thing('across' => $raft);
    ok $raft.container === $far, "able to use programmatic exit";

    # add-exit, programmatic shorthand form
    $far.add-exit('back' => &exit-rule);
    ok $far.exits<back> === &exit-rule, "able to use same code exit at two locations";
    $far.move-thing('back' => $raft);
    ok $raft.container === $near, "able to use location-dependent exit rule";

    $level = High;
    $near.move-thing('across' => $raft);
    ok $raft.container === $down, "programmatic exit can depend on external state";

    $down.add-exit('path' => $far);
    $down.move-thing('path' => $raft);
    ok $raft.container === $far, "returned to location with programmatic exit";

    $level = Raging;
    throws-like { $far.move-thing('back' => $raft) },
        X::RPG::Base::Location::Blocked, "blocked exit throws ::Blocked";
}


done-testing;
