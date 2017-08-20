use Test;
use RPG::Base::Adventure;


plan 6;


{
    # Default adventure
    my $adventure = RPG::Base::Adventure.new;
    isa-ok $adventure, RPG::Base::Adventure;

    is $adventure.name,  'unnamed', "default adventure got default name";
    is $adventure.intro, '',        "default adventure got empty intro";
}

{
    # Fully-specified adventure
    my $adventure = RPG::Base::Adventure.new(:name('Arachnophobia'),
                                             :intro('FEAR THE SPIDERS!'));
    isa-ok $adventure, RPG::Base::Adventure;

    is $adventure.name,  'Arachnophobia',     "adventure knows its name";
    is $adventure.intro, 'FEAR THE SPIDERS!', "adventure knows its intro";
}


done-testing;
