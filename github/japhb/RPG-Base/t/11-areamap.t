use Test;
use RPG::Base::Location;
use RPG::Base::Creature;
use RPG::Base::AreaMap;


plan 25;

{
    my $top    = RPG::Base::Location.new(:name('Top of ladder'));
    my $bottom = RPG::Base::Location.new(:name('Bottom of ladder'));
    my $ladder = RPG::Base::AreaMap.new;

    isa-ok $ladder, RPG::Base::AreaMap,        "Can create an unnamed AreaMap";
    is $ladder.name, 'unnamed',                "Unnamed AreaMap gets default name";
    is $ladder.locations.elems, 0,             "Default AreaMap has no locations";
    is $ladder.gist, "unnamed (locations: 0)", "Default map gist is correct";

    $ladder.add-location($bottom);
    is $ladder.locations.elems, 1,             "Able to add a location";
    ok $ladder.locations[0] === $bottom,       "Added location is correct";
    dies-ok { $ladder.add-location($bottom) }, "Can't add the same location twice";
    is $ladder.gist, "unnamed (locations: 1)", "Single-location map gist is correct";

    $ladder.add-location($top);
    is $ladder.locations.elems, 2,             "Able to add another location";
    ok $top ∈ $ladder.locations,               "Added location appears in locations";
    is $ladder.gist, "unnamed (locations: 2)", "Dual-location map gist is correct";

    my @locations = $ladder.locations-named('Middle of ladder');
    is @locations.elems, 0, "Unable to find location that doesn't exist";

    @locations = $ladder.locations-named('Top of ladder');
    is @locations.elems, 1,    "Able to find one location that does exist";
    ok @locations[0] === $top, "Found the correct location";

    # Extending ladder!
    my $middle1 = RPG::Base::Location.new(:name('Middle of ladder'));
    my $middle2 = RPG::Base::Location.new(:name('Middle of ladder'));
    ok $middle1 !=== $middle2, "Locations with same name are different";

    $ladder.add-location($_) for $middle1, $middle2;
    is $ladder.locations.elems, 4,   "Able to add two same-named locations";
    ok $middle1 ∈ $ladder.locations, "First new location appears in locations";
    ok $middle2 ∈ $ladder.locations, "Second new location appears in locations";
    is $ladder.gist, "unnamed (locations: 4)", "Four-location map gist is correct";

    @locations = $ladder.locations-named('Middle of ladder');
    is @locations.elems, 2,   "Able to find two locations with same name";
    ok $middle1 ∈ @locations, "First location appears in results";
    ok $middle2 ∈ @locations, "Second location appears in results";

    my $farmer = RPG::Base::Creature.new;
    dies-ok { $ladder.add-location($farmer) }, "Can't add non-location to AreaMap";

    my $barn = RPG::Base::AreaMap.new(:name('The old barn'));
    is $barn.name, 'The old barn', "Map can be named";
       $barn.name = 'Red barn';
    is $barn.name, 'Red barn', "Map can be renamed";
}


done-testing;
