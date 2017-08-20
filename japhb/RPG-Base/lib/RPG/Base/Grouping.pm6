role RPG::Base::Grouping[::T] { ... };

# XXXX: Backreferences from Thing to Groupings?


# Exceptions specific to this role
class X::RPG::Base::Grouping::NotMember is Exception {
    has                     $.member;
    has RPG::Base::Grouping $.grouping;

    method message() {
        "$.member.^name() '$.member' is not a member of $.grouping.^name() '$.grouping'"
    }
}

class X::RPG::Base::Grouping::AlreadyMember is Exception {
    has                     $.member;
    has RPG::Base::Grouping $.grouping;

    method message() {
        "$.member.^name() '$.member' is already a member of $.grouping.^name() '$.grouping'"
    }
}


#| A non-exclusive grouping of type-similar items with sugary Set-like semantics
role RPG::Base::Grouping[::T] {
    # XXXX: Make private, with method members() producing a read-only view?
    # XXXX: (The above would make .members more expensive, but safer.)
    has SetHash $.members handles 'Set';


    method BUILD(SetHash(Any) :$!members) { }


    # Coercers
    method list() { $!members.keys.sort.cache }


    # Invariant checkers
    method !throw-unless-member($member) {
        X::RPG::Base::Grouping::NotMember.new(:$member, :grouping(self)).throw
            unless $!members{$member};
    }

    method !throw-if-already-member($member) {
        X::RPG::Base::Grouping::AlreadyMember.new(:$member, :grouping(self)).throw
            if $!members{$member};
    }


    #| Add a member to this Grouping, checking it has not been double-added
    method add-member(T $member) {
        self!throw-if-already-member($member);

        $!members{$member} = True;
    }

    #| Remove an existing member of this Grouping
    method remove-member(T $member) {
        self!throw-unless-member($member);

        $!members{$member}:delete;
    }
}
