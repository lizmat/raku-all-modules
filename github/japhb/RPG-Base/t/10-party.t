use Test;
use RPG::Base::Thing;
use RPG::Base::Creature;
use RPG::Base::Party;


plan 8;

my $wagon    = RPG::Base::Thing.new(   :name('That Blasted Death Trap'));
my $teamster = RPG::Base::Creature.new(:name('Grouchy'));
my $horse1   = RPG::Base::Creature.new(:name('Scruffy'));
my $horse2   = RPG::Base::Creature.new(:name('Stumbly'));

{
    my $travelers = RPG::Base::Party.new;
    is $travelers.gist, "0 member party",      "Empty party gist is correct";
    dies-ok { $travelers.add-member($wagon) }, "Party only holds creatures";

    $travelers.add-member($teamster);
    is-deeply $travelers.list, ($teamster,),       "Can add first member";
    is $travelers.gist, "1 member party: Grouchy", "Party gist is correct";

    $travelers.add-member($horse1);
    $travelers.add-member($horse2);
    is-deeply $travelers.list, ($teamster, $horse1, $horse2),
        "Can add two more party members";
    is $travelers.gist, "3 member party: Grouchy, Scruffy, Stumbly",
        "Party gist is still correct";

    $travelers.remove-member($horse2);
    is-deeply $travelers.list, ($teamster, $horse1),
        "Can remove a party member";
    is $travelers.gist, "2 member party: Grouchy, Scruffy",
        "Party gist remains correct";
}


done-testing;
