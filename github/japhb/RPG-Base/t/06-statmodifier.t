use Test;
use RPG::Base::StatModifier;


plan 6;


{
    throws-like { RPG::Base::StatModifier.new },
        X::Attribute::Required, 'attributes required';
    throws-like { RPG::Base::StatModifier.new(:change(+1)) },
        X::Attribute::Required, 'stat attribute required';
    throws-like { RPG::Base::StatModifier.new(:stat<foo>) },
        X::Attribute::Required, 'change attribute required';

    my $mod = RPG::Base::StatModifier.new(:stat<bar>, :change(-3));
    isa-ok $mod, RPG::Base::StatModifier;
    is $mod.stat, 'bar', "modifier knows what stat it's modifying";
    is $mod.change, -3,  "modifier knows how much the stat is being changed";
}


done-testing;
