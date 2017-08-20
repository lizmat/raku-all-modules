use Test;
use RPG::Base::StatModifier;
use RPG::Base::StatsBearer;


plan 38;


class SolidCube does RPG::Base::StatsBearer {
    method base-stats()     { 'length' => 1.0, 'density' => 1.0;  }
    method computed-stats() { 'mass' => { .stat('length')³ * .stat('density') },; }
}


{
    my $water = SolidCube.new;
    does-ok $water, RPG::Base::StatsBearer;

    # XXXX: Handling of computed stats and modified stats when base stat still undefined
    # XXXX: Do we want even these to throw?  Or to automatically set-stats-to-defaults?
    ok $water.base-stat('length') === Rat, "base stat starts off undefined, with correct type";
    ok $water.stat('length')      === Rat, "stat starts off undefined, with correct type";

    throws-like { $water.base-stat('color') },
        X::RPG::Base::StatsBearer::StatUnknown,
            'unspecified stat is unknown to .base-stat';

    throws-like { $water.stat('color') },
        X::RPG::Base::StatsBearer::StatUnknown,
            'unspecified stat is unknown to .stat';

    throws-like { $water.set-base-stat('color', 'red') },
        X::RPG::Base::StatsBearer::StatUnknown,
            'unspecified stat is unknown to .set-base-stat';

    throws-like { $water.set-base-stat('mass', 57.0) },
        X::RPG::Base::StatsBearer::StatComputed,
            "can't set a computed stat";

    $water.set-stats-to-defaults;
    is-deeply $water.base-stat('length'),  1.0, "first stat defaults to base-stats value";
    is-deeply $water.base-stat('density'), 1.0, "second stat defaults to base-stats value";
    is-deeply $water.base-stat('mass'),    1.0, "computed stat on default values is correct";

    is-deeply $water.stat('length'),  1.0, "unmodified first stat remains default";
    is-deeply $water.stat('density'), 1.0, "unmodified second stat remains default";
    is-deeply $water.stat('mass'),    1.0, "unmodified computed stat is correct";

    $water.set-base-stat('length', 2.0);
    is-deeply $water.base-stat('length'), 2.0, "can update first stat's base value";
    is-deeply $water.stat('length'),      2.0, "updated base value propagates to stat value";
    is-deeply $water.base-stat('mass'),   8.0, "updated normal stat propagates to computed stat base value";
    is-deeply $water.stat('mass'),        8.0, "updated normal stat propagates to computed stat";

    my $frozen = RPG::Base::StatModifier.new(:stat('temperature'), :change(-100));
    throws-like { $water.add-modifier($frozen) },
        X::RPG::Base::StatsBearer::StatUnknown,
            "can't modify an unknown stat";

    my $muddy = RPG::Base::StatModifier.new(:stat('density'), :change(+.75));
    $water.add-modifier($muddy);
    is-deeply $water.base-stat('length'),   2.0,  "unmodified base stat still the same";
    is-deeply $water.stat('length'),        2.0,  "unmodified stat still the same";
    is-deeply $water.base-stat('density'),  1.0,  "modified base stat still the same";
    is-deeply $water.stat('density'),       1.75, "modified stat updated";
    is-deeply $water.base-stat('mass'),    14.0,  "modified stat propagates to computed stat base value";
    is-deeply $water.stat('mass'),         14.0,  "modified stat propagates to computed stat";

    my $tank = RPG::Base::StatModifier.new(:stat('mass'), :change(+2));
    $water.add-modifier($tank);
    is-deeply $water.base-stat('length'),   2.0,  "unmodified base stat still the same";
    is-deeply $water.stat('length'),        2.0,  "unmodified stat still the same";
    is-deeply $water.base-stat('density'),  1.0,  "previously-modified base stat still the same";
    is-deeply $water.stat('density'),       1.75, "previously-modified stat still the same";
    is-deeply $water.base-stat('mass'),    14.0,  "modified computed base stat still the same";
    is-deeply $water.stat('mass'),         16.0,  "modified computed stat updated";

    $water.remove-modifier($muddy);
    is-deeply $water.base-stat('length'),   2.0,  "unmodified base stat still the same";
    is-deeply $water.stat('length'),        2.0,  "unmodified stat still the same";
    is-deeply $water.base-stat('density'),  1.0,  "no-longer-modified base stat still the same";
    is-deeply $water.stat('density'),       1.0,  "no-longer-modified stat updated";
    is-deeply $water.base-stat('mass'),     8.0,  "no-longer-modified stat propagates to computed stat base value";
    is-deeply $water.stat('mass'),         10.0,  "computed stat still has its own modifier";

    throws-like { $water.remove-modifier($muddy) },
        X::RPG::Base::StatsBearer::NotActive,
            "Can't remove an already-removed modifier";

    throws-like { $water.remove-modifier($frozen) },
        X::RPG::Base::StatsBearer::NotActive,
            "Can't remove a modifier that was never successfully added";
}


done-testing;
