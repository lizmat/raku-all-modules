use Test;
use RPG::Base::Thing;
use RPG::Base::ThingContainer;


plan 16;

class Container does RPG::Base::ThingContainer { }

# Note: .instantiate-contents is tested via the Creature tests (08-creature.t)

{
    my $pocket = Container.new;
    my $jar    = Container.new;
    my $fluff  = RPG::Base::Thing.new(:name('fluff'));
    my $coin   = RPG::Base::Thing.new(:name('coin'));

    does-ok $pocket, RPG::Base::ThingContainer;

    nok $pocket.contents, 'container starts out empty';
    throws-like { $pocket.remove-thing($fluff) },
	X::RPG::Base::ThingContainer::NotContained,
	    "can't remove from an empty container";

    $pocket.add-thing($coin);
    ok $coin  ∈ $pocket.contents, 'can add thing to container';
    ok $fluff ∉ $pocket.contents, 'adding one thing does not bring in another';
    is +$pocket.contents, 1, 'container contains one thing';

    throws-like { $pocket.remove-thing($fluff) },
	X::RPG::Base::ThingContainer::NotContained,
	    "can't remove a non-contained thing";

    throws-like { $pocket.add-thing($coin) },
	X::RPG::Base::ThingContainer::AlreadyContained,
	    "can't add an already-contained thing";

    ok $coin.container === $pocket, 'thing knows its container';
    $pocket.remove-thing($coin);
    nok $coin.container, 'a removed thing forgets its old container';
    nok $pocket.contents, 'after thing removed, container is empty again';

    $jar.add-thing($coin);
    ok $coin.container === $jar, 'thing can be added to second container';

    throws-like { $pocket.add-thing($coin) },
	X::RPG::Base::ThingContainer::AlreadyHasContainer,
	    "can't add thing to two different containers";

    $jar.add-thing($fluff);
    ok $fluff.container === $jar, 'can add second thing to container';
    is +$jar.contents, 2, 'container now contains two items';

    $jar.remove-thing($fluff);
    $jar.remove-thing($coin);
    nok $jar.contents, 'container with multiple items can be emptied';
}


done-testing;
