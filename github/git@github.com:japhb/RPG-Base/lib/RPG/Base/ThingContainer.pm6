use RPG::Base::Thing;


role RPG::Base::ThingContainer {...};


# Exceptions specific to this role
class X::RPG::Base::ThingContainer::NotContained is Exception {
    has RPG::Base::Thing          $.thing;
    has RPG::Base::ThingContainer $.container;

    method message() {
        "$.thing.^name() '$.thing' is not in $.container.^name() '$.container'"
    }
}

class X::RPG::Base::ThingContainer::AlreadyContained is Exception {
    has RPG::Base::Thing          $.thing;
    has RPG::Base::ThingContainer $.container;

    method message() {
        "$.container.^name() '$.container' already contains $.thing.^name() '$.thing'"
    }
}

class X::RPG::Base::ThingContainer::AlreadyHasContainer is Exception {
    has RPG::Base::Thing $.thing;

    method message() {
        "$.container.^name() '$.thing' is already in another container"
        ~ ", $.thing.container.^name() '$.thing.container()'"
    }
}


#| A basic container for Things which enforces unique containment
#  Note: Containment need not be literal; it could indicate that the Things
#        "contained" are actually attached to or worn by the ThingContainer.
role RPG::Base::ThingContainer {
    has RPG::Base::Thing @.contents;


    # Invariant checkers
    method !throw-if-thing-in-self($thing) {
        X::RPG::Base::ThingContainer::AlreadyContained.new(:$thing, :container(self)).throw
            if $thing ∈ @!contents;
    }

    method !throw-unless-thing-in-self($thing) {
        X::RPG::Base::ThingContainer::NotContained.new(:$thing, :container(self)).throw
            unless $thing ∈ @!contents;
    }

    method !throw-if-thing-has-container($thing) {
        X::RPG::Base::ThingContainer::AlreadyHasContainer.new(:$thing).throw
            if $thing.container;
    }


    #| Add a thing (that does not have a current container) to this container
    method add-thing(RPG::Base::Thing:D $thing) {
        self!throw-if-thing-in-self($thing);
        self!throw-if-thing-has-container($thing);

        $thing.container = self;
        @!contents.push($thing);
    }

    #| Remove a thing from this container
    method remove-thing(RPG::Base::Thing:D $thing) {
        self!throw-unless-thing-in-self($thing);

        $thing.container = RPG::Base::ThingContainer;
        @!contents.splice(@!contents.first($thing, :k), 1);
    }

    #| Clone fresh copies of the contents, setting container properly for each
    method instantiate-contents() {
        @!contents = @!contents».clone;
        for @!contents {
            .container = self;
            .instantiate-contents if $_ ~~ RPG::Base::ThingContainer;
        }
    }
}
