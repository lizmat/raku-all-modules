use RPG::Base::StatModifier;


role RPG::Base::StatsBearer {...};


# Exceptions specific to this role
class X::RPG::Base::StatsBearer::StatUnknown is Exception {
    has                        $.stat;
    has RPG::Base::StatsBearer $.bearer;

    method message() {
        "Stat '$.stat' is unknown to $.bearer.^name() '$.bearer'"
    }
}

# XXXX: Currently unused
class X::RPG::Base::StatsBearer::StatUnset is Exception {
    has                        $.stat;
    has RPG::Base::StatsBearer $.bearer;

    method message() {
        "Stat '$.stat' is not set for $.bearer.^name() '$.bearer'"
    }
}

class X::RPG::Base::StatsBearer::StatComputed is Exception {
    has                        $.stat;
    has RPG::Base::StatsBearer $.bearer;

    method message() {
        "Stat '$.stat' is computed for $.bearer.^name() '$.bearer', and cannot be directly set or modified"
    }
}

class X::RPG::Base::StatsBearer::NotActive is Exception {
    has RPG::Base::StatModifier $.modifier;
    has RPG::Base::StatsBearer  $.bearer;

    method message() {
        "$.modifier.^name() '$.modifier' is not active for $.bearer.^name() '$.bearer'"
    }
}


#| A thing that has measurable (and modifiable) stats
role RPG::Base::StatsBearer {
    has %!stats;
    has %!stat-defaults;
    has @.modifiers;


    submethod BUILD() {
        self.add-known-stats(   self.base-stats    );
        self.add-computed-stats(self.computed-stats);
    }

    # Invariant checkers
    method !throw-if-stat-unknown($stat) {
        X::RPG::Base::StatsBearer::StatUnknown.new(:$stat, :bearer(self)).throw
            unless %!stats{$stat}:exists;
    }

    # XXXX: Currently unused
    method !throw-if-stat-unset($stat) {
        X::RPG::Base::StatsBearer::StatUnset.new(:$stat, :bearer(self)).throw
            unless %!stats{$stat}.defined;
    }

    method !throw-if-stat-computed($stat) {
        X::RPG::Base::StatsBearer::StatComputed.new(:$stat, :bearer(self)).throw
            if %!stats{$stat} ~~ Code;
    }

    method !throw-unless-modifier-active($modifier) {
        X::RPG::Base::StatsBearer::NotActive.new(:$modifier, :bearer(self)).throw
            unless $modifier ∈ @!modifiers;
    }


    #| Stats recognized by all instances of this class (as stat-name => default pairs); override in classes
    method base-stats() {
        ()
    }

    #| Stats computed in this class (as stat-name => code pairs); override in classes
    method computed-stats() {
        ()
    }

    #| Add additional known stats
    method add-known-stats(@pairs) {
        %!stats{.key}         = .value.WHAT for @pairs;
        %!stat-defaults{.key} = .value      for @pairs;
    }

    #| Add additional computed stats
    method add-computed-stats(@pairs) {
        %!stats{.key} = .value for @pairs;
    }

    #| Add modifier to modifier stack
    method add-modifier(RPG::Base::StatModifier:D $modifier) {
        self!throw-if-stat-unknown($modifier.stat);

        @!modifiers.push($modifier);
    }

    #| Remove a modifier from the modifier stack
    method remove-modifier(RPG::Base::StatModifier:D $modifier) {
        self!throw-unless-modifier-active($modifier);

        @!modifiers.splice(@!modifiers.first($modifier, :k), 1);
    }

    #| Apply modifiers to a given stat value; override in subclasses to e.g. redefine stacking behavior
    method apply-modifiers($stat, $value is copy) {
        $value += .change if .stat eq $stat for @!modifiers;
        $value
    }

    #| Set the base value for an already-known stat
    method set-base-stat($stat, $value) {
        self!throw-if-stat-unknown($stat);
        self!throw-if-stat-computed($stat);

        %!stats{$stat} = $value;
    }

    #| Set unset base stats to their defaults
    method set-stats-to-defaults() {
        %!stats{$_} //= %!stat-defaults{$_} for %!stat-defaults.keys;
    }

    #| Retrieve base (unmodified) value for a stat
    method base-stat($stat) {
        self!throw-if-stat-unknown($stat);

        my $value = %!stats{$stat};
        $value = $value(self) if $value ~~ Code;

        $value;
    }

    #| Calculate fully modified value for a stat
    method stat($stat) {
        self.apply-modifiers($stat, self.base-stat($stat))
    }
}
