use Test;
use RPG::Base::Thing;
use RPG::Base::Creature;
use RPG::Base::Grouping;


plan 14;

class Village does RPG::Base::Grouping[RPG::Base::Creature] { }

my $rock      = RPG::Base::Thing.new(   :name('Rocky'));
my $mayor     = RPG::Base::Creature.new(:name('Pride'));
my $constable = RPG::Base::Creature.new(:name('Harmony'));
my $ruffian   = RPG::Base::Creature.new(:name('Discord'));

{
    my $town = Village.new;
    is $town.members.elems, 0, "Empty grouping has no members";
    dies-ok { $town.add-member($rock) }, "Can't add a member of the wrong type";

    $town.add-member($mayor);
    is $town.members.elems, 1, "Can add a member of the right type";
    is-deeply $town.list, ($mayor,), "Town list is correct";

    $town.add-member($ruffian);
    is $town.members.elems, 2, "Can add another member of the right type";
    is-deeply $town.list, ($ruffian, $mayor), "Town list is still correct";

    my $hideout = Village.new(:members($ruffian,));
    is $hideout.members.elems, 1, "Can create a grouping with a starting member";
    is-deeply $hideout.list, ($ruffian,), "Hideout list is correct";
    is-deeply $town.list, ($ruffian, $mayor),
        "Adding member to new grouping did not remove them from original grouping";

    $town.add-member($constable);
    is $town.members.elems, 3, "Can add a third member of the right type";
    is-deeply $town.list, ($ruffian, $constable, $mayor), "Town list remains correct";

    $town.remove-member($ruffian);
    is $town.members.elems, 2, "Can remove an existing member";
    is-deeply $town.list, ($constable, $mayor), "Town list skips lost member";
    is-deeply $hideout.list, ($ruffian,), "Hideout list remains correct";
}


done-testing;
